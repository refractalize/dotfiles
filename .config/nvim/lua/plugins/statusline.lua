return {
  {
    'nvim-lualine/lualine.nvim',

    dependencies = {
      'nvim-lua/lsp-status.nvim',
    },

    config = function()
      local function filename()
        return vim.fn.expand('%')
      end
      local lualine = require 'lualine'

      lualine.themes = {
        ayu_light = 'ayu',
        github_light = 'auto',
      }

      lualine.setup {
        sections = {
          lualine_a = {'mode'},
          lualine_b = {
            {
              'filename',
              path = 1,
              shorting_target = 0,
              symbols = {
                modified = ' 😱😱😱'
              }
            }
          },
          lualine_c = {
            function()
              return vim.env.PROMPT_ICON or ''
            end,
            'branch',
            'diff',
            'diagnostics'
          },
          lualine_x = {
            'encoding',
            'fileformat',
            'filetype',
            function()
              return require('lsp-status').status_progress()
            end
          },
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_b = {
            {
              'filename',
              path = 1,
              shorting_target = 0

            }
          },
          lualine_a = {},
          lualine_c = {},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {
          lualine_a = {
            {
              'tabs',
              mode = 2
            }
          }
        },
        extensions = {
          'fugitive',
          'quickfix',
          'fzf'
        }
      }
    end
  },
}
