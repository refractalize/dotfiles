return {
  {
    "tpope/vim-fugitive", -- git commands

    lazy = false,

    keys = {
      {
        "<M-d>",
        "<Cmd>Gdiffsplit!<CR>",
        desc = "Show diffs",
      },
      {
        "<M-D>",
        "<Cmd>Gdiffsplit! origin/main<CR>",
        desc = "Show diffs with master",
      },
    },

    init = function()
      local function set_title_with_branch()
        local branch = vim.fn.exists("*FugitiveHead") == 1 and vim.fn.FugitiveHead() or ""
        vim.o.titlestring = "nvim [" .. branch .. "]"
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "FugitiveChanged",
        callback = function()
          set_title_with_branch()
        end,
      })

      set_title_with_branch()
    end,
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    opts = {
    }
  },
  {
    "folke/snacks.nvim",

    enabled = true,
    
    priority = 1000,
    lazy = false,

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
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          {
            icon = " ",
            title = "Git Status",
            section = "terminal",
            key = "g",
            action = function()
              vim.cmd("G")
            end,
            enabled = function()
              return Snacks.git.get_root() ~= nil
            end,
            cmd = "git status --short --branch --renames",
            height = 5,
            padding = 1,
            ttl = 5 * 60,
            indent = 3,
          },
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
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate'
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      vim.cmd("colorscheme rose-pine")
    end
  },
}
