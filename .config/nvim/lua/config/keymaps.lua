-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- .local/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua

-- highlight last edited text
vim.keymap.set("n", "gp", "`[v`]")

-- copy paths to clipboard
vim.keymap.set("n", "<leader>bcf", function()
  vim.fn.setreg("+", vim.fn.expand("%:."))
end)
vim.keymap.set("n", "<leader>bcl", function()
  vim.fn.setreg("+", vim.fn.expand("%:.") .. ":" .. vim.fn.line("."))
end)
vim.keymap.set("n", "<leader>bcF", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end)
vim.keymap.set("n", "<leader>bcL", function()
  vim.fn.setreg("+", vim.fn.expand("%:p") .. ":" .. vim.fn.line("."))
end)

local command_control = vim.fn.has('mac') == 1 and "D" or "C"

-- Claude Code format copy
vim.keymap.set("n", "<" .. command_control .. "-S-c>", function()
  vim.fn.setreg("+", vim.fn.expand("%:."))
end, { noremap = true, silent = true, desc = "Copy filename in Claude Code format" })

vim.keymap.set("v", "<" .. command_control .. "-S-c>", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local filepath = vim.fn.expand("%:.")
  local line_spec = start_line == end_line and tostring(start_line) or (start_line .. "-" .. end_line)
  local result = filepath .. ":" .. line_spec
  vim.fn.setreg("+", result)
end, { noremap = true, silent = true, desc = "Copy filename with line range in Claude Code format" })

vim.keymap.del("v", ">")
vim.keymap.del("v", "<")

require("refractalize.search")

-- windows
vim.keymap.set("n", "<M-j>", "<C-W>j")
vim.keymap.set("n", "<M-k>", "<C-W>k")
vim.keymap.set("n", "<M-l>", "<C-W>l")
vim.keymap.set("n", "<M-h>", "<C-W>h")

vim.keymap.set("n", "<M-Down>", "<C-W>j")
vim.keymap.set("n", "<M-Up>", "<C-W>k")
vim.keymap.set("n", "<M-Right>", "<C-W>l")
vim.keymap.set("n", "<M-Left>", "<C-W>h")

vim.keymap.set("n", "<M-;>", "<C-W>p")
vim.keymap.set("n", "<M-r>", "<C-W>r")
vim.keymap.set("n", "<M-x>", "<C-W>x")
vim.keymap.set("n", "<M-R>", "<C-W>R")
vim.keymap.set("n", "<M-s>", "<Cmd>split<CR>")
vim.keymap.set("n", "<M-v>", "<Cmd>vsplit<CR>")
vim.keymap.set("n", "<M-o>", "<C-W>o")
vim.keymap.set("n", "<M-=>", "<C-W>=")
vim.keymap.set("t", "<M-T>", "<C-\\><C-N><C-W>Ti")
vim.keymap.set("n", "<M-w>", "<C-W>c")
vim.keymap.set("n", "<M-J> <Cmd>resize", "-2<CR>")
vim.keymap.set("n", "<M-K> <Cmd>resize", "+2<CR>")
vim.keymap.set("n", "<M-L> <Cmd>vertical resize", "+2<CR>")
vim.keymap.set("n", "<M-H> <Cmd>vertical resize", "-2<CR>")
vim.keymap.set("n", "<leader>bn", "<Cmd>enew<CR>")

-- tabs
vim.keymap.set("n", "<M-1>", "1gt")
vim.keymap.set("n", "<M-2>", "2gt")
vim.keymap.set("n", "<M-3>", "3gt")
vim.keymap.set("n", "<M-4>", "4gt")
vim.keymap.set("n", "<M-5>", "5gt")
vim.keymap.set("n", "<M-6>", "6gt")
vim.keymap.set("n", "<M-7>", "7gt")
vim.keymap.set("n", "<M-8>", "8gt")
vim.keymap.set("n", "<M-9>", "9gt")
vim.keymap.set("n", "<M-0>", "<Cmd>tablast<CR>")
vim.keymap.set("n", "<M-W>", "<Cmd>tabclose<CR>")
vim.keymap.set("n", "<M-O>", "<Cmd>tabonly<CR>")
vim.keymap.set("n", "<M-S-]>", "<Cmd>tabnext<CR>")
vim.keymap.set("n", "<M-S-[>", "<Cmd>tabprev<CR>")
vim.keymap.set("n", "<M-S-;>", "g<Tab>")

-- emacs bindings in command mode
-- from :help emacs-keys
vim.keymap.set("c", "<C-A>", "<Home>")
vim.keymap.set("c", "<C-B>", "<Left>")
vim.keymap.set("c", "<C-D>", "<Del>")
vim.keymap.set("c", "<C-E>", "<End>")
vim.keymap.set("c", "<C-F>", "<Right>")
vim.o.cedit = "<C-x>"
vim.keymap.set("c", "<C-N>", "<Down>")
vim.keymap.set("c", "<C-P>", "<Up>")
vim.keymap.set("c", "<M-b>", "<S-Left>")
vim.keymap.set("c", "<M-f>", "<S-Right>")
vim.keymap.set("c", "<M-BS>", "<C-W>")

-- ghostty copy/paste
if vim.fn.has('mac') == 1 then
  -- keybind = performable:super+c=copy_to_clipboard
  vim.keymap.set("v", "<D-c>", '"+y', { noremap = true, silent = true, desc = "Copy visual text to clipboard" })
else
  -- keybind = performable:ctrl+c=copy_to_clipboard
  vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, silent = true, desc = "Copy visual text to clipboard" })
  -- Allow blockwise visual mode as a replacement for the default <C-v> mapping
  vim.keymap.set("n", "<C-S-v>", '<C-v>', { noremap = true, silent = true, desc = "Blockwise visual mode" })
