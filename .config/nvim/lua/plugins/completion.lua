return {
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace }),
        ["<C-y>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
      })

      opts.preselect = cmp.PreselectMode.None
      opts.completion = { completeopt = "menu,menuone,noinsert,noselect" }

      local buffer_source = vim.iter(opts.sources):find(function(s)
        return s.name == "buffer"
      end)
      if buffer_source then
        buffer_source.option = vim.tbl_deep_extend("force", buffer_source.option or {}, {
          get_bufnrs = function()
            return vim.api.nvim_list_bufs()
          end,
        })
      end
      return opts
    end,
  },
  {
    "rafamadriz/friendly-snippets",
    enabled = false,
  },
  {
    "saghen/blink.cmp",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      signature = {
        enabled = false,
      },
      snippets = {
        preset = 'luasnip',
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
  },

  {
    "garymjr/nvim-snippets",
    enabled = false,
  },

  {
    "L3MON4D3/LuaSnip",

    config = function(opts)
      require("luasnip").config.set_config({})

      require("luasnip.loaders.from_vscode").lazy_load({
        paths = vim.fn.stdpath("config") .. "/snippets",
      })

      local fns = {
        uuid = function()
          return vim.fn.system("uuidgen"):gsub("\n", ""):lower()
        end,
      }

      require("luasnip").env_namespace("SYS", { vars = os.getenv })
      require("luasnip").env_namespace("FN", {
        vars = function(name)
          return fns[name:lower()]()
        end,
      })

      vim.api.nvim_create_user_command("LuaSnipEdit", function(opts)
        require("luasnip.loaders").edit_snippet_files()
      end, { nargs = 0 })
    end,
  },
}
