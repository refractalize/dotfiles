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

---@class Entry
---@field filename string
---@field line_number number
---@field column_number number
---@field output_line_number number
---@field output_line string

---@class OutputWindow
---@field buf number
---@field entries Entry[]
---@field current_entry_index number
---@field win number | nil
---@field config { file_patterns: string[] }
local OutputWindow = {
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

  if current_window_id == self:current_window() then
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

function OutputWindow:goto_entry(entry)
  local target_window_id = self:get_target_window_id()

  if vim.api.nvim_win_is_valid(target_window_id) and vim.fn.filereadable(entry.filename) > 0 then
    vim.api.nvim_set_current_win(target_window_id)

    local absolute_filename = vim.fn.fnamemodify(entry.filename, ":p")
    local file_uri = vim.uri_from_fname(absolute_filename)
    local target_buffer = vim.uri_to_bufnr(file_uri)

    if vim.api.nvim_get_current_buf() ~= target_buffer then
      vim.api.nvim_set_current_buf(target_buffer)
    end
    vim.api.nvim_win_set_cursor(target_window_id, { entry.line_number, entry.column_number })

    self.current_entry_index = entry.index
    self:highlight_entry(entry)
  end
end

function OutputWindow:highlight_entry(entry)
  vim.api.nvim_buf_clear_namespace(self.buf, line_ns_id, 0, -1)
  vim.api.nvim_buf_add_highlight(self.buf, line_ns_id, "QuickFixLine", entry.output_line_number - 1, 0, -1)
end

function OutputWindow:goto_next_entry()
  local entry_index = (self.current_entry_index or 0) + 1
  local entry = self.entries[entry_index]

  if entry then
    self:goto_entry(entry)
  end
end

function OutputWindow:goto_previous_entry()
  local entry_index = (self.current_entry_index or 0) - 1
  local entry = self.entries[entry_index]

  if entry then
    self.current_entry_index = entry_index
    self:goto_entry(entry)
  end
end

function OutputWindow:parse_filenames()
  local lines = vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)

  self.entries = {}
  self.current_entry_index = nil

  for output_line_number, line in ipairs(lines) do
    local matches = self:match_filename(line)
    if matches then
      local filename = matches[2]
      local line_number = tonumber(matches[3]) or 1
      local column_number = tonumber(matches[4]) or 0

      local index = #self.entries + 1
      self.entries[index] = {
        index = index,
        filename = filename,
        line_number = line_number,
        column_number = column_number,
        output_line_number = output_line_number,
        output_line = line
      }
    end
  end
end

function OutputWindow:set_entry_signs()
  vim.api.nvim_buf_clear_namespace(self.buf, sign_ns_id, 0, -1)

  for i, entry in ipairs(self.entries) do
    vim.api.nvim_buf_set_extmark(self.buf, sign_ns_id, entry.output_line_number - 1, 0, {
      end_col = #entry.output_line,
      sign_text = "│",
      sign_hl_group = sign_highlight,
    })
  end
end

function OutputWindow:set_lines(lines, file_patterns)
  self.config.file_patterns = file_patterns

  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })

  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
  local baleia = require("baleia").setup()
  baleia.once(self.buf)

  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })

  self:parse_filenames()
  self:set_entry_signs()
end

local function create_output_buffer()
  local buf = vim.uri_to_bufnr('runtest://output')
  vim.api.nvim_set_option_value("buflisted", true, { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  return buf
end

function OutputWindow:new()
  local self = setmetatable({}, OutputWindow)

  self.buf = create_output_buffer()
  self.entries = {}

  vim.keymap.set("n", "<Enter>", function()
    local current_window = vim.api.nvim_get_current_win()
    self.win = current_window
    local current_line_number = vim.api.nvim_win_get_cursor(current_window)[1]
    local entry = vim.iter(self.entries):find(function (entry) return entry.output_line_number == current_line_number end)

    if entry then
      self:goto_entry(entry)
    end
  end, { buffer = self.buf })

  return self
end

function OutputWindow:current_window()
  if self.win and vim.api.nvim_win_is_valid(self.win) and vim.api.nvim_win_get_buf(self.win) == self.buf then
    return self.win
  else
    self.win = nil
  end
end

--- @param new_window_command string
function OutputWindow:open(new_window_command)
  local current_window = self:current_window()

  if current_window then
    vim.api.nvim_set_current_win(current_window)
  else
    vim.cmd(new_window_command)
    self.win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_buf(self.buf)
  end
end

return OutputWindow
