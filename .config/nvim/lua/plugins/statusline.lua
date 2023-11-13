return {
  {
    "SmiteshP/nvim-navic",
    config = function()
      require("nvim-navic").setup({
        highlight = true,
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",

    dependencies = {
      "nvim-lua/lsp-status.nvim",
      "SmiteshP/nvim-navic",
    },

    config = function()
      if vim.g.started_by_firenvim then
        return
      end

      local original_cwd = vim.fn.getcwd()

      local function filename()
        return vim.fn.expand("%")
      end
      local lualine = require("lualine")

      lualine.themes = {
        ayu_light = "ayu",
        github_light = "auto",
      }

      lualine.setup({
        options = {
          theme = "tokyonight",
        },
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
            {
              "navic",
              color_correction = nil,
              navic_opts = nil,
            },
          },
          lualine_x = {
            "diff",
            "diagnostics",
            "encoding",
            "fileformat",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = {
            "location",
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {
            function()
              return vim.fn.expand("%")
            end,
          },
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

              fmt = function(name, context)
                local tab_cwd = vim.fn.getcwd(-1, context.tabnr)

                if vim.fn.gettabvar(context.tabnr, "diffview_view_initialized") ~= "" then
                  return "[diffview] " .. name
                elseif tab_cwd ~= original_cwd then
                  return "[" .. tab_cwd .. "] " .. name
                else
                  return name
                end
              end,
            },
          },
          lualine_x = {
            function()
              return require("lsp-status").status_progress()
            end,
          },
          lualine_z = {
            "branch",
            function()
              return vim.env.PROMPT_ICON or ""
            end,
            function()
              return vim.fn.getcwd()
            end,
          },
        },
        extensions = {
          "fugitive",
          "quickfix",
          "fzf",
          "lazy",
          "neo-tree",
          "nvim-dap-ui",
          "mason",
        },
      })

      vim.api.nvim_create_autocmd("TabClosed", {
        callback = function()
          lualine.refresh({
            scope = "tabpage",
          })
        end,
      })
    end,
  },
}
