local function copy_patch(fargs)
  local branch = fargs[1] or "HEAD"
  vim.cmd("silent !git diff " .. branch .. " " .. vim.fn.expand("%:.") .. " | pbcopy")
end

local function paste_patch()
  vim.cmd("silent !pbpaste | git apply")
end

local function setup()
  vim.api.nvim_create_user_command("PatchPaste", function()
    paste_patch()
  end, { nargs = 0 })

  vim.api.nvim_create_user_command("PatchCopy", function(args)
    copy_patch(args.fargs)
  end, { nargs = "?", complete = "customlist,fugitive#ReadComplete" })
end

return {
  copy_patch = copy_patch,
  paste_patch = paste_patch,
  setup = setup,
}
