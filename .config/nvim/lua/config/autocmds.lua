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
  pattern = { "kdl" },
  callback = function()
    vim.opt_local.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua" },
  callback = function()
    vim.keymap.set("n", "<leader>rl", "<Cmd>%lua<CR>", { buffer = true })
  end,
})

local id = vim.api.nvim_create_augroup("CursorLine", {})
vim.api.nvim_create_autocmd({ "WinEnter" }, {
  group = id,
  callback = function()
    vim.wo.cursorline = true
  end,
})
vim.api.nvim_create_autocmd({ "WinLeave" }, {
  group = id,
  callback = function()
    vim.wo.cursorline = false
  end,
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

vim.api.nvim_create_user_command("ClaudeCodeCopyCommand", function(opts)
  local claudecode = require("claudecode")
  if not claudecode.state or not claudecode.state.port then
    vim.notify("Claude Code Neovim MCP Server is not running", vim.log.levels.ERROR)
    return
  end
  local port = claudecode.state.port
  vim.fn.setreg(
    "+",
    "(cd "
      .. vim.fn.getcwd()
      .. " && CLAUDE_CODE_SSE_PORT="
      .. port
      .. " ENABLE_IDE_INTEGRATION=true FORCE_CODE_TERMINAL=true claude)"
  )
  vim.notify("Claude Code command copied to clipboard", vim.log.levels.INFO)
end, {})

local function JumpToLastGlobalEdit()
  if vim.g.last_global_edit and vim.g.last_global_edit.buf and vim.fn.bufexists(vim.g.last_global_edit.buf) == 1 then
    vim.cmd("buffer " .. vim.g.last_global_edit.buf)
    vim.fn.setpos(".", vim.g.last_global_edit.pos)
  else
    print("No global edit recorded")
  end
end

vim.api.nvim_create_user_command("JumpLastEdit", JumpToLastGlobalEdit, {})
vim.api.nvim_set_keymap("n", "g:", ":lua JumpToLastGlobalEdit()<CR>", { noremap = true, silent = true })

vim.g.last_global_edit = {}

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  callback = function()
    vim.g.last_global_edit = { buf = vim.fn.bufnr("%"), pos = vim.fn.getpos(".") }
  end,
})
