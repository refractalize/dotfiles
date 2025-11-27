local ts_utils = require("runtest.languages.utils")
local kc_no = "XXXXXXX"

local default_config = {}
local global_config = {
  keyboard_templates = {},
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

local function find_template(bufnr)
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

local function render_template(template, layout_keys, column_width, indent)
  local rows = {}
  local k = 1
  local last_row = #template
  local last_col, _col = vim.iter(template[last_row]):enumerate():rfind(function(i, col)
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

local function get_keymap_layers()
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
                designator:
                  (subscript_designator
                    (identifier) @layer_name)
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

  local keymap = vim
    .iter(matches)
    :map(function(match)
      return {
        name = {
          text = match.layer_name[1].text,
          node = match.layer_name[1].node,
        },
        layout = vim
          .iter(ts_utils.find_matches(arguments_query, match._node))
          :map(function(argument)
            return {
              text = argument.argument[1].text,
              node = argument.argument[1].node,
            }
          end)
          :totable(),
      }
    end)
    :totable()

  return keymap
end

local function layout_keymaps()
  local keyboard_template = find_template(0)
  if not keyboard_template then
    vim.notify("No keyboard template found for this file", vim.log.levels.ERROR)
    return
  end

  local keymap_layers = get_keymap_layers()

  local column_width = max_column_width(vim
    .iter(keymap_layers)
    :map(function(keymap_layer)
      return keymap_layer.layout
    end)
    :flatten()
    :map(function(argument)
      return argument.text
    end)
    :totable())

  for _, keymap_layer in ipairs(vim.iter(keymap_layers):rev():totable()) do
    if #keymap_layer.layout > 0 then
      local layout_keys = vim
        .iter(keymap_layer.layout)
        :map(function(argument)
          return argument.text
        end)
        :totable()

      if layout_keys[#layout_keys] == "" then
        table.remove(layout_keys, #layout_keys)
      end

      local start_row, start_col = keymap_layer.layout[1].node:start()
      local indent = start_col
      local rendered_layout = render_template(keyboard_template, layout_keys, column_width, indent)
      local end_row, end_col = keymap_layer.layout[#keymap_layer.layout].node:end_()
      vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, rendered_layout)
    end
  end
end

local function keyboard_name_from_path(filepath)
  if filepath == "" then
    return nil
  end

  return filepath:match("keyboards/(.-)/keymaps/")
end

local function yaml_value(value)
  if value == "" then
    return "''"
  end

  if value:match("^%b{}$") then
    return value
  end

  if value:match("^[A-Z0-9_]+$") then
    return value
  end

  return string.format("'%s'", value:gsub("'", "''"))
end

local function rows_from_layout(layout)
  if #layout == 0 then
    return {}
  end

  while #layout > 0 and layout[#layout].text == "" do
    table.remove(layout)
  end

  local rows = {}
  local current_line = nil
  local current_row = nil

  for _, argument in ipairs(layout) do
    local line = argument.node:start()
    if current_line ~= line then
      current_row = {}
      table.insert(rows, current_row)
      current_line = line
    end

    table.insert(current_row, argument.text)
  end

  return rows
end

local function write_yaml(path)
  local keymap_layers = get_keymap_layers()
  if #keymap_layers == 0 then
    vim.notify("No keymap layers found", vim.log.levels.ERROR)
    return
  end

  local normalized_path = vim.fs.normalize(vim.fn.expand(path or ""))
  if normalized_path == "" then
    vim.notify("No output file provided for QMK YAML export", vim.log.levels.ERROR)
    return
  end

  local keyboard_name = keyboard_name_from_path(vim.api.nvim_buf_get_name(0)) or "unknown"

  local lines = {
    "layout:",
    string.format("  qmk_keyboard: %s", keyboard_name),
    "  layout_name: LAYOUT",
    "layers:",
  }

  for idx, keymap_layer in ipairs(keymap_layers) do
    local rows = rows_from_layout(keymap_layer.layout)
    lines[#lines + 1] = string.format("  %s:", keymap_layer.name.text)

    for _, row in ipairs(rows) do
      local row_values = vim
        .iter(row)
        :map(yaml_value)
        :join(", ")

      lines[#lines + 1] = string.format("  - [%s]", row_values)
    end

    if idx < #keymap_layers then
      lines[#lines + 1] = ""
    end
  end

  local ok, err = pcall(vim.fn.writefile, lines, normalized_path)
  if not ok then
    vim.notify("Failed to write QMK YAML: " .. err, vim.log.levels.ERROR)
    return
  end

  vim.notify("Wrote QMK YAML to " .. normalized_path, vim.log.levels.INFO)
end

local function setup(config)
  global_config = vim.tbl_deep_extend("force", default_config, config or {})
  vim.api.nvim_create_user_command("QmkFormat", layout_keymaps, { nargs = 0 })
  vim.api.nvim_create_user_command("QmkExportYaml", function(opts)
    write_yaml(opts.args)
  end, { nargs = 1, complete = "file" })
end

return {
  layout_keymaps = layout_keymaps,
  write_yaml = write_yaml,
  setup = setup,
}
