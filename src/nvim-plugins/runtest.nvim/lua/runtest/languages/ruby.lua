local utils = require('runtest.languages.utils')

local function line_tests()
  local buf = vim.api.nvim_get_current_buf()

  local query = vim.treesitter.query.parse(
    "ruby",
    [[
      (call
        method: (identifier) @method_name (#eq? @method_name "test")
        arguments: (argument_list . (string . (string_content) @test_name .))) @node
    ]]
  )

  local matches = utils.find_surrounding_matches(query)

  local test_names = vim.tbl_map(function(match)
    return match.test_name[1].text
  end, matches)

  return test_names
end

return {
  line_tests = line_tests,
}
