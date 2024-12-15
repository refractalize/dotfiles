local utils = require("runtest.languages.utils")

local function join_names(names)
  local result = ""
  local last_type = nil

  for _i, name in ipairs(names) do
    if result ~= "" then
      if last_type == "class" and name.type == "class" then
        result = result .. "+"
      else
        result = result .. "."
      end
    end

    result = result .. name.text
    last_type = name.type
  end

  return result
end

local function find_file_namespace()
  local query = vim.treesitter.query.parse(
    "c_sharp",
    [[
      (file_scoped_namespace_declaration name: (_) @name) @node
    ]]
  )

  local matches = utils.find_matches(query)

  if #matches == 0 then
    return nil
  end

  return matches[1]
end

local test_method_query = vim.treesitter.query.parse(
  "c_sharp",
  [[
      (method_declaration
        (attribute_list
          (attribute name:
            (identifier) @attr
              (#match? @attr "^Test$")))) @node
  ]]
)

local function matches_with_test_methods(matches, buf)
  return vim
    .iter(matches)
    :filter(function(match)
      return vim.iter(test_method_query:iter_matches(match._node, buf, 0, -1, { all = true })):next()
    end)
    :totable()
end

local function line_tests()
  local buf = vim.api.nvim_get_current_buf()

  local query = vim.treesitter.query.parse(
    "c_sharp",
    [[
      [
        (namespace_declaration name: (_) @name) @namespace
        (class_declaration name: (_) @name) @class
        (method_declaration name: (_) @name) @method
      ] @node
    ]]
  )

  local matches = matches_with_test_methods(utils.find_surrounding_matches(query), buf)

  local names = vim.tbl_map(function(match)
    if match.method then
      return { type = "method", text = match.name[1].text }
    elseif match.class then
      return { type = "class", text = match.name[1].text }
    elseif match.namespace then
      return { type = "namespace", text = match.name[1].text }
    end
  end, matches)

  local ns = find_file_namespace()

  if ns and #names > 0 then
    table.insert(names, 1, { type = "namespace", text = ns.name[1].text })
  end

  return join_names(names)
end

local list_concat = function(a, b)
  local result = {}
  for _, v in ipairs(a) do
    table.insert(result, v)
  end
  for _, v in ipairs(b) do
    table.insert(result, v)
  end
  return result
end

local function file_tests()
  local buf = vim.api.nvim_get_current_buf()

  local query = vim.treesitter.query.parse(
    "c_sharp",
    [[
      [
        (class_declaration name: (_) @name)
        (namespace_declaration name: (_) @name)
      ] @node
    ]]
  )

  local matches = matches_with_test_methods(utils.find_matches(query), buf)

  local match_tree = utils.to_tree(matches)

  local file_namespace = find_file_namespace()

  if file_namespace and #match_tree > 0 then
    file_namespace.children = match_tree
    match_tree = { file_namespace }
  end

  local names = {}

  local function traverse_tree(tree, path)
    for _, node in ipairs(tree) do
      local new_path = list_concat(path, { node.name[1].text })

      if #node.children > 0 then
        traverse_tree(node.children, new_path)
      else
        table.insert(names, vim.fn.join(new_path, "."))
      end
    end
  end

  traverse_tree(match_tree, {})

  return names
end

return {
  line_tests = line_tests,
  file_tests = file_tests,
}
