return {
  {
    "refractalize/diff-patch",
  },

  {
    "refractalize/copy-paste-patch",

    cmd = {
      "PatchCopy",
      "PatchPaste",
    },

    config = true,
  },

  {
    "refractalize/diff-lines",
  },

  {
    "refractalize/diff-conflicts",

    cmd = {
      "DiffConflicts",
    },

    keys = {
      {
        "<Leader>dc",
        function()
          require("diff-conflicts").show_diff_select()
        end,
        desc = "Show diff",
      },
    },

    config = true,
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
              win_opts = {}
            }
          end,
        }
      })
    end,
  },
}
