local global_options = {
  basename_suffixes = {},
}

local function remove_suffixes(filename)
  for _, basename_pattern in ipairs(global_options.basename_patterns or {}) do
    local start, _, basename = string.find(filename, basename_pattern)
    if start then
      return basename
    end
  end

  return vim.fn.split(filename, "\\.")[1]
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
