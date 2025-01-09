--- @class WindowProfile
--- @field vertical boolean
--- @field min number | nil
--- @field max number | nil
--- @field size number | nil

--- @param window_profile WindowProfile
--- @param new boolean | nil
local function open_window(window_profile, new)
  local new_split = new and "new" or "split"
  local window_command = (window_profile.vertical and "v" or "") .. new_split

  if window_profile.size then
    local absolute_full_size = window_profile.vertical and vim.o.columns or vim.o.lines
    local absolute_size = absolute_full_size * window_profile.size

    if window_profile.min then
      absolute_size = math.max(absolute_size, window_profile.min)
    end

    if window_profile.max then
      absolute_size = math.min(absolute_size, window_profile.max)
    end

    vim.cmd(absolute_size .. window_command)
    local window = vim.api.nvim_get_current_win()
    return window
  else
    vim.cmd(window_command)
    local window = vim.api.nvim_get_current_win()

    if window_profile.min or window_profile.max then
      local absolute_size = window_profile.vertical and vim.api.nvim_win_get_height(window)
        or vim.api.nvim_win_get_width(window)
      local new_absolute_size = absolute_size

      if window_profile.min then
        new_absolute_size = math.max(absolute_size, window_profile.min)
      end

      if window_profile.max then
        new_absolute_size = math.min(absolute_size, window_profile.max)
      end

      if absolute_size ~= new_absolute_size then
        if window_profile.vertical then
          vim.api.nvim_win_set_height(window, new_absolute_size)
        else
          vim.api.nvim_win_set_width(window, new_absolute_size)
        end
      end
    end

    return window
  end
end

local function new_window(window_profile)
  local window = open_window(window_profile, true)
  local buffer = vim.api.nvim_get_current_buf()
  return window, buffer
end

return {
  open_window = open_window,
  new_window = new_window
}
