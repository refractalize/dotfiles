return {
  {
    "nvim-neotest/neotest",

    enabled = false,
  },

  "tpope/vim-dispatch",
  "tpope/vim-eunuch",
  "mfussenegger/nvim-dap",
  {
    "refractalize/runtest.nvim",

    enabled = true,

    dependencies = {
      "mfussenegger/nvim-dap",
      "mfussenegger/nvim-dap-python",
    },

    keys = {
      {
        "<leader>to",
        function()
          require("runtest").open()
        end,
      },
      {
        "<leader>tr",
        function()
          require("runtest").run_line_tests()
        end,
      },
      {
        "<leader>tl",
        function()
          require("runtest").run_last_tests()
        end,
      },
      {
        "<leader>tL",
        function()
          require("runtest").debug_last_tests()
        end,
      },
      {
        "<leader>tf",
        function()
          require("runtest").run_file_tests()
        end,
      },
      {
        "<leader>ta",
        function()
          require("runtest").run_all_tests()
        end,
      },
      {
        "<leader>tv",
        function()
          require("runtest").goto_last()
        end,
      },
      {
        "<leader>td",
        function()
          require("runtest").debug_line_tests()
        end,
      },
      {
        "<leader>rb",
        function()
          require("runtest").run_build()
        end,
      },
      {
        "<leader>rl",
        function()
          require("runtest").run_lint()
        end,
      },
    },

    opts = {
      filetypes = {
        python = {
          args = { ["--log-cli-level"] = "INFO", "-s" },
        },
      },
    },
  },
}
