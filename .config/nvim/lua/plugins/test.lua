return {
  {
    "nvim-neotest/neotest",

    enabled = false,

    keys = {
      {
        "<leader>to",
        function()
          require("neotest_file_output"):open()
        end,
      },
    },

    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        consumers = {
          file = require("neotest_file_output"),
          ---@param client neotest.Client
          notify = function(client)
            client.listeners.starting = function()
              vim.notify("Running tests", vim.log.levels.INFO)
            end
            client.listeners.results = function(adapter_id, results, partial)
              if partial then
                return
              end

              vim.schedule(function()
                for _, result in pairs(results) do
                  if result.status == "failed" then
                    vim.notify("Tests failed", vim.log.levels.WARN)
                    return
                  end
                end
                vim.notify("Tests passed", vim.log.levels.INFO)
              end)
            end
          end,
          ---@param client neotest.Client
          stacktraces = function(client)
            local function load_file(filename)
              local lines = vim.fn.readfile(filename)
              vim.fn.setqflist({}, "r", {
                efm = "%.%# %f:line %l",
                lines = lines,
              })
            end

            client.listeners.results = function(adapter_id, results, partial)
              if partial then
                return
              end

              for pos_id, result in pairs(results) do
                if result.output then
                  vim.schedule(function()
                    load_file(result.output)
                  end)
                  return
                end
              end
            end
          end,
        },
        output = {
          enabled = true,
          open_on_run = false,
        },
        adapters = {
          ["neotest-python"] = {
            args = { "-vv" },
          },
          ["neotest-dotnet"] = {
            discovery_root = "solution",
          },
        },
      })
    end,
  },
  {
    "refractalize/neotest-file-output",

    opts = {
      file_patterns = {
        "\\v(\\f+):line (\\d+)",
      },
    },
  },
  {
    "vim-test/vim-test",
    enabled = false,

    config = function()
      vim.cmd([[
        nmap <leader>tf :TestFile<CR>
        nmap <leader>tl :TestNearest<CR>
        nmap <leader>tt :TestLast<CR>
        nmap <leader>tv :TestVisit<CR>
        nmap <leader>to :copen \| wincmd L<CR>
        let test#strategy = 'dispatch'
        let test#custom_runners = {'csharp': ['dotnettest2']}
        let test#csharp#runner = 'dotnettest2'
        let test#python#runner = 'pytest'
      ]])
    end,
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
