local ts_utils = require("runtest.languages.utils")
local kc_no = "XXXXXXX"

local default_config = {}
local global_config = {
  keyboard_templates = {
  },
}

local function parse_keyboard_template(template)
  local rows = vim.split(template, "\n")
  local keyboard = {}

  return vim
    .iter(rows)
    :map(function(row)
      local row = row:gsub("^%s*(.-)%s*$", "%1")
      if row == "" then
        return nil
      end
      local keys = vim.split(row, " ")
      return vim
        .iter(keys)
        :map(function(key)
          return key == "X"
        end)
        :totable()
    end)
    :filter(function(r)
      return r ~= nil
    end)
    :totable()
end

local function render_template(template, layout_keys, column_width, indent)
  local rows = {}
  local k = 1
  local last_row = #template
  local last_col, _col= vim.iter(template[last_row]):enumerate():rfind(function(i, col)
    return col
  end)

  for r, template_row in ipairs(template) do
    rows[r] = {}
    for c, template_col in ipairs(template_row) do
      local key
      if k <= #layout_keys then
        key = layout_keys[k] .. string.rep(" ", column_width - string.len(layout_keys[k]))
      else
        key = kc_no
      end

      if template_col then
        local comma = c == last_col and r == last_row and "" or ", "
        rows[r][c] = key .. string.rep(" ", column_width - string.len(key)) .. comma
        k = k + 1
      else
        rows[r][c] = string.rep(" ", column_width) .. "  "
      end
    end
  end

  return vim
    .iter(rows)
    :enumerate()
    :map(function(i, row)
      local row_indent = i > 1 and indent or 0
      return string.rep(" ", row_indent) .. table.concat(row, "")
    end)
    :totable()
end

local function max_column_width(layout_keys)
  return vim
    .iter(layout_keys)
    :map(function(key)
      return string.len(key)
    end)
    :fold(string.len(kc_no), function(acc, width)
      return math.max(acc, width)
    end)
end

local find_template = function(bufnr)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == "" then
    return nil
  end

  for _, template_config in pairs(global_config.keyboard_templates) do
    if vim.fn.match(filepath, vim.fn.glob2regpat(template_config.file_pattern)) ~= -1 then
      return parse_keyboard_template(template_config.template)
    end
  end

  return nil
end

local function layout_keymaps()
  local keyboard_template = find_template(0)
  if not keyboard_template then
    vim.notify("No keyboard template found for this file", vim.log.levels.ERROR)
    return
  end

  local query = vim.treesitter.query.parse(
    "c",
    [[
      (declaration
        declarator: (init_declarator
          declarator:
            (array_declarator declarator:
              (array_declarator declarator:
                (array_declarator declarator: (identifier) @array_name (#eq? @array_name "keymaps"))))
          value:
            (initializer_list
              (initializer_pair
                value:
                  (call_expression
                    function: (identifier) @function_name (#eq? @function_name "LAYOUT")
                    arguments: (_)) @node))))
    ]]
  )

  local arguments_query = vim.treesitter.query.parse(
    "c",
    [[
        (call_expression
          function: (identifier) @function_name (#eq? @function_name "LAYOUT")
          arguments: (argument_list (_) @argument)) @node
    ]]
  )

  local matches = ts_utils.find_matches(query)

  local file_arguments = vim.iter(matches)
    :map(function(match)
      return vim.iter(ts_utils.find_matches(arguments_query, match._node))
        :map(function(argument)
          return {
            text = argument.argument[1].text,
            node = argument.argument[1].node,
          }
        end)
        :totable()
    end)
    :totable()

  local column_width = max_column_width(vim.iter(file_arguments):flatten():map(function(argument)
    return argument.text
  end):totable())

  for _, layout_arguments in ipairs(vim.iter(file_arguments):rev():totable()) do
    if #layout_arguments > 0 then
      local layout_keys = vim
        .iter(layout_arguments)
        :map(function(argument)
          return argument.text
        end)
        :totable()

      if layout_keys[#layout_keys] == "" then
        table.remove(layout_keys, #layout_keys)
      end

      local start_row, start_col = layout_arguments[1].node:start()
      local indent = start_col
      local rendered_layout = render_template(keyboard_template, layout_keys, column_width, indent)
      local end_row, end_col = layout_arguments[#layout_arguments].node:end_()
      vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, rendered_layout)
    end
  end
end

local function setup(config)
  global_config = vim.tbl_deep_extend("force", default_config, config or {})
  vim.api.nvim_create_user_command("QmkFormat", layout_keymaps, { nargs = 0 })
end

return {
  layout_keymaps = layout_keymaps,
  setup = setup,
}
