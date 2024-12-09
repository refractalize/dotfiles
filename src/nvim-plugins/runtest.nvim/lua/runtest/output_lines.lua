local OutputLines = {}
OutputLines.__index = OutputLines

function OutputLines:new(clean_data)
  local self = setmetatable({}, OutputLines)
  self.clean_data = clean_data or function(data)
    return data
  end
  self.lines = { "" }
  return self
end

function OutputLines:append(lines)
  self.lines[#self.lines] = self.lines[#self.lines] .. self.clean_data(lines[1])

  for i = 2, #lines do
    local d = self.clean_data(lines[i])
    table.insert(self.lines, d)
  end
end

function OutputLines:get_lines()
  if self.removed_last_empty_line then
    return self.lines
  end

  if self.lines[#self.lines] == "" then
    table.remove(self.lines, #self.lines)
  end

  self.removed_last_empty_line = true

  return self.lines
end

return OutputLines
