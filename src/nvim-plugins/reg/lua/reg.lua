function edit_register(register_name)
  local reginfo = vim.fn.getreginfo(register_name)
  if not reginfo.regcontents then
    vim.api.nvim_err_writeln('Reg: nothing in "' .. register_name)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  buf_set_register_contents(buf, reginfo)

  local title = 'register "' .. register_name .. ", type " .. render_regtype(reginfo.regtype)
  local win = open_window(buf, title)

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = buf,

    callback = function()
      buf_get_register_contents(buf, register_name, reginfo)
      resize_window(win, buf)
    end,
  })
end

function resize_window(win, buf)
  local height = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_win_set_height(win, height)
end

function buf_set_register_contents(buf, reginfo)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, reginfo.regcontents)
  return reginfo
end

function buf_get_register_contents(buf, register_name, reginfo)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
  reginfo.regcontents = lines
  vim.fn.setreg(register_name, reginfo)
end

function open_window(buf, title)
  local ui_height = vim.api.nvim_list_uis()[1].height
  local ui_width = vim.api.nvim_list_uis()[1].width
  local width = math.floor(ui_width * 0.8)
  local height = vim.api.nvim_buf_line_count(buf)

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((ui_width - width) / 2),
    row = math.floor((ui_height - height) / 4),
    anchor = "NW",
    style = "minimal",
    border = "rounded",
    title = title,
  }

  return vim.api.nvim_open_win(buf, true, opts)
end

function render_regtype(regtype)
  local types = {
    v = "charwise",
    V = "linewise",
    ["\022"] = "blockwise",
    [""] = "",
  }

  return types[string.sub(regtype, 1, 1)]
end

return {
  edit_register = edit_register,
}
