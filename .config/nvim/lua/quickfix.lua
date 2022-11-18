function setup()
  local group = vim.api.nvim_create_augroup("QuickFixResize", {
    clear = true,
  })

  local position

  local width_height_ratio = 2.0

  function save_position()
    local height = vim.fn.winheight(0)
    local width = vim.fn.winwidth(0)
    local right = height / width * width_height_ratio > 1

    if right then
      position = {
        right = true,
        width = width
      }
    else
      position = {
        right = false,
        height = height
      }
    end
  end

  vim.api.nvim_create_autocmd("WinScrolled", {
    pattern = "*",
    group = group,
    callback = function()
      if vim.api.nvim_buf_get_option(0, 'buftype') == 'quickfix' then
        save_position()
      end
    end,
  })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'qf',
    group = group,

    callback = function()
      if position then
        if position.right then
          vim.fn.execute('wincmd L')
          vim.fn.execute('vertical resize ' .. position.width)
        else
          vim.fn.execute('resize ' .. position.height)
        end
      else
        save_position()
      end
    end
  })
end

return {
  setup = setup
}
