return {
  setup = function()
    local dir = vim.fn.stdpath("state") .. "/kitty-remotes"
    vim.fn.system("mkdir -p " .. dir)

    if os.getenv("KITTY_WINDOW_ID") then
      local filename = dir .. "/window-" .. os.getenv("KITTY_WINDOW_ID")
      vim.fn.system("rm -f " .. filename)
      vim.fn.serverstart(filename)
    end
  end,
}
