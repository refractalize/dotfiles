return {
  {
    "refractalize/diff-patch",
  },

  {
    "refractalize/diff-lines",
  },

  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",

    config = function()
      require("diffview").setup({
        default_args = {
          DiffviewOpen = { "--untracked-files=no", "--imply-local" },
        },
        view = {
          merge_tool = {
            layout = "diff4_mixed",
          },
        },
        hooks = {
          view_opened = function(view)
            require('utils').close_tab_when_any_window_is_closed()
          end,
        },
      })
    end,
  },
}
