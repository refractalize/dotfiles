function node_under_cursor(buf)
  local position = vim.api.nvim_win_get_cursor(0)
  return vim.treesitter.get_node_at_pos(buf, position[1] - 1, position[2], {})
end

function find_enclosing(query, buf)
  local node = node_under_cursor(buf)

  return match_enclosing(node, query, buf)
end

function find_all(query, buf)
  local node = node_under_cursor(buf)
  return find_matches(node:root(), query, buf)
end

function find_and_replace_surrounding_node_text(query, replace_fn)
  local buf = vim.api.nvim_get_current_buf()
  local match = find_enclosing(query, buf)

  if match then
    local replacement_node, replacement_text = replace_fn(
      match,
      function(node)
        return node_text(node, buf)
      end
    )

    if replacement_node and replacement_text then
      replace_node_text(replacement_node, buf, replacement_text)
      return true
    end
  end
end

function node_text(node, buf)
  return vim.treesitter.query.get_node_text(node, buf)
end

function replace_node_text(node, buf, text)
  local start_row, start_col, end_row, end_col = node:range()
  vim.api.nvim_buf_set_text(buf, start_row, start_col, end_row, end_col, { text })
end

function print_node(node, buf)
  print(node:type(), node:sexpr(), vim.treesitter.query.get_node_text(node, buf))
end

function cursor_range(buf)
  local position = vim.api.nvim_win_get_cursor(0)
  return {
    position[1] - 1,
    position[2],
    position[1] - 1,
    position[2] + 1
  }
end

function node_contains_cursor(node)
  return vim.treesitter.node_contains(node, cursor_range())
end

function node_children(node)
  local children = {}

  for i = 0, node:child_count() - 1 do
    local child = node:child(i)
    table.insert(children, child)
  end

  return children
end

function match_enclosing(node, query, buf)
  local matches = find_matches(node, query, buf)

  if #matches == 1 then
    return matches[1]
  else
    local parent_node = node:parent()
    if parent_node then
      return match_enclosing(parent_node, query, buf)
    end
  end
end

function find_matches(node, query, buf)
  local matches = {}

  for _, captures, _ in query:iter_matches(node, buf) do
    local named_captures = {}
    for capture_id, capture_node in pairs(captures) do
      local capture_name = query.captures[capture_id]
      named_captures[capture_name] = capture_node
    end

    table.insert(matches, named_captures)
  end

  return matches
end

return {
  find_and_replace_surrounding_node_text = find_and_replace_surrounding_node_text,
  node_text = node_text,
  replace_node_text = replace_node_text,
  find_enclosing = find_enclosing,
  find_all = find_all,
  cursor_range = cursor_range,
  node_contains_cursor = node_contains_cursor,
  print_node = print_node,
  node_children = node_children
}
