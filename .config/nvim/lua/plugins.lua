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
      ]])
    end
  }
  use {
    'hrsh7th/vim-vsnip-integ',
    after = 'vim-vsnip'
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
  use 'RRethy/vim-illuminate'
  use 'vim-scripts/summerfruit256.vim'
  use 'tomtom/tlib_vim'
  use 'AndrewRadev/splitjoin.vim'
  use 'AndrewRadev/linediff.vim'
  use 'direnv/direnv.vim'

  use {
    'hoob3rt/lualine.nvim',

    requires = {'nvim-lua/lsp-status.nvim'},

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
              shorting_target = 0
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
        -- tabline = {},
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
    'neovim/nvim-lspconfig',

    requires = {
      'nvim-lua/lsp-status.nvim'
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

      lsp_status.register_progress()

      local on_attach = function(client, bufnr)
        lsp_status.on_attach(client)

        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings
        local opts = { noremap=true, silent=true }
        buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

        buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)

        buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev({enable_popup = false})<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next({enable_popup = false})<CR>', opts)
        buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)

        -- Set some keybinds conditional on server capabilities
        if client.resolved_capabilities.document_formatting or client.resolved_capabilities.document_range_formatting then
            buf_set_keymap("n", "<M-f>", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
        end
      end

      local servers = {'tsserver', 'rust_analyzer', 'solargraph', 'jsonls', 'cssls', 'html', 'julials', 'yamlls'}

      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          on_attach = on_attach,
          capabilities = lsp_status.capabilities,
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
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = 'maintained',
        highlight = {
          enable = true              -- false will disable the whole extension
        },
        indent = {
          enable = false
        },
        textobjects = {
          select = {
            enable = true,
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
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

  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-lua/popup.nvim'},
      {'nvim-lua/plenary.nvim'}
    },

    config = function()
      require"telescope".load_extension("frecency")
      require("telescope").load_extension("file_browser")
    end
  }

  use {
    "nvim-telescope/telescope-frecency.nvim",

    requires = {"tami5/sqlite.lua"}
  }

  use { "nvim-telescope/telescope-file-browser.nvim" }

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
    'lambdalisue/fern.vim',

    requires = {
      'lambdalisue/fern-git-status.vim',
      'lambdalisue/nerdfont.vim',
      'lambdalisue/fern-renderer-nerdfont.vim',
      'lambdalisue/fern-hijack.vim'
    },

    config = function()
      vim.cmd([[
        let g:fern#renderer = "nerdfont"
        nnoremap - :Fern %:h -reveal=%:t<cr>
        nnoremap <leader>n :Fern . -reveal=%<cr>
      ]])
    end
  }

  use {
    'hrsh7th/nvim-cmp',

    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-vsnip'
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
          }
        }, {
          { name = 'cmdline' }
        }),
      })

      -- Setup lspconfig.
      local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
      local servers = {'tsserver', 'rust_analyzer', 'solargraph'}
      local lspconfig = require('lspconfig')
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          capabilities = capabilities
        }
      end
    end
  }

  use 'google/vim-searchindex'

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
  use 'nightsense/wonka'

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
  use {
    'Pocco81/AutoSave.nvim',

    config = function()
      local autosave = require("autosave")

      autosave.setup({
        conditions = {
          exists = false,
          filetype_is_not = {
            'fern-replacer'
          },
          filename_is_not = {
            'plugins.lua'
          },
          modifiable = true,
        },
        execution_message = '',
        on_off_commands = true,
      })
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

  use({
      "catppuccin/nvim",
      as = "catppuccin"
  })

  use {
    'radenling/vim-dispatch-neovim',
    after = 'vim-dispatch'
  }

  use {
    'github/copilot.vim'
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
