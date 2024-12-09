local ts_utils = require("refractalize.ts_utils")

local function tbl_compact(table)
  return vim.tbl_filter(function(item)
    return item
  end, table)
end

local function string_fragment_to_regex(string_fragment, buf)
  return vim.fn.escape(ts_utils.node_text(string_fragment, buf), '"?+*\\^$.|{}[]()')
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
    end, ts_utils.node_children(description))),
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
        arguments: (arguments . (string) @description)) @call
    ]]
  )

  local matches = ts_utils.find_all(query, buf)

  local enclosing_matches = vim.tbl_filter(function(match)
    return ts_utils.node_contains_cursor(match.call)
  end, matches)

  local lexically_sorted = ts_utils.sort_matches_by_lexical_order(enclosing_matches, function(item)
    return item.call
  end)

  local test_names = vim.tbl_map(function(match)
    return description_to_regex(match.description, buf)
  end, lexically_sorted)

  return test_names
end

return {
  line_tests = line_tests,
}
