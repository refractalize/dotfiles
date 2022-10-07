local namespace = vim.api.nvim_create_namespace('difflines')

local last_range

local RangeLines = {}

function RangeLines:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local Range = {}

function Range:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function show_diff(left, right)
  vim.cmd('tabnew')
  local left_lines = left:lines()
  local right_lines = right:lines()
  local single_line = left_lines:single_line() and right_lines:single_line()

  left_lines:setup_buffer()

  if single_line then
    vim.cmd('new')
  else
    vim.cmd('vertical new')
  end

  right_lines:setup_buffer()

  require('utils').close_tab_when_any_window_is_closed({
    on_closed = function()
      left:clear()
      right:clear()
    end
  })
end

function Range:lines()
  local start_position = vim.api.nvim_buf_get_extmark_by_id(self.buffer, namespace, self.start_extmark, {})
  local start_line = start_position[1]
  local end_position = vim.api.nvim_buf_get_extmark_by_id(self.buffer, namespace, self.end_extmark, {})
  local end_line = end_position[1]

  return RangeLines:new {
    start_line = start_line,
    end_line = end_line,
    lines = vim.api.nvim_buf_get_lines(self.buffer, start_line, end_line + 1, true),
    range = self
  }
end

function RangeLines:single_line()
  return self.start_line == self.end_line
end

function Range:clear()
  vim.api.nvim_buf_del_extmark(self.buffer, namespace, self.start_extmark)
  vim.api.nvim_buf_del_extmark(self.buffer, namespace, self.end_extmark)
end

function RangeLines:setup_buffer()
  vim.api.nvim_buf_set_option(0, 'filetype', vim.api.nvim_buf_get_option(self.range.buffer, 'filetype'))
  vim.api.nvim_buf_set_name(0, vim.api.nvim_buf_get_name(self.range.buffer) .. ':' .. self.start_line .. '-' .. self.end_line)
  vim.api.nvim_buf_set_lines(0, 0, -1, true, self.lines)
  vim.cmd('diffthis')
end

function create_range(buffer, start_line, end_line)
  if start_line == end_line then
    local extmark = create_extmark(buffer, start_line, '→')

    return Range:new {
      buffer = buffer,
      start_extmark = extmark,
      end_extmark = extmark
    }
  else
    return Range:new {
      buffer = buffer,
      start_extmark = create_extmark(buffer, start_line, '↱'),
      end_extmark = create_extmark(buffer, end_line, '↳')
    }
  end
end

function create_extmark(buffer, line, sign_text)
  return vim.api.nvim_buf_set_extmark(
    buffer,
    namespace,
    line - 1,
    0,
    {
      sign_text = sign_text,
      sign_hl_group = 'Question'
    }
  )
end

function clear_first_range()
  vim.api.nvim_buf_clear_namespace(first_range.buffer, namespace, 0, -1)
  first_range = nil
end

function select_lines(start_line, end_line)
  if last_range then
    local range = create_range(
      vim.api.nvim_get_current_buf(),
      start_line,
      end_line
    )

    show_diff(last_range, range)
    last_range = nil
  else
    last_range = create_range(
      vim.api.nvim_get_current_buf(),
      start_line,
      end_line
    )
  end
end

function select_range(range, start_line, end_line)
  if range == 2 then
    select_lines(start_line, end_line)
  elseif range == 1 then
    select_lines(start_line, start_line)
  else
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    select_lines(current_line, current_line)
  end
end

function reset_range()
  if last_range then
    last_range:clear()
    last_range = nil
  end
end

return {
  select_range = select_range,
  reset_range = reset_range
}
