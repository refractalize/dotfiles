local python_ts = require("runtest.languages.python")
local utils = require("runtest.utils")

local M = {}

M.file_patterns = {
  '\\vFile "(\\f+)",\\s*line\\s*(\\d+),',
  "\\v^(\\f+):(\\d+)",
}

M.name = 'pytest'

--- @param runner_config RunnerConfig
--- @param args string[]
--- @param start_config StartConfig
local function pytest_args(runner_config, args, start_config)
  return utils.build_command_line({ "--color=yes" }, args, runner_config.args, start_config.args)
end

local function run_pytest(runner_config, args, start_config)
  return {
    utils.build_command_line({ "python", "-m", "pytest" }, pytest_args(runner_config, args, start_config)),
  }
end

local function debug_pytest(runner_config, args, start_config)
  return {
    type = "python",
    request = "launch",
    module = "pytest",
    args = pytest_args(runner_config, args, start_config),
  }
end

local function pytest_profile(runner_config, args)
  return {
    runner_config = M,
    debug_spec = function(start_config)
      return debug_pytest(runner_config, args, start_config)
    end,
    run_spec = function(start_config)
      return run_pytest(runner_config, args, start_config)
    end,
  }
end

--- @param runner_config RunnerConfig
--- @returns Profile
function M.line_tests(runner_config)
  local filename = vim.fn.expand("%:p")
  local test_pattern = vim.list_extend({ filename }, python_ts.test_path())
  local args = { vim.fn.join(test_pattern, "::") }

  return pytest_profile(runner_config, args)
end

--- @param runner_config RunnerConfig
--- @returns Profile
function M.all_tests(runner_config)
  return pytest_profile(runner_config, {})
end

--- @param runner_config RunnerConfig
--- @returns Profile
function M.file_tests(runner_config)
  local filename = vim.fn.expand("%:p")
  local args = { filename }

  return pytest_profile(runner_config, args)
end

return M
