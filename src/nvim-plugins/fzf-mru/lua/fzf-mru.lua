function fzf_mru(options)
  options = options or {}

  local all = options.all
  options.all = nil

  local open_buffers_temp_file = vim.fn.tempname()
  local command
  if all then
    command = "fzf-mru ~/.config/nvim/mru --all"
  else
    command = "rg --files --hidden | fzf-mru ~/.config/nvim/mru"
  end

  local fzf_lua = require("fzf-lua")

  fzf_lua.fzf_exec(
    command,
    vim.tbl_deep_extend("keep", options, {
      fzf_opts = {
        ["--no-sort"] = "",
      },
      fn_transform = function(x)
        return fzf_lua.make_entry.file(x, { file_icons = true, color_icons = true })
      end,
      actions = fzf_lua.config.globals.actions.files,
      previewer = "builtin",
    })
  )
end

return {
  fzf_mru = fzf_mru,
}
