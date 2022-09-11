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

        nmap        <C-j>   <Plug>(vsnip-select-text)
        xmap        <C-j>   <Plug>(vsnip-select-text)
        nmap        <C-J>   <Plug>(vsnip-cut-text)
        xmap        <C-J>   <Plug>(vsnip-cut-text)

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
          lualine_x = {'encoding', 'fileformat', 'filetype', require'lsp-status'.status},
          -- lualine_y = {'progress'},
          -- lualine_z = {'location'}
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
      vim.api.nvim_set_keymap('n', '<leader>d', '<cmd>DiffviewOpen<CR>', { noremap=true, silent=true })

      require("diffview").setup({
        view = {
          merge_tool = {
            layout = 'diff4_mixed'
          }
        }
      })
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

      lsp_status.config {
        indicator_errors = '🤬',
        indicator_warnings = '🤔',
        indicator_info = '🤓',
        indicator_hint = '🥃',
        indicator_ok = 'Ok',
      }

      vim.cmd([[
        command! LspLogs execute("e " . luaeval('vim.lsp.get_log_path()'))
        sign define DiagnosticSignError text=🤬
        sign define DiagnosticSignWarn text=🤔
        sign define DiagnosticSignInfo text=🤓
        sign define DiagnosticSignHint text=🤓
      ]])

      local opts = { noremap=true, silent=true }
      vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
      vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
      vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
      vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

      lsp_status.register_progress()

      local on_attach = function(client, bufnr)
        lsp_status.on_attach(client)

        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<M-f>', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
      end

      local servers = {'tsserver', 'rust_analyzer', 'solargraph', 'jsonls', 'cssls', 'html', 'julials', 'yamlls'}
      local capabilities = require('cmp_nvim_lsp').update_capabilities(lsp_status.capabilities)

      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          on_attach = on_attach,
          capabilities = capabilities,
          flags = {
            debounce_text_changes = 140,
          },
          root_dir = lspconfig.util.find_git_ancestor
        })
      end

      -- vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
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
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      local all_except_broken_languages = vim.tbl_filter(function (e) return e ~= "phpdoc" end, require('nvim-treesitter.parsers').available_parsers())

      require"nvim-treesitter.parsers".filetype_to_parsername.zsh = 'bash'

      require'nvim-treesitter.configs'.setup {
        ensure_installed = all_except_broken_languages,
        highlight = {
          enable = true              -- false will disable the whole extension
        },
        indent = {
          enable = false
        },
        matchup = {
          enable = true
        }
      }
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

  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      { 'nvim-lua/popup.nvim' },
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-file-browser.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
    },

    config = function()
      require("telescope").setup {
        extensions = {
          file_browser = {
            hijack_netrw = true,

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
      }

      require("telescope").load_extension("file_browser")
      require("telescope").load_extension("fzf")

      vim.cmd([[
        nnoremap - :Telescope file_browser path=%:p:h select_buffer=true<CR>
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
          local baleia = require('baleia')

          baleia.setup().once(vim.fn.bufnr('%'))
          vim.api.nvim_buf_set_option(0, 'buftype', 'nowrite')
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
        mapping = cmp.mapping.preset.insert(),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' }, -- For vsnip users.
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
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),

        completion = {
          autocomplete = false,
        },

        sources = {
          { name = 'buffer' }
        },
      })

      -- inoremap <C-x><C-o> <Cmd>lua require('cmp').complete()<CR>
      -- Use cmdline & path source for ':'.
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),

        completion = {
          autocomplete = false,
        },

        sources = cmp.config.sources({
          { name = 'path' },
          {
            name = 'buffer',
            option = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end
            }
          },
          { name = 'cmdline' },
          { name = 'cmdline_history' },
        }),
      })


      vim.cmd([[
        cnoremap <C-n> <Cmd>lua require('cmp').complete()<CR>
      ]])
    end
  }

  use {
    'kevinhwang91/nvim-hlslens',

    after = 'nvim-scrollbar',

    config = function()
      local kopts = {noremap = true, silent = true}

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

      vim.api.nvim_set_keymap('n', '<Leader>l', ':noh<CR>', kopts)

      require('hlslens').setup({
          nearest_only = true,
      })
    end
  }

  use {
    'petertriho/nvim-scrollbar',

    config = function()
      require("scrollbar").setup()
    end
  }

  use {
    'rcarriga/nvim-notify',

    config = function()
      vim.notify = require("notify")
    end
  }

  use {
    'mfussenegger/nvim-dap',

    config = function()
      local dap = require('dap')
      dap.adapters.ruby = {
        type = 'executable';
        command = 'bundle';
        args = {'exec', 'readapt', 'stdio'};
      }

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
          request = 'launch';
          name = 'Nearest Test';
          program = 'bundle';
          programArgs = {'exec', 'rails', 'test', '${file}:${lineNumber}'};
          useBundler = true;
        },
      }
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

  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

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
