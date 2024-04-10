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
        desc = "Toggle breakpoint",
      },
      {
        "<Leader>dr",
        function()
          require("dap").continue()
        end,
        desc = "Debugger continue",
      },
      {
        "<Leader>dl",
        function()
          require("dap").step_into()
        end,
        desc = "Debugger step into",
      },
      {
        "<Leader>dj",
        function()
          require("dap").step_over()
        end,
        desc = "Debugger step over",
      },
      {
        "<Leader>dh",
        function()
          require("dap").step_out()
        end,
        desc = "Debugger step out",
      },
    },

    config = function()
      local dap = require("dap")

      dap.set_log_level("DEBUG")

      dap.adapters.netcoredbg = {
        type = "executable",
        command = vim.fn.expand("~/src/netcoredbg/bin/netcoredbg"),
        args = { "--interpreter=vscode" },
      }

      dap.configurations.cs = {
        {
          type = "netcoredbg",
          name = "Test",
          request = "launch",
          program = "dotnet",
        },
        {
          type = "netcoredbg",
          name = "Launch WebApp",
          request = "launch",
          program = function()
            local debugDir = vim.fn.finddir("bin/Debug", ".;")
            local projectDir = vim.fn.fnamemodify(debugDir, ":h:h")
            local projectFile = vim.fn.glob(projectDir .. "/*.csproj")
            local projectName = vim.fn.fnamemodify(projectFile, ":t:r")
            local dllPath = vim.fn.findfile(projectName .. ".dll", debugDir .. "/**")
            local dllPathRelativeToProjectDir = string.sub(dllPath, #projectDir + 2, -1)

            return dllPathRelativeToProjectDir
          end,
          cwd = function()
            local debugDir = vim.fn.finddir("bin/Debug", ".;")
            local projectDir = vim.fn.fnamemodify(vim.fn.fnamemodify(debugDir, ":h:h"), ":p")
            return projectDir
          end,
        },
        {
          type = "netcoredbg",
          name = "attach - netcoredbg",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }

      vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939" })
      vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef" })
      vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379" })

      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "󰜴", texthl = "DapStopped", linehl = "", numhl = "" })

      local function get_breakpoint(buffer, line)
        local breakpoints = require("dap.breakpoints")
        local buffer_breakpoints = breakpoints.get(buffer)[buffer]
        local current_line = vim.fn.line(".")
        return vim.tbl_filter(function(b)
          return b.line == current_line
        end, buffer_breakpoints)[1]
      end

      vim.api.nvim_create_user_command("DapEditBreakpointCondition", function()
        local breakpoint = get_breakpoint(vim.fn.bufnr(), vim.fn.line("."))
        vim.ui.input(
          { prompt = "Breakpoint Condition: ", default = breakpoint and breakpoint.condition },
          function(condition)
            if condition then
              dap.set_breakpoint(condition)
            end
          end
        )
      end, {})

      vim.api.nvim_create_user_command("DapEditBreakpointLogMessage", function()
        local breakpoint = get_breakpoint(vim.fn.bufnr(), vim.fn.line("."))
        vim.ui.input(
          { prompt = "Breakpoint Log Message: ", default = breakpoint and breakpoint.logMessage },
          function(log_message)
            if log_message then
              dap.set_breakpoint(nil, nil, log_message)
            end
          end
        )
      end, {})
    end,
  },

  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = { "mfussenegger/nvim-dap" },

    config = function()
      require("dap-vscode-js").setup({
        -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
        -- debugger_path = "(runtimedir)/site/pack/packer/opt/vscode-js-debug", -- Path to vscode-js-debug installation.
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug", -- Path to vscode-js-debug installation.
        -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
        adapters = {
          "pwa-node",
          "pwa-chrome",
          "pwa-msedge",
          "node-terminal",
          "pwa-extensionHost",
        }, -- which adapters to register in nvim-dap
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
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },

    lazy = false,

    keys = {
      {
        "<Leader>de",
        function()
          require("dapui").eval(nil, { enter = true })
        end,
        desc = "Debug evaluate expression",
      },
      {
        "<Leader>de",
        function()
          require("dapui").eval(nil, { enter = true })
        end,
        desc = "Debug evaluate expression",
        mode = "v",
      },
      {
        "<Leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle debug UI",
      },
    },

    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup({
        layouts = {
          {
            elements = {
              {
                id = "scopes",
                size = 0.25,
              },
              {
                id = "breakpoints",
                size = 0.25,
              },
              {
                id = "stacks",
                size = 0.25,
              },
              {
                id = "watches",
                size = 0.25,
              },
            },
            position = "left",
            size = 100,
          },
          {
            elements = {
              {
                id = "repl",
                size = 0.5,
              },
              {
                id = "console",
                size = 0.5,
              },
            },
            position = "bottom",
            size = 10,
          },
        },
      })

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
