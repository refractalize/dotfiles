local M = {}

local config = {
  modes = { "n" },
}

---@type string|nil
local last_back_target
---@type string|nil
local last_forward_target

local function map_prefix(prefix)
  return function()
    print("[movement-repeat] prefix pressed:", prefix)
    local next_key = vim.fn.getcharstr()
    print("[movement-repeat] next key:", vim.inspect(next_key))

    if prefix == "[" then
      if next_key == "[" then
        if last_back_target then
          print("[movement-repeat] replay backward:", "[" .. last_back_target)
          return "[" .. last_back_target
        end
        print("[movement-repeat] no backward target yet, fallback: [[")
        return "[["
      end

      last_back_target = next_key
      print("[movement-repeat] captured backward target:", vim.inspect(last_back_target))
      print("[movement-repeat] emit:", "[" .. next_key)
      return "[" .. next_key
    end

    if next_key == "]" then
      if last_forward_target then
        print("[movement-repeat] replay forward:", "]" .. last_forward_target)
        return "]" .. last_forward_target
      end
      print("[movement-repeat] no forward target yet, fallback: ]]")
      return "]]"
    end

    last_forward_target = next_key
    print("[movement-repeat] captured forward target:", vim.inspect(last_forward_target))
    print("[movement-repeat] emit:", "]" .. next_key)
    return "]" .. next_key
  end
end

local function setup_keymaps()
  local opts = { noremap = true, silent = true, expr = true }
  print("[movement-repeat] setting keymaps for modes:", vim.inspect(config.modes))
  vim.keymap.set(config.modes, "[", map_prefix("["), opts)
  vim.keymap.set(config.modes, "]", map_prefix("]"), opts)
  print("[movement-repeat] keymaps installed for '[' and ']'")
end

function M.setup(user_config)
  print("[movement-repeat] setup called with:", vim.inspect(user_config))
  config = vim.tbl_deep_extend("force", config, user_config or {})
  print("[movement-repeat] merged config:", vim.inspect(config))
  setup_keymaps()
end

return M
