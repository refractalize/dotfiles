return {
  'tomasr/molokai',
  {
    'sonph/onehalf',

    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/vim")
    end
  },
  'ntk148v/vim-horizon',
  'joshdick/onedark.vim',
  {
    'rose-pine/neovim',
    name = 'rose-pine',
  },
  'EdenEast/nightfox.nvim',
  'morhetz/gruvbox',
  'rakr/vim-one',
  'glepnir/oceanic-material',
  'marko-cerovac/material.nvim',
  'rakr/vim-two-firewatch',
  'NLKNguyen/papercolor-theme',
  'ayu-theme/ayu-vim',
  'Lokaltog/vim-monotone',
  'yashguptaz/calvera-dark.nvim',
  'rebelot/kanagawa.nvim',
  'sam4llis/nvim-tundra',
  {
    'glepnir/zephyr-nvim',
  },

  'dstein64/vim-startuptime',

  {
    'hrsh7th/vim-vsnip',

    config = function()
      vim.cmd([[
        " Expand
        imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
        smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

        " Expand or jump
        imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
        smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

        " Jump forward or backward
        imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
        smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
        imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
        smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

        nmap        <C-j>   <Plug>(vsnip-cut-text)
        xmap        <C-j>   <Plug>(vsnip-cut-text)

        let g:vsnip_filetypes = {}
        let g:vsnip_filetypes.typescript = ['javascript']
      ]])
    end
  },
  {
    'hrsh7th/vim-vsnip-integ',
    dependencies = 'vim-vsnip'
  },

  {
    'folke/which-key.nvim',

    config = function()
      require("which-key").setup()
    end
  },

  'overcache/NeoSolarized',
  'mhartington/oceanic-next',
  'kyazdani42/nvim-web-devicons', -- for file icons
  'tpope/vim-fugitive', -- git commands
  'shumphrey/fugitive-gitlab.vim',
  'tpope/vim-rhubarb', -- github helpers for vim-fugitive
  'junegunn/gv.vim',
  'groenewege/vim-less',
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
    'tpope/vim-rails',
    ft = { 'ruby' }
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

  'tpope/vim-cucumber',
  'godlygeek/tabular', -- format tables of data
  'plasticboy/vim-markdown',
  'michaeljsmith/vim-indent-object', -- treat indented sections of code as vim objects
  'leafgarland/typescript-vim',
  'maxmellon/vim-jsx-pretty',
  'jparise/vim-graphql',
  {
    'RRethy/vim-illuminate',

    config = function()
      vim.cmd('source $HOME/.config/nvim/illuminate.vim')
    end
  },
  'vim-scripts/summerfruit256.vim',
  'tomtom/tlib_vim',
  'AndrewRadev/splitjoin.vim',
  'AndrewRadev/linediff.vim',
  'direnv/direnv.vim',
  'nvim-lua/lsp-status.nvim',

  {
    'nvim-lualine/lualine.nvim',

    enabled = true,
    dependencies = {'lsp-status.nvim'},

    config = function()
      local function filename()
        return vim.fn.expand('%')
      end
      local lualine = require 'lualine'

      lualine.themes = {
        ayu_light = 'ayu',
        github_light = 'auto',
      }

      lualine.setup {
        sections = {
          lualine_a = {'mode'},
          lualine_b = {
            {
              'filename',
              path = 1,
              shorting_target = 0,
              symbols = {
                modified = ' 😱😱😱'
              }
            }
          },
          lualine_c = {
            function()
              return vim.env.PROMPT_ICON or ''
            end,
            'branch',
            'diff',
            'diagnostics'
          },
          lualine_x = {
            'encoding',
            'fileformat',
            'filetype',
            function()
              return require('lsp-status').status_progress()
            end
          },
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_b = {
            {
              'filename',
              path = 1,
              shorting_target = 0

            }
          },
          lualine_a = {},
          lualine_c = {},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {
          lualine_a = {
            {
              'tabs',
              mode = 2
            }
          }
        },
        extensions = {
          'fugitive',
          'quickfix',
          'fzf'
        }
      }

      vim.cmd([[
        autocmd ColorScheme * lua require'lualine'.setup { options = { theme = require'lualine'.themes[vim.g.colors_name] or vim.g.colors_name } }
      ]])
    end
  },

  {
    'sindrets/diffview.nvim',
    dependencies = 'nvim-lua/plenary.nvim',

    config = function()
      require("diffview").setup({
        view = {
          merge_tool = {
            layout = 'diff4_mixed'
          }
        }
      })
    end
  },

  'tapayne88/vim-mochajs',

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

    config = function()
      require('formatter').setup {
        logging = true,
        log_level = vim.log.levels.WARN,

        filetype = {
          javascript = {
            require('formatter.filetypes.javascript').prettierd
          }
        }
      }

      vim.api.nvim_set_keymap('n', '<M-f>', '<cmd>Format<CR>', { noremap = true, silent = true })
    end
  },

  {
    'neovim/nvim-lspconfig',

    dependencies = {
      'lsp-status.nvim',
      'nvim-cmp',
      'vim-matchup',
    },

    config = function()
      local lspconfig = require('lspconfig')
      local lsp_status = require'lsp-status'

      vim.cmd([[
        sign define DiagnosticSignError text=🤬
        sign define DiagnosticSignWarn text=🤔
        sign define DiagnosticSignInfo text=🤓
        sign define DiagnosticSignHint text=🤓
      ]])

      local opts = {
        noremap=true,
        silent=true
      }
      vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
      vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
      vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
      vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

      lsp_status.register_progress()

      local setup_lsp_mappings = function(
        client,
        bufnr,
        server_mappings
      )
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

        if server_mappings.format then
          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<M-f>', '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts)
          end

          if client.server_capabilities.documentRangeFormattingProvider then
            vim.api.nvim_buf_set_keymap(bufnr, 'x', '<M-f>', '<cmd>lua vim.lsp.buf.range_formatting({})<CR>', opts)
          end
        end

        if server_mappings.setup then
          server_mappings.setup(client, bufnr)
        end
      end

      local servers = {
        'cssls',
        'html',
        'jsonls',
        'julials',
        rust_analyzer = {
          ["rust-analyzer"] = {
            imports = {
              granularity = {
                group = "module",
              },
              prefix = "self",
            },
            cargo = {
              buildScripts = {
                enable = true,
              },
            },
            procMacro = {
              enable = true
            },
          }
        },
        'solargraph',
        'sqls',
        tsserver = {
          mappings = {
            format = false
          }
        },
        eslint = {
          format = true,
          mappings = {
            format = false,
            setup = function(client, bufnr)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<M-F>', '<cmd>EslintFixAll<CR>', opts)
            end,
          }
        },
        'yamlls',
      }

      local capabilities = vim.tbl_extend('keep', {}, lsp_status.capabilities)
      require('cmp_nvim_lsp').default_capabilities(capabilities)

      function removekey(table, key)
        local element = table[key]
        table[key] = nil
        return element
      end

      local server_mappings_default = {
        format = true
      }

      for server, server_settings in pairs(servers) do
        if type(server) == 'number' then
          server = server_settings
          server_settings = nil
        end

        local server_mappings = vim.tbl_extend(
          'force',
          server_mappings_default,
          server_settings and removekey(server_settings, 'mappings') or {}
        )

        lspconfig[server].setup({
          on_attach = function(client, bufnr)
            lsp_status.on_attach(client)
            setup_lsp_mappings(client, bufnr, server_mappings)
          end,
          capabilities = capabilities,
          flags = {
            debounce_text_changes = 140,
          },
          settings = server_settings
        })
      end
    end
  },

  {
    'folke/lsp-colors.nvim',

    config = function()
      require("lsp-colors").setup({
        Error = "#db4b4b",
        Warning = "#e0af68",
        Information = "#0db9d7",
        Hint = "#10B981"
      })
    end
  },

  {
    'projekt0n/github-nvim-theme',
    config = function()
      -- require('github-theme').setup()
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
    'nvim-treesitter/playground',
    dependencies = 'nvim-treesitter',

    config = function()
      require "nvim-treesitter.configs".setup {
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
          },
        }
      }
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

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',

    config = function()
      local all_except_broken_languages = vim.tbl_filter(function (e) return e ~= "t32" end, require('nvim-treesitter.parsers').available_parsers())

      require"nvim-treesitter.parsers".filetype_to_parsername.zsh = 'bash'

      require'nvim-treesitter.configs'.setup {
        ensure_installed = all_except_broken_languages,
        highlight = {
          enable = true              -- false will disable the whole extension
        },
        indent = {
          enable = true
        },
        matchup = {
          enable = true
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = ')',
            node_incremental = ')',
            node_decremental = '(',
          },
        },
      }

      vim.cmd([[
        nnoremap ( <Nop>
      ]])
    end
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = 'nvim-treesitter',

    config = function()
      require'nvim-treesitter.configs'.setup {
        textobjects = {
          select = {
            enable = true,
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner"
            },

            selection_modes = {
              ['@function.outer'] = 'V',
              ['@function.inner'] = 'V',
              ['@class.outer'] = 'V',
              ['@class.inner'] = 'V',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["+"] = "@parameter.inner",
            },
            swap_previous = {
              ["_"] = "@parameter.inner",
            },
          }
        },
      }
    end
  },

  'tpope/vim-vinegar',

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
    version = 'v1.2.0',

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
  'tpope/vim-jdaddy', -- JSON manipulation
  'tpope/vim-commentary', -- make lines comments or not
  'tpope/vim-repeat', -- repeat complex commands with .
  'tpope/vim-dadbod',
  'FooSoft/vim-argwrap', -- expanding and collapsing lists
  'google/vim-jsonnet', -- jsonnet language support
  'jxnblk/vim-mdx-js',
  { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
  'junegunn/fzf.vim',
  'wsdjeg/vim-fetch',
  'norcalli/nvim-colorizer.lua',
  {
    'lewis6991/gitsigns.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('gitsigns').setup{
        on_attach = function(bufnr)
          vim.cmd([[
            nnoremap <expr> ]c &diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'
            nnoremap <expr> [c &diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'
          ]])
        end
      }
    end
  },

  {
    'KabbAmine/vCoolor.vim',
    init = function()
      vim.g.vcoolor_disable_mappings = 1
    end
  },

  {
    'hrsh7th/nvim-cmp',

    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/cmp-nvim-lsp',
      'dmitmel/cmp-cmdline-history',
    },

    config = function()
      local cmp = require'cmp'

      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.confirm(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' }, -- For vsnip users.
          { name = 'path' },
          -- { name = 'luasnip' }, -- For luasnip users.
          -- { name = 'ultisnips' }, -- For ultisnips users.
          -- { name = 'snippy' }, -- For snippy users.
          {
            name = 'buffer',
            option = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end
            }
          }
        })
      })

      -- Use buffer source for `/`.
      -- cmp.setup.cmdline('/', {
      --   mapping = cmp.mapping.preset.cmdline(),

      --   completion = {
      --     autocomplete = false,
      --   },

      --   sources = {
      --     { name = 'buffer' }
      --   },
      -- })

      -- inoremap <C-x><C-o> <Cmd>lua require('cmp').complete()<CR>
      -- Use cmdline & path source for ':'.
      -- cmp.setup.cmdline(':', {
      --   mapping = cmp.mapping.preset.cmdline(),

      --   completion = {
      --     autocomplete = false,
      --   },

      --   sorting = {
      --     comparators = {
      --       cmp.config.compare.order,
      --     }
      --   },

      --   sources = cmp.config.sources({
      --     { name = 'cmdline_history' },
      --   }),
      -- })
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

      -- print('setting up hlslens')
      -- require("hlslens").setup({
      --   nearest_only = true,
        -- build_position_cb = function(plist, _, _, _)
        --   print('build_position_cb: ', vim.inspect(plist.start_pos))
        --   require("scrollbar.handlers.search").handler.show(plist.start_pos)
        -- end,
      -- })

      -- vim.cmd([[
      --     augroup scrollbar_search_hide
      --         autocmd!
      --         autocmd CmdlineLeave : lua require('scrollbar.handlers.search').handler.hide()
      --     augroup END
      -- ]])
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

  'vim-scripts/indentpython.vim',
  'rust-lang/rust.vim',
  'racer-rust/vim-racer',
  {
    'JuliaEditorSupport/julia-vim',

    config = function()
      vim.g.latex_to_unicode_tab = "off"
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

  'folke/tokyonight.nvim',

  {
    "catppuccin/nvim",
    name = "catppuccin"
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
    dev = true,
    config = function()
      require('auto-save').setup({
        write_delay = 0
      })
    end
  }
}
