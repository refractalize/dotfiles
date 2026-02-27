-- .local/share/nvim/lazy
return {
  {
    "NotAShelf/direnv.nvim",
    config = {
      statusline = {
        -- Enable statusline component
        enabled = true,
        -- Icon to display in statusline
        icon = "$",
      },
      keybindings = {
        allow = "<Leader>da",
        reload = "<Leader>dr",
      },
    },
  },
  {
    "folke/trouble.nvim",

    opts = {
      follow = false,
    },
  },
  {
    "nvim-lualine/lualine.nvim",

    opts = {
      sections = {
        lualine_x = {
          function()
            return require("direnv").statusline()
          end,
          "encoding",
          "fileformat",
          "filetype",
        },
      },
      winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1 },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1 },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
    },
  },
  {
    "refractalize/auto-save",
    enabled = function()
      return not vim.g.started_by_firenvim
    end,
    opts = {
      write_delay = 0,
      ignore_files = {
        large_files = function(bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > 50000
        end,
      },
    },
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
    "nvim-mini/mini.pairs",
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
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
  {
    "kristijanhusak/vim-dadbod-ui",

    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_tmp_query_location = ".dbui-queries"
      vim.filetype.add({
        pattern = {
          [".+/" .. vim.pesc(vim.g.db_ui_tmp_query_location) .. "/.+"] = "sql",
        },
      })

      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_use_nvim_notify = true

      -- NOTE: The default behavior of auto-execution of queries on save is disabled
      -- this is useful when you have a big query that you don't want to run every time
      -- you save the file running those queries can crash neovim to run use the
      -- default keymap: <leader>S
      vim.g.db_ui_execute_on_save = false
    end,
  },
  {
    "stevearc/oil.nvim",

    dependencies = { "nvim-tree/nvim-web-devicons" },
    specs = {
      {

        "refractalize/auto-save",
        opts = {
          ignore_files = {
            oil = function(bufnr)
              return vim.bo[bufnr].filetype == "oil"
            end,
          },
        },
      },
    },

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
        ["<C-S-c>"] = function()
          local buf_name = vim.api.nvim_buf_get_name(0)
          local prefix = "oil:///"
          local abs_path = buf_name

          if buf_name:sub(1, #prefix) == prefix then
            abs_path = "/" .. buf_name:sub(#prefix + 1)
          end

          local cwd = vim.uv.cwd()
          local rel_path = vim.fn.fnamemodify(abs_path, ":.")

          if cwd then
            local in_cwd = abs_path == cwd or abs_path:sub(1, #cwd + 1) == (cwd .. "/")
            if in_cwd then
              rel_path = abs_path:sub(#cwd + 2)
              if rel_path == "" then
                rel_path = "."
              end
            end
          end

          vim.fn.setreg("+", rel_path)
        end,
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
    "nvim-mini/mini.animate",
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
      image = {},
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

    cmd = {
      "QmkFormat",
      "QmkExportYaml",
    },

    opts = {
      keyboard_templates = {
        sofle = {
          file_pattern = "*sofle*",
          template = [[
            X X X X X X _ _ X X X X X X
            X X X X X X _ _ X X X X X X
            X X X X X X _ _ X X X X X X
            X X X X X X X X X X X X X X
            _ _ X X X X X X X X X X _ _
          ]],
        },
        voyager = {
          file_pattern = "*voyager*",
          template = [[
            X X X X X X _ _ X X X X X X
            X X X X X X _ _ X X X X X X
            X X X X X X _ _ X X X X X X
            X X X X X X _ _ X X X X X X
            _ _ _ _ X X _ _ X X _ _ _ _
          ]],
        },
      },
    },
  },
  {
    "refractalize/ignore-lint",

    cmd = { "IgnoreLint" },

    config = function()
      vim.api.nvim_create_user_command("IgnoreLint", function()
        require("ignore-lint").ignore_lint()
      end, { desc = "Ignore lint for current line or selection" })
    end,

    keys = {
      {
        "<leader>xl",
        function()
          require("ignore-lint").ignore_lint()
        end,
        desc = "Ignore lint for current line",
        mode = { "n", "v" },
      },
    },
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
    "refractalize/uv-deps.nvim",

    opts = {},
  },

  {
    "willmcpherson2/gnome.nvim",

    cond = function()
      return vim.fn.has("mac") ~= 1
    end,

    opts = {},
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = false,
  },

  {
    "zapling/mason-lock.nvim",

    cmd = { "MasonLock", "MasonLockRestore" },
    opts = {},
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,

    dependencies = {
      {
        "neovim/nvim-lspconfig",
        opts = { diagnostics = { virtual_text = false } },
      },
    },

    opts = {
      options = {
        show_source = {
          enabled = true, -- Enable showing source names
          if_many = false, -- Only show source if multiple sources exist for the same diagnostic
        },
        override_open_float = false,
      },
    },
  },
  {
    "MagicDuck/grug-far.nvim",

    keys = {
      {
        "<Leader>ss",
        function()
          local search = vim.fn.getreg("/")

          if search then
            search = search:gsub("\\<", "\\b"):gsub("\\>", "\\b")
          end

          require("grug-far").open({
            prefills = {
              search = search,
            },
          })
        end,
        desc = "Select and open file from grug",
      },
    },

    opts = {},
  },
  {
    "stevearc/quicker.nvim",
    ft = "qf",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {
      keys = {
        {
          ">",
          function()
            require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
          end,
          desc = "Expand quickfix context",
        },
        {
          "<",
          function()
            require("quicker").collapse()
          end,
          desc = "Collapse quickfix context",
        },
      },
    },
  },
  {
    "refractalize/log-duration.nvim",
    opts = {},
  },
}
