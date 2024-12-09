local function open_window(buf)
  local height = vim.api.nvim_list_uis()[1].height
  local width = vim.api.nvim_list_uis()[1].width
  local cmdheight = vim.o.cmdheight

  local opts = {
    relative = "editor",
    width = width,
    height = height - cmdheight,
    col = 0,
    row = 0,
    anchor = "NW",
  }

  return vim.api.nvim_open_win(buf, true, opts)
end

local function run_command(command)
  local output = vim.api.nvim_exec2(command, { output = true })
  return vim.split(output.output, "\n")
end

local function page_command(command)
  local output_lines = run_command(command)
  local dest_buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(dest_buffer, 0, -1, false, output_lines)
  local window = open_window(dest_buffer)

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(window),

    callback = function()
      vim.api.nvim_buf_delete(dest_buffer, { force = true })
    end,
  })

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(window, true)
  end, { buffer = dest_buffer })
end

local function page_buffer_command(command)
  local output_lines = run_command(command)
  vim.cmd("enew")
  local dest_buffer = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(dest_buffer, 0, -1, false, output_lines)
end

vim.api.nvim_create_user_command("Page", function(args)
  page_command(args.args)
end, {
  nargs = "*",
  complete = "command",
})

vim.api.nvim_create_user_command("PageBuffer", function(args)
  page_buffer_command(args.args)
end, {
  nargs = "*",
  complete = "command",
})

return {
  page_command = page_command,
}
