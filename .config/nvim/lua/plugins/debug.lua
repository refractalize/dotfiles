return {
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
}
