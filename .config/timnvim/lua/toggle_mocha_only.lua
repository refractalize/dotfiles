local ts_utils = require('ts_utils')

function toggle_mocha_only()
  local buf = vim.api.nvim_get_current_buf()

  remove_onlys(buf)
end

function remove_onlys(buf)
  local only_query = vim.treesitter.query.parse('javascript', [[
    (
      call_expression
        function: [
          (
            member_expression
              object: (identifier) @it_object (#eq? @it_object "it")
              property: (property_identifier) @only_property (#eq? @only_property "only")
          ) @only_function

          ((identifier) @it_function (#eq? @it_function "it"))
        ] @fn
    ) @call
  ]])

  local only_matches = ts_utils.find_all(only_query, buf)

  for _, only_match in pairs(only_matches) do
    if ts_utils.node_contains_cursor(only_match.call) then
      toggle_only(only_match, buf)
    elseif only_match.only_function then
      remove_only(only_match, buf)
    end
  end
end

function remove_only(only_match, buf)
  local text = ts_utils.node_text(only_match.it_object, buf)
  ts_utils.replace_node_text(only_match.only_function, buf, text)
end

function toggle_only(match, buf)
  if match.only_function then
    remove_only(match, buf)
  else
    add_only(match, buf)
  end
end

function add_only(it_match, buf)
  local text = ts_utils.node_text(it_match.it_function, buf)
  ts_utils.replace_node_text(it_match.it_function, buf, text .. ".only")
end

return {
  toggle_mocha_only = toggle_mocha_only
}
