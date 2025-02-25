local utils = require("runtest.utils")
local ruby_ts = require("runtest.languages.ruby")

--- @class RailsRunnerConfig: RunnerConfig
local M = {}

M.name = "rails"

--- @param command string
--- @param runner_config RunnerConfig
--- @param args string[]
--- @param start_config StartConfig
--- @returns RunSpec
local function rails_command(command, runner_config, args, start_config)
  return {
    utils.build_command_line({ "rails", command, '--color' }, args, runner_config.args, start_config.args),
  }
end

local function rails_debug(command, runner_config, args, start_config)
  return {
    type = "ruby",
    request = "attach",
    name = "Attach to Rails",
    localfs = true,
    command = "bundle",
    random_port = true,
    args = utils.build_command_line({ "exec", "rails", command }, args, runner_config.args, start_config.args),
  }
end

--- @param runner_config RunnerConfig
--- @param args string[]
--- @returns Profile
local function rails_test_profile(runner_config, args)
  args = args or {}

  local P = {}

  P.runner_config = M

  function P.run_spec(start_config)
    return rails_command("test", runner_config, args, start_config)
  end

  function P.debug_spec(start_config)
    return rails_debug("test", runner_config, args, start_config)
  end

  return P
end

--- @param runner_config RunnerConfig
--- @returns Profile
function M.all_tests(runner_config)
  return rails_test_profile(runner_config, {})
end

--- @param runner_config RunnerConfig
--- @returns Profile
function M.line_tests(runner_config)
  local filename = vim.fn.expand("%:p")
  local names = vim.iter(ruby_ts.line_tests()):map(function(name)
    return { '--name', name }
  end):flatten():totable()
  local args = vim.list_extend({ filename }, names)
  return rails_test_profile(runner_config, args)
end

--- @param runner_config RunnerConfig
--- @returns Profile
function M.file_tests(runner_config)
  local filename = vim.fn.expand("%:p")
  return rails_test_profile(runner_config, { filename })
end

return M
