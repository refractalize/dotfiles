local function build_match(query, captures, buf)
  local named_captures = {}
  for capture_id, capture_nodes in pairs(captures) do
    local capture_name = query.captures[capture_id]
    if capture_name == "node" then
      named_captures._node = capture_nodes[1]
    else
      named_captures[capture_name] = vim.tbl_map(function(capture_node)
        return { node = capture_node, text = vim.treesitter.get_node_text(capture_node, buf) }
      end, capture_nodes)
    end
  end

  if named_captures._node == nil then
    error("@node capture not found in query")
  end

  return named_captures
end

local function get_node()
  local node = vim.treesitter.get_node()

  if node == nil then
    error("No Treesitter node found")
  end

  return node
end

local function find_matches(query, node, buf)
  buf = buf or vim.api.nvim_get_current_buf()
  node = node or get_node():root()

  local matches = {}

  for pattern, captures, metadata in query:iter_matches(node, buf, 0, -1, { all = true }) do
    table.insert(matches, build_match(query, captures, buf))
  end

  return matches
end

local function find_surrounding_matches(query, node, buf)
  buf = buf or vim.api.nvim_get_current_buf()
  node = node or get_node()

  local matches = find_matches(query, node:root(), buf)

  local enclosing_matches = vim.tbl_filter(function(match)
    return vim.treesitter.is_ancestor(match._node, node)
  end, matches)

  return enclosing_matches
end

local function to_tree(matches)
  local function split_descendants(parent, matches)
    local descendants = {}
    local rest = {}
    for _, match in ipairs(matches) do
      if vim.treesitter.is_ancestor(parent._node, match._node) then
        table.insert(descendants, match)
      else
        table.insert(rest, match)
      end
    end
    return descendants, rest
  end

  local function build_tree(matches)
    if #matches == 0 then
      return {}
    end

    local parent = matches[1]
    matches = table.move(matches, 2, #matches, 1, {})

    local descendants, rest = split_descendants(parent, matches)
    local nodes = { parent }

    if #descendants >= 1 then
      parent.children = build_tree(descendants)
    else
      parent.children = {}
    end

    if #rest >= 1 then
      return vim.list_extend(nodes, build_tree(rest))
    else
      return nodes
    end
  end

  return build_tree(matches)
end

return {
  find_surrounding_matches = find_surrounding_matches,
  find_matches = find_matches,
  to_tree = to_tree,
}
