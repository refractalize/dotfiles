local copy_command = vim.fn.has('mac') == 1 and "pbcopy" or "xsel -b"
local paste_command = vim.fn.has('mac') == 1 and "pbpaste" or "xsel -b"

local function copy_patch(fargs)
  local branch = fargs[1] or "HEAD"
  vim.cmd("silent !git diff " .. branch .. " " .. vim.fn.expand("%:.") .. " | " .. copy_command)
end

local function paste_patch()
  vim.cmd("silent !" .. paste_command .. " | git apply")
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
