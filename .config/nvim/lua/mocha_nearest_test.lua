local ts_utils = require('ts_utils')

function mocha_nearest_test()
  local buf = vim.api.nvim_get_current_buf()

  local regex = current_test_regex(buf)
  vim.api.nvim_command('TestFile ' .. '--grep ' .. vim.fn.shellescape(regex))
end

function string_child_to_regex(string_child, buf)
  local type = string_child:type()
  if type == 'string_fragment' then
    return string_fragment_to_regex(string_child, buf)
  elseif type == 'escape_sequence' then
    return escape_sequence_to_regex(string_child, buf)
  end
end

function string_fragment_to_regex(string_fragment, buf)
  return vim.fn.escape(ts_utils.node_text(string_fragment, buf), '"?+*\\^$.|{}[]()')
end

function description_to_regex(description, buf)
  return vim.fn.join(
    tbl_compact(
      vim.tbl_map(
        function (child)
          return string_child_to_regex(child, buf)
        end,
        ts_utils.node_children(description)
      )
    ),
    ''
  )
end

function mocha_calls_to_regex(mocha_calls, buf)
  local strings = vim.tbl_map(
    function (mocha_call)
      return description_to_regex(mocha_call.description, buf)
    end,
    mocha_calls
  )

  local end_pattern

  if is_it_mocha_call(mocha_calls, buf) then
    end_pattern = '$'
  else
    end_pattern = ''
  end

  return '^' .. vim.fn.join(strings, ' ') .. end_pattern
end

function is_it_mocha_call(mocha_calls, buf)
  local last_call = mocha_calls[#mocha_calls]

  local call_identifier = ts_utils.node_text(last_call.call, buf)

  return call_identifier == 'it'
end

function escape_sequence_to_regex(escape_sequence, buf)
  return '.'
end

function tbl_compact(table)
  return vim.tbl_filter(
    function (item)
      return item
    end,
    table
  )
end

function current_test_regex(buf)
  local mocha_query = vim.treesitter.query.parse_query('javascript', [[
    (
      call_expression
        function: [
          (
            member_expression
              object: (identifier) @it_object (#match? @it_object "^(describe|context|it)$")
              property: (property_identifier) @only_property (#eq? @only_property "only")
          )

          ((identifier) @it_function (#match? @it_function "^(describe|context|it)$"))
        ]
        arguments: (arguments . (string) @description)
    ) @call
  ]])

  local mocha_matches = ts_utils.find_all(mocha_query, buf)

  local enclosing_mocha_matches = vim.tbl_filter(
    function (mocha_match)
      return ts_utils.node_contains_cursor(mocha_match.call)
    end,
    mocha_matches
  )

  local enclosing_mocha_calls = vim.tbl_map(
    function(match)
      return {
        description = match.description,
        call = match.it_object or match.it_function
      }
    end,
    enclosing_mocha_matches
  )

  return mocha_calls_to_regex(enclosing_mocha_calls, buf)
end

return {
  mocha_nearest_test = mocha_nearest_test
}
