-- ~/.local/share/nvim/lazy
return {
  "dstein64/vim-startuptime",

  {
    "folke/which-key.nvim",

    config = function()
      require("which-key").setup()
    end,
  },

  "nvim-tree/nvim-web-devicons", -- for file icons
  "tpope/vim-abolish",

  {
    "tpope/vim-surround", -- add/remove/change quotes, parens
    config = function()
      vim.cmd([[
        autocmd FileType ruby let b:surround_45 = "do \r end"
        let g:surround_no_insert_mappings = 1
      ]])
    end,
  },
  {
    "junegunn/vim-easy-align",
  },

  "godlygeek/tabular", -- format tables of data
  {
    "michaeljsmith/vim-indent-object", -- treat indented sections of code as vim objects
  },
  {
    "RRethy/vim-illuminate",

    config = function()
      require("illuminate").configure({
        large_file_cutoff = 50000,
      })
    end,
  },
  "AndrewRadev/splitjoin.vim",
  "direnv/direnv.vim",

  {
    "kosayoda/nvim-lightbulb",
    enabled = true,

    config = function()
      require("nvim-lightbulb").setup({
        autocmd = {
          enabled = true,
        },
        virtual_text = {
          enabled = true,
        },
        sign = {
          enabled = false,
        },
      })
    end,
  },

  {
    "mhartington/formatter.nvim",

    cmd = {
      "Format",
      "FormatAs",
    },

    keys = {
      { "<M-f>", "<cmd>Format<cr>", desc = "Format" },
    },

    config = function()
      require("formatter").setup({
        logging = true,
        log_level = vim.log.levels.INFO,

        filetype = {
          javascript = {
            require("formatter.filetypes.javascript").prettierd,
          },
          javascriptreact = {
            require("formatter.filetypes.javascriptreact").prettierd,
          },
          typescript = {
            require("formatter.filetypes.typescript").prettierd,
          },
          typescriptreact = {
            require("formatter.filetypes.typescriptreact").prettierd,
          },
          markdown = {
            require("formatter.filetypes.markdown").prettierd,
          },
          yaml = {
            require("formatter.filetypes.yaml").prettierd,
          },
          bash = {
            require("formatter.filetypes.sh").shfmt,
          },
          sh = {
            require("formatter.filetypes.sh").shfmt,
          },
          python = {
            require("formatter.filetypes.python").black,
          },
          lua = {
            require("formatter.filetypes.lua").stylua,
          },
          json = {
            require("formatter.filetypes.json").jq,
          },
          sql = {
            require("formatter.filetypes.sql").pgformat,
          },
          xml = {
            require("formatter.filetypes.xml").tidy,
          },
        },
      })
    end,
  },

  {
    "andymass/vim-matchup",

    init = function()
      -- this is required so `config` is run _after_ the plugin is loaded
    end,

    config = function()
      if vim.fn.mapcheck("<C-G>%", "i") ~= "" then
        vim.cmd([[
          iunmap <C-G>%
        ]])
      end
    end,
  },

  {
    "cshuaimin/ssr.nvim",
    -- Calling setup is optional.
    config = function()
      require("ssr").setup({
        border = "rounded",
        min_width = 50,
        min_height = 5,
        max_width = 120,
        max_height = 25,
        keymaps = {
          close = "q",
          next_match = "n",
          prev_match = "N",
          replace_confirm = "<cr>",
          replace_all = "<leader><cr>",
        },
      })

      vim.keymap.set({ "n", "x" }, "<leader>sr", function()
        require("ssr").open()
      end)
    end,
  },

  -- 'tpope/vim-vinegar',

  {
    "m00qek/baleia.nvim",

    config = function()
      local baleia = require("baleia").setup()

      local function run_once()
        baleia.once(vim.fn.bufnr("%"))
        if vim.bo.modified then
          vim.bo.buftype = "nowrite"
        end
      end

      vim.api.nvim_create_user_command("Baleia", function(opts)
        run_once()
      end, { nargs = 0 })

      vim.api.nvim_create_autocmd({ "BufRead" }, {
        pattern = { "*.tty", "*.log" },

        callback = function()
          if vim.api.nvim_buf_line_count(0) <= 5000 then
            run_once()
          end
        end,
      })
    end,
  },

  "tpope/vim-unimpaired", -- [c ]c ]l [l etc, for navigating git changes, lint errors, search results, etc
  "tpope/vim-eunuch", -- file unix commands, :Delete, :Move, etc
  {
    "tpope/vim-commentary", -- make lines comments or not
    enabled = false,
  },

  {
    "numToStr/Comment.nvim",
    opts = {
      -- add any options here
    },
    lazy = false,
  },

  "tpope/vim-repeat", -- repeat complex commands with .
  "FooSoft/vim-argwrap", -- expanding and collapsing lists
  "wsdjeg/vim-fetch",
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      vim.opt.termguicolors = true
      require("colorizer").setup()
    end,
  },

  {
    "KabbAmine/vCoolor.vim",
    enabled = false,
    init = function()
      vim.g.vcoolor_disable_mappings = 1
    end,
  },

  "will133/vim-dirdiff",

  {
    "mattn/emmet-vim",

    init = function()
      vim.g.user_emmet_mode = "i"
      vim.g.user_emmet_settings = {
        html = {
          empty_element_suffix = " />",
        },
        mdx = {
          extends = "jsx",
        },
      }
    end,
  },

  -- "kshenoy/vim-signature",

  {
    "tpope/vim-dispatch",

    keys = {
      "<leader>m",
      "<Cmd>Make<CR>",
    },
  },

  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- "antoinemadec/FixCursorHold.nvim", -- disabled due to perf, but apparently still needed?
      "Issafalcon/neotest-dotnet",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-jest",
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
    enabled = false,

    config = function()
      vim.cmd([[
        nmap <leader>tf :TestFile<CR>
        nmap <leader>tl :TestNearest<CR>
        nmap <leader>tt :TestLast<CR>
        nmap <leader>tv :TestVisit<CR>
        nmap <leader>to :copen<CR>
        let test#strategy = 'dispatch'
        let test#custom_runners = {'csharp': ['dotnettest2']}
        let test#csharp#runner = 'dotnettest2'

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

  {
    "radenling/vim-dispatch-neovim",
    dependencies = "vim-dispatch",
  },

  {
    "voldikss/vim-floaterm",

    config = function()
      vim.cmd([[
        autocmd FileType json nnoremap <leader>j :FloatermNew --autoclose=2 --wintype=split jqfzf %<cr>
      ]])
    end,
  },

  {
    "refractalize/auto-save",
    config = function()
      if vim.g.started_by_firenvim then
        return
      end

      require("auto-save").setup({
        write_delay = 0,
        ignore_buffer = function(bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > 50000 or vim.bo[bufnr].filetype == "oil"
        end,
      })
    end,
  },

  {
    "refractalize/watch",
  },

  {
    "refractalize/line-notes",

    keys = {
      {
        "<leader>nl",
        function()
          require("line_notes").add()
        end,
        desc = "Add note to line",
      },
      {
        "<leader>nc",
        function()
          require("line_notes").clear()
        end,
        desc = "Clear line notes",
      },
      {
        "<leader>nq",
        function()
          require("line_notes").quickfix()
        end,
        desc = "Show line notes in quickfix window",
      },
      {
        "<leader>nf",
        function()
          local notes = vim.diagnostic.get(nil, { namespace = require("line_notes").namespace })

          local fzf_lua = require("fzf-lua")

          local files = vim.tbl_map(function(item)
            local filename = vim.fn.bufname(item.bufnr)
            local line_number = item.lnum
            local line = vim.api.nvim_buf_get_lines(item.bufnr, line_number, line_number + 1, false)[1]

            local file = filename .. ":" .. line_number + 1 .. ":" .. line
            return fzf_lua.make_entry.file(file, { file_icons = true, color_icons = true })
          end, notes)

          fzf_lua.fzf_exec(files, {
            actions = fzf_lua.config.globals.actions.files,
            previewer = "builtin",
          })
        end,
        desc = "Show line notes in quickfix window",
      },
    },

    config = function()
      vim.api.nvim_create_user_command("LineNotesToggleLine", function(opts)
        require("line_notes").add(opts.args)
      end, { nargs = "?" })

      vim.api.nvim_create_user_command("LineNotesQuickfix", function(opts)
        require("line_notes").quickfix()
      end, { nargs = "?" })

      vim.api.nvim_create_user_command("LineNotesClearAll", function(opts)
        require("line_notes").clear()
      end, { nargs = 0 })
    end,
  },

  {
    "refractalize/editreg",

    config = function()
      vim.api.nvim_create_user_command("EditReg", function(opts)
        require("editreg").edit_register(opts.args)
      end, { nargs = 1 })
    end,
  },

  {
    "AckslD/nvim-neoclip.lua",

    keys = {
      {
        "<Leader>p",
        function()
          require("neoclip.fzf")()
        end,
        desc = "Neoclip",
      },
    },

    lazy = false,

    dependencies = {
      { "ibhagwan/fzf-lua" },
    },

    config = function()
      require("neoclip").setup()
    end,
  },

  {
    "refractalize/inter-session",

    config = true,
  },

  {
    "williamboman/mason.nvim",

    config = true,
  },

  {
    "Julian/vim-textobj-variable-segment",
    dependencies = "kana/vim-textobj-user",
  },

  {
    "github/copilot.vim",
  },

  {
    "folke/zen-mode.nvim",

    keys = {
      {
        "<M-Enter>",
        function()
          require("zen-mode").toggle()
        end,
        desc = "ZenMode",
        mode = { "n", "i" },
      },
    },

    config = function()
      require("zen-mode").setup({
        window = {
          backdrop = 1,
          width = 200,
        },
      })
    end,
  },

  {
    "ethanholz/nvim-lastplace",

    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
        lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
        lastplace_open_folds = true,
      })
    end,
  },

  {
    "refractalize/kitty-open-file",

    config = true,
  },

  {
    "jackMort/ChatGPT.nvim",
    enabled = false,
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        api_key_cmd = "security find-generic-password -s ChatGPT.nvim -a api_key -w",
        edit_with_instructions = {
          diff = true,
        },
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },

  {
    "mbbill/undotree",
  },

  {
    "glacambre/firenvim",

    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    lazy = not vim.g.started_by_firenvim,

    build = function()
      vim.fn["firenvim#install"](0)
    end,

    config = function()
      vim.g.firenvim_config = {
        localSettings = {
          [".*"] = {
            takeover = "never",
          },
        },
      }

      if vim.g.started_by_firenvim then
        vim.api.nvim_create_autocmd({ "VimEnter" }, {
          pattern = "*",

          callback = function()
            vim.go.laststatus = 0
            vim.go.cmdheight = 0
          end,
        })
      end
    end,
  },

  {
    "refractalize/focus-buffer",

    keys = {
      {
        "<leader>fb",
        function()
          require("focus-buffer").start_focus_buffer()
        end,
        mode = "v",
        desc = "Focus buffer",
      },
    },
  },

  {
    "stevearc/oil.nvim",

    dependencies = { "nvim-tree/nvim-web-devicons" },

    lazy = false,

    keys = {
      {
        "-",
        function()
          require("oil").open()
        end,
        desc = "Open Oil",
      },
    },

    config = function()
      require("oil").setup({
        view_options = {
          show_hidden = true,
        },
        win_options = {
          signcolumn = "yes:2",
        },
      })
    end,
  },

  {
    "refractalize/oil-git-status.nvim",

    dev = false,

    dependencies = {
      "stevearc/oil.nvim",
    },

    config = { show_ignored = false },
  },

  {
    "David-Kunz/gen.nvim",
  },

  {
    "rcarriga/nvim-notify",

    keys = {
      {
        "<leader>nd",
        function()
          require("notify").dismiss()
        end,
        desc = "Dissmiss notifications",
      },
    },

    config = function()
      vim.notify = require("notify")
    end,
  },

  {
    "gsuuon/llm.nvim",
  },

  {
    "refractalize/ls.nvim",

    -- config = true,
  },

  {
    "untitled-ai/jupyter_ascending.vim",

    init = function()
      vim.g.jupyter_ascending_default_mappings = false
    end,
  },

  {
    "3rd/image.nvim",
    -- couldn't get imagemagick to work
    enabled = false,

    config = true,

    opts = {
      backend = "kitty", -- whatever backend you would like to use
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },

    init = function()
      package.path = package.path
        .. ";"
        .. vim.fn.expand("$HOME")
        .. "/.luarocks/share/lua/5.1/?/init.lua"
        .. ";"
        .. vim.fn.expand("$HOME")
        .. "/.luarocks/share/lua/5.1/?.lua"
    end,

    build = "luarocks --lua-version 5.1 --local install magick",
  },

  {
    "stevearc/dressing.nvim",

    config = {
      input = {
        insert_only = false,
      },
      select = {
        backend = { "fzf_lua" },
        fzf_lua = {
          winopts = {
            fullscreen = false,
          },
        },
      },
    },
  },

  {
    "L3MON4D3/LuaSnip",
    enabled = true,

    keys = {
      {
        "<C-j>",
        function()
          require("luasnip").expand_or_jump()
        end,
        mode = { "i" },
        desc = "Expand or jump",
      },
      {
        "<C-k>",
        function()
          require("luasnip").jump(-1)
        end,
        mode = "i",
        desc = "Jump backward",
      },
    },

    config = function()
      require("luasnip").config.set_config({
        store_selection_keys = "<c-j>",
      })
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = vim.fn.stdpath("config") .. "/snippets",
      })

      local fns = {
        uuid = function()
          return vim.fn.system("uuidgen"):gsub("\n", ""):lower()
        end,
      }

      require("luasnip").env_namespace("SYS", { vars = os.getenv })
      require("luasnip").env_namespace("FN", {
        vars = function(name)
          return fns[name:lower()]()
        end,
      })

      vim.api.nvim_create_user_command("LuaSnipEdit", function(opts)
        require("luasnip.loaders").edit_snippet_files()
      end, { nargs = 0 })
    end,
  },

  {
    "refractalize/google.nvim",

    config = true,
  },

  {
    "refractalize/curl.nvim",

    config = function()
      require("curl").setup()

      vim.api.nvim_create_user_command("CurlSetHostArgs", function(opts)
        require("curl").input_host_args(opts.fargs[1])
      end, { nargs = 1 })
    end,
  },

  {
    "refractalize/ignore-lint",

    keys = {
      {
        "<leader>il",
        function()
          require("ignore-lint").ignore_lint()
        end,
        desc = "Ignore lint",
        mode = { "n", "v" },
      },
    },

    config = function()
      vim.api.nvim_create_user_command("IgnoreLint", function(opts)
        if opts.range >= 2 then
          require("ignore-lint").ignore_lint_visual(opts.line1, opts.line2)
        else
          require("ignore-lint").ignore_lint_line()
        end
      end, { nargs = 0, range = true })
    end,
  },

  {
    "Wansmer/sibling-swap.nvim",

    config = {
      keymaps = {
        ["<C-.>"] = "swap_with_right",
        ["<C-,>"] = "swap_with_left",
        ["<space>."] = "swap_with_right_with_opp",
        ["<space>,"] = "swap_with_left_with_opp",
      },
    },
  },

  {
    "robitx/gp.nvim",
    config = function()
      require("gp").setup({
        openai_api_key = { "security", "find-generic-password", "-s", "ChatGPT.nvim", "-a", "api_key", "-w" },
      })

      -- or setup with your own config (see Install > Configuration in Readme)
      -- require("gp").setup(config)

      -- shortcuts might be setup here (see Usage > Shortcuts in Readme)
    end,
  },

  {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
    end,
  },

  {
    "arthurxavierx/vim-caser"
  },
}
