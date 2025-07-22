return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",

    enabled = false,

    opts = {
      model = "claude-3.7-sonnet",
      auto_insert_mode = false,
      window = {
        width = 0,
        height = 0,
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {
      strategies = {
        chat = {
          adapter = "anthropic",
        },
        inline = {
          adapter = "anthropic",
        },
        cmd = {
          adapter = "anthropic",
        },
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "cmd: secret-tool lookup service claude api-type token",
            },
          })
        end,
      },
      display = {
        chat = {
          window = {
            width = "auto",
          },
        },
      },
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            show_result_in_chat = true, -- Show mcp tool results in chat
            make_vars = true, -- Convert resources to #variables
            make_slash_commands = true, -- Add prompts as /slash commands
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
    },
  },
  {
    "mpataki/claudecode.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    specs = {
      {

        "refractalize/auto-save",
        opts = {
          ignore_files = {
            claudecode = function(bufno)
              local filename = vim.api.nvim_buf_get_name(bufno)
              return filename:match("%[Claude Code%]")
            end,
          },
        },
      },
    },
    opts = {
      enable_terminal = false,
    },
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCodeCopyCommand<cr>", desc = "Copy Claude Code Command" },
      { "<leader>as", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}
