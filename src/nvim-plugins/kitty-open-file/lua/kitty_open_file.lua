return {
  setup = function()
    local dir = vim.fn.stdpath("state") .. "/kitty-remotes"
    vim.fn.system("mkdir -p " .. dir)
    vim.fn.serverstart(dir .. "/window-" .. os.getenv("KITTY_WINDOW_ID"))
  end,
}
