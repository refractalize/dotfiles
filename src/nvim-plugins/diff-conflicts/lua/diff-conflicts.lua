local utils = require("refractalize.utils")

local namespace = vim.api.nvim_create_namespace("diff_conflicts")

local function split_conflicts(lines)
  local left = { name = nil, lines = {}, conflict_markers = {} }
  local right = { name = nil, lines = {}, conflict_markers = {} }
  local base = { name = nil, lines = {}, conflict_markers = {} }
  local versions_to_capture = { left, right, base }
  local conflict_number = 0
  local in_conflict = false
  local conflict_markers = {}

  for _, line in ipairs(lines) do
    local start_conflict = false
    local end_conflict = false

    if line:match("^<<<<<<< ") then
      conflict_number = conflict_number + 1
      start_conflict = true
      left.name = line:match("^<<<<<<< (.*)")
      versions_to_capture = { left }
    elseif line:match("^||||||| ") then
      base.name = line:match("^||||||| (.*)")
      versions_to_capture = { base }
    elseif line:match("^=======") then
      versions_to_capture = { right }
    elseif line:match("^>>>>>>> ") then
      right.name = line:match("^>>>>>>> (.*)")
      end_conflict = true
      versions_to_capture = { left, right, base }
    else
      for _, version in ipairs(versions_to_capture) do
        table.insert(version.conflict_markers, in_conflict and conflict_number or 0)
        table.insert(version.lines, line)
      end
    end

    if start_conflict then
      in_conflict = true
    end

    table.insert(conflict_markers, in_conflict and conflict_number or 0)

    if end_conflict then
      in_conflict = false
    end
  end

  if conflict_number > 0 then
    return {
      left = left,
      right = right,
      base = base,
      conflict_markers = conflict_markers,
    }
  end
end

local function set_conflict_markers(buffer, conflict_markers)
  for line, conflict_marker in ipairs(conflict_markers) do
    if conflict_marker > 0 then
      local two_digit_conflict_marker = tostring((conflict_marker - 1) % 99 + 1)
      vim.api.nvim_buf_set_extmark(buffer, namespace, line - 1, 0, {
        sign_text = two_digit_conflict_marker,
        sign_hl_group = "Error",
        priority = 5,
      })
    end
  end
end

local function clear_conflict_markers(buffer)
  vim.api.nvim_buf_clear_namespace(buffer, namespace, 0, -1)
end

local function on_window_close(window, callback)
  vim.api.nvim_create_autocmd({ "WinClosed" }, {
    pattern = tostring(window),
    callback = callback,
  })
end

local function clear_conflict_markers_on_window_close(window, buffer)
  on_window_close(window, function()
    clear_conflict_markers(buffer)
  end)
end

local function create_version_window(version, split_command, options)
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, version.lines)
  vim.api.nvim_buf_set_name(buffer, options.create_buffer_name(version.name))
  vim.api.nvim_set_option_value("filetype", options.filetype, { buf = buffer })
  vim.cmd(split_command)
  local window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(0, buffer)
  vim.cmd("diffthis")

  set_conflict_markers(buffer, version.conflict_markers)
  on_window_close(window, function()
    clear_conflict_markers(buffer)
    vim.api.nvim_buf_delete(buffer, { force = true })
  end)
end

local function buffer_names(name, tabpage_handle)
  return function(ref)
    return "diff-conflicts://" .. tabpage_handle .. "/" .. name .. (ref and ("#" .. ref) or "")
  end
end

local function diff_conflicts_lines(buffer, lines, options)
  options = options or {}
  local versions = split_conflicts(lines)

  if not versions then
    vim.api.nvim_err_writeln("No conflicts found")
    return
  end

  local filename = vim.api.nvim_buf_get_name(buffer)
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = buffer })

  vim.cmd("tabnew")
  local create_buffer_name = buffer_names(options.filename, vim.api.nvim_get_current_tabpage())
  vim.api.nvim_win_set_buf(0, buffer)
  if vim.api.nvim_buf_get_name(buffer) == "" then
    vim.api.nvim_buf_set_name(buffer, create_buffer_name())
  end
  local window = vim.api.nvim_get_current_win()
  vim.cmd("diffthis")

  create_version_window(
    versions.left,
    "horizontal top split",
    { filename = filename, filetype = filetype, create_buffer_name = create_buffer_name }
  )
  create_version_window(
    versions.base,
    "vertical rightbelow split",
    { filename = filename, filetype = filetype, create_buffer_name = create_buffer_name }
  )
  create_version_window(
    versions.right,
    "vertical rightbelow split",
    { filename = filename, filetype = filetype, create_buffer_name = create_buffer_name }
  )

  set_conflict_markers(buffer, versions.conflict_markers)

  on_window_close(window, function()
    clear_conflict_markers(buffer)
    if options.close_buffer then
      vim.api.nvim_buf_delete(buffer, { force = true })
    end
  end)
end

local function diff_conflicts()
  local buffer = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
  diff_conflicts_lines(buffer, lines, {
    filename = vim.api.nvim_buf_get_name(buffer),
  })
end

local function show_diff(changes)
  local function set_window_diff(winnr, diff)
    vim.api.nvim_win_call(vim.fn.win_getid(winnr), function()
      if diff and not vim.wo.diff then
        vim.cmd("diffthis")
      elseif not diff and vim.wo.diff then
        vim.cmd("diffoff")
      end
    end)
  end

  set_window_diff(1, changes == "ours" or changes == "ours_merge")
  set_window_diff(2, changes == "ours" or changes == "theirs")
  set_window_diff(3, changes == "theirs" or changes == "theirs_merge")
  set_window_diff(4, changes == "ours_merge" or changes == "theirs_merge")
end

local function show_diff_select()
  local change_names = {
    { "Ours", "ours" },
    { "Theirs", "theirs" },
    { "Ours (merge)", "ours_merge" },
    { "Theirs (merge)", "theirs_merge" },
  }
  vim.ui.select(
    vim.tbl_map(function(item)
      return item[1]
    end, change_names),
    {
      prompt = "Show diff: ",
    },
    function(choice, index)
      if choice == nil then
        return
      end

      show_diff(change_names[index][2])
    end
  )
end

local function diff_conflicts_range(line1, line2)
  local original_buffer = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(original_buffer, line1 - 1, line2, false)
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)

  diff_conflicts_lines(buffer, lines, {
    close_buffer = true,
    filename = vim.api.nvim_buf_get_name(original_buffer) .. ":" .. line1 .. "-" .. line2,
  })
end

local function setup()
  vim.api.nvim_create_user_command("DiffConflicts", function(args)
    if args.range > 0 then
      diff_conflicts_range(args.line1, args.line2)
    else
      diff_conflicts()
    end
  end, { nargs = 0, range = true })
end

return {
  diff_conflicts = diff_conflicts,
  diff_conflicts_range = diff_conflicts_range,
  show_diff = show_diff,
  show_diff_select = show_diff_select,
  setup = setup,
}

--[[
one
two
three
<<<<<<< HEAD
four left
four and a half
||||||| base
four original
=======
four right
>>>>>>> right
five
six
seven
<<<<<<< HEAD
eight left
||||||| base
eight original
=======
eight right
eight and a half
>>>>>>> right
nine
ten
]]
