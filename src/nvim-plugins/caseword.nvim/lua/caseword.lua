--- A Neovim plugin to guess the case style of the word under the cursor

---@class CaseWordConfigUser
---@field mapping? string
---@field mapping_is_delimiter? boolean
---@field delimiters? table<string, string>

--- @class CaseWordOptions
--- @field mapping string The key mapping to trigger the case joining (default: "-")
--- @field mapping_is_delimiter boolean Whether the mapping character is also a delimiter (default: true)
--- @field delimiters table[string, string] A table mapping filetypes to their preferred delimiters
local default_options = {
  mapping = "-",
  mapping_is_delimiter = true,
  delimiters = {
    python = "_",
    lua = "_",
    javascript = "upper_case_next",
    javascriptreact = "upper_case_next",
    typescript = "upper_case_next",
    typescriptreact = "upper_case_next",
    ruby = "_",
    c = "_",
  }
}

local options = vim.deepcopy(default_options)

--- @return string | nil
local function current_word()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  
  if col == 0 or #line == 0 then
    return nil
  end
  
  local start_pos = col
  local end_pos = col
  
  while start_pos > 1 and line:sub(start_pos, start_pos):match("[%w_%-/]") do
    start_pos = start_pos - 1
  end
  if not line:sub(start_pos, start_pos):match("[%w_%-/]") then
    start_pos = start_pos + 1
  end
  
  while end_pos <= #line and line:sub(end_pos, end_pos):match("[%w_%-/]") do
    end_pos = end_pos + 1
  end
  end_pos = end_pos - 1
  
  if start_pos > end_pos then
    return nil
  end
  
  return line:sub(start_pos, end_pos)
end

--- Guess the case style of a given word
--- @param word string The word to analyze
--- @return string | nil The guessed case style or nil if none matched
local function guess_case(word)
  local has_hyphen = word:find("-") ~= nil
  local has_underscore = word:find("_") ~= nil
  local has_slash = word:find("/") ~= nil
  local has_upper = word:find("%u") ~= nil
  local has_lower = word:find("%l") ~= nil
  
  if has_slash then
    return "path_case"
  end

  if has_hyphen and not has_underscore and not has_slash and not has_upper and has_lower then
    return "kebab_case"
  end

  if not has_hyphen and not has_slash and has_underscore and not has_upper and has_lower then
    return "snake_case"
  end

  if not has_hyphen and not has_underscore and not has_slash and has_upper and has_lower then
    return "camel_case"
  end

  if not has_hyphen and not has_underscore and not has_upper and has_lower then
    return "none"
  end
end

--- Get the tree-sitter language at the current cursor position
--- @return string | nil The language name or nil if not available
local function get_treesitter_language()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1 -- Convert to 0-based indexing
  
  local buf = vim.api.nvim_get_current_buf()
  
  -- Check if tree-sitter is available for this buffer
  if not vim.treesitter.highlighter.active[buf] then
    return nil
  end
  
  local parser = vim.treesitter.get_parser(buf)
  if not parser then
    return nil
  end
  
  -- Get the language tree at the cursor position
  local lang_tree = parser:language_for_range({ row, col, row, col })
  if not lang_tree then
    return nil
  end
  
  return lang_tree:lang()
end

--- Listen for the next character and make it uppercase
local function next_char_upper()
  local group = vim.api.nvim_create_augroup("NextCharUpper", { clear = true })
  vim.api.nvim_create_autocmd("InsertCharPre", {
    group = group,
    once = true,
    callback = function()
      vim.v.char = string.upper(vim.v.char)
      vim.api.nvim_del_augroup_by_id(group)
    end,
  })
end

local function insert_char_at_cursor(char)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { char })
    vim.api.nvim_win_set_cursor(0, { row, col + #char })
end

local function replace_char_at_cursor(char)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    if col == 0 then
      return
    end
    vim.api.nvim_buf_set_text(0, row - 1, col - 1, row - 1, col, { char })
    vim.api.nvim_win_set_cursor(0, { row, col })
end

local function join_case()
  local word = current_word()
  if not word then
    return
  end

  local case = guess_case(word)
  local lang = get_treesitter_language()
  local lang_delimiter = lang and options.delimiters[lang] or nil

  local case_delimiter = {
    snake_case = "_",
    kebab_case = "-",
    camel_case = "upper_case_next", -- Special handling for camelCase
    path_case = "/",
    none = lang_delimiter,
  }

  local mapping_delimiter = options.mapping_is_delimiter and options.mapping or nil
  local delimiter = case and case_delimiter[case] or mapping_delimiter

  if delimiter == "upper_case_next" then
    next_char_upper()
  elseif delimiter then
    local last_char = word:sub(-1)
    if options.mapping_is_delimiter and last_char == delimiter and delimiter ~= options.mapping then
      replace_char_at_cursor(options.mapping)
    else
      insert_char_at_cursor(delimiter)
    end
  end
end

--- Setup the caseword plugin
--- @param opts CaseWordConfigUser | nil User configuration options
local function setup(opts)
  options = vim.tbl_deep_extend("force", options, opts or {})
  vim.keymap.set("i", options.mapping, join_case, { noremap = true, silent = true })
end

return {
  join_case = join_case,
  setup = setup,
}
