local utils = require('runtest.languages.utils')

--- @generic T
--- @param table T[]
--- @return T[]
local function tbl_compact(table)
  return vim.tbl_filter(function(item)
    return item
  end, table)
end

--- @param string_fragment TSNode
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

--- @param description TSNode
local function description_to_regex(description, buf)
  local descriptions = vim.iter(description:iter_children())
    :map(function(child)
      return string_child_to_regex(child, buf)
    end)
    :filter(function(desc)
      return desc
    end)
    :totable()

  return vim.fn.join(
    descriptions,
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

  local test_names = vim.iter(matches):map(function(match)
    return description_to_regex(match.description[1].node, buf)
  end):totable()

  return test_names
end

return {
  line_tests = line_tests,
}
