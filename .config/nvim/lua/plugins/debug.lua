return {
  {
    "mfussenegger/nvim-dap",

    keys = {
      {
        "<leader>td",
        false,
      },
      {
        "<leader>dn",
        function()
          require("dap").step_over()
        end,
        desc = "Debugger Step Over",
      },
    },

    dependencies = {
      {
        "Joakker/lua-json5",
        build = "./install.sh",
      },
    },

    opts = function()
      -- require("dap.ext.vscode").json_decode = require("json5").parse
    end,
  },

  {
    "Cliffback/netcoredbg-macOS-arm64.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    cond = function()
      return vim.fn.has("mac") == 1 and vim.fn.systemlist("uname -m")[1] == "arm64"
    end,
    config = function()
      require("netcoredbg-macOS-arm64").setup(require("dap"))
    end,
  },
}
