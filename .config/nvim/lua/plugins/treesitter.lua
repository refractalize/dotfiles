return {
  {
    "nvim-treesitter/nvim-treesitter",

    opts = {
      incremental_selection = {
        keymaps = {
          init_selection = ")",
          node_incremental = ")",
          node_decremental = "(",
        },
      },
      textobjects = {
        swap = {
          enable = true,
          swap_next = {
            ["<leader>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>A"] = "@parameter.inner",
          },
        },
      },
    },
  },
  {
    "michaeljsmith/vim-indent-object", -- treat indented sections of code as vim objects
  },
  {
    "Julian/vim-textobj-variable-segment",
    dependencies = "kana/vim-textobj-user",
  },
}
