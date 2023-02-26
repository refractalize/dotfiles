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
  'overcache/NeoSolarized',
  'mhartington/oceanic-next',
  {
    'projekt0n/github-nvim-theme',
    config = function()
      -- require('github-theme').setup()
    end
  },
  'folke/tokyonight.nvim',
  {
    "catppuccin/nvim",
    name = "catppuccin"
  }
}
