local ts_utils = require('ts_utils')

function toggle_import_require()
  local import_query = vim.treesitter.query.parse('javascript', [[
    [
      (
        import_statement (import_clause) @import_target source: (_) @import_source
      ) @import
      (
        lexical_declaration (
          variable_declarator
            name: (_) @name
            value: (
              call_expression
                function: (identifier) @require_fn (#eq? @require_fn "require")
                arguments: (arguments (string) @module)
            )
          )
      ) @require
    ] @node
  ]])

  ts_utils.find_and_replace_surrounding_node_text(import_query, function(match, node_text)
    if match.import then
      return match.import, 'const ' .. node_text(match.import_target) .. ' = require(' .. node_text(match.import_source) .. ')'
    else
      return match.require, 'import ' .. node_text(match.name) .. ' from ' .. node_text(match.module)
    end
  end)
end

return {
  toggle_import_require = toggle_import_require
}
