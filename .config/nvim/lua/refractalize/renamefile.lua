vim.keymap.set("n", "<leader>fr", function()
  local input_options = {
    prompt = "New file name",
    default = vim.fn.expand("%:."),
    completion = "file",
  }
  vim.ui.input(input_options, function(filename)
    if filename then
      -- local status, result = pcall(function()
        -- vim.cmd('Move ' .. filename)
        vim.cmd.Move({ filename })
      -- end)
      -- if not status and result then
        -- print('result: ' .. vim.inspect(result))
        -- vim.notify(result)
      -- end
    end
  end)
end)
