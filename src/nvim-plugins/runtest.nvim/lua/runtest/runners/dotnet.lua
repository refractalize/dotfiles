local csharp_ts = require("runtest.languages.csharp")
local utils = require("runtest.utils")

local M = {}

M.name = "dotnet"

M.file_patterns = {
  "\\v(\\f+):line (\\d+)",
  "\\v^(\\f+)\\((\\d+),(\\d+)\\):",
}

--- @returns string
local function buffer_csproj()
  local current_dir = vim.fn.expand("%:p:h")
  while current_dir ~= "/" do
    local csproj = vim.fn.glob(current_dir .. "/*.csproj")
    if csproj ~= "" then
      return csproj
    end
    current_dir = vim.fn.fnamemodify(current_dir, ":h")
  end

  error("No .csproj file found")
end

--- @param profile Profile
--- @param command [string[], { env: table<string, string>, pty: boolean, on_stdout: fun(data: string[]) }]
--- @returns fun(cb: fun(err: any, result: dap.Configuration))
local function start_debugger(profile, command)
  return function(runner, cb)
    local stdout = { "" }
    local launched_debugger = false

    runner:run_job(profile, {
      command[1],
      vim.tbl_deep_extend("force", command[2] or {}, {
        env = { ["VSTEST_HOST_DEBUG"] = "1" },
        pty = true,
        on_stdout = function(_, data)
          if launched_debugger then
            return
          end

          stdout[#stdout] = stdout[#stdout] .. data[1]

          for i = 2, #data do
            table.insert(stdout, data[i])
          end

          for _, line in ipairs(stdout) do
            local dotnet_test_pid = string.match(line, "Process Id%p%s(%d+)")

            if dotnet_test_pid ~= nil then
              launched_debugger = true
              runner:debug(profile, {
                type = "netcoredbg",
                name = "attach - netcoredbg",
                request = "attach",
                processId = dotnet_test_pid,
              })
            end
          end
        end,
      }),
    })
  end
end

--- @param command string
--- @param runner_config RunnerConfig
--- @param start_config StartConfig
--- @returns string[]
local function dotnet(command, runner_config, args, start_config)
  return {
    utils.build_command_line({ "dotnet", command }, args, runner_config.args, start_config.args),
    { env = { ["DOTNET_SYSTEM_CONSOLE_ALLOW_ANSI_COLOR_REDIRECTION"] = "true" } },
  }
end

--- @param runner_config RunnerConfig
--- @param start_config StartConfig
--- @returns string[]
local function dotnet_test(runner_config, args, start_config)
  return dotnet("test", runner_config, args, start_config)
end

--- @param args string[] | nil
--- @returns Profile
local function dotnet_test_profile(runner_config, args)
  args = args or {}
  table.insert(args, 1, buffer_csproj())

  local P = {}

  P.runner = M

  function P.debug_spec(start_config)
    return start_debugger(P, dotnet_test(runner_config, args, start_config))
  end

  function P.run_spec(start_config)
    return dotnet_test(runner_config, args, start_config)
  end

  return P
end

--- @param args string[] | nil
--- @returns Profile
local function dotnet_build_profile(runner_config, args)
  args = args or {}

  local P = {}

  P.runner = M

  function P.run_spec(start_config)
    return dotnet("build", runner_config, args, start_config)
  end

  return P
end

--- @returns Profile
function M.line_tests(runner_config)
  return dotnet_test_profile(runner_config, {
    "--filter",
    "FullyQualifiedName~" .. csharp_ts.line_tests(),
  })
end

--- @returns Profile
function M.file_tests(runner_config)
  return dotnet_test_profile(runner_config, {
    "--filter",
    vim.fn.join(
      vim.tbl_map(function(class_name)
        return 'FullyQualifiedName~"' .. class_name .. '"'
      end, csharp_ts.file_tests()),
      " | "
    ),
  })
end

--- @returns Profile
function M.all_tests(runner_config)
  return dotnet_test_profile(runner_config, {})
end

--- @returns Profile
function M.build(runner_config)
  return dotnet_build_profile(runner_config, {})
end

return M
