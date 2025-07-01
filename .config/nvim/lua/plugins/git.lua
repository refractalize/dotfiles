return {
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
        "<Cmd>Gdiffsplit! origin/main...<CR>",
        desc = "Show diffs with master",
      },
    },
  },
  "cedarbaum/fugitive-azure-devops.vim",
  {
    "tpope/vim-rhubarb",
  },
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",

    cmd = {
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewLog",
      "DiffviewOpen",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
    },

    config = function()
      require("diffview").setup({
        default_args = {
          DiffviewOpen = {
            "--untracked-files=no",
            "--imply-local",
          },
        },
        file_panel = {
          win_config = function()
            return {
              position = "left",
              width = math.floor(math.max(40, vim.o.columns * 0.15)),
              win_opts = {},
            }
          end,
        },
      })
    end,
  },
  {
    "refractalize/diff-conflicts",

    cmd = {
      "DiffConflicts",
    },

    keys = {
      {
        "<Leader>ddc",
        function()
          require("diff-conflicts").show_diff_select()
        end,
        desc = "Show diff",
      },
    },

    config = true,
  },
  {
    "NeogitOrg/neogit",
  },
}
