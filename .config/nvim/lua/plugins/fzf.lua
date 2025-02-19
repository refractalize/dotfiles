return {
  {
    "ibhagwan/fzf-lua",

    keys = {
      -- { "<leader><space>", false },
      { "<leader><space>", false },
      {
        "gi",
        function()
          require("fzf-lua").lsp_implementations()
        end,
      },
      {
        "gt",
        function()
          require("fzf-lua").lsp_typedefs()
        end,
      },
      {
        "<Leader>bl",
        function()
          require("fzf-lua").grep_curbuf()
        end,
        desc = "Buffer lines",
      },
      {
        "<Leader>bl",
        function()
          local utils = require("fzf-lua.utils")
          require("fzf-lua").grep_curbuf({
            search = utils.get_visual_selection(),
          })
        end,
        desc = "Buffer lines",
        mode = "v",
      },
      {
        "<Leader>fd",
        function()
          local fzf_lua = require("fzf-lua")
          local env_files = vim.fn.findfile(".envrc", ".;", -1)
          local abs_env_files = vim
            .iter(env_files)
            :map(function(f)
              return vim.fn.fnamemodify(f, ":p")
            end)
            :totable()

          require("fzf-lua").fzf_exec(abs_env_files, {
            fn_transform = function(x)
              return fzf_lua.make_entry.file(x, { file_icons = true, color_icons = true })
            end,
            actions = fzf_lua.config.globals.actions.files,
            previewer = "builtin",
          })
        end,
        desc = "Direnv envrcs",
      },
      {
        "<c-x><c-h>",
        function()
          local cmd =
            "zsh -c \"export HISTFILE=~/.zsh_history && fc -R && printf '%s\\\\000' \\\"\\${history[@]}\\\" | perl -0 -ne 'if (\\!\\$seen{(/^\\\\s*[0-9]+\\\\**\\\\t(.*)/s, \\$1)}++) { s/\\\\n/\\n\\\\t/g; print; }'\""

          require("fzf-lua").fzf_exec(cmd, {
            complete = function(selected, opts, line, col)
              -- does not allow newlines in the completion :(
              local newline = line:sub(1, col) .. vim.fn.join(selected, "\n")
              local newline_end = line:sub(col + 1)
              return newline .. newline_end, #newline + 1
            end,
            fzf_opts = {
              ["-n"] = "2..,..",
              ["--scheme"] = "history",
              ["--highlight-line"] = "",
              ["--read0"] = "",
            },
          })
        end,
        mode = "i",
        desc = "Complete historical command",
      },
    },

    opts = function(_, opts)
      local actions = require("fzf-lua.actions")
      local file_actions = {
        ["default"] = actions.file_edit_or_qf,
        ["alt-s"] = actions.file_split,
        ["alt-v"] = actions.file_vsplit,
        ["alt-t"] = actions.file_tabedit,
      }

      return {
        winopts = {
          fullscreen = true,
        },
        files = {
          actions = vim.tbl_extend("force", {}, opts.files.actions, file_actions),
        },
        buffers = {
          actions = vim.tbl_extend("force", {}, opts.buffers and opts.buffers.actions or {}, file_actions),
        },
        grep = {
          actions = vim.tbl_extend("force", {}, opts.buffers and opts.grep.actions or {}, file_actions),
        },
        lsp = {
          jump1 = true,
          jump1_action = actions.file_edit,
        },
        diagnostics = {
          severity_limit = vim.diagnostic.severity.WARN,
        },
      }
    end,
  },

  {
    "refractalize/fzf-mru",
    auto = false,
    lazy = false,

    dependencies = {
      "ibhagwan/fzf-lua",
    },

    keys = {
      {
        "<leader><space>",
        function()
          require("fzf-mru").fzf_mru()
        end,
        desc = "Search MRU files",
        mode = "n",
      },
      {
        "<leader>fa",
        function()
          require("fzf-mru").fzf_mru({ all = true })
        end,
        desc = "Search All MRU files",
        mode = "n",
      },
      {
        "<leader><space>",
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
    },

    opts = {},
  },
}
