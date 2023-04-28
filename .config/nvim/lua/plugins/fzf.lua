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
          local actions = require("fzf-lua.actions")
          require("fzf-lua").grep({
            search = vim.fn.getline("."),
            actions = {
              -- ["default"] = actions.complete_insert,
              ["default"] = function(selected, opts)
                vim.fn.setline('.', vim.fn.substitute(selected[1], "^.\\{-}:.\\{-}:", "", ""))
                vim.cmd [[noautocmd lua vim.api.nvim_feedkeys('A', 'n', true)]]
              end,
            },
          })
        end,
        mode = "i",
        desc = "Complete line",
      },
      {
        "<c-i>",
        function()
          local actions = require("fzf-lua.actions")

          require("fzf-lua").fzf_complete(
            "rg --files | sed 's/.*/.\\/&/' && [[ -f package.json ]] && jq -r '.dependencies + .devDependencies | keys[]' package.json",
            {
              actions = {
                ["default"] = function(selected, opts)
                  local path = selected[1]
                  local basepath = vim.fn.fnamemodify(path, ":t:r")

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

                  local import_statement = "import " .. basepath .. " from '" .. module_path .. "'"
                  return actions.complete_insert({ import_statement }, opts)
                end,
              },
            }
          )
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
        "<Leader>g",
        function()
          require("fzf-lua").grep({
            search = "\\b" .. vim.fn.expand("<cword>") .. "\\b",
            no_esc = true,
          })
        end,
        desc = "Start search",
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

      vim.api.nvim_create_user_command("A", function(opts)
        local filename = vim.fn.expand("%")
        local basename = vim.fn.substitute(filename, "\\.[^/]*", "", "")
        local files_with_same_basename = vim.fn.glob(basename .. ".*", false, true)
        local alternate_files = vim.tbl_filter(function(f)
          return f ~= filename
        end, files_with_same_basename)

        if #alternate_files == 1 then
          vim.cmd("e " .. alternate_files[1])
        else
          require("fzf-lua").fzf_exec(alternate_files, {
            actions = require("fzf-lua").defaults.actions.files,
          })
        end
      end, { nargs = 0 })

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
