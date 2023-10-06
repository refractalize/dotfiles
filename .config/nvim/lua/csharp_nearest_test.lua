local ts_utils = require("ts_utils")

function nearest_test()
  local buf = vim.api.nvim_get_current_buf()

  local query = vim.treesitter.query.parse(
    "c_sharp",
    [[
      [
        (file_scoped_namespace_declaration name: (_) @name) @body
        (class_declaration name: (_) @name) @body
        (method_declaration name: (_) @name) @body
      ]
    ]]
  )

  local matches = ts_utils.find_all(query, buf)

  local enclosing_matches = vim.tbl_filter(function(match)
    return ts_utils.node_contains_cursor(match.body)
  end, matches)

  lexically_sorted = ts_utils.sort_matches_by_lexical_order(enclosing_matches, function(item)
    return item.name
  end)

  local names = vim.tbl_map(function(match)
    return ts_utils.node_text(match.name, buf)
  end, lexically_sorted)

  return names
end

function file_classes()
  local buf = vim.api.nvim_get_current_buf()

  local query = vim.treesitter.query.parse(
    "c_sharp",
    [[
      [
        (class_declaration name: (_) @name)
      ]
    ]]
  )

  local namesapce_query = vim.treesitter.query.parse(
    "c_sharp",
    [[
      (file_scoped_namespace_declaration name: (_) @name) @node
    ]]
  )

  local matches = ts_utils.find_all(query, buf)

  local names = vim.tbl_map(function(match)
    local namespace = ts_utils.find_enclosing(namesapce_query, buf)
    local name = ts_utils.node_text(match.name, buf)

    if namespace then
      local namespace_name = ts_utils.node_text(namespace.name, buf)
      return namespace_name .. "." .. name
    else
      return name
    end
  end, matches)

  return names
end

return {
  nearest_test = nearest_test,
  file_classes = file_classes,
}
