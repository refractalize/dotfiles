local utils = require('runtest.languages.utils')

local function test_path()
  local buf = vim.api.nvim_get_current_buf()

  local query = vim.treesitter.query.parse(
    "python",
    [[
      [
        (function_definition name: (_) @function_name)
        (class_definition name: (_) @class_name)
      ] @node
    ]]
  )

  local matches = utils.find_surrounding_matches(query)

  local test_matches = vim.tbl_filter(function(match)
    if match.function_name then
      return match.function_name[1].text:match("^test_")
    elseif match.class_name then
      return match.class_name[1].text:match("^Test")
    end
  end, matches)

  local test_path = vim.tbl_map(function(match)
    if match.function_name then
      return match.function_name[1].text
    elseif match.class_name then
      return match.class_name[1].text
    end
  end, test_matches)

  return test_path
end

return {
  test_path = test_path,
}
