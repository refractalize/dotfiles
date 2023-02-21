local buffers = {}

local watch_autocmd_group = vim.api.nvim_create_augroup("Watch", {
  clear = true,
})

local LiveBuffer = {}

function LiveBuffer:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
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
  local cmd = self:expand_shell_command()

  function set_result()
    if finished then
      if exit_code ~= 0 then
        self:reload_buffer(self.result_buf)
        table.insert(std_err, "")
        vim.list_extend(std_err, vim.split(cmd .. " exited with code " .. exit_code, '\n'))
        self:append_buffer_lines(std_err)
      else
        self:reload_buffer(self.result_buf)
      end

      if self.on_updated then
        self.on_updated()
      end
    end
  end

  self.executing = true
  self.job = vim.fn.jobstart(self:redirect_command(cmd), {
    stdout_buffered = true,
    stderr_buffered = true,

    on_exit = function(job, code, event)
      exit_code = code
      finished = true
      self.executing = false
      self.exit_code = code
      self.job = nil
      set_result()
    end,

    on_stderr = function(job, lines, event)
      std_err = lines
      set_result()
    end,
  })

  if self.stdin_buf then
    local buf_lines = vim.api.nvim_buf_get_lines(self.stdin_buf, 0, -1, true)
    vim.fn.chansend(self.job, buf_lines)
    vim.fn.chanclose(self.job, 'stdin')
  end
end

function LiveBuffer:expand_shell_command()
  return vim.api.nvim_call_function('RenderCommandWithArguments', { self.cmd })
end

function LiveBuffer:redirect_command(cmd)
  return cmd .. ' > ' .. self:out_file()
end

function LiveBuffer:out_file()
  return vim.api.nvim_buf_get_name(self.result_buf)
end

