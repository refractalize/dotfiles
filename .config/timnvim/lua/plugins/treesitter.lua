return {
  {
    "nvim-treesitter/playground",
    dependencies = "nvim-treesitter",

    cmd = { "TSPlaygroundToggle" },

    config = function()
      require("nvim-treesitter.configs").setup({
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = "o",
            toggle_hl_groups = "i",
            toggle_injected_languages = "t",
            toggle_anonymous_nodes = "a",
            toggle_language_display = "I",
            focus_language = "f",
            unfocus_language = "F",
            update = "R",
            goto_node = "<cr>",
            show_help = "?",
          },
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",

    config = function()
      vim.treesitter.language.register("bash", "zsh")

      function disable(lang, bufnr)
        local max_filesize = 100 * 1024 -- 100 KB
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local ok, stats = pcall(vim.loop.fs_stat, filename)
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end

      require("nvim-treesitter.configs").setup({
        ensure_installed = "all",
        ignore_install = { "java", "smali", "t32" },
        highlight = {
          enable = true, -- false will disable the whole extension
          disable = disable,
        },
        indent = {
          enable = true,
          disable = disable,
        },
        matchup = {
          enable = true,
          disable = disable,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = ")",
            node_incremental = ")",
            node_decremental = "(",
          },
          disable = disable,
        },
      })

      vim.cmd([[
        nnoremap ( <Nop>
      ]])
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter",

    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },

            selection_modes = {
              ["@function.outer"] = "V",
              ["@function.inner"] = "V",
              ["@class.outer"] = "V",
              ["@class.inner"] = "V",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["+"] = "@parameter.inner",
            },
            swap_previous = {
              ["_"] = "@parameter.inner",
            },
          },
        },
      })
    end,
  },
}
