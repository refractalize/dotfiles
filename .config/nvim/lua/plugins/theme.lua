return {
  {
    'refractalize/theme',

    priotity = 1000,

    config = function()
      vim.cmd[[
        call theme#SetupCurrentTheme()
      ]]
    end
  },

  {
    'tomasr/molokai',
    lazy = true
  },
  {
    'sonph/onehalf',

    lazy = true,

    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/vim")
    end
  },
  {
    'ntk148v/vim-horizon',
    lazy = true,
  },
  {
    'joshdick/onedark.vim',
    lazy = true
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = true,
  },
  {
    'EdenEast/nightfox.nvim',
    lazy = true
  },
  {
    'morhetz/gruvbox',
    lazy = true
  },
  {
    'rakr/vim-one',
    lazy = true
  },
  {
    'glepnir/oceanic-material',
    lazy = true
  },
  {
    'marko-cerovac/material.nvim',
    lazy = true
  },
  {
    'rakr/vim-two-firewatch',
    lazy = true
  },
  {
    'NLKNguyen/papercolor-theme',
    lazy = true
  },
  {
    'ayu-theme/ayu-vim',
    lazy = true
  },
  {
    'Lokaltog/vim-monotone',
    lazy = true
  },
  {
    'yashguptaz/calvera-dark.nvim',
    lazy = true
  },
  {
    'rebelot/kanagawa.nvim',
    lazy = true
  },
  {
    'sam4llis/nvim-tundra',
    lazy = true
  },
  {
    'glepnir/zephyr-nvim',
    lazy = true,
  },
  {
    'overcache/NeoSolarized',
    lazy = true
  },
  {
    'mhartington/oceanic-next',
    lazy = true
  },
  {
    'projekt0n/github-nvim-theme',
    config = function()
      -- require('github-theme').setup()
    end,
    lazy = true,
  },
  {
    'folke/tokyonight.nvim',
    lazy = true
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
  }
}
