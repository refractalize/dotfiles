local javascript_ts = require("runtest.languages.javascript")

--- @class JestProfile: Profile
--- @field cwd string

--- @class M: RunnerConfig
local M = {
  name = "jest",
  file_patterns = {
    --- @param profile JestProfile
    --- @param line string
    function(profile, line)
      local matches = vim.fn.matchlist(line, "\\v(\\f+):(\\d+):(\\d+)")
      if matches[1] ~= nil then
        matches[2] = profile.cwd .. "/" .. matches[2]
        return matches
      end
    end,
  },
}

function get_node_root_directory()
  local node_modules = vim.fn.finddir("node_modules", ".;")

  if node_modules then
    return vim.fn.fnamemodify(node_modules, ":h")
  end
end

--- @param args string[]
--- @param start_config StartConfig
--- @param cwd string
function run_jest(args, start_config, cwd)
  return {
    vim.list_extend({ "npm", "exec", "--", "jest" }, vim.list_extend(start_config.args or {}, args or {})),
    {
      env = { ["FORCE_COLOR"] = "true" },
      cwd = cwd,
    },
  }
end

function debug_jest(args, start_config)
  return {
    type = "pwa-node",
    request = "launch",
    name = "Debug Jest Tests",
    trace = true, -- include debugger info
    runtimeExecutable = "node",
    runtimeArgs = vim.list_extend(
      { "./node_modules/jest/bin/jest.js", "--runInBand" },
      vim.list_extend(start_config.args or {}, args or {})
    ),
    rootPath = "${workspaceFolder}",
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    internalConsoleOptions = "neverOpen",
  }
end

--- @param args string[]
--- @return JestProfile
function jest_profile(args)
  local cwd = get_node_root_directory()
  return {
    runner_config = M,
    cwd = cwd,
    --- @param start_config StartConfig
    debug_spec = function(start_config)
      return debug_jest(args, start_config)
    end,
    --- @param start_config StartConfig
    run_spec = function(start_config)
      return run_jest(args, start_config, cwd)
    end,
  }
end

--- @param runner_config RunnerConfig
--- @returns Profile
function M.all_tests(runner_config)
  return jest_profile({})
end

--- @param runner_config RunnerConfig
--- @returns Profile
function M.line_tests(runner_config)
  local test_context = javascript_ts.line_tests()
  local pattern = vim.fn.join(test_context, " ")
  local test_filename = vim.fn.expand("%:p")
  return jest_profile({ test_filename, "--testNamePattern", pattern })
end

--- @param runner_config RunnerConfig
--- @returns Profile
function M.file_tests(runner_config)
  local test_filename = vim.fn.expand("%:p")

  return jest_profile({ test_filename })
end

return M
