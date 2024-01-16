local function reverse_table(table)
  local result = {}

  for index, item in ipairs(table) do
    result[#table - index + 1] = item
  end

  return result
end

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
    prefer_previous_line = true,
    previous_line = function(codes, previous_line)
      if string.match(previous_line, "//%s*eslint-disable-next-line") then
        return ", " .. vim.fn.join(codes, ", ")
      else
        return { "// eslint-disable-next-line " .. vim.fn.join(codes, ", ") }
      end
    end,
    single_line_suffix = function(codes, line)
      if string.match(line, "//%s*eslint-disable-line") then
        return ", " .. vim.fn.join(codes, ", ")
      else
        return " // eslint-disable-line " .. vim.fn.join(codes, ", ")
      end
    end,
  },
}

return languages
