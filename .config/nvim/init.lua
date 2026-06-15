-- bootstrap lazy.nvim, LazyVim and your plugins
if vim.uv.fs_stat("/run/.containerenv") or vim.env.NVIM_LAZY == "true" then
  require("config.lazy")
end