end

Snacks.toggle
  .option("diff", {
    name = "Diff",
    set = function(state)
      if state then
        vim.cmd.diffthis()
      else
        vim.cmd.diffoff()
      end
    end,
  })
  :map("<leader>ddd")

Snacks.toggle
  .new({
    name = "Diff Whitespace",
    set = function(state)
      if state then
        vim.opt.diffopt:append("iwhite")
      else
        vim.opt.diffopt:remove("iwhite")
      end
    end,
    get = function()
      return vim.list_contains(vim.opt.diffopt:get(), "iwhite")
    end,
  })
  :map("<leader>ddw")

vim.keymap.set("n", "<leader>dda", function()
  local options = {
    "myers",
    "minimal",
    "patience",
    "histogram",
  }

  local active_algorithms = vim.tbl_map(
    function(item)
      return string.match(item, "^algorithm:(%a+)$")
    end,
    vim.tbl_filter(function(setting)
      return string.find(setting, "^algorithm:") ~= nil
    end, vim.opt.diffopt:get())
  )

  vim.ui.select(options, {
    prompt = "Diff Algorithm",
    format_item = function(item)
      if vim.tbl_contains(active_algorithms, item) or (#active_algorithms == 0 and item == "myers") then
        return "✔ " .. item
      else
        return "  " .. item
      end
    end,
  }, function(selected)
    if selected then
      for _, algorithm in ipairs(active_algorithms) do
        vim.opt.diffopt:remove("algorithm:" .. algorithm)
      end

      vim.opt.diffopt:append("algorithm:" .. selected)
    end
  end)
end)

vim.keymap.set("n", "]s", function()
  local dap = require("dap")
  if dap.session() ~= nil then
    dap.up()
  else
    require("runtest").goto_next_entry(false)
  end
end)

vim.keymap.set("n", "[s", function()
  local dap = require("dap")
  if dap.session() ~= nil then
    dap.down()
  else
    require("runtest").goto_previous_entry(false)
  end
end)

vim.o.mousescroll = 'ver:1,hor:2'

local function open_buffer_in_tab(tabnumber, close, vertical)
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  
  if tabnumber ~= nil then
    local tabpages = vim.api.nvim_list_tabpages()

    if tabnumber > #tabpages then
      tabnumber = #tabpages
    end

    if tabnumber < 1 then
      tabnumber = 1
    end

    local tabhandle = tabpages[tabnumber]
    vim.api.nvim_set_current_tabpage(tabhandle)
    if vertical then
      vim.cmd.vnew()
    else
      vim.cmd.new()
    end
    vim.api.nvim_set_current_buf(buf)
  else
    vim.cmd.tabnew()
    vim.api.nvim_set_current_buf(buf)
  end

  if close then
    vim.api.nvim_win_close(win, false)
  end
end

vim.keymap.set("n", "<M-t>", function()
  local count = vim.v.count > 0 and vim.v.count or nil
  open_buffer_in_tab(count, false, true)
end)

vim.keymap.set("n", "<M-T>", function()
  local count = vim.v.count > 0 and vim.v.count or nil
  open_buffer_in_tab(count, true, true)
end)

vim.keymap.set("n", "<leader>lr", "<Cmd>LspRestart<CR>")
vim.keymap.set("n", "<leader>li", "<Cmd>LspInfo<CR>")

function lsp_client_root_dirs()
  local lsp_clients = vim.lsp.get_clients({ bufnr = 0 })
  local lsp_root_dirs = vim
    .iter(lsp_clients)
    :map(function(client)
      local dirs = { client.root_dir }
      if client.config.workspace_folders then
        vim.list_extend(dirs, vim.iter(client.config.workspace_folders):map(function(folder)
          return vim.uri_to_fname(folder.uri)
        end):totable())
      end
      return dirs
    end)
    :flatten()
    :totable()

  return lsp_root_dirs
end

function git_root_dirs()
  return vim
    .iter(vim.fn.finddir(".git", ".;", -1))
    :map(function(path)
      return vim.fn.fnamemodify(path, ":p:h:h")
    end)
    :totable()
end

local function remove_duplicates(t)
  local seen = {}
  local result = {}
  for _, v in ipairs(t) do
    if not seen[v] then
      seen[v] = true
      result[#result + 1] = v
    end
  end
  return result
end

vim.keymap.set("n", "<leader>cd", function()
  local dirs = {}
  vim.list_extend(dirs, lsp_client_root_dirs())
  vim.list_extend(dirs, git_root_dirs())
  dirs = remove_duplicates(dirs)

  vim.ui.select(dirs, {
    prompt = "Change directory",
  }, function(selected)
    if selected then
      vim.cmd.tcd(selected)
    end
  end)
end)

vim.keymap.set("n", "<leader>cR", function()
  local input_options = {
    prompt = "New File Name",
    default = vim.fn.expand("%:."),
    completion = "file",
  }
  vim.ui.input(input_options, function(filename)
    if filename then
      vim.cmd.Move({ filename })
      vim.notify("Renamed file to " .. filename)
    end
  end)
end)

local last_char = nil

-- Forward mapping - waits for character
vim.keymap.set('n', '<C-N>s', function()
  last_char = vim.fn.getcharstr()
  vim.cmd('normal ]' .. last_char)
end)

-- Backward mapping - reuses last character
vim.keymap.set('n', '<C-N>[', function()
  if last_char then
    vim.cmd('normal [' .. last_char)
  end
end)

-- Backward mapping - reuses last character
vim.keymap.set('n', '<C-N>]', function()
  if last_char then
    vim.cmd('normal ]' .. last_char)
  end
end)
