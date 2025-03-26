--- @param ... table
local function build_command_line(...)
  local command_line = {}


  for i, arguments in pairs({ ... }) do
    for i, arg in pairs(arguments or {}) do
      if type(i) == "string" then
        if type(arg) == "boolean" then
          if arg then
            table.insert(command_line, i)
          end
        else
          table.insert(command_line, i)
          table.insert(command_line, arg)
        end
      else
        table.insert(command_line, arg)
      end
    end
  end

  return command_line
end

return {
  build_command_line = build_command_line,
}
