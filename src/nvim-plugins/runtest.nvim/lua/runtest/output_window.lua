local window_layout = require("runtest.window_layout")
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
---@field bufnr number
---@field ext_mark? number

---@class OutputWindow
---@field buf number
---@field entries Entry[]
---@field current_entry_index number | nil
local OutputWindow = {
}
OutputWindow.__index = OutputWindow

function OutputWindow:setup(config)
  self.config = vim.tbl_deep_extend("force", self.config, config)
end

--- @param bufnr number
function OutputWindow:get_target_window_id(bufnr)
  local current_window_id = vim.api.nvim_get_current_win()

  if current_window_id == self:current_window() then
    local buffer_window = find_window_in_current_tab(bufnr)

    if buffer_window then
      return buffer_window
    else
      local last_window = vim.fn.winnr("#")
      return vim.fn.win_getid(last_window)
    end
  else
    return current_window_id
  end
end

function OutputWindow:is_output_window_focussed()
  local current_window = vim.api.nvim_get_current_win()
  local windows = vim.fn.win_findbuf(self.buf)

  return vim.list_contains(windows, current_window)
end

--- @param profile Profile
--- @param line string
--- @return [string, string, string, string] | nil
function OutputWindow:match_filename(profile, line)
  for i, pattern in ipairs(profile.runner_config.file_patterns or {}) do
    if type(pattern) == "function" then
      return pattern(profile, line)
    else
      local matches = vim.fn.matchlist(line, pattern)
      if matches[1] ~= nil then
        return matches
      end
    end
  end
end

--- @param entry Entry
--- @return number
function create_entry_ext_mark(entry)
  local success, extmark_id = pcall(vim.api.nvim_buf_set_extmark, entry.bufnr, sign_ns_id, entry.line_number - 1, entry.column_number - 1, {})
  if success then
    return extmark_id
  end
end

--- @param bufnr number
function OutputWindow:load_buffer_ext_marks(bufnr)
  for i, entry in ipairs(self.entries) do
    if entry.bufnr == bufnr and not entry.ext_mark then
      entry.ext_mark = create_entry_ext_mark(entry)
    end
  end
end

function OutputWindow:goto_entry(entry)
  if vim.fn.filereadable(entry.filename) > 0 then
    if vim.fn.bufloaded(entry.bufnr) == 0 then
      vim.fn.bufload(entry.bufnr)
      self:load_buffer_ext_marks(entry.bufnr)
    end

    local target_window_id = self:get_target_window_id(entry.bufnr)
    vim.api.nvim_set_current_win(target_window_id)

    if vim.api.nvim_get_current_buf() ~= entry.bufnr then
      vim.api.nvim_set_current_buf(entry.bufnr)
    end

    if entry.ext_mark == nil then
      return
    end

    local position = vim.api.nvim_buf_get_extmark_by_id(entry.bufnr, sign_ns_id, entry.ext_mark, {})
    vim.api.nvim_win_set_cursor(target_window_id, { position[1] + 1, position[2] })

    self.current_entry_index = entry.index
    self:highlight_entry(entry)

    local current_window = self:current_window()
    if current_window then
      vim.api.nvim_win_set_cursor(current_window, { entry.output_line_number, 0 })
    end
  end
end

function OutputWindow:highlight_entry(entry)
  vim.api.nvim_buf_clear_namespace(self.buf, line_ns_id, 0, -1)
  vim.api.nvim_buf_add_highlight(self.buf, line_ns_id, "QuickFixLine", entry.output_line_number - 1, 0, -1)
end

function OutputWindow:get_next_entry()
  local current_window = self:current_window()

  if current_window then
    local current_line_number = vim.api.nvim_win_get_cursor(current_window)[1]

    for i, entry in ipairs(self.entries) do
      if entry.output_line_number > current_line_number then
        return entry, i
      end
    end
  elseif self.current_entry_index then
    return self.entries[self.current_entry_index + 1], self.current_entry_index + 1
  elseif #self.entries > 0 then
    return self.entries[1], 1
  end
end

function OutputWindow:goto_next_entry()
  local entry, index = self:get_next_entry()

  if entry then
    self.current_entry_index = index
    self:goto_entry(entry)
  end
end

