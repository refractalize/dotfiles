-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cs" },
  callback = function()
    vim.cmd.compiler("dotnet")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua" },
  callback = function()
    vim.keymap.set('n', '<leader>rl', '<Cmd>%lua<CR>', { buffer = true })
  end,
})

local id = vim.api.nvim_create_augroup("CursorLine", {})
vim.api.nvim_create_autocmd({"WinEnter"}, {
  group = id,
  callback = function()
    vim.wo.cursorline = true
  end
})
vim.api.nvim_create_autocmd({"WinLeave"}, {
  group = id,
  callback = function()
    vim.wo.cursorline = false
  end
})

function unload(module)
  package.loaded[module] = nil
end

vim.api.nvim_create_user_command("Gdiff", function(opts)
  local actions = require("fzf-lua.actions")
  require("fzf-lua").fzf_exec("git diff " .. opts.args .. " | diff2vimgrep", {
    previewer = "builtin",
    actions = {
      ["default"] = actions.file_edit_or_qf,
    },
    fzf_opts = {
      ["--multi"] = "",
    },
  })
end, {
  nargs = "*",
  complete = "customlist,fugitive#ReadComplete",
})
