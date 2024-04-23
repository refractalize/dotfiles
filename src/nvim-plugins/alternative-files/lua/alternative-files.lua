local global_options = {
  basename_suffixes = {},
}

local function remove_suffixes(filename)
  local basename = vim.fn.split(filename, "\\.")[1]
  local result = basename
  local suffixes = global_options.basename_suffixes[vim.bo.filetype] or {}

  for _, suffix in ipairs(suffixes) do
    if string.sub(result, -string.len(suffix)) == suffix then
      result = string.sub(result, 1, -string.len(suffix) - 1)
    end
  end

  return result
end

local function show_alternative_files()
  local filename = vim.fn.expand("%:t")
  local query = remove_suffixes(filename)

  require("fzf-lua").files({
    prompt = "Alternative Files: ",
    cwd_prompt = false,
    query = query .. ' ',
  })
end

local function setup(options)
  global_options = vim.tbl_extend("force", global_options, options or {})
end

return {
  setup = setup,
  show_alternative_files = show_alternative_files,
}
