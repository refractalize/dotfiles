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
