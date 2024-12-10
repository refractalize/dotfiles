local utils = require('runtest.languages.utils')

local function tbl_compact(table)
  return vim.tbl_filter(function(item)
    return item
  end, table)
end

local function string_fragment_to_regex(string_fragment, buf)
  return vim.fn.escape(vim.treesitter.get_node_text(string_fragment, buf), '"?+*\\^$.|{}[]()')
end

local function escape_sequence_to_regex(escape_sequence, buf)
  return "."
end

local function string_child_to_regex(string_child, buf)
  local type = string_child:type()
  if type == "string_fragment" then
    return string_fragment_to_regex(string_child, buf)
  elseif type == "escape_sequence" then
    return escape_sequence_to_regex(string_child, buf)
  end
end

local function description_to_regex(description, buf)
  return vim.fn.join(
    tbl_compact(vim.tbl_map(function(child)
      return string_child_to_regex(child, buf)
    end, vim.iter(description:iter_chilldren()))),
    ""
  )
end

local function line_tests()
  local buf = vim.api.nvim_get_current_buf()
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)

  if not lang then
    error('No treesitter language found for filetype: ' .. vim.bo.filetype)
  end

  local query = vim.treesitter.query.parse(
    lang,
    [[
      (call_expression
        function: ((identifier) @function_name (#match? @function_name "^(describe|test)$"))
        arguments: (arguments . (string) @description)) @node
    ]]
  )

  local matches = utils.find_surrounding_matches(query)

  local test_names = vim.tbl_map(function(match)
    return description_to_regex(match.description, buf)
  end, matches)

  return test_names
end

return {
  line_tests = line_tests,
}
