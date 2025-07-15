-- .local/share/nvim/lazy
return {
  {
    "direnv/direnv.vim",

    config = function()
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "DirenvLoaded",
        callback = function()
          local path = require("mason-core.path")
          local platform = require("mason-core.platform")

          local paths = vim.fn.split(vim.env.PATH, platform.path_sep)

          local already_in_path = vim.iter(paths):any(function(p)
            return p == path.bin_prefix()
          end)

          if not already_in_path then
            vim.env.PATH = vim.env.PATH .. platform.path_sep .. path.bin_prefix()
          end
        end,
      })
    end,
  },
  {
    "folke/trouble.nvim",

    opts = {
      follow = false,
    },
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
        indicator = {
          style = "underline",
        },
        mode = "tabs",
        separator_style = "slant",
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
    enabled = true,
  },
  {
    "gregorias/coerce.nvim",

    config = function()
      local coerce = require("coerce")
      coerce.setup({
        default_mode_mask = {
          normal_mode = false,
        },
      })

      require("coerce").register_mode({
        vim_mode = "n",
        keymap_prefix = "cr",
        selector = require("coerce.selector").select_current_word,
        transformer = require("coerce.transformer").transform_local,
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

    opts = {
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
      },
      view_options = {
        show_hidden = true,
      },
      buf_options = {
        buflisted = true,
        bufhidden = "",
      },
    },
  },

  {
    "refractalize/oil-git-status.nvim",

    dependencies = {
      {
        "stevearc/oil.nvim",

        opts = {
          watch_for_changes = true,
          win_options = {
            signcolumn = "yes:2",
          },
        },
      },
    },

    opts = {
      show_ignored = true,
    },
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
      scroll = {
        enabled = false,
      },
      indent = {
        animate = {
          enabled = false,
        },
      },
      scope = {
        enabled = false,
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

      vim.api.nvim_create_user_command("WatchGawk", function(opts)
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
  {
    "CopilotC-Nvim/CopilotChat.nvim",

    opts = {
      model = "claude-3.7-sonnet",
      auto_insert_mode = false,
      window = {
        width = 0,
        height = 0,
      },
    },
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup()
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {
      strategies = {
        chat = {
          adapter = "anthropic",
        },
        inline = {
          adapter = "anthropic",
        },
        cmd = {
          adapter = "anthropic",
        },
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "cmd: secret-tool lookup service claude api-type token",
            },
          })
        end,
      },
      display = {
        chat = {
          window = {
            width = "auto",
          },
        },
      },
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            show_result_in_chat = true, -- Show mcp tool results in chat
            make_vars = true, -- Convert resources to #variables
            make_slash_commands = true, -- Add prompts as /slash commands
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
    },
  },

  {
    "refractalize/pager.nvim",

    opts = {},
  },

  {
    "refractalize/curl.nvim",

    opts = {},
  },

  {
    "refractalize/envtoggle.nvim",

    keys = {
      {
        "<Leader>uv",
        function()
          require("envtoggle").select_environment_variable()
        end,
        desc = "Select environment variable to toggle",
      },
    },

    opts = {},
  },
  {
    "refractalize/editreg",

    config = function()
      vim.api.nvim_create_user_command("EditReg", function(opts)
        require("editreg").edit_register(opts.args)
      end, { nargs = 1 })
    end,
  },
  {
    "refractalize/qmkformat.nvim",
  },
  {
    "refractalize/ignore-lint",
  },
  {
    "refractalize/movement-repeat",
    enabled = false,

    opts = {
      capture_keys = {
        ["[q"] = "]q",
      },
    },
  },

  {
    "willmcpherson2/gnome.nvim",

    opts = {},
  },
}
