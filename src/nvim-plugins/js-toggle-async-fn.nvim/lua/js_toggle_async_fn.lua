local ts_utils = require("ts_utils")

local async_pattern = "^%s*async%s+"

function toggle_async_function(language)
  local query = vim.treesitter.query.parse(
    language or vim.treesitter.language.get_lang(vim.bo.filetype),
    [[
      [
        (function_declaration)
        (arrow_function)
        (function)
        (method_definition)
      ] @node
    ]]
  )

  ts_utils.find_and_replace_surrounding_node_text(query, function(match, node_text)
    if match.node then
      local text = node_text(match.node)

      if string.match(text, async_pattern) then
        return match.node, string.gsub(text, async_pattern, "")
      else
        return match.node, "async " .. node_text(match.node)
      end
    end
  end)
end

return {
  toggle_async_function = toggle_async_function,
}
