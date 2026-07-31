return {
  {
    "stevearc/conform.nvim",

    opts = {
      formatters_by_ft = {
        kdl = { "kdlfmt" },
        html = { "prettier" },
      },
      formatters = {
        prettier = {
          append_args = { "--ignore-path", "null" },
        },
      },
    },
  },
}
