return {
  "tpope/vim-rhubarb", -- github helpers for vim-fugitive

  {
    "tpope/vim-fugitive", -- git commands

    lazy = false,

    keys = {
      {
        "<M-d>",
        "<Cmd>Gdiffsplit!<CR>",
        desc = "Show diffs",
      },
      {
        "<M-D>",
        "<Cmd>Gdiffsplit! origin/master...<CR>",
        desc = "Show diffs with master",
      },
    },
  },

  "shumphrey/fugitive-gitlab.vim",
  "cedarbaum/fugitive-azure-devops.vim",

  {
    "refractalize/git-copy-lines",
    cmd = { "GCopy" },
    dependencies = {
      "tpope/vim-fugitive",
    },
  },

  {
    "lewis6991/gitsigns.nvim",

    lazy = false,

    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          vim.keymap.set("n", "]c", function()
            require("gitsigns").next_hunk()
          end, { buffer = bufnr })
          vim.keymap.set("n", "[c", function()
            require("gitsigns").prev_hunk()
          end, { buffer = bufnr })
          vim.keymap.set("n", "<Leader>dp", function()
            require("gitsigns").preview_hunk_inline()
          end, { buffer = bufnr })
        end,
      })
    end,
  },
}
