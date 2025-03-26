-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- .local/share/nvim/lazy/LazyVim/lua/lazyvim/config/options.lua
vim.g.autoformat = false
vim.opt.clipboard = ""
vim.opt.relativenumber = false
vim.opt.timeoutlen = 1000
vim.opt.laststatus = 2
vim.opt.statuscolumn = vim.opt.statuscolumn._info.default
vim.opt.diffopt:append("vertical")
vim.g.ai_cmp = false
vim.g.root_spec = { "cwd" }
vim.g.vim_json_syntax_conceal = 0
vim.g.vim_json_conceal = 0
vim.opt.fillchars:append("foldsep:│")
vim.opt.splitkeep = "cursor"
