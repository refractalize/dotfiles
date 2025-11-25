return {
  {
    "refractalize/runtest.nvim",

    dependencies = {
      "mfussenegger/nvim-dap",
      "mfussenegger/nvim-dap-python",
    },

    keys = {
      {
        "]S",
        function()
          require("runtest").goto_next_entry(true)
        end,
        desc = "Next Entry (Including External Files)",
      },
      {
        "[S",
        function()
          require("runtest").goto_previous_entry(true)
        end,
        desc = "Previous Entry (Including External Files)",
      },
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
      {
        "]r",
        function()
          require("runtest").next_output_history()
        end,
        desc = "Next Output History",
      },
      {
        "[r",
        function()
          require("runtest").previous_output_history()
        end,
        desc = "Previous Output History",
      },
    },

    ---@module 'runtest'
    ---@type runtest.PartialConfig
    opts = {
      open_output_on_failure = true,
      close_output_on_success = true,
      runners = {
        pytest = {
          args = { ["--log-cli-level"] = "INFO", "-s" },
          external_file_patterns = { "^\\.venv/" },
        },
      },
    },
  },
}
