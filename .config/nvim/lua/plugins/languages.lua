return {
  {
    "tpope/vim-rails",
    ft = { "ruby" },
  },
  {
    "tpope/vim-cucumber",
    ft = { "cucumber" },
  },
  {
    "plasticboy/vim-markdown",
    ft = { "markdown" },
  },
  {
    "leafgarland/typescript-vim",
    ft = { "typescript", "typescriptreact" },
  },
  {
    "maxmellon/vim-jsx-pretty",
    ft = { "javascriptreact" },
  },
  {
    "jparise/vim-graphql",
    ft = { "graphql" },
  },
  {
    "refractalize/vim-mochajs",
    ft = { "javascriptreact", "javascript" },
  },
  {
    "google/vim-jsonnet", -- jsonnet language support
    ft = { "jsonnet" },
  },
  {
    "rust-lang/rust.vim",
    ft = { "rust" },
  },
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = "cd app && npm install",
    config = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },
}
