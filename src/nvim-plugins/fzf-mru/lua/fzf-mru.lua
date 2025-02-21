local mru_dir = vim.fn.stdpath("data") .. "/fzf-mru"
local mru_filename = mru_dir .. "/mru"

function fzf_mru(options)
  options = options or {}

  local all = options.all
  options.all = nil

  local open_buffers_temp_file = vim.fn.tempname()
  local command
  if all then
    command = "fzf-mru " .. mru_filename .. " --all"
  else
    command = "rg --files --hidden | fzf-mru " .. mru_filename
  end

  local fzf_lua = require("fzf-lua")

  fzf_lua.fzf_exec(
    command,
    vim.tbl_deep_extend("keep", options, {
      fzf_opts = {
        ["--no-sort"] = "",
        ["--multi"] = "",
      },
      fn_transform = function(x)
        return fzf_lua.make_entry.file(x, { file_icons = true, color_icons = true })
      end,
      actions = fzf_lua.config.globals.actions.files,
      previewer = "builtin",
    })
  )
end

local function ignore_buffer(ignore_filename_lpegs, ignore_filetypes, filename, filetype)
  for _, pattern in ipairs(ignore_filename_lpegs) do
    if pattern:match_str(filename) then
      return true
    end
  end

  for _, ignored_filetype in ipairs(ignore_filetypes) do
    if filetype == ignored_filetype then
      return true
    end
  end

  local stat = vim.uv.fs_stat(filename)
  return not stat or stat.type ~= 'file'
end

local function write_mru_line(line)
  local fd = assert(vim.uv.fs_open(mru_filename, "a", 420))
  assert(vim.uv.fs_write(fd, line))
  assert(vim.uv.fs_close(fd))
end

local function setup(config)
  config = vim.tbl_deep_extend("force", {
    ignore = {
      filename_patterns = {
        "\\/\\.git\\/",
        "^term:",
      },
      filetypes = {
        "fugitive",
      },
    },
  }, config)

  vim.fn.mkdir(mru_dir, "p")

  local ignore_filename_lpegs = vim
    .iter(config.ignore.filename_patterns)
    :map(function(pattern)
      return vim.regex(pattern)
    end)
    :totable()

  vim.api.nvim_create_autocmd({
    "BufAdd",
    "BufEnter",
    "BufLeave",
    "BufWritePost",
  }, {
    callback = function()
      local buffer = vim.api.nvim_get_current_buf()
      local buffer_name = vim.api.nvim_buf_get_name(buffer)
      local full_filename = vim.fn.fnamemodify(buffer_name, ":p")
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = buffer })

      if not ignore_buffer(ignore_filename_lpegs, config.ignore.filetypes, full_filename, filetype) then
        write_mru_line(os.time() .. " " .. full_filename .. "\n")
      end
    end,
  })
end

return {
  setup = setup,
  fzf_mru = fzf_mru,
}
