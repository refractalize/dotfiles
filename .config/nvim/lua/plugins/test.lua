return {
  {
    "refractalize/runtest.nvim",

    enabled = true,

    dependencies = {
      "mfussenegger/nvim-dap",
      "mfussenegger/nvim-dap-python",
    },

    keys = {
      {
        "<leader>ro",
        function()
          require("runtest").open_output()
        end,
        desc = "Open Run Output",
      },
      {
        "<leader>rO",
        function()
          require("runtest").open_output("split")
        end,
        desc = "Open Run Output in Split",
      },
      {
        "<leader>rtt",
        function()
          require("runtest").run_line_tests()
        end,
        desc = "Run Tests at Line",
      },
      {
        "<leader>rl",
        function()
          require("runtest").run_last()
        end,
        desc = "Run Last Profile",
      },
      {
        "<leader>rL",
        function()
          require("runtest").debug_last()
        end,
        desc = "Debug Last Profile",
      },
      {
        "<leader>rtf",
        function()
          require("runtest").run_file_tests()
        end,
        desc = "Run Tests in File",
      },
      {
        "<leader>rta",
        function()
          require("runtest").run_all_tests()
        end,
        desc = "Run All Tests",
      },
      {
        "<leader>rgl",
        function()
          require("runtest").goto_last()
        end,
        desc = "Go to Last Test",
      },
      {
        "<leader>rtT",
        function()
          require("runtest").debug_line_tests()
        end,
        desc = "Debug Tests at Line",
      },
      {
        "<leader>rto",
        function()
          require("runtest").open_terminal()
        end,
        desc = "Open Run Terminal",
      },
      {
        "<leader>rtO",
        function()
          require("runtest").open_terminal("split")
        end,
        desc = "Open Run Terminal in Split",
      },
      {
        "<leader>rb",
        function()
          require("runtest").run_build()
        end,
        desc = "Run Build",
      },
      {
        "<leader>rc",
        function()
          require("runtest").run_lint()
        end,
        desc = "Run Lint",
      },
      {
        "<leader>rf",
        function()
          require("runtest").send_entries_to_fzf()
        end,
        desc = "Send Run Entries to FZF",
      },
    },

    ---@module 'runtest'
    ---@type runtest.Config
    opts = {
      open_output_on_failure = true,
      filetypes = {
        python = {
          args = { ["--log-cli-level"] = "INFO", "-s" },
        },
      },
    },
  },
}
