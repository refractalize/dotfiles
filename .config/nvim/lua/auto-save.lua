local defaults = {
  write_delay = 135,
  ignore_files = {},
  ignore_buffer = nil
}

function ignore_buffer(options, buffer)
  local filename = vim.api.nvim_buf_get_name(buffer)

  local ignored = vim.tbl_filter(
    function(ignore_path)
      local pattern = string.sub(vim.fn.glob2regpat(ignore_path), 2)
      local match = vim.fn.match(filename, pattern)
      return match >= 0
    end,
    options.ignore_files
  )

  return next(ignored) or (options.ignore_buffer and options.ignore_buffer(buffer))
end

function delay(fn, write_delay)
  if write_delay then
    vim.defer_fn(fn, write_delay)
  else
    fn()
  end
end

function setup(options)
  options = vim.tbl_deep_extend('force', defaults, options or {})

  vim.api.nvim_create_augroup("AutoSave", {
    clear = true,
  })

  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
      callback = function()
        local buf = vim.api.nvim_get_current_buf()

        if not ignore_buffer(options, buf) then
          delay(function()
            if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'modified') then
              vim.api.nvim_buf_call(buf, function () vim.cmd("silent! lockmarks write") end)
            end
          end, options.write_delay)
        end
      end,
      pattern = "*",
      group = "AutoSave",
  })
end

return {
  setup = setup
}
