local namespace = vim.api.nvim_create_namespace("kitty-user-var")

-- put this into kitty.conf
-- map --when-focus-on var:nvim cmd+c send_text all \x1by

local function setup()
  vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = function()
      io.stdout:write("\x1b]1337;SetUserVar=nvim=MQo\007")
    end,
  })

  vim.api.nvim_create_autocmd({ "VimLeave" }, {
    callback = function()
      io.stdout:write("\x1b]1337;SetUserVar=nvim\007")
    end,
  })

  vim.keymap.set("n", "<M-y>", '"+y', { noremap = true })
  vim.keymap.set("v", "<M-y>", '"+y', { noremap = true })
end

return {
  setup = setup,
}
