return {
  {
    'refractalize/diff-patch',
  },

  {
    'refractalize/diff-lines',
  },

  {
    'sindrets/diffview.nvim',
    dependencies = 'nvim-lua/plenary.nvim',

    config = function()
      require("diffview").setup({
        default_args = {
          DiffviewOpen = { "--untracked-files=no", "--imply-local" },
          DiffviewFileHistory = { "--base=LOCAL" },
        },
        view = {
          merge_tool = {
            layout = 'diff4_mixed'
          }
        }
      })
    end
  },
}
