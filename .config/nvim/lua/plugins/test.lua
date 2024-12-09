return {
  {
    "nvim-neotest/neotest",

    enabled = false,

    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- "antoinemadec/FixCursorHold.nvim", -- disabled due to perf, but apparently still needed?
      "Issafalcon/neotest-dotnet",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-jest",
      "nvim-neotest/nvim-nio",
    },

    keys = {
      {
        "<leader>tl",
        function()
          require("neotest").run.run()
        end,
        desc = "Run nearest test",
      },
      {
        "<leader>td",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug nearest test",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run test file",
      },
      {
        "<leader>tt",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run test file",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true })
        end,
        desc = "Run test file",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output_panel.open()
        end,
        desc = "Run test file",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.open()
        end,
        desc = "Show test summary",
      },
      {
        "<leader>tc",
        function()
          require("neotest").output_panel.clear()
        end,
        desc = "Clear output panel",
      },
    },

    config = function()
      local neotest = require("neotest")
      neotest.setup({
        log_level = vim.log.levels.DEBUG,
        adapters = {
          require("neotest-dotnet"),
          require("neotest-python")({
            args = {
              "-s", -- show std out (print statements)
            },
          }),
          require("neotest-jest"),
        },
        -- quickfix = {
        --   enabled = false,
        -- },
        -- consumers = {
        --   myquickfix = require("neotest_quickfix_stacktrace"),
        -- },
      })
    end,
  },

  {
    "vim-test/vim-test",
    -- enabled = false,

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

        " autocmd FileType qf call AdjustWindowHeight(30, 40)
        function! AdjustWindowHeight(percent_full_width, percent_full_height)
          if &columns*a:percent_full_width/100 >= 100
            exe "wincmd L"
            exe (&columns*a:percent_full_width/100) . "wincmd |"
          else
            exe "wincmd J"
            exe (&lines*a:percent_full_height/100) . "wincmd _"
          endif
        endfunction
      ]])
    end,
  },
}
