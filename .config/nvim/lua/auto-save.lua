vim.api.nvim_create_augroup("AutoSave", {
  clear = true,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    callback = function()
      local buf = vim.api.nvim_get_current_buf()

      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'modified') then
          vim.api.nvim_buf_call(buf, function () vim.cmd("silent! lockmarks write") end)
        end
      end, 135)
    end,
    pattern = "*",
    group = "AutoSave",
})
