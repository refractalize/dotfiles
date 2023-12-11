local utils = require("refractalize.utils")

-- prompt to search inside the visual selection
vim.keymap.set("v", "/", function()
  return "<Esc>/\\%V"
end, { expr = true, noremap = true })

local function escape_query(text)
  return vim.fn.substitute(vim.fn.substitute(vim.fn.escape(text, "/"), "\n", "\\\\n", "g"), "\t", "\\\\t", "g")
end

-- search for the visual selection and jump to the next match
-- this is better than the built-in one because it handles
-- multiple lines
vim.keymap.set("v", "*", function()
  local selection = utils.get_visual_text()
  local query = escape_query(selection)
  return "<Esc>/\\V" .. query .. "<CR>n"
end, { expr = true })

-- search for the visual selection and don't jump to the next match
vim.keymap.set("v", "g*", function()
  local selection = utils.get_visual_text()
  local query = escape_query(selection)
  vim.fn.setreg("/", query)
  vim.fn.histadd("search", query)
  return "<Esc>"
end, { expr = true })

-- search for the word under the cursor but don't jump to the next match
vim.keymap.set("n", "g*", function()
  local query = "\\<" .. vim.fn.expand("<cword>") .. "\\>"
  vim.fn.setreg("/", query)
  vim.fn.histadd("search", query)
end)
