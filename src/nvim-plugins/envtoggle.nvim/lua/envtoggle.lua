local environment_variables = {}

local function environment_variable_names()
  local names = {}

  for name, value in pairs(config.environment_variables) do
    if type(name) == "string" then
      table.insert(names, name)
    else
      table.insert(names, value)
    end
  end

  return names
end

local function setup(c)
  config = vim.tbl_deep_extend("force", {
    environment_variables = {}
  }, c)

  for name, value in pairs(config.environment_variables) do
    if type(name) == "string" then
      environment_variables[name] = value
    else
      environment_variables[value] = "true"
    end
  end
end

local function is_variable_set(variable_name)
  local value = vim.fn.getenv(variable_name)
  return (value ~= "" and value ~= nil and value ~= vim.NIL)
end

local function toggle_environment_variable(name)
  if is_variable_set(name) then
    vim.fn.setenv(name, nil)
    vim.notify("Environment variable '" .. name .. "' unset", vim.log.levels.INFO)
  else
    vim.fn.setenv(name, config.environment_variables[name] or "true")
    vim.notify("Environment variable '" .. name .. "' set", vim.log.levels.INFO)
  end
end

local function select_environment_variable()
  vim.ui.select(vim.tbl_keys(environment_variables), {
    prompt = "Toggle environment variable",
    format_item = function(item)
      local badge = is_variable_set(item) and "✔" or " "
      return badge .. " " .. item
    end,
  }, function(selected)
    if selected then
      toggle_environment_variable(selected)
    end
  end)
end

return {
  setup = setup,
  select_environment_variable = select_environment_variable,
  toggle_environment_variable = toggle_environment_variable,
}
