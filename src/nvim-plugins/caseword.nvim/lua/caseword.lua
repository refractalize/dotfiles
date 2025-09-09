--- A Neovim plugin to guess the case style of the word under the cursor

local default_delimiters = {
  python = "_",
  lua = "_",
  javascript = "upper_case_next",
  javascriptreact = "upper_case_next",
  typescript = "upper_case_next",
  typescriptreact = "upper_case_next",
  ruby = "_",
}

local delimiters = vim.deepcopy(default_delimiters)

--- @return string | nil The guessed case style or nil if none matched
local function guess_case()
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
  
  local word = line:sub(start_pos, end_pos)

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

local case_delimiter = {
  snake_case = "_",
  kebab_case = "-",
  camel_case = "upper_case_next", -- Special handling for camelCase
  path_case = "/",
}

local function join_case()
  local case = guess_case()
  local lang = get_treesitter_language()
  local lang_delimiter = lang and delimiters[lang] or nil
  local word_delimiter = case and case_delimiter[case] or nil
  local delimiter = word_delimiter or lang_delimiter or nil

  if delimiter == "upper_case_next" then
    next_char_upper()
  elseif delimiter then
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { delimiter })
    vim.api.nvim_win_set_cursor(0, { row, col + #delimiter })
  end
end

local function setup(opts)
  opts = opts or {}
  if opts.delimiters then
    delimiters = vim.tbl_extend("force", default_delimiters, opts.delimiters)
  end
end

return {
  join_case = join_case,
  setup = setup,
}
