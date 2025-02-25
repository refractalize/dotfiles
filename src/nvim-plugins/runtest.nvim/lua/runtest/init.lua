local namespace_name = "runtest"
local ns_id = vim.api.nvim_create_namespace(namespace_name)
local OutputWindow = require("runtest.output_window")
local OutputLines = require("runtest.output_lines")
local window_layout = require("runtest.window_layout")

--- @class StartConfig
--- @field debugger? boolean
--- @field args? string[]

--- @alias RunSpec [string[], table?]

--- @class Profile
--- @field debug_spec (fun(start_config: StartConfig, runner: Runner): dap.Configuration)
--- @field run_spec (fun(start_config: StartConfig, runner: Runner): RunSpec)
--- @field runner_config RunnerConfig

--- @class RunnerConfig
--- @field args string[]
--- @field name string
--- @field file_patterns string[]
--- @field line_tests fun(): Profile
--- @field all_tests fun(): Profile
--- @field file_tests fun(): Profile

local exec_no_tty = debug.getinfo(1, "S").source:sub(2):match("(.*/)") .. "exec-no-tty"

local M = {}

local function handle_error(err)
  if type(err) == "table" and type(err.message) == "string" then
    vim.notify(err.message, err.level or vim.log.levels.ERROR)
  else
    vim.notify("Error: " .. err, vim.log.levels.ERROR)
    error(err)
  end
end

--- @class Runner
--- @field output_window OutputWindow
--- @field last_profile Profile | nil
--- @field last_buffer number | nil
--- @field last_ext_mark number | nil
--- @field terminal_buf number | nil
local Runner = {}
Runner.__index = Runner

function Runner.new()
  local self = setmetatable({}, Runner)
  self.output_window = nil
  self.config = {
    windows = {
      output = {
        vertical = true,
      },
      terminal = {
        vertical = false,
        size = 0.25,
        min = 10,
        max = 40,
      },
    },
    filetypes = {
      cs = require("runtest.runners.dotnet"),
      ruby = require('runtest.runners.rails'),
      python = require("runtest.runners.pytest"),
      typescriptreact = require("runtest.runners.jest"),
      typescript = require("runtest.runners.jest"),
      javascriptreact = require("runtest.runners.jest"),
      javascript = require("runtest.runners.jest"),
    },
  }
  return self
end

function Runner:setup(config)
  self.config = vim.tbl_deep_extend("force", self.config, config)
  M.config = self.config
end

--- @param profile Profile
function Runner:set_last_profile(profile)
  if self.last_ext_mark ~= nil then
    if self.last_buffer ~= nil and vim.api.nvim_buf_is_valid(self.last_buffer) then
      vim.api.nvim_buf_del_extmark(self.last_buffer, ns_id, self.last_ext_mark)
    end
  end

  self.last_profile = profile
  self.last_buffer = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  self.last_ext_mark = vim.api.nvim_buf_set_extmark(self.last_buffer, ns_id, cursor[1] - 1, cursor[2], {})
end

--- @param profile Profile
--- @param debug_spec dap.Configuration
function Runner:debug(profile, debug_spec)
  local dap = require("dap")
  local listen = type(debug_spec) == 'table' and debug_spec.request ~= "attach"

  local output_lines = OutputLines:new()

  dap.listeners.before["event_exited"][namespace_name] = function(_session, body)
    if listen then
      self:tests_finished(body.exitCode, output_lines:get_lines(), profile.runner_config.file_patterns)
    end
  end

  dap.listeners.before["event_output"][namespace_name] = function(_session, body)
    if listen then
      if body.category == "stdout" or body.category == "stderr" then
        output_lines:append(vim.fn.split(body.output, "\n", true))
      end
    end
  end

  dap.run(debug_spec)
end

--- @param exit_code number
--- @param output_lines string[]
--- @param file_patterns string[]
--- @param detail_lines? string[]
function Runner:tests_finished(exit_code, output_lines, file_patterns, detail_lines)
  if exit_code == 0 then
    vim.notify("Tests passed", vim.log.levels.INFO)
  else
    vim.notify("Tests failed", vim.log.levels.ERROR)
  end

  local output_window = self:get_output_window()
  output_window:set_lines(vim.list_extend(detail_lines or {}, output_lines), file_patterns)
end

--- @param job_spec RunSpec
--- @returns string[]
local function render_command_line(job_spec)
  local env = (job_spec[2] or {}).env
  local env_str = env
    and vim.fn.join(
      vim.tbl_map(function(key)
        return key .. "=" .. vim.fn.shellescape(env[key])
      end, vim.tbl_keys(env)),
      " "
    )
  local command_str = vim.fn.join(vim.tbl_map(function(arg)
    return vim.fn.shellescape(arg)
  end, job_spec[1]))

  return { env_str and env_str .. " " .. command_str or command_str }
end

