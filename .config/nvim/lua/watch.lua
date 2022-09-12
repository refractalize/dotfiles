local buffers = {}

local LiveBuffer = {}

function LiveBuffer:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function LiveBuffer:notify(std_err, exit_code)
  local notice = vim.list_slice(std_err, 1, 5)

  vim.notify(#notice > 0 and notice or { '' }, vim.log.levels.ERROR, {
    title = 'Watch `' .. self.cmd .. '` exited (' .. exit_code .. ')'
  })
end

function LiveBuffer:startjob()
  if is_buffer_hidden(self.result_buf) then
    self.result_stale = true
    return
  else
    self.result_stale = false
  end

  if self.job then
    vim.fn.jobstop(self.job)
  end

  local finished = false
  local exit_code
  local std_err = {}
  local std_out = {}

  function set_result()
    if finished then
      if exit_code ~= 0 then
        set_buffer_lines(self.result_buf, std_err)

        self:notify(std_err, exit_code)
      else
        set_buffer_lines(self.result_buf, std_out)
      end
    end
  end

  local cmd = self:shell_command()
  self.executing = true
  self.job = vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,

    on_exit = function(job, code, event)
      exit_code = code
      finished = true
      self.executing = false
      self.exit_code = code
      set_result()
    end,

    on_stderr = function(job, lines, event)
      std_err = lines
      set_result()
    end,

    on_stdout = function(job, lines, event)
      std_out = lines
      set_result()
    end
  })

  if self.source_buf and self.stdin then
    local buf_lines = vim.api.nvim_buf_get_lines(self.source_buf, 0, -1, true)
    vim.fn.chansend(self.job, buf_lines)
    vim.fn.chanclose(self.job, 'stdin')
  end
end

function LiveBuffer:shell_command()
  return vim.fn.substitute(self.cmd, '\\\\\\?{}', function(m)
    if m == '\\{}' then
      return m
    else
      local buf_lines = vim.api.nvim_buf_get_lines(self.source_buf, 0, -1, true)
      return vim.fn.shellescape(vim.fn.join(buf_lines, '\n'))
    end
  end, 'g')
end

function set_buffer_lines(buf, lines)
  if lines[#lines] == "" then
    table.remove(lines)
  end

  vim.api.nvim_buf_set_lines(
    buf,
    0,
    -1,
    true,
    lines
  )
end

function LiveBuffer:find(buf)
  local live_buffer = buffers[buf]

  return live_buffer
end

function LiveBuffer:find_or_create(buf)
  local live_buffer = self:find(vim.api.nvim_get_current_buf())
  
  if not live_buffer then
    live_buffer = LiveBuffer:new({
      autocmds = {}
    })
    buffers[buf] = live_buffer
  end

  return live_buffer
end

function LiveBuffer:start(cmd, source_buf, stdin)
  self.cmd = cmd
  self.stdin = stdin
  self.source_buf = source_buf

  self:open_buffer()

  self:attach_source_buffer(source_buf)
end

function LiveBuffer:stop()
  for buf, _ in pairs(self.autocmds) do
    self:detach_source_buffer(buf)
  end
end

function LiveBuffer:show_buffer()
  vim.cmd('vsplit')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, self.result_buf)
end

function is_buffer_hidden(buf)
  return vim.fn.bufwinid(buf) == -1
end

function LiveBuffer:create_result_buffer()
  self.result_buf = vim.api.nvim_create_buf(true, true)

  vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    buffer = self.result_buf,

    callback = function()
      if self.result_stale then
        self:startjob()
      end
    end
  })
end

function LiveBuffer:open_buffer()
  if self.result_buf then
    if is_buffer_hidden(self.result_buf) then
      self:show_buffer()
    end
  else
    self:create_result_buffer()
    buffers[self.result_buf] = self

    self:show_buffer()
  end

  vim.api.nvim_buf_set_name(self.result_buf, 'Watch (' .. self.result_buf .. '): ' .. self.cmd)
end

function LiveBuffer:detach_source_buffer(buffer)
  local autocmd = self.autocmds[buffer]
  if autocmd then
    vim.api.nvim_del_autocmd(autocmd)
    self.autocmds[buffer] = nil
    buffers[buffer] = nil
  end
end

function LiveBuffer:autocmd_events(buffer)
  if (buffer == self.source_buf and self.stdin) or vim.api.nvim_buf_get_name(buffer) == '' then
    return { "InsertLeave", "TextChanged" }
  else
    return { "BufWritePost" }
  end
end

function LiveBuffer:existing_autocmd_events(buffer)
  local autocmds = vim.api.nvim_get_autocmds({
    buffer = buffer
  })

  return vim.tbl_map(function (autocmd)
    return autocmd.event
  end, autocmds)
end

function LiveBuffer:has_correct_autocmds(buffer)
  local existing = self:existing_autocmd_events(buffer)
  local desired = self:autocmd_events(buffer)

  return vim.fn.join(vim.fn.sort(existing), ',') == vim.fn.join(vim.fn.sort(desired))
end

function LiveBuffer:add_on_change_autocmds(buffer)
  self.autocmds[buffer] = vim.api.nvim_create_autocmd(self:autocmd_events(buffer), {
    buffer = buffer,

    callback = function()
      print('changed')
      self:startjob()
    end
  })
end

function LiveBuffer:attach_source_buffer(buffer)
  if self.result_buf ~= buffer and not self:has_correct_autocmds(buffer) then
    self:add_on_change_autocmds(buffer)

    buffers[buffer] = self

    self:startjob()
  end
end

return {
  start = function(cmd, stdin)
    local source_buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find_or_create(source_buf)
    live_buffer:start(cmd, source_buf, stdin)
  end,
  attach = function(bufname)
    local current_buf = vim.api.nvim_get_current_buf()
    local buf = vim.fn.bufnr(bufname)

    if buf > 0 then
      local live_buffer = LiveBuffer:find(current_buf) or LiveBuffer:find(buf)
      if buf ~= live_buffer.result_buf then
        live_buffer:attach_source_buffer(buf)
      end
      if current_buf ~= live_buffer.result_buf then
        live_buffer:attach_source_buffer(current_buf)
      end
    end
  end,
  detach = function()
    local buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find_or_create(buf)
    live_buffer:detach_source_buffer(buf)
  end,
  stop = function()
    local buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find_or_create(buf)
    live_buffer:stop()
  end,
  info = function()
    local buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find_or_create(buf)
    print(vim.inspect(live_buffer))
  end,
  status = function()
    local buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find(buf)

    if live_buffer then
      if live_buffer.executing then
        return '...'
      else
        return 'exit ' + live_buffer.exit_code
      end
    end

    return ''
  end
}
