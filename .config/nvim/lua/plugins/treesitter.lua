return {
  {
    'nvim-treesitter/playground',
    dependencies = 'nvim-treesitter',

    config = function()
      require "nvim-treesitter.configs".setup {
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
          },
        }
      }
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',

    config = function()
      local all_except_broken_languages = vim.tbl_filter(function (e) return e ~= "t32" end, require('nvim-treesitter.parsers').available_parsers())

      require"nvim-treesitter.parsers".filetype_to_parsername.zsh = 'bash'

      require'nvim-treesitter.configs'.setup {
        ensure_installed = all_except_broken_languages,
        highlight = {
          enable = true              -- false will disable the whole extension
        },
        indent = {
          enable = true
        },
        matchup = {
          enable = true
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = ')',
            node_incremental = ')',
            node_decremental = '(',
          },
        },
      }

      vim.cmd([[
        nnoremap ( <Nop>
      ]])
    end
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = 'nvim-treesitter',

    config = function()
      require'nvim-treesitter.configs'.setup {
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
              ["ia"] = "@parameter.inner"
            },

            selection_modes = {
              ['@function.outer'] = 'V',
              ['@function.inner'] = 'V',
              ['@class.outer'] = 'V',
              ['@class.inner'] = 'V',
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
          }
        },
      }
    end
  },
}
