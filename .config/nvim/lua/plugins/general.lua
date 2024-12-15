-- .local/share/nvim/lazy
return {
  {
    "direnv/direnv.vim",
  },
  {
    "refractalize/auto-save",
    config = function()
      if vim.g.started_by_firenvim then
        return
      end

      require("auto-save").setup({
        write_delay = 0,
        ignore_buffer = function(bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > 50000 or vim.bo[bufnr].filetype == "oil"
        end,
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",

    enabled = true,

    keys = {
      { "<leader>bl", false },
    },

    opts = {
      options = {
        mode = "tabs",
      },
    },
  },
  {
    "echasnovski/mini.pairs",
    enabled = false,
  },
  {
    "folke/flash.nvim",
    enabled = false,
  },
  {
    "folke/which-key.nvim",
    -- doesn't play nice with :FzfLua keymaps
    enabled = false,
  },
  {
    "gregorias/coerce.nvim",
    config = function()
      local coerce = require("coerce")
      coerce.setup({
        default_mode_mask = {
          normal_mode = false,
          motion_mode = false,
          visual_mode = false,
        },
      })
    end,
  },
  {
    "stevearc/oil.nvim",

    dependencies = { "nvim-tree/nvim-web-devicons" },

    lazy = false,

    keys = {
      {
        "-",
        function()
          require("oil").open()
        end,
        desc = "Open Oil",
      },
    },

    config = function()
      require("oil").setup({
        keymaps = {
          ["<C-h>"] = false,
          ["<C-l>"] = false,
        },
        view_options = {
          show_hidden = true,
        },
        win_options = {
          signcolumn = "yes:2",
        },
      })
    end,
  },

  {
    "refractalize/oil-git-status.nvim",

    dev = false,

    dependencies = {
      {
        "stevearc/oil.nvim",

        opts = {
          win_options = {
            signcolumn = "yes:2",
          },
        },
      },
    },

    config = { show_ignored = false },
  },

  {
    "folke/noice.nvim",

    enabled = false,

    opts = {
      cmdline = {
        enabled = true,
        format = {
          search_down = false,
          search_up = false,
          filter = false,
          lua = false,
          help = false,
        },
      },
      presets = {
        bottom_search = true,
      },
    },
  },

  {
    "refractalize/alternative-files",

    keys = {
      {
        "ga",
        function()
          require("alternative-files").show_alternative_files()
        end,
        desc = "Show alternative files",
      },
    },

    cmd = {
      "A",
    },

    config = function()
      require("alternative-files").setup({
        basename_patterns = {
          "(.*)Tests%.cs",
          "test_(.*)%.py",
        },
      })

      vim.api.nvim_create_user_command("A", function(opts)
        require("alternative-files").show_alternative_files()
      end, { nargs = 0 })
    end,
  },

  {
    "echasnovski/mini.animate",
    enabled = false,
  },
  {
    "refractalize/google.nvim",

    config = true,
  },

  {
    "m00qek/baleia.nvim",

    config = function()
      local baleia = require("baleia").setup()

      local function run_once()
        baleia.once(vim.fn.bufnr("%"))
        if vim.bo.modified then
          vim.bo.buftype = "nowrite"
        end
      end

      vim.api.nvim_create_user_command("Baleia", function(opts)
        run_once()
      end, { nargs = 0 })

      vim.api.nvim_create_autocmd({ "BufRead" }, {
        pattern = { "*.tty", "*.log" },

        callback = function()
          if vim.api.nvim_buf_line_count(0) <= 5000 then
            run_once()
          end
        end,
      })
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,

    opts = {
        style = "night",
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
    "folke/snacks.nvim",

    enabled = true,

    keys = {
      {
        "<leader>ns",
        function()
          Snacks.notifier.show_history()
        end,
      },
    },

    opts = {
      statuscolumn = {
        enabled = false,
        folds = {
          open = false,
          git_hl = false,
        },
      },
      notifier = {
        enabled = true,
      },
      dashboard = {
        sections = {
          { section = "header" },
          {
            icon = " ",
            key = "s",
            desc = "Restore Session",
            action = function()
              require("inter-session").load()
            end,
            padding = 1,
          },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },

  {
    "refractalize/treesj",
    branch = "support-for-csharp",
    keys = {
      {
        "<Leader>j",
        function()
          require("treesj").toggle()
        end,
        desc = "Toggle treesj",
      },
      {
        "<Leader>J",
        function()
          require("treesj").toggle({
            split = {
              recursive = true,
            },
          })
        end,
        desc = "Toggle treesj",
      },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
    },
  },

  {
    "refractalize/kittycopy",
    config = true,
  },

  {
    "gbprod/yanky.nvim",

    enabled = false,

    keys = {
      { "y", false },
      { "p", false },
      { "P", false },
      { "gp", false },
      { "gP", false },
      { "[y", false },
      { "]y", false },
      { "]p", false },
      { "[p", false },
      { "]P", false },
      { "[P", false },
      { ">p", false },
      { "<p", false },
      { ">P", false },
      { "<P", false },
      { "=p", false },
      { "=P", false },
    },
  },

  {
    "stevearc/dressing.nvim",

    config = {
      input = {
        insert_only = false,
      },
      select = {
        backend = { "fzf_lua" },
        fzf_lua = {
          winopts = {
            fullscreen = false,
          },
        },
      },
    },
  },

  {
    "refractalize/watch",

    commands = {
      "WatchJq",
    },

    config = function()
      local watch = require("watch")

      vim.api.nvim_create_user_command("WatchJq", function(opts)
        vim.api.nvim_set_option_value("filetype", "json", { buf = 0 })
        watch.start("jq {new:jq}", { stdin = true, filetype = "json" })
      end, { nargs = 0 })

      vim.api.nvim_create_user_command("WatchAwk", function(opts)
        watch.start("gawk {new:gawk}", { stdin = true })
      end, { nargs = 0 })
    end,
  },

  {
    "wsdjeg/vim-fetch",
  },

  {
    "luukvbaal/statuscol.nvim",
    opts = {},
  },
  {
    "folke/persistence.nvim",
    enabled = false,
  },
  {
    "refractalize/inter-session",

    opts = {
      load_session = false,
    },
  },
  "tpope/vim-eunuch",
}
