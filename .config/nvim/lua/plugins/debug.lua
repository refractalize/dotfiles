function mochaTestConfig(args)
  args = args or {}

  local runtimeArgs = {
    "./node_modules/mocha/bin/mocha.js",
    "--no-parallel",
    "${file}",
    unpack(args),
  }

  return {
    type = "pwa-node",
    request = "launch",
    name = "Debug Mocha Tests",
    -- trace = true, -- include debugger info
    runtimeExecutable = "node",
    runtimeArgs = runtimeArgs,
    rootPath = "${workspaceFolder}",
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    internalConsoleOptions = "neverOpen",
  }
end

return {
  {
    "microsoft/vscode-js-debug",
    lazy = true,
    build = "npm ci --legacy-peer-deps && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
  },

  {
    "mfussenegger/nvim-dap",

    lazy = false,

    keys = {
      {
        "<Leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        "Toggle breakpoint",
      },
      {
        "<Leader>dr",
        function()
          require("dap").continue()
        end,
        "Debugger continue",
      },
      {
        "<Leader>dt",
        function()
          local args = require("mocha_nearest_test").mocha_nearest_test_grep()
          require("dap").run(mochaTestConfig(args))
        end,
        "Debugger continue",
      },
      {
        "<Leader>dl",
        function()
          require("dap").step_into()
        end,
        "Debugger step into",
      },
      {
        "<Leader>dj",
        function()
          require("dap").step_over()
        end,
        "Debugger step over",
      },
      {
        "<Leader>dh",
        function()
          require("dap").step_out()
        end,
        "Debugger step out",
      },
    },

    config = function()
      vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939", bg = "#31353f" })
      vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef", bg = "#31353f" })
      vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379", bg = "#31353f" })

      vim.fn.sign_define(
        "DapBreakpoint",
        { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
      )
      vim.fn.sign_define(
        "DapBreakpointCondition",
        { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
      )
      vim.fn.sign_define(
        "DapBreakpointRejected",
        { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
      )
      vim.fn.sign_define(
        "DapLogPoint",
        { text = "", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "DapLogPoint" }
      )
      vim.fn.sign_define(
        "DapStopped",
        { text = "⮕", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" }
      )
    end,
  },

  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = { "mfussenegger/nvim-dap" },

    config = function()
      require("dap-vscode-js").setup({
        -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
        -- debugger_path = "(runtimedir)/site/pack/packer/opt/vscode-js-debug", -- Path to vscode-js-debug installation.
        debugger_path = "/Users/tim/.local/share/nvim/lazy/vscode-js-debug", -- Path to vscode-js-debug installation.
        -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
        -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
        -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
        -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
      })

      for _, language in ipairs({ "typescript", "javascript" }) do
        require("dap").configurations[language] = { mochaTestConfig() }
      end
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },

    lazy = false,

    keys = {
      {
        "<Leader>de",
        function()
          require("dapui").eval(nil, { enter = true })
        end,
        "Debug evaluate expression",
      },
      {
        "<Leader>de",
        function()
          require("dapui").eval(nil, { enter = true })
        end,
        "Debug evaluate expression",
        mode = "v",
      },
    },

    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  {
    "theHamsta/nvim-dap-virtual-text",

    config = true,
  },
}
