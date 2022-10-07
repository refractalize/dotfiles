function compact(items)
  return vim.tbl_filter(
    function (line)
      return line
    end,
    items
  )
end

function filter_lines(lines, prefix)
  return compact(
    vim.tbl_map(
      function(line)
        local first_char = string.sub(line, 1, 1)
        if first_char == prefix or first_char == ' ' then
          return string.sub(line, 2)
        end
      end,
      lines
    )
  )
end

function setup_buffer(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
  vim.cmd('diffthis')
end

function diff_patch(lines)
  local left = filter_lines(lines, '-')
  local right = filter_lines(lines, '+')

  vim.cmd('tabnew')
  setup_buffer(left, tab)

  vim.cmd('vertical new')
  setup_buffer(right, tab)
  require('utils').close_tab_when_any_window_is_closed()
end

function buffers_in_tab()
  vim.tbl_map(
    function(win)
      local buf = vim.api.nvim_win_get_buf(win)

      return {
        win = win,
        buf = buf,
        bufname = vim.fn.bufname(buf)
      }
    end,
    vim.api.nvim_tabpage_list_wins(tab)
  )
end

function show_theirs()
end

return {
  diff_patch = diff_patch
}

--[[

 one
 two
-left
+right
 three
 four

--]]
