local M = {}

function M.setup() end

local function fail(message)
  vim.notify("copy-file-paths: " .. message, vim.log.levels.ERROR)
  return nil, message
end

local function git(cwd, ...)
  local command = { "git", "-C", cwd, ... }
  local result = vim.system(command, { text = true }):wait()

  if result.code ~= 0 then
    local message = vim.trim(result.stderr or "")
    if message == "" then
      message = "git command failed: " .. table.concat(command, " ")
    end
    return nil, message
  end

  return vim.trim(result.stdout or "")
end

local function encode_path(path)
  local parts = vim.split(path, "/", { plain = true })
  for index, part in ipairs(parts) do
    parts[index] = vim.uri_encode(part)
  end
  return table.concat(parts, "/")
end

function M._parse_github_origin(origin)
  if type(origin) ~= "string" then
    return nil
  end

  local repository = origin:match("^git@github%.com:(.+)$")
    or origin:match("^ssh://git@github%.com/(.+)$")
    or origin:match("^https?://github%.com/(.+)$")

  if not repository then
    return nil
  end

  repository = repository:gsub("/+$", ""):gsub("%.git$", "")
  if not repository:match("^[^/]+/[^/]+$") then
    return nil
  end

  return "https://github.com/" .. repository
end

function M._build_url(base_url, revision, relative_path, first_line, last_line)
  local fragment = ""
  if first_line then
    fragment = "#L" .. first_line
    if last_line and last_line ~= first_line then
      fragment = fragment .. "-L" .. last_line
    end
  end

  return string.format(
    "%s/blob/%s/%s%s",
    base_url,
    vim.uri_encode(revision),
    encode_path(relative_path),
    fragment
  )
end

local function selected_lines(options)
  if options.line_start then
    local first = options.line_start
    local last = options.line_end or first
    return math.min(first, last), math.max(first, last)
  end

  local mode = vim.fn.mode(1)
  if mode == "v" or mode == "V" or mode == "\22" then
    local first = vim.fn.line("v")
    local last = vim.fn.line(".")
    return math.min(first, last), math.max(first, last)
  end

  return nil, nil
end

local function line_suffix(first_line, last_line)
  if not first_line then
    return ""
  end

  if first_line == last_line then
    return ":" .. first_line
  end

  return ":" .. first_line .. "-" .. last_line
end

---Return a GitHub URL for the current file and optional visual selection.
---@param options? { line_start?: integer, line_end?: integer }
---@return string? url
---@return string? error
function M.get_browse_url(options)
  options = options or {}

  local buffer = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(buffer)
  if filename == "" or vim.bo[buffer].buftype ~= "" then
    return fail("the current buffer is not a file")
  end

  filename = vim.fs.normalize(filename)
  local directory = vim.fs.dirname(filename)
  local root, root_error = git(directory, "rev-parse", "--show-toplevel")
  if not root then
    return fail(root_error)
  end

  local origin, origin_error = git(root, "remote", "get-url", "origin")
  if not origin then
    return fail(origin_error)
  end

  local base_url = M._parse_github_origin(origin)
  if not base_url then
    return fail("origin is not a supported GitHub URL: " .. origin)
  end

  local revision, revision_error = git(root, "rev-parse", "HEAD")
  if not revision then
    return fail(revision_error)
  end

  local relative_path = vim.fs.relpath(root, filename)
  if not relative_path then
    return fail("the current file is outside the Git repository")
  end

  local first_line, last_line = selected_lines(options)
  return M._build_url(base_url, revision, relative_path, first_line, last_line)
end

---Return the current file path relative to the working directory.
---@param options? { line_start?: integer, line_end?: integer }
---@return string
function M.get_relative_path(options)
  local first_line, last_line = selected_lines(options or {})
  return vim.fn.expand("%:.") .. line_suffix(first_line, last_line)
end

---Return the GitHub URL for the current file.
---@param options? { line_start?: integer, line_end?: integer }
---@return string? url
---@return string? error
function M.get_url(options)
  return M.get_browse_url(options)
end

---Return the absolute path of the current file.
---@param options? { line_start?: integer, line_end?: integer }
---@return string
function M.get_absolute_path(options)
  local first_line, last_line = selected_lines(options or {})
  return vim.fn.expand("%:p") .. line_suffix(first_line, last_line)
end

---Return the absolute path of the current file's directory.
---@return string
function M.get_absolute_dirname()
  return vim.fn.expand("%:p:h")
end

---Return the current file's directory relative to the working directory.
---@return string
function M.get_relative_dirname()
  return vim.fn.expand("%:.:h")
end

---Return the current working directory.
---@return string
function M.get_cwd()
  return vim.fn.getcwd()
end

---Show the available paths for the current file and copy the selected one.
---Visual selections add line numbers to file-specific entries.
function M.select_paths()
  local first_line, last_line = selected_lines({})
  local options
  if first_line then
    options = { line_start = first_line, line_end = last_line }
  end

  local paths = {
    M.get_relative_path(options),
    M.get_url(options),
    M.get_absolute_path(options),
    M.get_absolute_dirname(),
    M.get_relative_dirname(),
    M.get_cwd(),
  }

  vim.ui.select(paths, {
    prompt = "Copy path to clipboard",
  }, function(selected)
    if selected then
      vim.fn.setreg("+", selected)
    end
  end)
end

return M
