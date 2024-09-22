local ts_utils = require("ts_utils")

function nearest_test()
  local buf = vim.api.nvim_get_current_buf()

  local query = vim.treesitter.query.parse(
    "c_sharp",
    [[
      [
        (namespace_declaration name: (_) @namespace_name) @body
        (class_declaration name: (_) @class_name) @body
        (method_declaration name: (_) @method_name) @body
      ]
    ]]
  )

  local matches = ts_utils.find_all(query, buf)

  local enclosing_matches = vim.tbl_filter(function(match)
    return ts_utils.node_contains_cursor(match.body)
  end, matches)

  lexically_sorted = ts_utils.sort_matches_by_lexical_order(enclosing_matches, function(item)
    return item.body
  end)

  local names = vim.tbl_map(function(match)
    if match.method_name then
      return { type = "method", text = ts_utils.node_text(match.method_name, buf) }
    elseif match.class_name then
      return { type = "class", text = ts_utils.node_text(match.class_name, buf) }
    elseif match.namespace_name then
      return { type = "namespace", text = ts_utils.node_text(match.namespace_name, buf) }
    end
  end, lexically_sorted)

  local ns = current_file_namespace()

  if ns then
    table.insert(names, 1, { type = "namespace", text = ns })
  end

  return join_names(names)
end

function join_names(names)
  local result = ''
  local last_type = nil

  for i, name in ipairs(names) do
    if result ~= '' then
      if last_type == 'class' and name.type == 'class' then
        result = result .. '+'
      else
        result = result .. '.'
      end
    end

    result = result .. name.text
    last_type = name.type
  end

  return result
end

function current_file_namespace()
  local buf = vim.api.nvim_get_current_buf()

  local query = vim.treesitter.query.parse(
    "c_sharp",
    [[
      [
        (file_scoped_namespace_declaration name: (_) @namespace_name) @body
      ]
    ]]
  )

  local matches = ts_utils.find_all(query, buf)
  if #matches == 0 then
    return nil
  end
  local ns = matches[1]
  local start_row, start_col, end_row, end_col = ns.body:range()

  local position = vim.api.nvim_win_get_cursor(0)

  if position[1] > end_row then
    return ts_utils.node_text(ns.namespace_name, buf)
  end
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
