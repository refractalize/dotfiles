local ts_utils = require("ts_utils")

local function toggle_await()
  local call_query = vim.treesitter.query.parse(
    vim.treesitter.language.get_lang(vim.bo.filetype),
    [[
      [
        (call_expression)
        (await_expression (call_expression) @call_expression)
      ] @node
    ]]
  )

  ts_utils.find_and_replace_surrounding_node_text(call_query, function(match, node_text)
    if match.node:type() == "await_expression" then
      return match.node, node_text(match.call_expression)
    elseif match.node:parent():type() == "await_expression" then
      return match.node:parent(), node_text(match.node)
    else
      return match.node, "await " .. node_text(match.node)
    end
    return
  end)
end

return {
  toggle_await = toggle_await,
}
