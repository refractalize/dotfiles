return {
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
      {
        "<Leader>l",
        function()
          require("fzf-lua").grep_curbuf()
        end,
        desc = "Buffer lines",
      },
      {
        "<Leader>l",
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
        "<Leader>b",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<Leader>*",
        function()
          require("fzf-lua").grep_visual()
        end,
        desc = "Search visual",
        mode = "v",
      },
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
          local actions = require("fzf-lua.actions")
          require("fzf-lua").grep({
            search = vim.fn.getline("."),
            complete = function(selected)
              local line = vim.fn.substitute(selected[1], "^.\\{-}:\\d\\+:\\(\\d\\+:\\)\\?", "", "")
              return line, #line - 1
            end,
          })
        end,
        mode = "i",
        desc = "Complete line",
      },
      {
        "<c-i>",
        function()
          local actions = require("fzf-lua.actions")
          local package_json = vim.fn.findfile("package.json", ".;")
          local search_package_json = package_json
              and " && jq -r '.dependencies + .devDependencies | keys[]' " .. package_json
            or ""

          require("fzf-lua").fzf_exec("rg --files | sed 's/.*/.\\/&/'" .. search_package_json, {
            complete = function(selected, opts, line, col)
              local path = selected[1]
              local basepath = vim.fn.fnamemodify(path, ":t:r")
              local module_path

              if string.sub(path, 1, 1) ~= "." then
                module_path = path
              else
                local relative_path =
                  vim.fn.systemlist("grealpath --relative-to " .. vim.fn.expand("%:h") .. " " .. path)[1]

                if string.sub(relative_path, 1, 1) ~= "." then
                  module_path = "./" .. relative_path
                else
                  module_path = relative_path
                end
              end

              line = "import " .. basepath .. " from '" .. module_path .. "'"
              return line, #line - 1
            end,
          })
        end,
        mode = "i",
        desc = "Import module",
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
          local cmd = "zsh -c \"export HISTFILE=~/.zsh_history && fc -R && printf '%s\\\\t%s\\\\000' \\\"\\${(kv)history[@]}\\\" | perl -0 -ne 'if (\\!\\$seen{(/^\\\\s*[0-9]+\\\\**\\\\t(.*)/s, \\$1)}++) { s/\\\\n/\\n\\\\t/g; print; }'\""

          require("fzf-lua").fzf_exec(
            -- "zsh -c \"export HISTFILE=~/.zsh_history && fc -R && fc -rl 1 | sed -E 's/^[[:blank:]]*[[:digit:]]*\\*?[[:blank:]]*//'\"",
            -- "zsh -c \"printf '%s\\t%s\\000' \\\"${(kv)history[@]}\\\" | perl -0 -ne 'if (!$seen{(/^\\s*[0-9]+\\**\\t(.*)/s, $1)}++) { s/\\n/\\n\\t/g; print; }'\"",
            -- zsh -c "export HISTFILE=~/.zsh_history && fc -R && printf '%s\\t%s\\000' \"\${(kv)history[@]}\""
            cmd,
            {
              complete = true,
              fzf_opts = {
                ["--scheme"] = "history",
                ["--highlight-line"] = '',
                ["--read0"] = '',
              },
            }
          )
        end,
        mode = "i",
        desc = "Complete historical command",
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
      {
        "gs",
        function()
          require("fzf-lua").lsp_document_symbols()
        end,
        desc = "Show symbols",
      },
      {
        "<M-r>",
        function()
          -- There seems to be an issue when the command line has text in it
          -- That when we open the command history, the terminal containing
          -- fzf is in normal mode, and you need to get back into terminal/insert
          -- mode to be able to use it.
          --
          -- Solution is to take the command line text, clear it, escape from the
          -- command line then run the command history with the captured command line text
          local existing_command = vim.fn.getcmdline()
          local query = existing_command ~= '' and vim.fn.shellescape(existing_command) or nil
          vim.fn.setcmdline("")

          vim.schedule(function()
            require("fzf-lua").command_history({
              reverse_list = false,
              fzf_opts = {
                ["--query"] = query,

                -- Sort by most recent
                ["--no-sort"] = "",
                -- Prompt at the bottom
                ["--layout"] = "default",
              },
            })
          end)

          return "<C-C>"
        end,
        mode = { "c" },
        desc = "Show command history",
        expr = true,
      },
      {
        "<Leader>ca",
        function()
          require("fzf-lua").lsp_code_actions()
        end,
        desc = "Code action menu",
        mode = { "n", "v" },
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
            previewer = "codeaction_native",
          },
        },

        grep = {
          fzf_opts = {
            ["--no-sort"] = "",
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

      vim.api.nvim_create_user_command("Rg", function(opts)
        require("fzf-lua").grep({
          search = opts.args,
          no_esc = true,
        })
      end, { nargs = "?" })

      vim.api.nvim_create_user_command("RgOpts", function(opts)
        require("fzf-lua").grep({
          rg_opts = opts.args
            .. " --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
        })
      end, { nargs = "?" })

      vim.api.nvim_create_user_command("RgLast", function(opts)
        require("fzf-lua").grep_last()
      end, { nargs = 0 })

      vim.api.nvim_create_user_command("Rgs", function(opts)
        require("fzf-lua").grep({
          search = opts.args,
        })
      end, { nargs = 1 })

      vim.api.nvim_create_user_command("Gdiff", function(opts)
        local actions = require("fzf-lua.actions")
        require("fzf-lua").fzf_exec("git diff " .. opts.args .. " | diff2vimgrep", {
          previewer = "builtin",
          actions = {
            ["default"] = actions.file_edit_or_qf,
          },
          fzf_opts = {
            ["--multi"] = "",
          },
        })
      end, {
        nargs = "*",
        complete = "customlist,fugitive#ReadComplete",
      })

      vim.api.nvim_create_user_command("SearchCurrentFilename", function(opts)
        require("fzf-lua").grep({
          search = "\\b" .. vim.fn.expand("%:t:r") .. "\\b",
          no_esc = true,
        })
      end, { nargs = 0 })

      vim.api.nvim_create_user_command("Todos", function(opts)
        require("fzf-lua").grep({
          search = "\\bTODO\\b|\\bFIXME\\b|\\bNOTE\\b|\\bBUG\\b|\\bHACK\\b|\\bXXX\\b",
          no_esc = true,
        })
      end, { nargs = 0 })

      vim.api.nvim_create_user_command("DocumentSymbols", function(opts)
        require("fzf-lua").lsp_document_symbols()
      end, { nargs = 0 })
    end,
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
}
