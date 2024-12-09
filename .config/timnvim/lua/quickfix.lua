function setup()
  local group = vim.api.nvim_create_augroup("QuickFixResize", {
    clear = true,
  })

  local position

  local width_height_ratio = 2.0

  function save_position(win_id)
    local height = vim.fn.winheight(win_id)
    local width = vim.fn.winwidth(win_id)
    local right = height / width * width_height_ratio > 1

    if right then
      position = {
        right = true,
        width = width,
      }
    else
      position = {
        right = false,
        height = height,
      }
    end
  end

  function is_qf_window(win_id)
    local buf = vim.api.nvim_win_get_buf(win_id)
    return vim.api.nvim_buf_get_option(buf, "buftype") == "quickfix"
  end

  vim.api.nvim_create_autocmd("WinResized", {
    pattern = "*",
    group = group,
    callback = function(event)
      local qf_windows = vim.tbl_filter(is_qf_window, vim.api.nvim_get_vvar("event").windows)
      for _i, qf_win in pairs(qf_windows) do
        save_position(qf_win)
      end
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    group = group,

    callback = function()
      if position then
        if position.right then
          vim.fn.execute("wincmd L")
          vim.fn.execute("vertical resize " .. position.width)
        else
          vim.fn.execute("resize " .. position.height)
        end
      else
        save_position(0)
      end
    end,
  })
end

return {
  setup = setup,
}
