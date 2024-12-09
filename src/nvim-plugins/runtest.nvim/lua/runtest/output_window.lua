local sign_ns_id = vim.api.nvim_create_namespace("runtest.sign")
local line_ns_id = vim.api.nvim_create_namespace("runtest.line")
local highlight = "NeotestFileOutputFilename"
vim.api.nvim_set_hl(0, highlight, {
  undercurl = true,
})

local sign_highlight = "NeotestFileOutputFilenameSign"
vim.api.nvim_set_hl(0, sign_highlight, {
  link = "DiagnosticSignWarn",
})

---@class OutputWindow
local OutputWindow = {
  buf = nil,
  win = nil,
  config = {
    file_patterns = {},
  },
}
OutputWindow.__index = OutputWindow

function OutputWindow:setup(config)
  self.config = vim.tbl_deep_extend("force", self.config, config)
end

function OutputWindow:get_target_window_id()
  local current_window_id = vim.api.nvim_get_current_win()

  if current_window_id == self.win then
    local last_window = vim.fn.winnr("#")
    return vim.fn.win_getid(last_window)
  else
    return current_window_id
  end
end

function OutputWindow:match_filename(line)
  for i, pattern in ipairs(self.config.file_patterns or {}) do
    local matches = vim.fn.matchlist(line, pattern)
    if matches[1] ~= nil then
      return matches
    end
  end
end

function OutputWindow:goto_filename(line, output_line_number)
  local matches = self:match_filename(line)

  local target_window_id = self:get_target_window_id()

  if matches ~= nil and matches[1] ~= nil then
    local filename = matches[2]
    local line_number = tonumber(matches[3]) or 1
    local column_number = tonumber(matches[4]) or 0

    if vim.api.nvim_win_is_valid(target_window_id) and vim.fn.filereadable(filename) > 0 then
      vim.api.nvim_set_current_win(target_window_id)

      local absolute_filename = vim.fn.fnamemodify(filename, ":p")
      local file_uri = vim.uri_from_fname(absolute_filename)
      local target_buffer = vim.uri_to_bufnr(file_uri)

      if vim.api.nvim_get_current_buf() ~= target_buffer then
        vim.api.nvim_set_current_buf(target_buffer)
      end
      vim.api.nvim_win_set_cursor(target_window_id, { line_number, column_number })

      self:highlight_line(output_line_number)
    end
  end
end

function OutputWindow:highlight_line(line_number)
  vim.api.nvim_buf_clear_namespace(self.buf, line_ns_id, 0, -1)
  vim.api.nvim_buf_add_highlight(self.buf, line_ns_id, "QuickFixLine", line_number - 1, 0, -1)
end

function OutputWindow:goto_next_file()
  if self.win == nil then
    return
  end

  local current_line_number = vim.api.nvim_win_get_cursor(self.win)[1]
  local next_lines = vim.api.nvim_buf_get_lines(self.buf, current_line_number, -1, false)

  for i, line in ipairs(next_lines) do
    if self:match_filename(line) then
      local line_number = current_line_number + i
      vim.api.nvim_win_set_cursor(self.win, { line_number, 0 })
      local current_window_id = vim.api.nvim_get_current_win()
      self:goto_filename(line, line_number)
      return
    end
  end
end

function OutputWindow:goto_previous_file()
  if self.win == nil then
    return
  end

  local current_line_number = vim.api.nvim_win_get_cursor(self.win)[1]
  local previous_lines = vim.fn.reverse(vim.api.nvim_buf_get_lines(self.buf, 0, current_line_number - 1, false))

  for i, line in ipairs(previous_lines) do
    if self:match_filename(line) then
      local line_number = #previous_lines - i + 1
      vim.api.nvim_win_set_cursor(self.win, { line_number, 0 })
      local current_window_id = vim.api.nvim_get_current_win()
      self:goto_filename(line, line_number)
      return
    end
  end
end

function OutputWindow:parse_filenames()
  local lines = vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)
  for i, line in ipairs(lines) do
    if self:match_filename(line) then
      vim.api.nvim_buf_set_extmark(self.buf, sign_ns_id, i - 1, 0, {
        end_col = #line,
        sign_text = "│",
        sign_hl_group = sign_highlight,
      })
    end
  end
end

function OutputWindow:set_buffer(buffer)
  if self.buf then
    vim.api.nvim_buf_delete(self.buf, { force = true })
  end

  self.buf = buffer

  if self.win and vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_set_buf(self.win, self.buf)
  end

  self:parse_filenames()
end

function OutputWindow:set_lines(lines, file_patterns)
  self.config.file_patterns = file_patterns

  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })

  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
  local baleia = require("baleia").setup()
  baleia.once(self.buf)

  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })

  self:parse_filenames()
end

function OutputWindow:new()
  local self = setmetatable({}, OutputWindow)

  self.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nowrite", { buf = self.buf })
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })

  vim.keymap.set("n", "<Enter>", function()
    local current_line_number = vim.api.nvim_win_get_cursor(self.win)[1]
    local current_line = vim.api.nvim_get_current_line()
    local last_window = vim.fn.winnr("#")
    local last_used_window_id = vim.fn.win_getid(last_window)
    self:goto_filename(current_line, current_line_number)
  end, { buffer = self.buf })

  return self
end

function OutputWindow:open()
  if self.win and vim.api.nvim_win_is_valid(self.win) and vim.api.nvim_win_get_buf(self.win) == self.buf then
    vim.api.nvim_set_current_win(self.win)
    return
  end

  vim.cmd("vsplit")
  self.win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_buf(self.buf)
end

return OutputWindow
