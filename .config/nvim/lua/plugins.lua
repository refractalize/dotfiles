-- installed ~/.local/share/nvim/site/pack/packer/start

require('packer').init({
  max_jobs = 70,
})

require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'tomasr/molokai'
  use { 'sonph/onehalf', rtp = 'vim/' }
  use 'ntk148v/vim-horizon'
  use 'joshdick/onedark.vim'
  use({
      'rose-pine/neovim',
      as = 'rose-pine',
  })
  use 'EdenEast/nightfox.nvim'
  use 'morhetz/gruvbox'
  use 'rakr/vim-one'
  use 'glepnir/oceanic-material'
  use 'marko-cerovac/material.nvim'
  use 'rakr/vim-two-firewatch'
  use 'NLKNguyen/papercolor-theme'
  use 'ayu-theme/ayu-vim'
  use 'Lokaltog/vim-monotone'
  use 'yashguptaz/calvera-dark.nvim'
  use 'rebelot/kanagawa.nvim'
  use 'sam4llis/nvim-tundra'
  use({
    'glepnir/zephyr-nvim',
    requires = { 'nvim-treesitter/nvim-treesitter', opt = true },
  })

  use {
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
  }
  use {
    'hrsh7th/vim-vsnip-integ',
    after = 'vim-vsnip'
  }

  use {
    'folke/which-key.nvim',

    config = function()
      require("which-key").setup()
    end
  }

  use 'overcache/NeoSolarized'
  use 'mhartington/oceanic-next'
  use 'kyazdani42/nvim-web-devicons' -- for file icons
  use 'tpope/vim-fugitive' -- git commands
  use 'shumphrey/fugitive-gitlab.vim'
  use 'tpope/vim-rhubarb' -- github helpers for vim-fugitive
  use 'junegunn/gv.vim'
  use 'groenewege/vim-less'
  use 'tpope/vim-abolish'
  use 'featurist/vim-pogoscript'
  -- use 'vim-ruby/vim-ruby'
  use {
    'tpope/vim-surround', -- add/remove/change quotes, parens
    config = function()
      vim.cmd([[
        autocmd FileType ruby let b:surround_45 = "do \r end"
        let g:surround_no_insert_mappings = 1
      ]])
    end
  }
  use {
    'tpope/vim-rails',
    ft = { 'ruby' }
  }
  use {
    'junegunn/vim-easy-align',

    config = function()
      vim.cmd([[
        " Start interactive EasyAlign in visual mode (e.g. vipga)
        xmap ga <Plug>(EasyAlign)

        " Start interactive EasyAlign for a motion/text object (e.g. gaip)
        nmap ga <Plug>(EasyAlign)
      ]])
    end
  }
  use {
    'mbbill/undotree',
    disable = true
  }

  use 'tpope/vim-cucumber'
  use 'godlygeek/tabular' -- format tables of data
  use 'plasticboy/vim-markdown'
  use 'michaeljsmith/vim-indent-object' -- treat indented sections of code as vim objects
  use 'leafgarland/typescript-vim'
  use 'maxmellon/vim-jsx-pretty'
  use 'jparise/vim-graphql'
  use {
    'RRethy/vim-illuminate',

    config = function()
      vim.cmd('source $HOME/.config/nvim/illuminate.vim')
    end
  }
  use 'vim-scripts/summerfruit256.vim'
  use 'tomtom/tlib_vim'
  use 'AndrewRadev/splitjoin.vim'
  use 'AndrewRadev/linediff.vim'
  use 'direnv/direnv.vim'
  use 'nvim-lua/lsp-status.nvim'

  use {
    'nvim-lualine/lualine.nvim',

    after = {'lsp-status.nvim'},

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
        options = {
          theme = lualine.themes[vim.g.colors_name] or vim.g.colors_name
        },
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
  }

  use {
    'sindrets/diffview.nvim',
    requires = 'nvim-lua/plenary.nvim',

    config = function()
      require("diffview").setup({
        view = {
          merge_tool = {
            layout = 'diff4_mixed'
          }
        }
      })
    end
  }

  use 'tapayne88/vim-mochajs'

  use {
    'weilbith/nvim-code-action-menu',
    cmd = 'CodeActionMenu',
  }

  use {
    'kosayoda/nvim-lightbulb',
    requires = 'antoinemadec/FixCursorHold.nvim',

    config = function()
      require('nvim-lightbulb').setup({autocmd = {enabled = true}})
    end
  }

  use {
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
  }

  use {
    'neovim/nvim-lspconfig',

    after = {
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
  }

  use {
    'folke/lsp-colors.nvim',

    config = function()
      require("lsp-colors").setup({
        Error = "#db4b4b",
        Warning = "#e0af68",
        Information = "#0db9d7",
        Hint = "#10B981"
      })
    end
  }

  use {
    'projekt0n/github-nvim-theme',
    config = function()
      -- require('github-theme').setup()
    end
  }

  use {
    'andymass/vim-matchup',

    setup = function()
      -- this is required so `config` is run _after_ the plugin is loaded
    end,

    config = function()
      if vim.fn.mapcheck('<C-G>%', 'i') ~= '' then
        vim.cmd([[
          iunmap <C-G>%
        ]])
      end
    end
  }

  use {
    'nvim-treesitter/playground',
    after = 'nvim-treesitter',

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
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',

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
  }

  use {
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = 'nvim-treesitter',

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
          },
          lsp_interop = {
            enable = true,
            peek_definition_code = {
              ["dm"] = "@function.outer",
              ["dM"] = "@class.outer",
            },
          },
        },
      }
    end
  }

  use 'tpope/vim-vinegar'

  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      { 'nvim-lua/popup.nvim' },
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-file-browser.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
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
  }

  use {
    'm00qek/baleia.nvim',
    tag = 'v1.2.0',

    config = function()
      vim.api.nvim_create_autocmd({ "BufRead" }, {
        pattern = {"*.tty", "*.log"},

        callback = function()
          if vim.api.nvim_buf_line_count(0) <= 1000 then
            local baleia = require('baleia')

            baleia.setup().once(vim.fn.bufnr('%'))
            vim.api.nvim_buf_set_option(0, 'buftype', 'nowrite')
          end
        end
      })
    end
  }

  use 'tpope/vim-unimpaired' -- [c ]c ]l [l etc, for navigating git changes, lint errors, search results, etc
  use 'tpope/vim-eunuch' -- file unix commands, :Delete, :Move, etc
  use 'tpope/vim-jdaddy' -- JSON manipulation
  use 'tpope/vim-commentary' -- make lines comments or not
  use 'tpope/vim-repeat' -- repeat complex commands with .
  use 'tpope/vim-dadbod'
  use 'FooSoft/vim-argwrap' -- expanding and collapsing lists
  use 'google/vim-jsonnet' -- jsonnet language support
  use 'jxnblk/vim-mdx-js'
  use { 'junegunn/fzf', run = function() vim.fn['fzf#install']() end }
  use 'junegunn/fzf.vim'
  use 'wsdjeg/vim-fetch'
  use 'norcalli/nvim-colorizer.lua'
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
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
  }

  use {
    'KabbAmine/vCoolor.vim',
    setup = function()
      vim.g.vcoolor_disable_mappings = 1
    end
  }

  use {
    'hrsh7th/nvim-cmp',

    requires = {
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
  }

  use {
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
  }

  use {
    'gelguy/wilder.nvim',
    disable = true,

    config = function()
      local wilder = require('wilder')
      wilder.setup({
        modes = {':', '/', '?'},
        -- next_key = '<C-p>',
        -- previous_key = '<C-n>',
      })

      local hist_cmd = { wilder.history() }
      vim.list_extend(hist_cmd, wilder.cmdline_pipeline())
      -- print('hist_cmd')
      -- print(vim.inspect(hist_cmd))

      wilder.set_option('pipeline', {
        wilder.branch(
          {
            wilder.check(function(_, x) return vim.fn.empty(x) end),
            wilder.history(15),
          },
          wilder.cmdline_pipeline(),
          {
            wilder.history(50),
            function(ctx, xs) return vim.fn.filter(xs, function(i, x) return vim.fn.match(x, ctx.input) end) end
          }
        )
      })

      -- wilder.set_option('pipeline', wilder.map(
      --   function(ctx, x)
      --     print('first: ' .. vim.inspect(x))
      --     return { 'foo', 'bar' }
      --   end,
      --   function(ctx, x)
      --     print('second: ' .. vim.inspect(x))
      --     return { 'blah', 'blog' }
      --   end
      -- ))

--       wilder.set_option('pipeline', {
--         wilder.branch(
--           hist_cmd,
--           wilder.search_pipeline()
--         )
--       })

      wilder.set_option('renderer', wilder.popupmenu_renderer({
        reverse = 1,
        highlighter = wilder.basic_highlighter(),
        left = {' ', wilder.popupmenu_devicons()},
        right = {' ', wilder.popupmenu_scrollbar()},
      }))
    end,
  }

  use {
    'petertriho/nvim-scrollbar',

    after = 'nvim-hlslens',

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
  }

  use {
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
  }

  use {
    'suketa/nvim-dap-ruby',

    after = 'nvim-dap',

    config = function()
      -- require('dap-ruby').setup()
    end
  }

  -- use {
  --   'elzr/vim-json',
  --   config = function()
  --     vim.g.vim_json_syntax_conceal = 0
  --   end
  -- }

  use 'vim-scripts/indentpython.vim'
  use 'rust-lang/rust.vim'
  use 'racer-rust/vim-racer'
  use {
    'JuliaEditorSupport/julia-vim',

    config = function()
      vim.g.latex_to_unicode_tab = "off"
    end
  }

  -- use {
  --   'w0rp/ale',
  --   config = function()
  --     vim.cmd('source $HOME/.config/nvim/ale.vim')
  --   end
  -- }
  use 'will133/vim-dirdiff'

  use {
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
  }

  use 'kshenoy/vim-signature'

  use {
    'AndrewRadev/sideways.vim', -- move arguments left and right
    disable = true,
    config = function()
      vim.cmd([[
        nnoremap _ :SidewaysLeft<cr>
        nnoremap + :SidewaysRight<cr>

        omap aa <Plug>SidewaysArgumentTextobjA
        xmap aa <Plug>SidewaysArgumentTextobjA
        omap ia <Plug>SidewaysArgumentTextobjI
        xmap ia <Plug>SidewaysArgumentTextobjI
      ]])
    end
  }

  use {
    'tpope/vim-dispatch',

    config = function()
      -- we keep this here to make sure the `after` in vim-dispatch-neovim works
    end
  }

  use {
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
  }

  use {
    "rcarriga/vim-ultest",
    disable = true,

    requires = {
      "vim-test/vim-test"
    },

    run = ":UpdateRemotePlugins"
  }

  use 'folke/tokyonight.nvim'

  use({
      "catppuccin/nvim",
      as = "catppuccin"
  })

  use {
    'radenling/vim-dispatch-neovim',
    after = 'vim-dispatch'
  }

  use {
    'voldikss/vim-floaterm',

    config = function()
      vim.cmd([[
        autocmd FileType json nnoremap <leader>j :FloatermNew --autoclose=2 --wintype=split jqfzf %<cr>
      ]])
    end
  }
end)
