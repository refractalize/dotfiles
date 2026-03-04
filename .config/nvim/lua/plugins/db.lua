return {
  {
    "tpope/vim-dadbod",
    enabled = false,
  },
  {
    "kristijanhusak/vim-dadbod-ui",

    enabled = false,

    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_tmp_query_location = ".dbui-queries"
      vim.filetype.add({
        pattern = {
          [".+/" .. vim.pesc(vim.g.db_ui_tmp_query_location) .. "/.+"] = "sql",
        },
      })

      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_use_nvim_notify = true

      -- NOTE: The default behavior of auto-execution of queries on save is disabled
      -- this is useful when you have a big query that you don't want to run every time
      -- you save the file running those queries can crash neovim to run use the
      -- default keymap: <leader>S
      vim.g.db_ui_execute_on_save = false
    end,
  },
}
