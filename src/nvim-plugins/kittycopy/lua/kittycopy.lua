local namespace = vim.api.nvim_create_namespace("kitty-user-var")

-- put this into kitty.conf
-- map --when-focus-on var:nvim ctrl+c no_op
-- map --when-focus-on var:nvim ctrl+shift+v no_op
-- map ctrl+c copy_or_interrupt
-- map ctrl+v paste_from_clipboard

local function setup()
  vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = function()
      io.stdout:write("\x1b]1337;SetUserVar=nvim=" .. vim.base64.encode(vim.v.servername) .. "\007")
    end,
  })

  vim.api.nvim_create_autocmd({ "VimLeave" }, {
    callback = function()
      io.stdout:write("\x1b]1337;SetUserVar=nvim\007")
    end,
  })

  vim.keymap.set("v", "<C-c>", '"+y', { noremap = true })
  vim.keymap.set("n", "<C-S-v>", '<C-v>', { noremap = true })
end

return {
  setup = setup,
}
