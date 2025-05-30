local function reverse_table(table)
  local result = {}

  for index, item in ipairs(table) do
    result[#table - index + 1] = item
  end

  return result
end

-- each language has the following keys:
-- Valid combinations are
--  * `start_lines` and `end_lines`
-- [optional] start_lines: function(codes: string[]) => string | string[]
--   Used alongside `end_lines` to ignore the lint rules of several lines at once.
--   The function can return either a string (representing a single line) or a string[] (representing multiple lines).
-- [optional] end_lines: function(codes: string[]) => string | string[]
--  Used alongside `start_lines` re-apply the lint rules after ignoring them.
-- [optional] previous_line: function(codes: string[], previous_line: string) => string | string[]
--   Used to place the ignore rules on the line above the current line.
-- [optional] single_line_suffix: function(codes: string[], line: string) => string
--   Used to ignore the lint rules of a single line by placing a comment on the current line.

local languages = {
  ruby = {
    start_lines = function(codes)
      return "# rubocop:disable " .. vim.fn.join(codes, ", ")
    end,
    end_lines = function(codes)
      return "# rubocop:enable " .. vim.fn.join(codes, ", ")
    end,
    single_line_suffix = function(codes, line)
      if string.match(line, "#%s*rubocop:disable") then
        return ", " .. vim.fn.join(codes, ", ")
      else
        return " # rubocop:disable " .. vim.fn.join(codes, ", ")
      end
    end,
  },
  csharp = {
    start_lines = function(codes)
      return vim.tbl_map(function(code)
        return "# pragma warning disable " .. code
      end, codes)
    end,
    end_lines = function(codes)
      return vim.tbl_map(function(code)
        return "# pragma warning restore " .. code
      end, reverse_table(codes))
    end,
  },
  eslint = {
    start_lines = function(codes)
      return "// eslint-disable " .. vim.fn.join(codes, ", ")
    end,
    end_lines = function(codes)
      return "// eslint-enable " .. vim.fn.join(codes, ", ")
    end,
    previous_line = function(codes, previous_line)
      if string.match(previous_line, "//%s*eslint-disable-next-line") then
        return ", " .. vim.fn.join(codes, ", ")
      else
        return { "// eslint-disable-next-line " .. vim.fn.join(codes, ", ") }
      end
    end,
  },
  flake8 = {
    current_line = function(codes, line)
      if string.match(line, "#%s*noqa") then
        return ", " .. vim.fn.join(codes, ", ")
      else
        return "  # noqa " .. vim.fn.join(codes, ", ")
      end
    end,
  },
}

return languages
