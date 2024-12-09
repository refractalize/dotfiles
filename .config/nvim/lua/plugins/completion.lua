return {
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping["<C-y>"] = cmp.mapping.confirm({ select = false })
      opts.mapping["<CR>"] = nil
      opts.mapping["<S-CR>"] = nil
      opts.mapping["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })
      opts.mapping["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      -- opts.mapping["<C-N>"] = cmp.mapping(function()
      --   if cmp.visible() then
      --     cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      --   else
      --     cmp.complete()
      --   end
      -- end)
    end,
  },
  {
    "rafamadriz/friendly-snippets",
    enabled = false,
  },
  {
    "blink.cmp",
    optional = true,
    opts = {
      keymap = "default",
      sources = {
        providers = {
          copilot = {
            score_offset = 20,
          },
        },
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    enabled = false,
    opts = {
      suggestion = {
        keymap = {
          accept = "<Tab>",
        },
      },
    },
  },

  {
    "github/copilot.vim",
  }
}
