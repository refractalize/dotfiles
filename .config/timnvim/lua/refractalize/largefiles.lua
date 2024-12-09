vim.api.nvim_create_autocmd({ "BufReadPre" }, {
  pattern = "*",

  callback = function()
  local max_filesize = 100 * 1024 -- 100 KB
    local filename = vim.api.nvim_buf_get_name(0)
    local ok, stats = pcall(vim.loop.fs_stat, filename)
    if ok and stats and stats.size > max_filesize then
      require("illuminate").pause_buf()
      vim.cmd("syntax off")
    end
  end,
})