--- @param job_spec RunSpec
local function parse_job_spec(job_spec)
  if type(job_spec) ~= "table" then
    error("expected run_spec to be a table, got " .. type(job_spec))
  end

  if type(job_spec[1]) ~= "table" then
    error("expected run_spec[1] to be a table, got " .. type(job_spec[1]))
  end

  if vim.iter(job_spec[1]):any(function(arg)
    return type(arg) ~= "string"
  end) then
    error("expected run_spec[1] to be a list of strings")
  end

  return job_spec
end

--- @param profile Profile
--- @param job_spec RunSpec
function Runner:run_terminal(profile, job_spec)
  job_spec = parse_job_spec(job_spec)

  local output_lines = OutputLines:new(function(data)
    return data:gsub("\r$", ""):gsub("\x1b%[%?1h\x1b=", "")
  end)
  local current_window = vim.api.nvim_get_current_win()

  local win, buf = window_layout.new_window(self.config.windows.terminal)
  self.terminal_win = win
  self.terminal_buf = buf

  local function on_data(_, data)
    output_lines:append(data)
  end

  local on_exit = function(_, exit_code)
    vim.api.nvim_buf_delete(self.terminal_buf, { force = true })
    self.terminal_buf = nil
    self.terminal_win = nil

    self:tests_finished(
      exit_code,
      output_lines:get_lines(),
      profile.runner_config.file_patterns,
      render_command_line(job_spec)
    )
  end

  local no_tty_command = vim.list_extend({ exec_no_tty }, job_spec[1])
  vim.fn.termopen(
    no_tty_command,
    vim.tbl_extend("force", job_spec[2] or {}, {
      on_exit = on_exit,
      stdout_buffered = true,
      on_stdout = on_data,
    })
  )

  vim.api.nvim_set_current_win(current_window)
end

local function combine(fn1, fn2)
  return function(...)
    fn1(...)
    fn2(...)
  end
end

local function optional_combine(fn1, fn2)
  if fn2 == nil then
    return fn1
  else
    return combine(fn1, fn2)
  end
end

--- @param profile Profile
--- @param job_spec RunSpec
function Runner:run_job(profile, job_spec)
  job_spec = parse_job_spec(job_spec)

  local output_lines = OutputLines:new(function(data)
    return data:gsub("\r$", "")
  end)

  local function on_data(_, data)
    output_lines:append(data)
  end

  local on_exit = function(_, exit_code)
    self:tests_finished(exit_code, output_lines:get_lines(), profile.runner_config.file_patterns)
  end

  local no_tty_command = vim.list_extend({ exec_no_tty }, job_spec[1])

  local job_spec_options = job_spec[2] or {}

  local options = vim.tbl_extend("force", job_spec_options, {
    on_exit = optional_combine(on_exit, job_spec_options.on_exit),
    on_stdout = optional_combine(on_data, job_spec_options.on_stdout),
    on_stderr = optional_combine(on_data, job_spec_options.on_stderr),
  })

  vim.fn.jobstart(no_tty_command, options)
end

--- @return OutputWindow
function Runner:get_output_window()
  if self.output_window == nil then
    self.output_window = OutputWindow:new()
  end

  return self.output_window
end

--- @param new_window_command string
function Runner:open_terminal_window(new_window_command)
  if
    self.terminal_win
    and vim.api.nvim_win_is_valid(self.terminal_win)
    and vim.api.nvim_win_get_buf(self.terminal_win) == self.terminal_buf
  then
    vim.api.nvim_set_current_win(self.terminal_win)
  elseif self.terminal_buf then
    vim.cmd(new_window_command)
    vim.api.nvim_set_current_buf(self.terminal_buf)
  end
end

--- @param runner_config RunnerConfig
local function validate_runner_config(runner_config)
  if type(runner_config.name) ~= "string" then
    error({ message = "RunnerConfig.name must be a string", level = vim.log.levels.ERROR })
  end
end

--- @return RunnerConfig
function Runner:runner_config()
  local filetype = vim.bo.filetype
  local runner_config = self.config.filetypes[filetype]

  if runner_config == nil then
    error({ message = "No test runner configured for " .. filetype, level = vim.log.levels.WARN })
  end

  validate_runner_config(runner_config)

  return runner_config
end

--- @param profile Profile
--- @param start_config StartConfig
function Runner:start_profile(profile, start_config)
  if start_config.debugger then
    local debug_spec = profile.debug_spec(start_config, self)
    self:debug(profile, debug_spec)
  else
    local run_spec = profile.run_spec(start_config, self)
    self:run_terminal(profile, run_spec)
  end
end

--- @param start_config StartConfig | nil
--- @return StartConfig
local function parse_start_config(start_config)
  return vim.tbl_extend("force", {
    debugger = false,
    args = {},
  }, start_config or {})
end

--- @param profile_name string
--- @return Profile
function Runner:resolve_profile(profile_name)
  local runner_config = self:runner_config()

  local profile_fn = runner_config[profile_name]

  if not profile_fn then
    error({
      message = "No profile " .. profile_name .. " for runner " .. runner_config.name,
      level = vim.log.levels.WARN,
    })
  end

  return profile_fn(runner_config)
