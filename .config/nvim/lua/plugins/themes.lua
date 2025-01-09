return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "nightwolf",
    },
  },
  { "catppuccin/nvim", name = "catppuccin" },
  { "rebelot/kanagawa.nvim" },
  {
    "rose-pine/neovim",
    name = "rose-pine",
  },
  {
    "navarasu/onedark.nvim",
    opts = {
      style = "deep",
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,

    opts = {
      style = "storm",
      on_highlights = function(hi, c)
        local util = require("tokyonight.util")
        hi.DiagnosticUnnecessary =
          { fg = util.lighten(hi.DiagnosticUnnecessary.fg, 0.5), bg = hi.DiagnosticUnnecessary.bg }
        if hi.CmpGhostText then
          hi.CmpGhostText = { fg = util.lighten(hi.CmpGhostText.fg, 0.5), bg = hi.CmpGhostText.bg }
        end
      end,
    },
  },

  {
    "ricardoraposo/nightwolf.nvim",
    enabled = false,
    -- lazy = false,
    -- priority = 1000,
    opts = {},
  },
}
