local ts_utils = require("ts_utils")

local function toggle_arrow_function_block()
  local arrow_query = vim.treesitter.query.parse(
    vim.treesitter.language.get_lang(vim.bo.filetype),
    [[
      (arrow_function body: (_) @body) @node
    ]]
  )

  local body_query = vim.treesitter.query.parse(
    vim.treesitter.language.get_lang(vim.bo.filetype),
    [[
      (arrow_function body: (statement_block . (return_statement (_) @return_expression) .) @body)
    ]]
  )

  local buf = vim.api.nvim_get_current_buf()
  ts_utils.find_and_replace_surrounding_node_text(arrow_query, function(match, node_text)
    if match.body:type() == "statement_block" then
      local body_match = ts_utils.find_first_match(match.body:parent(), body_query, buf)

      if body_match then
        return body_match.body, node_text(body_match.return_expression)
      end
    else
      return match.body, "{ return " .. node_text(match.body) .. " }"
    end
    return
  end)
end

return {
  toggle_arrow_function_block = toggle_arrow_function_block,
}