end

--- @param profile_name string
--- @param start_config StartConfig | nil
function Runner:start_profile_name(profile_name, start_config)
  start_config = parse_start_config(start_config)

  local profile = self:resolve_profile(profile_name)

  self:set_last_profile(profile)

  self:start_profile(profile, start_config)
end

--- @param profile_name string
--- @param start_config StartConfig | nil
function Runner:get_profile_command(profile_name, start_config)
  start_config = parse_start_config(start_config)

  local profile = self:resolve_profile(profile_name)

  return profile.run_spec(start_config, self)
end

--- @param start_config StartConfig | nil
function Runner:debug_last(start_config)
  if start_config then
    start_config.debugger = true
  else
    start_config = { debugger = true }
  end

  self:run_last(start_config)
end

--- @param start_config StartConfig | nil
function Runner:run_last(start_config)
  if self.last_profile == nil then
    error({ message = "No last test", level = vim.log.levels.INFO })
  end

  self:start_profile(self.last_profile, parse_start_config(start_config))
end

function Runner:goto_last()
  if self.last_profile == nil then
    error({ message = "No last test", level = vim.log.levels.INFO })
  end

  vim.api.nvim_set_current_buf(self.last_buffer)
  local extmark_pos = vim.api.nvim_buf_get_extmark_by_id(self.last_buffer, ns_id, self.last_ext_mark, {})
  vim.api.nvim_win_set_cursor(0, { extmark_pos[1] + 1, extmark_pos[2] })
end

local runner = Runner.new()

--- @generic T
--- @param fn fun(): T?
--- @return T?
local function error_wrapper(fn)
  local status, result = xpcall(function()
    return fn()
  end, function(err)
    return debug.traceback(err, 2)
  end)

  if not status then
    handle_error(result)
  else
    return result
  end
end

function M.setup(config)
  runner:setup(config)
end

--- @param new_window_command string|nil The VIM command to run to create the window, default's to `vsplit`
function M.open_output(new_window_command)
  runner:get_output_window():open(new_window_command or "vsplit")
end

--- @param new_window_command string|nil The VIM command to run to create the window, default's to `split`
function M.open_terminal(new_window_command)
  runner:open_terminal_window(new_window_command or "split")
end

for _, profile_name in ipairs({ "line_tests", "all_tests", "file_tests", "lint", "build" }) do
  M["run_" .. profile_name] = function(start_config)
    error_wrapper(function()
      runner:start_profile_name(profile_name, start_config)
    end)
  end
  M["get_" .. profile_name .. "_command"] = function(start_config)
    return error_wrapper(function()
      return runner:get_profile_command(profile_name, start_config)
    end)
  end
end

for _, profile_name in ipairs({ "line_tests", "all_tests", "file_tests" }) do
  M["debug_" .. profile_name] = function(start_config)
    error_wrapper(function()
      runner:start_profile_name(
        profile_name,
        vim.tbl_extend("force", start_config or {}, { debugger = true })
      )
    end)
  end
end

function M.run_last(start_config)
  error_wrapper(function()
    runner:run_last(start_config)
  end)
end

function M.debug_last(start_config)
  error_wrapper(function()
    runner:debug_last(start_config)
  end)
end

function M.goto_last()
  error_wrapper(function()
    runner:goto_last()
  end)
end

--- @return Profile | nil
function M.last_profile()
  return runner.last_profile
end

function M.goto_next_entry()
  error_wrapper(function()
    runner:get_output_window():goto_next_entry()
  end)
end

function M.goto_previous_entry()
  error_wrapper(function()
    runner:get_output_window():goto_previous_entry()
  end)
end

function M.send_entries_to_quickfix()
  error_wrapper(function()
    local entries = runner:get_output_window().entries
    local quickfix_entries = vim
      .iter(entries)
      :map(function(entry)
        return {
          filename = entry.filename,
          lnum = entry.line_number,
          col = entry.column_number,
          text = entry.output_line,
        }
      end)
      :totable()
    vim.fn.setqflist(quickfix_entries, "r")
  end)
end

function M.send_entries_to_fzf()
  error_wrapper(function()
    local fzf_lua = require("fzf-lua")
    local entries = runner:get_output_window().entries
    local fzf_entries = vim
      .iter(entries)
      :map(function(entry)
        return entry.filename .. ":" .. entry.line_number .. ":" .. entry.column_number
      end)
      :totable()
    fzf_lua.fzf_exec(fzf_entries, {
      fzf_opts = {
        ["--no-sort"] = "",
      },
      fn_transform = function(x)
        return fzf_lua.make_entry.file(x, { file_icons = true, color_icons = true })
      end,
      actions = fzf_lua.config.globals.actions.files,
      previewer = "builtin",
    })
  end)
end

return M
