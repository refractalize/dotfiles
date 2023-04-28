return {
  {
    "nvim-lualine/lualine.nvim",

    dependencies = {
      "nvim-lua/lsp-status.nvim",
    },

    config = function()
      local function filename()
        return vim.fn.expand("%")
      end
      local lualine = require("lualine")

      lualine.themes = {
        ayu_light = "ayu",
        github_light = "auto",
      }

      lualine.setup({
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            function()
              if vim.bo.modified then
                return "%#lualine_b_replace#" .. vim.fn.expand("%") .. " [modified]"
              else
                return vim.fn.expand("%")
              end
            end,
          },
          lualine_c = {
            function()
              return vim.env.PROMPT_ICON or ""
            end,
            "branch",
            "diff",
            "diagnostics",
          },
          lualine_x = {
            "encoding",
            "fileformat",
            "filetype",
            function()
              return require("lsp-status").status_progress()
            end,
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_b = {
            function()
              return vim.fn.expand("%")
            end,
          },
          lualine_a = {},
          lualine_c = {},
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {
          lualine_a = {
            {
              "tabs",
              max_length = function()
                return vim.o.columns
              end,
              mode = 2,
            },
          },
        },
        extensions = {
          "fugitive",
          "quickfix",
          "fzf",
        },
      })
    end,
  },
}
