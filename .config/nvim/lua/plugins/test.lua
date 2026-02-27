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
        "<leader>rl",
        function()
          require("runtest").run('line')
        end,
        desc = "Run Tests at Line",
      },
      {
        "<leader>rr",
        function()
          require("runtest").run_last()
        end,
        desc = "Run Last Profile",
      },
      {
        "<leader>rR",
        function()
          require("runtest").debug_last()
        end,
        desc = "Debug Last Profile",
      },
      {
        "<leader>rf",
        function()
          require("runtest").run('file')
        end,
        desc = "Run Tests in File",
      },
      {
        "<leader>ra",
        function()
          require("runtest").run('all')
        end,
        desc = "Run All Tests",
      },
      {
        "<leader>rp",
        function()
          require("runtest").run('project')
        end,
        desc = "Run Project Tests",
      },
      {
        "<leader>rgl",
        function()
          require("runtest").goto_last()
        end,
        desc = "Go to Last Test",
      },
      {
        "<leader>rL",
        function()
          require("runtest").debug('line')
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
          require("runtest").run('build')
        end,
        desc = "Run Build",
      },
      {
        "<leader>rs",
        function()
          require("runtest").select_context()
        end,
        desc = "Select Run Context",
      },
      {
        "<leader>rc",
        function()
          require("runtest").run('check')
        end,
        desc = "Run Lint",
      },
      {
        "<leader>rz",
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

    cmd = {
      "RunTestAttach",
      "RunTestCmd",
    },

    ---@module 'runtest'
    ---@type runtest.PartialConfig
    opts = {
      open_output_on_failure = true,
      close_output_on_success = true,
      runners = {
        pytest = {
          args = { ["--log-cli-level"] = "INFO", "-s" },
          output_profile = {
            external_file_patterns = { "^\\.venv/" },
          },
        },
        pyright = {
          output_profile = {
            file_patterns = {
              "\\v^\\s*(\\f+):(\\d+):(\\d+)",
            },
          },
        },
        cargo = {
          args = { "--", "--nocapture" },
          env = { RUST_BACKTRACE = "1" },
        },
        docker_compose = {
          name = "docker-compose",
        },
      },
    },
  },
}
