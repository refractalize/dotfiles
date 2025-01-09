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

vim.keymap.del('v', '>')
vim.keymap.del('v', '<')

require("refractalize.search")

-- windows
vim.keymap.set("n", "<M-j>", "<C-W>j")
vim.keymap.set("n", "<M-k>", "<C-W>k")
vim.keymap.set("n", "<M-l>", "<C-W>l")
vim.keymap.set("n", "<M-h>", "<C-W>h")
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
vim.keymap.set("n", "<M-Left>", "<C-W><")
vim.keymap.set("n", "<M-Right>", "<C-W>>")
vim.keymap.set("n", "<M-Up>", "<C-W>+")
vim.keymap.set("n", "<M-Down>", "<C-W>-")

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
      if vim.tbl_contains(active_algorithms, item) or (#active_algorithms == 0 and item == 'myers') then
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

vim.keymap.set('n', ']s', function()
  local dap = require('dap')
  if dap.session() ~= nil then
    dap.up()
  else
    require('runtest').goto_next_entry()
  end
end)

vim.keymap.set('n', '[s', function()
  local dap = require('dap')
  if dap.session() ~= nil then
    dap.down()
  else
    require('runtest').goto_previous_entry()
  end
end)

-- smoother scrolling
vim.keymap.set("", "<ScrollWheelUp>", "<C-Y>")
vim.keymap.set("", "<ScrollWheelDown>", "<C-E>")

local function open_buffer_in_tab(count, close)
  local buf = vim.fn.bufnr()
  local tabcount = vim.fn.tabpagenr("$")

  if close then
    if count > 0 then
      vim.api.nvim_win_close(0, false)
    else
      vim.fn.normal('<C-W>T')
    end
  end

  if count > 0 and count <= tabcount then
    vim.cmd.tabnext(count)
    vim.cmd.vnew()
  else
    vim.cmd.tabnew()
  end

  vim.api.nvim_set_current_buf(buf)
end

vim.keymap.set("n", "<M-t>", function()
  open_buffer_in_tab(vim.v.count, false)
end)

vim.keymap.set("n", "<M-T>", function()
  open_buffer_in_tab(vim.v.count, true)
end)

vim.keymap.set("n", "<leader>lr", "<Cmd>LspRestart<CR>")
vim.keymap.set("n", "<leader>li", "<Cmd>LspInfo<CR>")

vim.keymap.set('n', '<leader>uv', function()
  local environment_variable_names = {
    "CERES_TEST_LOG",
    "CERES_TEST_DB_KEEP_DATA",
    "CERES_TEST_DB_LOG",
  }

  local function is_variable_set(variable_name)
    local value = vim.fn.getenv(variable_name)
    return (value ~= "" and value ~= nil and value ~= vim.NIL)
  end

  vim.ui.select(environment_variable_names, {
    prompt = "Toggle environment variable",
    format_item = function(item)
      local badge = is_variable_set(item) and "✔" or " "
      return badge .. " " .. item
    end,
  }, function(selected)
    if selected then
      if is_variable_set(selected) then
        vim.fn.setenv(selected, nil)
      else
        vim.fn.setenv(selected, "true")
      end
    end
  end)
end)