function LiveBuffer:append_buffer_lines(lines)
  if lines[#lines] == "" then
    table.remove(lines)
  end
  
  local start_line = vim.api.nvim_buf_line_count(self.result_buf)
  local keep_lines = vim.fn.getfsize(self:out_file()) ~= 0

  vim.api.nvim_buf_set_lines(
    self.result_buf,
    keep_lines and -1 or 0,
    -1,
    true,
    lines
  )

  if not keep_lines then
    start_line = start_line - 1
  end

  local end_line = vim.api.nvim_buf_line_count(self.result_buf)

  for line = start_line, end_line - 1 do
    vim.api.nvim_buf_add_highlight(
      self.result_buf,
      self.highlight_namespace,
      'Error',
      line,
      0,
      -1
    )
  end
end

function LiveBuffer:reload_buffer(buf)
  vim.api.nvim_buf_clear_namespace(self.result_buf, self.highlight_namespace, 0, -1)

  local limit = 1048576 * 16
  local size = vim.fn.getfsize(self:out_file())

  if size <= limit then
    vim.api.nvim_buf_call(buf, function () vim.cmd("e!") end)
  else
    vim.api.nvim_err_writeln('Watch: command output (' .. size .. ') larger than limit (' .. limit .. ')')
  end
end

function LiveBuffer:find(buf)
  local live_buffer = buffers[buf]

  return live_buffer
end

function LiveBuffer:find_or_create(buf)
  local live_buffer = self:find(vim.api.nvim_get_current_buf())
  
  if not live_buffer then
    live_buffer = LiveBuffer:new({
      autocmds = {},
      highlight_namespace = vim.api.nvim_create_namespace('')
    })
    buffers[buf] = live_buffer
  end

  return live_buffer
end

function LiveBuffer:resolve_command(cmd, current_buf)
  local buffers = vim.api.nvim_call_function('FindCommandArgumentBuffers', { cmd })
  local new_buffer_types = vim.tbl_filter(function(b) return type(b) == 'string' end, buffers)
  local new_buffers = {}

  for _, buf_type in pairs(new_buffer_types) do
    vim.cmd('vertical new')
    local buffer = vim.api.nvim_get_current_buf()
    if buf_type ~= '' then
      vim.api.nvim_buf_set_option(buffer, 'filetype', buf_type)
    end
    table.insert(new_buffers, buffer)
  end

  self.cmd = vim.api.nvim_call_function('ResolveCommandArgumentBuffers', { cmd, current_buf, new_buffers })

  self:reattach_buffers()
end

function LiveBuffer:reattach_buffers()
  local buffers = vim.api.nvim_call_function('FindCommandArgumentBuffers', { self.cmd })
  for _, buffer in pairs(self:attached_buffers()) do
    self:detach_source_buffer(buffer)
  end

  for _, buffer in pairs(buffers) do
    self:attach_source_buffer(buffer, false)
  end

  if self.stdin_buf then
    self:attach_source_buffer(self.stdin_buf, false)
  end
end

function LiveBuffer:set_filetypes(filetypes)
  if filetypes.result_buf then
    vim.api.nvim_buf_set_option(self.result_buf, 'filetype', filetypes.result_buf)
  end
end

function LiveBuffer:start(cmd, current_buf, options)
  if options.stdin then
    self.stdin_buf = current_buf
  end
  self.on_updated = options.on_updated

  self:resolve_command(cmd, current_buf)

  self:open_buffer()

  self:startjob()

  if options.filetype then
    vim.api.nvim_buf_set_option(self.result_buf, 'filetype', options.filetype)
  end
end

function LiveBuffer:attached_buffers()
  return vim.tbl_keys(self.autocmds)
end

function LiveBuffer:stop()
  for buf, _ in pairs(self.autocmds) do
    self:detach_source_buffer(buf)
  end
end

function LiveBuffer:show_buffer()
  local orig_win = vim.api.nvim_get_current_win()
  vim.cmd('vsplit')
  local new_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(new_win, self.result_buf)
  vim.api.nvim_set_current_win(orig_win)
end

function is_buffer_hidden(buf)
  return vim.fn.bufwinid(buf) == -1
end

function LiveBuffer:create_result_buffer()
  self.result_buf = vim.api.nvim_create_buf(true, false)
  local temp_file = vim.fn.tempname()
  vim.api.nvim_buf_set_name(self.result_buf, temp_file)
  vim.api.nvim_buf_set_option(self.result_buf, 'autoread', true)
  vim.api.nvim_buf_set_option(self.result_buf, 'buftype', 'nowrite')

  vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    buffer = self.result_buf,
    group = watch_autocmd_group,

    callback = function()
      if self.result_stale then
        self:startjob()
      end
    end
  })

  vim.api.nvim_create_autocmd({ "BufDelete" }, {
    buffer = self.result_buf,
    group = watch_autocmd_group,

    callback = function()
      self:stop()
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
  if (buffer == self.stdin_buf) or vim.api.nvim_buf_get_name(buffer) == '' then
    return { "InsertLeave", "TextChanged" }
  else
    return { "BufWritePost" }
  end
end

function LiveBuffer:existing_autocmd_events(buffer)
  local autocmds = vim.api.nvim_get_autocmds({
    buffer = buffer,
    group = watch_autocmd_group
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
    group = watch_autocmd_group,

    callback = function()
      self:startjob()
    end
  })
end

function LiveBuffer:attach_source_buffer(buffer, startjob)
  startjob = startjob == nil and true or false

  if self.result_buf ~= buffer and not self:has_correct_autocmds(buffer) then
    self:add_on_change_autocmds(buffer)

    buffers[buffer] = self

    if startjob then
      self:startjob()
    end
  end
end

function LiveBuffer:edit(cmd, current_buf)
  local newCmd = cmd ~= '' and cmd or vim.fn.input('Watch command: ', self.cmd)

  if newCmd ~= '' then
    self:resolve_command(newCmd, vim.api.nvim_get_current_buf())
    self:startjob()
  end
end

function LiveBuffer:set_stdin(buf)
  self.stdin_buf = buf
  self:reattach_buffers()
  self:startjob()
end

function LiveBuffer:inspect()
  return {
    cmd = self.cmd,
    executing = self.executing,
    exit_code = self.exit_code,
    job = self.job,
    result_buf = self.result_buf,
    stdin_buf = self.stdin_buf,
    attached_buffers = self:attached_buffers()
  }
end

local defaults = {
  stdin = false
}

return {
  start = function(cmd, options)
    options = vim.tbl_deep_extend('force', defaults, options or {})
    local current_buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find_or_create(current_buf)
    live_buffer:start(cmd, current_buf, options)
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
    else
      vim.api.nvim_err_writeln('no such buffer ' .. vim.fn.shellescape(bufname))
    end
  end,
  detach = function()
    local buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find(buf)
    live_buffer:detach_source_buffer(buf)
  end,
  stop = function()
    local buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find(buf)

    if live_buffer then
      live_buffer:stop()
    end
  end,
  info = function()
    local buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find(buf)

    if live_buffer then
      print(vim.inspect(live_buffer:inspect()))
    end
  end,
  current = function()
    local buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find(buf)

    if live_buffer then
      return live_buffer:inspect()
    end
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
  end,
  edit = function(cmd)
    local current_buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find(current_buf)
    if live_buffer then
      live_buffer:edit(cmd, current_buf)
    end
  end,
  set_stdin = function()
    local buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find(buf)
    if live_buffer then
      live_buffer:set_stdin(buf)
    end
  end,
  unset_stdin = function()
    local buf = vim.api.nvim_get_current_buf()
    local live_buffer = LiveBuffer:find(buf)
    if live_buffer then
      live_buffer:set_stdin(nil)
    end
  end
}
