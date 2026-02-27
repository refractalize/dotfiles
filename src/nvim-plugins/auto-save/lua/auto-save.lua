---@type {write_delay: number, ignore_files: {[string]: function|string}, ignore_buffer: function|nil}
local defaults = {
  write_delay = 0,
  ignore_files = {},
}

---@param options {write_delay: number, ignore_files: {[string]: function|string}, ignore_buffer: function|nil}
---@param buffer number
---@return boolean
function ignore_buffer(options, buffer)
  local filename = vim.api.nvim_buf_get_name(buffer)

  for ignore_file_name, ignore_file in pairs(options.ignore_files) do
    if type(ignore_file) == "function" then
      local ignore = ignore_file(buffer)
      if ignore then
        return true
      end
    elseif type(ignore_file) == "string" then
      local pattern = string.sub(vim.fn.glob2regpat(ignore_file), 2)
      local match = vim.fn.match(filename, pattern)
      if match >= 0 then
        return true
      end
    else
      error("Invalid type for ignore_files[" .. ignore_file_name .. "]: " .. type(ignore_file))
    end
  end

  return false
end

---@param fn function
---@param write_delay number|nil
function delay(fn, write_delay)
  if write_delay then
    vim.defer_fn(fn, write_delay)
  else
    fn()
  end
end

--- @param options {write_delay: number, ignore_files: {[string]: function|string}, ignore_buffer: function|nil}
function setup(options)
  options = vim.tbl_deep_extend("force", defaults, options or {})

  vim.api.nvim_create_augroup("AutoSave", {
    clear = true,
  })

  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "TextChangedP" }, {
    callback = function()
      local buf = vim.api.nvim_get_current_buf()

      if not ignore_buffer(options, buf) then
        delay(function()
          if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_option_value("modified", { buf = buf }) then
            vim.api.nvim_buf_call(buf, function()
              vim.cmd("silent! lockmarks write")
            end)
          end
        end, options.write_delay)
      end
    end,
    pattern = "*",
    group = "AutoSave",
  })
end

return {
  setup = setup,
}
