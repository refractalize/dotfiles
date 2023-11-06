local namespace = vim.api.nvim_create_namespace("focus-buffer")

local SourceBuffer = {}

function SourceBuffer:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o:set_marks()

  return o
end

function SourceBuffer:set_marks()
  print('self.buffer: ' .. vim.inspect(self.buffer))
  print('self.start_line: ' .. vim.inspect(self.start_line))
  print('self.end_line: ' .. vim.inspect(self.end_line))
  self.start_extmark = vim.api.nvim_buf_set_extmark(self.buffer, namespace, self.start_line, 0, {
    sign_text = "↱",
    sign_hl_group = "Question",
  })
  self.end_extmark = vim.api.nvim_buf_set_extmark(self.buffer, namespace, self.end_line, 0, {
    sign_text = "↳",
    sign_hl_group = "Question",
  })
end

function SourceBuffer:clear_marks()
  vim.api.nvim_buf_del_extmark(self.buffer, namespace, self.start_extmark)
  vim.api.nvim_buf_del_extmark(self.buffer, namespace, self.end_extmark)
end

function SourceBuffer:reset_marks()
  self:clear_marks()
  self:set_marks()
end

function SourceBuffer:get_lines()
  return vim.api.nvim_buf_get_lines(self.buffer, self.start_line, self.end_line + 1, true)
end

function SourceBuffer:name()
  local source_buffer_name = vim.api.nvim_buf_get_name(self.buffer)
  return source_buffer_name .. ":" .. self.start_line + 1 .. "-" .. self.end_line + 1
end

function SourceBuffer:set_lines(lines)
  vim.api.nvim_buf_set_lines(self.buffer, self.start_line, self.end_line + 1, true, lines)
  self.end_line = self.start_line + #lines - 1
end

local FocusBuffer = {}

function FocusBuffer:new(source_buffer)
  local dest_buffer = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_option(dest_buffer, "buftype", "acwrite")
  vim.api.nvim_buf_set_option(dest_buffer, "filetype", vim.api.nvim_buf_get_option(source_buffer.buffer, "filetype"))
  vim.api.nvim_buf_set_name(dest_buffer, 'focus-buffer://' .. source_buffer:name())

  local lines = source_buffer:get_lines()
  vim.api.nvim_buf_set_lines(dest_buffer, 0, -1, true, lines)

  local o = {
    buffer = dest_buffer,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function FocusBuffer:is_modified()
  return vim.api.nvim_buf_get_option(self.buffer, "modified")
end

function FocusBuffer:set_is_modified(is_modified)
  vim.api.nvim_buf_set_option(self.buffer, "modified", is_modified)
end

function FocusBuffer:get_lines()
  return vim.api.nvim_buf_get_lines(self.buffer, 0, -1, true)
end

function FocusBuffer:delete()
  vim.api.nvim_buf_delete(self.buffer, { force = true })
end

function FocusBuffer:on_write_cmd(callback)
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = self.buffer,

    callback = callback,
  })
end

local function open_window(buf, title)
  local ui_height = vim.api.nvim_list_uis()[1].height
  local ui_width = vim.api.nvim_list_uis()[1].width
  local width = math.floor(ui_width * 0.8)
  local height = math.floor(ui_height * 0.8)

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((ui_width - width) / 2),
    row = math.floor((ui_height - height) / 4),
    anchor = "NW",
    style = "minimal",
    border = "rounded",
    title = title,
  }

  return vim.api.nvim_open_win(buf, true, opts)
end

local FocusWindow = {}

function FocusWindow:new(focus_buffer, name)
  local window = open_window(focus_buffer.buffer, name)
  local o = {
    window = window,
    focus_buffer = focus_buffer,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function FocusWindow:on_closed(callback)
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(self.window),

    callback = callback,
  })
end

local function get_visual_line_range()
  local start_line = vim.fn.line("v") - 1
  local end_line = vim.fn.line(".") - 1

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  return start_line, end_line
end

local function start_focus_buffer()
  local start_line, end_line = get_visual_line_range()

  local source_buffer = SourceBuffer:new({
    buffer = vim.api.nvim_get_current_buf(),
    start_line = start_line,
    end_line = end_line,
  })

  local focus_buffer = FocusBuffer:new(source_buffer)
  local focus_window = FocusWindow:new(focus_buffer, source_buffer:name())

  local function save_to_source_buffer()
    if not focus_buffer:is_modified() then
      return
    end

    local changed_lines = focus_buffer:get_lines()
    source_buffer:set_lines(changed_lines)
    focus_buffer:set_is_modified(false)
  end

  focus_buffer:on_write_cmd(function()
    save_to_source_buffer()
    source_buffer:reset_marks()
  end)

  focus_window:on_closed(function()
    save_to_source_buffer()
    source_buffer:clear_marks()
    focus_buffer:delete()
  end)
end

return {
  start_focus_buffer = start_focus_buffer,
}
