local function uniq(items)
  local hash = {}
  for _,v in ipairs(items) do
      hash[v] = true
  end

  -- transform keys back into values
  local res = {}
  for k,_ in pairs(hash) do
      res[#res+1] = k
  end

  return res
end

local function diagnostic_codes(diagnostics)
  local diagnostic_codes = uniq(vim.tbl_map(function (d)
    return d.code
  end, diagnostics))

  table.sort(diagnostic_codes)

  return vim.fn.join(diagnostic_codes, ", ")
end

local function ignore_lint_line()
  local current_buffer = vim.api.nvim_get_current_buf()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local diagnostics = vim.diagnostic.get(current_buffer, {lnum = current_line - 1})

  if diagnostics then
    local line = vim.api.nvim_get_current_line()

    local new_line
    local codes = diagnostic_codes(diagnostics)

    if string.match(line, "rubocop:disable") then
      new_line = line .. ", " .. codes
    else
      new_line = line .. " # rubocop:disable " .. codes
    end

    vim.api.nvim_set_current_line(new_line)
  end
end

local function get_indent(lines)
  local non_empty_lines = vim.tbl_filter(function (l)
    return l ~= ''
  end, lines)

  local indents = vim.tbl_map(function (l)
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

local function ignore_lint_visual()
  local start_line = vim.fn.line("'<'")
  local end_line = vim.fn.line("'>")
  local current_buffer = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(current_buffer)

  local matching_diagnostics = vim.tbl_filter(function (d)
    return d.lnum >= (start_line - 1) and d.lnum <= (end_line - 1)
  end, diagnostics)

  local codes = diagnostic_codes(matching_diagnostics)

  local lines = vim.api.nvim_buf_get_lines(current_buffer, start_line - 1, end_line, 1)
  local indent = get_indent(lines)

  vim.api.nvim_buf_set_lines(current_buffer, end_line, end_line, 1, {indent .. "# rubocop:enable " .. codes})
  vim.api.nvim_buf_set_lines(current_buffer, start_line - 1, start_line - 1, 1, {indent .. "# rubocop:disable " .. codes})
end

local function ignore_lints(range)
  if range > 0 then
    ignore_lint_visual()
  else
    ignore_lint_line()
  end
end

return {
  ignore_lint_line = ignore_lint_line,
  ignore_lint_visual = ignore_lint_visual,
  ignore_lints = ignore_lints,
}
