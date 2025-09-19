return {
  {
    "nvim-treesitter/nvim-treesitter",

    opts = {
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
    "shushtain/nvim-treesitter-incremental-selection",
    keys = {
      {
        ")",
        desc = "Increment selection",
        function()
          require("nvim-treesitter-incremental-selection").init_selection()
        end,
        mode = "n",
      },
      {
        ")",
        desc = "Increment selection",
        function()
          require("nvim-treesitter-incremental-selection").increment_node()
        end,
        mode = "v",
      },
      {
        "(",
        desc = "Decrement selection",
        function()
          require("nvim-treesitter-incremental-selection").decrement_node()
        end,
        mode = "v",
      },
    },
    opt = {},
  },
  {
    "michaeljsmith/vim-indent-object", -- treat indented sections of code as vim objects
  },
  {
    "Julian/vim-textobj-variable-segment",
    dependencies = "kana/vim-textobj-user",
  },
}
