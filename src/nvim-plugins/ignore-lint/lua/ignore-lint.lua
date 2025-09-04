local languages = require("ignore-lint.languages")

local function uniq(items)
  local hash = {}

  for _, v in ipairs(items) do
    hash[v] = true
  end

  return vim.tbl_keys(hash)
end

local function compact(items)
  return vim.tbl_filter(function(d)
    return d
  end, items)
end

local function diagnostic_codes(diagnostics)
  local diagnostic_codes = uniq(compact(vim.tbl_map(function(d)
    return tostring(d.code)
  end, diagnostics)))

  table.sort(diagnostic_codes)

  return diagnostic_codes
end

local LanguageLintIgnorer = {}

function LanguageLintIgnorer:new(rules, source)
  local o = {
    rules = rules,
    source = source,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

local function line_indent(line)
  return line:match("^%s*")
end

local function indent_lines(lines, indent)
  return vim.tbl_map(function(l)
    return indent .. l
  end, lines)
end

local function ensure_table(x)
  if type(x) == "table" then
    return x
  else
    return { x }
  end
end

function LanguageLintIgnorer:start_lines(codes, indent)
  return indent_lines(ensure_table(self.rules.start_lines(codes)), indent)
end

function LanguageLintIgnorer:end_lines(codes, indent)
  return indent_lines(ensure_table(self.rules.end_lines(codes)), indent)
end

function LanguageLintIgnorer:ignore_lines(codes, buffer, start_line_number, end_line_number)
  local lines = vim.api.nvim_buf_get_lines(0, start_line_number - 1, end_line_number, true)
  local start_indent = line_indent(lines[1])
  local end_indent = line_indent(lines[#lines])
  local start_lines = self:start_lines(codes, start_indent)
  local end_lines = self:end_lines(codes, end_indent)

  vim.api.nvim_buf_set_lines(0, start_line_number - 1, start_line_number - 1, true, start_lines)
  vim.api.nvim_buf_set_lines(0, end_line_number + #start_lines, end_line_number + #start_lines, true, end_lines)
end

function LanguageLintIgnorer:ignore_single_line(codes, buffer, line_number)
  local line = vim.api.nvim_get_current_line()

  if self.rules.current_line then
    local new_line = self.rules.current_line(codes, line)
    vim.api.nvim_buf_set_lines(buffer, line_number - 1, line_number, false, { new_line })
  elseif self.rules.previous_line then
    local previous_line = vim.api.nvim_buf_get_lines(buffer, line_number - 2, line_number - 1, true)[1]
    local new_lines = self.rules.previous_line(codes, previous_line)
    local indent = line_indent(line)
    if type(new_lines) == "table" then
      vim.api.nvim_buf_set_lines(buffer, line_number - 1, line_number - 1, true, indent_lines(new_lines, indent))
    else
      vim.api.nvim_buf_set_text(
        buffer,
        line_number - 2,
        #previous_line,
        line_number - 2,
        #previous_line,
        { indent .. new_lines }
      )
    end
  else
    local indent = line_indent(line)
    local start_lines = self:start_lines(codes, indent)
    local end_lines = self:end_lines(codes, indent)

    vim.api.nvim_buf_set_lines(buffer, line_number - 1, line_number - 1, true, start_lines)
    vim.api.nvim_buf_set_lines(buffer, line_number + #start_lines, line_number + #start_lines, true, end_lines)
  end
end

local function find_linter(diagnostics)
  local sources = vim.tbl_map(function(d)
    return d.source
  end, diagnostics)
  for _, source in ipairs(sources) do
    local linter = languages[source]
    if linter then
      return LanguageLintIgnorer:new(linter, source)
    end
  end

  vim.notify("No linter found for diagnostic sources " .. vim.fn.join(sources, ", "), vim.log.levels.ERROR)
end

local function filter_by_source(diagnostics, source)
  return vim.tbl_filter(function(d)
    return d.source == source
  end, diagnostics)
end

local function ignore_lint_line()
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local diagnostics = vim.diagnostic.get(0, { lnum = line_number - 1 })
  local linter = find_linter(diagnostics)

  if not linter then
    return
  end

  local line = vim.api.nvim_get_current_line()

  local codes = diagnostic_codes(filter_by_source(diagnostics, linter.source))

  if #codes > 0 then
    linter:ignore_single_line(codes, 0, line_number)
  end
end

local function get_indent(lines)
  local non_empty_lines = vim.tbl_filter(function(l)
    return l ~= ""
  end, lines)

  local indents = vim.tbl_map(function(l)
    return vim.fn.matchstr(l, "^\\s*")
  end, non_empty_lines)

  local min_indent

  for _, indent in ipairs(indents) do
    if min_indent == nil or string.len(indent) < string.len(min_indent) then
      min_indent = indent
    end
  end

  return min_indent
end

local function ignore_lint_visual(start_line_number, end_line_number)
  local diagnostics = vim.diagnostic.get(0)
  local linter = find_linter(diagnostics)

  if not linter then
    return
  end

  local matching_diagnostics = vim.tbl_filter(function(d)
    return d.lnum >= (start_line_number - 1) and d.lnum <= (end_line_number - 1)
  end, diagnostics)

  local codes = diagnostic_codes(filter_by_source(matching_diagnostics, linter.source))

  if #codes > 0 then
    linter:ignore_lines(codes, 0, start_line_number, end_line_number)
  end
end

local function ignore_lint()
  local mode = vim.fn.mode()

  if mode == "v" or mode == "V" or mode == "^V" then
    local start_line = vim.fn.getpos("v")[2]
    local end_line = vim.fn.getpos(".")[2]

    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end

    ignore_lint_visual(start_line, end_line)
  else
    ignore_lint_line()
  end
end

return {
  ignore_lint_line = ignore_lint_line,
  ignore_lint_visual = ignore_lint_visual,
  ignore_lint = ignore_lint,
}
