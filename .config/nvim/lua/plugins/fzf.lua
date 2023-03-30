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
  },

  {
    "refractalize/fzf-git",
  },

  {
    "ibhagwan/fzf-lua",

    dependencies = {
      "nvim-tree/nvim-web-devicons",
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
    },

    lazy = false,

    config = function()
      local actions = require("fzf-lua.actions")
      require("fzf-lua").setup({
        winopts = {
          fullscreen = true,
        },

        actions = {
          -- These override the default tables completely
          -- no need to set to `false` to disable an action
          -- delete or modify is sufficient
          files = {
            -- providers that inherit these actions:
            --   files, git_files, git_status, grep, lsp
            --   oldfiles, quickfix, loclist, tags, btags
            --   args
            -- default action opens a single selection
            -- or sends multiple selection to quickfix
            -- replace the default action with the below
            -- to open all files whether single or multiple
            -- ["default"]     = actions.file_edit,
            ["default"] = actions.file_edit_or_qf,
            ["alt-s"] = actions.file_split,
            ["alt-v"] = actions.file_vsplit,
            ["alt-t"] = actions.file_tabedit,
            ["alt-q"] = actions.file_sel_to_qf,
            ["alt-l"] = actions.file_sel_to_ll,
          },
          buffers = {
            -- providers that inherit these actions:
            --   buffers, tabs, lines, blines
            ["default"] = actions.buf_edit,
            ["alt-s"] = actions.buf_split,
            ["alt-v"] = actions.buf_vsplit,
            ["alt-t"] = actions.buf_tabedit,
          },
        },
      })
    end,
  },
}
