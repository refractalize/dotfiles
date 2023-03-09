return {
  'tpope/vim-rhubarb', -- github helpers for vim-fugitive

  {
    'tpope/vim-fugitive', -- git commands

    config = function()
      vim.cmd[[
        nnoremap <M-d> :Gdiffsplit!<cr>
        nnoremap <M-D> :Gdiffsplit! origin/master<cr>
        nnoremap <M-g> :G<cr>
      ]]
    end
  },

  'shumphrey/fugitive-gitlab.vim',

  {
    'refractalize/git-copy-lines',
    cmd = { 'GCopy' },
    dependencies = { 
      'tpope/vim-fugitive'
    }
  },

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
}
