return {
  {
    "microsoft/vscode-js-debug",
    lazy = true,
    build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
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
        require("dap").configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Mocha Tests",
            -- trace = true, -- include debugger info
            runtimeExecutable = "node",
            runtimeArgs = {
              "./node_modules/mocha/bin/mocha.js",
              "--no-parallel",
              "${file}",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
          },
        }
      end
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    config = true,
  },
}
