local M = {}

local config = {
  repeat_key_back = "[*",
  repeat_key_forward = "]*",

  capture_keys = {
    ["[r"] = "]r"
  }
}

--- @type string | nil
local captured_key

function setup_keymaps()
  local opts = { noremap = true, silent = true, expr = true }
  for k, v in pairs(config.capture_keys) do
    print("Mapping key: " .. k)
    vim.keymap.set("n", k, function()
      captured_key = k
      print("Captured key: " .. captured_key)
      return k
    end, opts)
    print("Mapping key: " .. v)
    vim.keymap.set("n", v, function()
      captured_key = v
      print("Captured key: " .. captured_key)
      return v
    end, opts)
  end

  vim.keymap.set("n", config.repeat_key_back, function()
    print("Captured key: " .. captured_key)
    if captured_key then
      return captured_key
    end
    return nil
  end, opts)

  vim.keymap.set("n", config.repeat_key_forward, function()
    print("Captured key: " .. captured_key)
    if captured_key then
      local forward_key = config.capture_keys[captured_key]
      print("Forward key: " .. forward_key)
      if forward_key then
        return forward_key
      end
    end
    return nil
  end, opts)
end

function M.setup(user_config)
  print("Setting up movement-repeat")
  print("Config: " .. vim.inspect(user_config))
  config = vim.tbl_deep_extend("force", config, user_config)
  print("Config after: " .. vim.inspect(config))
  setup_keymaps()
end

return M
