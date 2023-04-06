return {
  {
    "junegunn/fzf",

    build = function()
      vim.fn["fzf#install"]()
    end,
  },

  "junegunn/fzf.vim",

  {
    "refractalize/fzf-mru",
    auto = false,

    keys = {
      {
        "<Leader><Leader>",
        function()
          require("fzf-mru").fzf_mru()
        end,
        desc = "Search MRU files",
        mode = "n",
      },
      {
        "<Leader><Leader>",
        function()
          local utils = require("fzf-lua.utils")
          require("fzf-mru").fzf_mru({
            fzf_opts = {
              ["--query"] = utils.get_visual_selection(),
            },
          })
        end,
        desc = "Search MRU files with visual",
        mode = "v",
      },
      {
        "<Leader>f",
        function()
          require("fzf-mru").fzf_mru({
            all = true,
          })
        end,
        desc = "Search MRU all files",
      },
    },
  },

  {
    "refractalize/fzf-git",
  },

  {
    "ibhagwan/fzf-lua",

    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },

    cmds = {
      "Rg",
    },

    keys = {
      { "<Leader>l", "<cmd>FzfLua blines<cr>", desc = "Buffer lines" },
      { "<Leader>*", "<cmd>FzfLua grep_visual<cr>", desc = "Search visual", mode = "v" },
      {
        "<Leader>*",
        function()
          require("fzf-lua").grep({
            search = "\\b" .. vim.fn.expand("<cword>") .. "\\b",
            no_esc = true,
          })
        end,
        desc = "Search cword",
      },
      {
        "<c-x><c-f>",
        function()
          require("fzf-lua.complete").path()
        end,
        mode = "i",
        desc = "Complete path",
      },
      {
        "<c-x><c-l>",
        function()
          require("fzf-lua").complete_line()
        end,
        mode = "i",
        desc = "Complete line",
      },
      {
        "<c-x><c-r>",
        function()
          require("fzf-lua").complete_path({
            cmd = "rg --files | xargs grealpath --relative-to " .. vim.fn.expand("%:h"),
          })
        end,
        mode = "i",
        desc = "Complete relative path",
      },
      {
        "<c-x><c-h>",
        function()
          local actions = require("fzf-lua.actions")

          require("fzf-lua").fzf_complete(
            "zsh -c \"export HISTFILE=~/.zsh_history && fc -R && fc -rl 1 | sed -E 's/^[[:blank:]]*[[:digit:]]*\\*?[[:blank:]]*//'\"",
            {
              fzf_opts = {
                ["--tiebreak"] = "index",
              },
            }
          )
        end,
        mode = "i",
        desc = "Complete historical command",
      },
      {
        "<Leader>dv",
        function()
          require("fzf-lua").dap_variables()
        end,
        desc = "Debug show variables",
      },
      {
        "<Leader>G",
        ":Rg ",
        desc = "Start search",
      },
      {
        "gr",
        function()
          require("fzf-lua").lsp_finder()
        end,
        desc = "Find references",
      },
    },

    lazy = false,

    config = function()
      local actions = require("fzf-lua.actions")
      local fzf_lua = require("fzf-lua")

      fzf_lua.setup({
        winopts = {
          fullscreen = true,

          preview = {
            flip_columns = 200,
          },
        },

        lsp = {
          code_actions = {
            winopts = {
              fullscreen = false,
            },
          },
        },

        actions = {
          files = {
            ["default"] = actions.file_edit_or_qf,
            ["alt-s"] = actions.file_split,
            ["alt-v"] = actions.file_vsplit,
            ["alt-t"] = actions.file_tabedit,
            ["alt-q"] = actions.file_sel_to_qf,
            ["alt-l"] = actions.file_sel_to_ll,
          },
          buffers = {
            ["default"] = actions.buf_edit,
            ["alt-s"] = actions.buf_split,
            ["alt-v"] = actions.buf_vsplit,
            ["alt-t"] = actions.buf_tabedit,
          },
        },
      })

      -- fzf_lua.register_ui_select()

      vim.api.nvim_create_user_command("Rg", function(opts)
        require("fzf-lua").grep({
          search = opts.args,
          no_esc = true,
        })
      end, { nargs = "?" })

      vim.api.nvim_create_user_command("Rgs", function(opts)
        require("fzf-lua").grep({
          search = opts.args,
        })
      end, { nargs = 1 })

      vim.api.nvim_create_user_command("SearchCurrentFilename", function(opts)
        require("fzf-lua").grep({
          search = "\\b" .. vim.fn.expand("%:t:r") .. "\\b",
          no_esc = true,
        })
      end, { nargs = 0 })
    end,
  },
}
