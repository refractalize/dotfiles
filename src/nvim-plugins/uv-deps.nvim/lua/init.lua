local function find_repo_package_names(current_project_path)
  -- Ensure the current project file is passed as the first argument
  local script = vim.fs.joinpath(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h"), "pyproject_names.py")
  local cmd = { "python", script, current_project_path }
  local result = vim.fn.systemlist(cmd)

  if vim.v.shell_error ~= 0 or #result == 0 then
    vim.notify("Failed to retrieve package names from repository", vim.log.levels.ERROR)
    return
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(result, "\n"))
  if not ok or type(decoded) ~= "table" then
    vim.notify("Failed to decode package names from repository", vim.log.levels.ERROR)
    return
  end

  return decoded
end

local function select_repo_packages(added_packages, callback)
  local choices = {}

  for pkg_name, is_dependency in pairs(added_packages) do
    table.insert(choices, pkg_name)
  end

  table.sort(choices)

  vim.ui.select(choices, {
    prompt = "Select packages to add to repo:",
    format_item = function(item)
      local badge = added_packages[item] and "✔" or " "
      return badge .. " " .. item
    end,
  }, function(selected_package)
    if selected_package then
      local command = added_packages[selected_package] and "remove" or "add"
      callback(true, { command = command, package = selected_package })
    else
      callback(true, nil)
    end
  end)
end

local function run_in_terminal(bin, args, cwd)
  local cmd = vim.list_extend({ bin }, args or {})

  local ok, err = pcall(function()
    vim.cmd("belowright split")
    local term_buf = vim.api.nvim_create_buf(false, true)
    local term_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(term_win, term_buf)
    vim.fn.jobstart(cmd, {
      term = true,
      cwd = cwd,
      on_exit = function(_, code)
        if code == 0 and vim.api.nvim_win_is_valid(term_win) then
          vim.schedule(function()
            if vim.api.nvim_win_is_valid(term_win) then
              vim.api.nvim_win_close(term_win, true)
            end
          end)
        end
      end,
    })
  end)

  if not ok then
    vim.notify("Failed to run command: " .. err, vim.log.levels.ERROR)
  end
end

local function locate_current_project()
  local current_buf = vim.api.nvim_buf_get_name(0)
  local start_path = current_buf ~= "" and vim.fs.dirname(current_buf) or vim.fn.getcwd()
  local current_project = vim.fs.find("pyproject.toml", { path = start_path, type = "file", upward = true })[1]
  if not current_project then
    vim.notify("No pyproject.toml found in current directory or parent directories", vim.log.levels.ERROR)
    return
  end

  return current_project
end

local function set_repo_packages()
  local current_project = locate_current_project()
  if not current_project then
    return
  end

  local packages = find_repo_package_names(current_project)
  if not packages then
    return
  end

  if vim.tbl_isempty(packages.names) then
    vim.notify("No additional packages found in the repository", vim.log.levels.INFO)
    return
  end

  select_repo_packages(packages.names, function(ok, command)
    if not ok then
      return
    end

    if not command then
      return
    end

    local project_dir = vim.fn.fnamemodify(current_project, ":h")
    run_in_terminal(
      "uv",
      vim.list_extend({ command.command, "--package", packages.project_name }, { command.package }),
      project_dir
    )
  end)
end

local function add_package(package_name)
  if not package_name or package_name == "" then
    vim.notify("No package name provided", vim.log.levels.ERROR)
    return
  end

  local current_project = locate_current_project()
  if not current_project then
    return
  end

  local project_dir = vim.fn.fnamemodify(current_project, ":h")
  run_in_terminal("uv", { "add", package_name }, project_dir)
end

local function remove_package(package_name)
  if not package_name or package_name == "" then
    vim.notify("No package name provided", vim.log.levels.ERROR)
    return
  end

  local current_project = locate_current_project()
  if not current_project then
    return
  end

  local project_dir = vim.fn.fnamemodify(current_project, ":h")
  run_in_terminal("uv", { "remove", package_name }, project_dir)
end

local function setup()
  vim.api.nvim_create_user_command("UvSetRepoPackages", function()
    set_repo_packages()
  end, { nargs = 0 })
  vim.api.nvim_create_user_command("UvAddPackage", function(opts)
    add_package(opts.args)
  end, { nargs = 1 })
  vim.api.nvim_create_user_command("UvRemovePackage", function(opts)
    remove_package(opts.args)
  end, { nargs = 1 })
end

return {
  setup = setup,
  set_repo_packages = set_repo_packages,
  add_package = add_package,
  remove_package = remove_package,
}
