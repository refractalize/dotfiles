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
        "<Cmd>Gdiffsplit! origin/main<CR>",
        desc = "Show diffs with master",
      },
    },

    init = function()
      local function set_title_with_branch()
        local branch = vim.fn.exists("*FugitiveHead") == 1 and vim.fn.FugitiveHead() or ""
        vim.o.titlestring = "nvim [" .. branch .. "]"
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "FugitiveChanged",
        callback = function()
          set_title_with_branch()
        end,
      })

      set_title_with_branch()
    end,
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

    keys = {
      {
        "<Leader>gg",
        function()
          require("diffview").open({})
        end,
        desc = "Show diffview",
      },
      {
        "<Leader>gm",
        function()
          require("diffview").open({'origin/main...'})
        end,
        desc = "Show diffview",
      },
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

    enabled = false,
  },
}