function OutputWindow:get_previous_entry()
  local current_window = self:current_window()

  if current_window then
    local current_line_number = vim.api.nvim_win_get_cursor(current_window)[1]

    for i = #self.entries, 1, -1 do
      local entry = self.entries[i]
      if entry.output_line_number < current_line_number then
        return entry, i
      end
    end
  elseif self.current_entry_index then
    local index = self.current_entry_index - 1
    return self.entries[index], index
  end
end

function OutputWindow:goto_previous_entry()
  local entry, index = self:get_previous_entry()

  if entry then
    self.current_entry_index = index
    self:goto_entry(entry)
  end
end

--- @param profile Profile
function OutputWindow:parse_filenames(profile)
  local lines = vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)

  self.entries = {}
  self.current_entry_index = nil

  for output_line_number, line in ipairs(lines) do
    local matches = self:match_filename(profile, line)
    if matches then
      local filename = matches[2]
      local line_number = tonumber(matches[3]) or 1
      local column_number = tonumber(matches[4]) or 1

      local index = #self.entries + 1

      local absolute_filename = vim.fn.fnamemodify(filename, ":p")
      local file_uri = vim.uri_from_fname(absolute_filename)
      local bufnr = vim.uri_to_bufnr(file_uri)

      local entry = {
        index = index,
        filename = filename,
        bufnr = bufnr,
        line_number = line_number,
        column_number = column_number,
        output_line_number = output_line_number,
        output_line = line,
      }

      if vim.fn.bufloaded(bufnr) == 1 then
        entry.ext_mark = create_entry_ext_mark(entry)
      end

      self.entries[index] = entry
    end
  end
end

function OutputWindow:set_entry_signs()
  for i, entry in ipairs(self.entries) do
    vim.api.nvim_buf_set_extmark(self.buf, sign_ns_id, entry.output_line_number - 1, 0, {
      end_col = #entry.output_line,
      sign_text = "│",
      sign_hl_group = sign_highlight,
    })
  end
end

--- @param lines string[]
--- @param profile Profile
function OutputWindow:set_lines(lines, profile)
  vim.api.nvim_buf_clear_namespace(self.buf, sign_ns_id, 0, -1)

  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })

  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
  local baleia = require("baleia").setup()
  baleia.once(self.buf)

  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })

  local current_window = self:current_window()
  if current_window and current_window == vim.api.nvim_get_current_win() then
    vim.api.nvim_win_set_cursor(current_window, { 1, 0 })
  end

  self:parse_filenames(profile)
  self:set_entry_signs()
end

local function create_output_buffer()
  local buf = vim.uri_to_bufnr("runtest://output")
  vim.api.nvim_set_option_value("buflisted", true, { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  vim.api.nvim_create_autocmd("BufReadPre", {
    buffer = buf,
    callback = function()
      -- Do nothing
    end,
  })

  return buf
end

function OutputWindow:new()
  local self = setmetatable({}, OutputWindow)

  self.buf = create_output_buffer()
  self.entries = {}

  vim.keymap.set("n", "<Enter>", function()
    local current_window = vim.api.nvim_get_current_win()
    local current_line_number = vim.api.nvim_win_get_cursor(current_window)[1]
    local entry = vim.iter(self.entries):find(function(entry)
      return entry.output_line_number == current_line_number
    end)

    if entry then
      self:goto_entry(entry)
    end
  end, { buffer = self.buf })

  vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function(event)
      self:load_buffer_ext_marks(event.buf)
    end,
  })

  return self
end

--- @param bufnr number
--- @return number | nil
function find_window_in_current_tab(bufnr)
  local current_tab = vim.api.nvim_get_current_tabpage()
  local windows = vim.fn.win_findbuf(bufnr)

  for _, window in ipairs(windows) do
    if vim.api.nvim_win_get_tabpage(window) == current_tab then
      return window
    end
  end
end

function OutputWindow:current_window()
  return find_window_in_current_tab(self.buf)
end

--- @param new_window_command string
function OutputWindow:open(new_window_command)
  local current_window = self:current_window()

  if current_window then
    vim.api.nvim_set_current_win(current_window)
  else
    vim.cmd(new_window_command)
    vim.api.nvim_set_current_buf(self.buf)
  end
end

return OutputWindow
