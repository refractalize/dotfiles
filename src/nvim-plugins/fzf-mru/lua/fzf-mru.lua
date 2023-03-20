function fzf_mru()
  local open_buffers_temp_file = vim.fn.tempname()
  local command = "rg --files --hidden | fzf-mru ~/.config/nvim/mru"

  local fzf_lua = require("fzf-lua")

  fzf_lua.fzf_exec(command, {
    fzf_opts = {
      ["--no-sort"] = "",
    },
    fn_transform = function(x)
      return fzf_lua.make_entry.file(x, { file_icons = true, color_icons = true })
    end,
    actions = fzf_lua.config.globals.actions.files,
    previewer = "builtin",
  })
end

return {
  fzf_mru = fzf_mru,
}
