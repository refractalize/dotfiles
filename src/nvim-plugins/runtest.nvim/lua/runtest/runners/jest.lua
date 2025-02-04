local javascript_ts = require("runtest.languages.javascript")

local M = {}

function run_jest(args, run_config)
  return {
    vim.list_extend({ "npm", "exec", "jest" }, vim.list_extend(run_config.args or {}, args or {})),
    {
      env = { ["FORCE_COLOR"] = "true" },
    },
  }
end

function debug_jest(args, run_config)
  return {
    type = "pwa-node",
    request = "launch",
    name = "Debug Jest Tests",
    trace = true, -- include debugger info
    runtimeExecutable = "node",
    runtimeArgs = vim.list_extend({ "./node_modules/jest/bin/jest.js", "--runInBand" }, vim.list_extend(run_config.args or {}, args or {})),
    rootPath = "${workspaceFolder}",
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    internalConsoleOptions = "neverOpen",
  }
end

function jest_profile(args)
  return {
    runner_config = M,
    debug_spec = function(run_config)
      return debug_jest(args, run_config)
    end,
    run_spec = function(run_config)
      return run_jest(args, run_config)
    end,
  }
end

function M.line_tests()
  local test_context = javascript_ts.line_tests()
  local pattern = vim.fn.join(test_context, " ")
  local test_filename = vim.fn.expand("%:p")
  return jest_profile({ test_filename, "--testNamePattern", pattern })
end

return M
