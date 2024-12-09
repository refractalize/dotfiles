local function get_last_visual_range()
  return {
    start_position = vim.fn.getpos("'<"),
    end_position = vim.fn.getpos("'>"),
    mode = vim.fn.visualmode(),
  }
end

local function get_current_visual_range(mode)
  local mode = vim.fn.mode()

  if mode ~= "v" and mode ~= "V" and mode ~= "" then
    return nil
  end

  local start_position = vim.fn.getpos("v")
  local end_position = vim.fn.getpos(".")

  if
    start_position[2] > end_position[2]
    or (start_position[2] == end_position[2] and start_position[3] > end_position[3])
  then
    start_position, end_position = end_position, start_position
  end

  return {
    start_position = start_position,
    end_position = end_position,
    mode = mode,
  }
end

local function get_visual_range()
  return get_current_visual_range() or get_last_visual_range()
end

local function get_visual_lines(range)
  local range = range or get_visual_range()
  local start_position = range.start_position
  local end_position = range.end_position
  local mode = range.mode

  if mode ~= "v" and mode ~= "V" and mode ~= "" then
    return nil
  end

  local lines = vim.fn.getbufline("%", start_position[2], end_position[2])

  if mode == "v" then
    if #lines == 1 then
      lines[1] = string.sub(lines[1], start_position[3], end_position[3])
      return lines
    else
      lines[1] = string.sub(lines[1], start_position[3])
      lines[#lines] = string.sub(lines[#lines], 1, end_position[3])
      return lines
    end
  elseif mode == "V" then
    return lines
  elseif mode == "" then
    return vim.tbl_map(function(line)
      return string.sub(line, start_position[3], end_position[3])
    end, lines)
  else
    return nil
  end
end

local function delete_visual_lines(range)
  local range = range or get_visual_range()
  local start_position = range.start_position
  local end_position = range.end_position
  local mode = range.mode

  if mode ~= "v" and mode ~= "V" and mode ~= "" then
    return false
  end

  if mode == "v" then
    vim.api.nvim_buf_set_text(0, start_position[2] - 1, start_position[3] - 1, end_position[2] - 1, end_position[3], {})
  elseif mode == "V" then
    vim.api.nvim_buf_set_lines(0, start_position[2] - 1, end_position[2], false, {})
  elseif mode == "" then
    for i = start_position[2], end_position[2] do
      vim.api.nvim_buf_set_text(0, i - 1, start_position[3] - 1, i - 1, end_position[3], {})
    end
  end

  return true
end

local function get_visual_text(range)
  local lines = get_visual_lines(range)

  if lines ~= nil then
    return vim.fn.join(lines, "\n")
  else
    return nil
  end
end

local function set_buf_options(buf, options)
  for option, value in pairs(options) do
    if value ~= nil then
      vim.api.nvim_buf_set_option(buf, option, value)
    end
  end
end

local defaults = {
  buf_options = {
    bufhidden = "delete",
    buflisted = false,
    buftype = "nofile",
  },
}

local function close_tab_when_any_window_is_closed(options)
  options = vim.tbl_deep_extend("force", defaults, options or {})

  local tab = vim.api.nvim_get_current_tabpage()
  local tabclosed = false

  for _, winid in pairs(vim.api.nvim_tabpage_list_wins(tab)) do
    set_buf_options(vim.api.nvim_win_get_buf(winid), options.buf_options)

    vim.api.nvim_create_autocmd("WinClosed", {
      pattern = tostring(winid),

      callback = function()
        if not tabclosed then
          local tabnr = vim.api.nvim_tabpage_get_number(tab)
          vim.cmd("tabclose " .. tostring(tabnr))
          tabclosed = true

          if options.on_closed then
            options.on_closed()
          end
        end
      end,
    })
  end
end

return {
  get_visual_lines = get_visual_lines,
  delete_visual_lines = delete_visual_lines,
  get_visual_text = get_visual_text,
  get_visual_range = get_visual_range,
  close_tab_when_any_window_is_closed = close_tab_when_any_window_is_closed,
}
