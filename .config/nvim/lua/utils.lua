function getRangeLines(range, line1, line2)
  if range == 2 then
    return vim.fn.getline(line1, line2)
  elseif range == 1 then
    return vim.fn.getline(line1)
  else
    return ''
  end
end

function getVisualText(range)
  if range > 0 then
    return string.sub(vim.fn.getline("'<"), vim.fn.getpos("'<")[3], vim.fn.getpos("'>")[3])
  else
    return ''
  end
end

function set_buf_options(buf, options)
  for option, value in pairs(options) do
    if value ~= nil then
      vim.api.nvim_buf_set_option(buf, option, value)
    end
  end
end

local defaults = {
  buf_options = {
    bufhidden = 'delete',
    buflisted = false,
    buftype = 'nofile'
  }
}

function close_tab_when_any_window_is_closed(options)
  options = vim.tbl_deep_extend('force', defaults, options or {})

  local tab = vim.api.nvim_get_current_tabpage()
  local tabclosed = false

  for _, winid in pairs(vim.api.nvim_tabpage_list_wins(tab)) do
    set_buf_options(vim.api.nvim_win_get_buf(winid), options.buf_options)

    vim.api.nvim_create_autocmd('WinClosed', {
      pattern = tostring(winid),

      callback = function()
        if not tabclosed then
          local tabnr = vim.api.nvim_tabpage_get_number(tab)
          vim.cmd('tabclose ' .. tostring(tabnr))
          tabclosed = true

          if options.on_closed then
            options.on_closed()
          end
        end
      end
    })
  end
end

return {
  getRangeLines = getRangeLines,
  getVisualText = getVisualText,
  close_tab_when_any_window_is_closed = close_tab_when_any_window_is_closed
}
