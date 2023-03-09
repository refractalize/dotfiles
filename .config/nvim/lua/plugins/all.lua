return {
  'dstein64/vim-startuptime',

  {
    'folke/which-key.nvim',

    config = function()
      require("which-key").setup()
    end
  },

  'nvim-tree/nvim-web-devicons', -- for file icons
  'tpope/vim-abolish',

  {
    'tpope/vim-surround', -- add/remove/change quotes, parens
    config = function()
      vim.cmd([[
        autocmd FileType ruby let b:surround_45 = "do \r end"
        let g:surround_no_insert_mappings = 1
      ]])
    end
  },
  {
    'junegunn/vim-easy-align',

    config = function()
      vim.cmd([[
        " Start interactive EasyAlign in visual mode (e.g. vipga)
        xmap ga <Plug>(EasyAlign)

        " Start interactive EasyAlign for a motion/text object (e.g. gaip)
        nmap ga <Plug>(EasyAlign)
      ]])
    end
  },

  'godlygeek/tabular', -- format tables of data
  'michaeljsmith/vim-indent-object', -- treat indented sections of code as vim objects
  {
    'RRethy/vim-illuminate',

    config = function()
      vim.cmd('source $HOME/.config/nvim/illuminate.vim')
    end
  },
  'AndrewRadev/splitjoin.vim',
  'AndrewRadev/linediff.vim',
  'direnv/direnv.vim',

  {
    'weilbith/nvim-code-action-menu',
    cmd = 'CodeActionMenu',
  },

  {
    'kosayoda/nvim-lightbulb',
    dependencies = 'antoinemadec/FixCursorHold.nvim',

    config = function()
      require('nvim-lightbulb').setup({autocmd = {enabled = true}})
    end
  },

  {
    'mhartington/formatter.nvim',

    cmd = { 'Format' },
    keys = {
      { "<M-f>", "<cmd>Format<cr>", desc = "Format" },
    },

    config = function()
      require('formatter').setup {
        logging = true,
        log_level = vim.log.levels.WARN,

        filetype = {
          javascript = {
            require('formatter.filetypes.javascript').prettierd
          },
          json = {
            require('formatter.filetypes.json').jq
          }
        }
      }
    end
  },

  {
    'andymass/vim-matchup',

    init = function()
      -- this is required so `config` is run _after_ the plugin is loaded
    end,

    config = function()
      if vim.fn.mapcheck('<C-G>%', 'i') ~= '' then
        vim.cmd([[
          iunmap <C-G>%
        ]])
      end
    end
  },


  {
    "cshuaimin/ssr.nvim",
    -- Calling setup is optional.
    config = function()
      require("ssr").setup {
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
      }

      vim.keymap.set({ "n", "x" }, "<leader>sr", function() require("ssr").open() end)
    end
  },

  -- 'tpope/vim-vinegar',

  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },

    config = function()
      require("telescope").setup {
        extensions = {
          file_browser = {
            mappings = {
              ["i"] = {
                ["<C-w>"] = function() vim.cmd('normal vbd') end,
              },
            },
          },

          fzf = {
            fuzzy = false,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                             -- the default case_mode is "smart_case"
          },

        },

        defaults = {
          layout_strategy = 'bottom_pane',
          layout_config = {
            height = 0.4,
            prompt_position = 'bottom'
          },
        },

        pickers = {
          command_history = {
            mappings = {
              n = {
                ['<CR>'] = 'edit_command_line',
              },
              i = {
                ['<CR>'] = 'edit_command_line',
              },
            },
          },
        },
      }

      require("telescope").load_extension("file_browser")
      require("telescope").load_extension("fzf")

      vim.cmd([[
        cnoremap <M-r> <Cmd>lua require('telescope.builtin').command_history{default_text = vim.fn.getcmdline()}<cr>
      ]])
    end
  },

  {
    'm00qek/baleia.nvim',

    config = function()
      vim.api.nvim_create_autocmd({ "BufRead" }, {
        pattern = {"*.tty", "*.log"},

        callback = function()
          if vim.api.nvim_buf_line_count(0) <= 5000 then
            local baleia = require('baleia')

            baleia.setup().once(vim.fn.bufnr('%'))
            vim.api.nvim_buf_set_option(0, 'buftype', 'nowrite')
          end
        end
      })
    end
  },

  'tpope/vim-unimpaired', -- [c ]c ]l [l etc, for navigating git changes, lint errors, search results, etc
  'tpope/vim-eunuch', -- file unix commands, :Delete, :Move, etc
  'tpope/vim-commentary', -- make lines comments or not
  'tpope/vim-repeat', -- repeat complex commands with .
  'FooSoft/vim-argwrap', -- expanding and collapsing lists
  'wsdjeg/vim-fetch',
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      vim.opt.termguicolors = true
      require'colorizer'.setup()
    end
  },

  {
    'KabbAmine/vCoolor.vim',
    init = function()
      vim.g.vcoolor_disable_mappings = 1
    end
  },

  {
    'kevinhwang91/nvim-hlslens',

    config = function()
      local kopts = {noremap = true, silent = true}
      require("hlslens").setup()

      vim.api.nvim_set_keymap('n', 'n',
          [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
          kopts)
      vim.api.nvim_set_keymap('n', 'N',
          [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
          kopts)
      vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)
    end
  },

  {
    'petertriho/nvim-scrollbar',

    dependencies = 'nvim-hlslens',

    config = function()
      require("scrollbar").setup({
        -- handlers = {
        --   search = true
        -- }
      })

      require('scrollbar.handlers.search').setup({
        nearest_only = true,
      })
    end
  },

  {
    'mfussenegger/nvim-dap',

    config = function()
      local dap = require('dap')
      dap.set_log_level('TRACE')
      dap.adapters.ruby = function(callback, config)
        callback {
          type = "server",
          host = "127.0.0.1",
          port = 38697,
          executable = {
            command = "bundle",
            args = vim.list_extend({ "exec", "rdbg", "--open", "--port", 38697,
              "-c", "--", "bundle", "exec", config.program,
            }, config.programArgs),
          },
        }
      end

      dap.configurations.ruby = {
        {
          type = 'ruby';
          request = 'launch';
          name = 'Rails';
          program = 'bundle';
          programArgs = {'exec', 'rails', 's'};
          useBundler = true;
        },
        {
          type = 'ruby';
          request = 'attach';
          localfs = true,
          name = 'Nearest Test';
          program = 'rails';
          programArgs = {'test', '${file}'};
          useBundler = true;
        },
      }
    end
  },

  {
    'suketa/nvim-dap-ruby',

    dependencies = 'nvim-dap',

    config = function()
      -- require('dap-ruby').setup()
    end
  },

  'will133/vim-dirdiff',

  {
    'mattn/emmet-vim',
    config = function()
      vim.g.user_emmet_settings = {
        html = {
          empty_element_suffix = ' />'
        },
        mdx = {
          extends = 'jsx',
        }
      }
    end
  },

  'kshenoy/vim-signature',

  {
    'tpope/vim-dispatch',

    config = function()
      -- we keep this here to make sure the `after` in vim-dispatch-neovim works
    end
  },

  {
    'vim-test/vim-test',

    config = function()
      vim.cmd([[
        nmap <leader>tf :TestFile<CR>
        nmap <leader>tl :TestNearest<CR>
        nmap <leader>tt :TestLast<CR>
        nmap <leader>tv :TestVisit<CR>
        nmap <leader>to :copen<CR>
        let test#strategy = 'dispatch'

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
    end
  },

  {
    'radenling/vim-dispatch-neovim',
    dependencies = 'vim-dispatch'
  },

  {
    'voldikss/vim-floaterm',

    config = function()
      vim.cmd([[
        autocmd FileType json nnoremap <leader>j :FloatermNew --autoclose=2 --wintype=split jqfzf %<cr>
      ]])
    end
  },

  {
    'refractalize/auto-save',
    config = function()
      require('auto-save').setup({
        write_delay = 0,
        ignore_files = {
          '.config/nvim/lua/plugins/*'
        }
      })
    end
  },

  {
    'refractalize/watch',
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },

    lazy = false,

    keys = {
      { "-", "<cmd>Neotree position=current reveal=true dir=%:h<cr>", desc = "Open Neotree" },
    },

    config = function()
      require("neo-tree").setup({
        -- enable_git_status = false,
        filesystem = {
          bind_to_cwd = false,
          use_libuv_file_watcher = true,
          follow_current_file = true,
          hijack_netrw_behavior = "open_current",
        },
        buffers = {
          follow_current_file = true,
        },
        window = {
          mappings = {
            ['/'] = 'noop',
            ['-'] = 'navigate_up',
          }
        }
      })
    end
  }
}
