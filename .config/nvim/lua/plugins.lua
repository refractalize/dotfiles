require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'tomasr/molokai'
  use { 'sonph/onehalf', rtp = 'vim/' }
  use 'ntk148v/vim-horizon'
  use 'joshdick/onedark.vim'
  use 'rakr/vim-one'
  use 'rakr/vim-two-firewatch'
  use 'ghifarit53/tokyonight-vim'
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
  use 'tpope/vim-vinegar'
  use 'tpope/vim-fugitive' -- git commands
  use 'tpope/vim-rhubarb' -- github helpers for vim-fugitive
  use 'junegunn/gv.vim'
  use 'groenewege/vim-less'
  use 'tpope/vim-abolish'
  use 'featurist/vim-pogoscript'
  use 'vim-ruby/vim-ruby'
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
  use 'mbbill/undotree'
  use 'tpope/vim-cucumber'
  use 'godlygeek/tabular' -- format tables of data
  use 'plasticboy/vim-markdown'
  use 'michaeljsmith/vim-indent-object' -- treat indented sections of code as vim objects
  use 'leafgarland/typescript-vim'
  use 'maxmellon/vim-jsx-pretty'
  use 'jparise/vim-graphql'
  use 'pangloss/vim-javascript'
  use 'RRethy/vim-illuminate'
  use 'vim-scripts/summerfruit256.vim'
  -- use 'MarcWeber/vim-addon-mw-utils' -- not sure what's using this?
  use 'tomtom/tlib_vim'
  use 'AndrewRadev/splitjoin.vim'
  use 'AndrewRadev/linediff.vim'
  use 'direnv/direnv.vim'
  use {
    'itchyny/lightline.vim',

    config = function()
      vim.g.lightline = {
        colorscheme = vim.g.lightline.colorscheme,

        separator = { left = "\u{e0b0}", right = "\u{e0b2}" },
        subseparator = { left = "\u{e0b1}", right = "\u{e0b3}" },
        active = {
          left = {
            { 'mode', 'paste' },
            { 'readonly', 'relativepath', 'modified' }
          },
          right = {
            { 'lineinfo' },
            { 'percent' },
            { 'fileformat', 'fileencoding', 'filetype' }
          }
        },
        component_function = {
          gitbranch = 'FugitiveHead'
        },
      }
    end
  }

  use {
    'neovim/nvim-lspconfig',
    config = function()
      local nvim_lsp = require('lspconfig')

      local on_attach = function(client, bufnr)
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
        buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

        -- Set some keybinds conditional on server capabilities
        if client.resolved_capabilities.document_formatting then
            buf_set_keymap("n", "<M-f>", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
        elseif client.resolved_capabilities.document_range_formatting then
            buf_set_keymap("n", "<M-f>", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
        end
      end

      local servers = {'tsserver', 'rust_analyzer', 'solargraph'}
      for _, lsp in ipairs(servers) do
        nvim_lsp[lsp].setup {
          on_attach = on_attach,
        }
      end

      vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
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
          enable = true
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
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'tpope/vim-unimpaired' -- [c ]c ]l [l etc, for navigating git changes, lint errors, search results, etc
  use 'tpope/vim-eunuch' -- file unix commands, :Delete, :Move, etc
  use 'tpope/vim-jdaddy' -- JSON manipulation
  use 'tpope/vim-commentary' -- make lines comments or not
  use 'tpope/vim-repeat' -- repeat complex commands with .
  use 'tpope/vim-dadbod'
  use 'moll/vim-node'
  use 'FooSoft/vim-argwrap' -- expanding and collapsing lists
  use 'google/vim-jsonnet' -- jsonnet language support
  use 'jxnblk/vim-mdx-js'
  use { 'junegunn/fzf', run = function() vim.fn['fzf#install']() end }
  use 'junegunn/fzf.vim'
  use 'wsdjeg/vim-fetch'
  use 'norcalli/nvim-colorizer.lua'
  use 'lewis6991/gitsigns.nvim'
  use {
    'kyazdani42/nvim-tree.lua',

    config = function()
      vim.g.nvim_tree_follow = 1
      vim.g.nvim_tree_disable_netrw = 0
      vim.g.nvim_tree_icons = {
        default = '',
        symlink = '',
        git = {
          unstaged = "#",
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          untracked = "?",
          deleted = "",
          ignored = "◌"
        },
        folder = {
          arrow_open = "",
          arrow_closed = "",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = "",
        },
        lsp = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        }
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
    'Shougo/deoplete.nvim',
    setup = function()
      vim.g['deoplete#enable_at_startup'] = 1
    end,
    run = ':UpdateRemotePlugins',
    requires = { 'shougo/deoplete-lsp' },
    config = function()
      vim.cmd([[
        set completeopt=menuone,noinsert,noselect

        " Avoid showing message extra message when using completion
        set shortmess+=c

        call deoplete#custom#option('auto_complete_popup', 'manual')
        inoremap <silent><expr> <C-N> deoplete#complete()
      ]])
    end
  }

  use {
    'elzr/vim-json',
    config = function()
      vim.g.vim_json_syntax_conceal = 0
    end
  }

  use 'vim-scripts/indentpython.vim'
  use 'rust-lang/rust.vim'
  use 'racer-rust/vim-racer'
  use 'JuliaEditorSupport/julia-vim'

  use {
    'w0rp/ale',
    config = function()
      vim.cmd('source $HOME/.config/nvim/ale.vim')
    end
  }
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
    '907th/vim-auto-save',
    config = function()
      vim.g.auto_save = 1
    end
  }

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
    'vim-test/vim-test',
    requires = {
      'tpope/vim-dispatch',
      {
        'radenling/vim-dispatch-neovim',
        after = 'vim-dispatch'
      }
    },
    config = function()
      vim.cmd([[
        nmap <leader>tf :TestFile<CR>
        nmap <leader>tl :TestNearest<CR>
        nmap <leader>tt :TestLast<CR>
        nmap <leader>tv :TestVisit<CR>
        nmap <leader>to :copen<CR>
        let test#strategy = 'dispatch'

        autocmd FileType qf call AdjustWindowHeight(30, 40)
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
end)
