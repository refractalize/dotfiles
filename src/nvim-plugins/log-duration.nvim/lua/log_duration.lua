local M = {}

local ns = vim.api.nvim_create_namespace("log_duration_visual_selection")
local augroup = vim.api.nvim_create_augroup("LogDurationVisualSelection", { clear = true })
local enabled_key = "log_duration_enabled"
local setup_done = false
local buffer_autocmd_ids = {}
local fold_states = {}
local active_foldmethod = "marker"
local active_foldmarker = "##[group],##[endgroup]"
local active_foldtext = "v:lua.require'log_duration'.foldtext()"

local function parse_timestamp_to_micros(text)
  local ts = text:match("^(%S+)")
  if not ts then
    return nil
  end

  local y, mon, d, h, min, s, frac =
    ts:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)%.?(%d*)Z$")
  if not y then
    return nil
  end

  local base_seconds = vim.fn.strptime(
    "%Y-%m-%dT%H:%M:%S",
    string.format("%s-%s-%sT%s:%s:%s", y, mon, d, h, min, s)
  )
  if base_seconds < 0 then
    return nil
  end

  local micro_frac = 0
  if frac and #frac > 0 then
    local six = frac:sub(1, 6)
    if #six < 6 then
      six = six .. string.rep("0", 6 - #six)
    end
    micro_frac = tonumber(six) or 0
  end

  return (base_seconds * 1000000) + micro_frac
end

local function format_duration(micros)
  local total_seconds = math.floor(micros / 1000000)
  local remainder_micros = micros % 1000000
  local hours = math.floor(total_seconds / 3600)
  local minutes = math.floor((total_seconds % 3600) / 60)
  local seconds = total_seconds % 60

  return string.format("%dh%dm%d.%06ds", hours, minutes, seconds, remainder_micros)
end

local function duration_for_lines(bufnr, first_line_idx, last_line_idx)
  local first_text = vim.api.nvim_buf_get_lines(bufnr, first_line_idx, first_line_idx + 1, false)[1] or ""
  local last_text = vim.api.nvim_buf_get_lines(bufnr, last_line_idx, last_line_idx + 1, false)[1] or ""
  local first_micros = parse_timestamp_to_micros(first_text)
  local last_micros = parse_timestamp_to_micros(last_text)
  if not first_micros or not last_micros then
    return nil
  end

  return format_duration(math.abs(last_micros - first_micros))
end

local function group_name_for_line(bufnr, line_idx)
  local text = vim.api.nvim_buf_get_lines(bufnr, line_idx, line_idx + 1, false)[1] or ""
  local name = text:match("##%[group%](.*)$")
  if not name then
    return nil
  end

  name = vim.trim(name)
  if name == "" then
    return nil
  end

  return name
end

local function is_visual_mode()
  local mode = vim.fn.mode(1)
  return mode == "v" or mode == "V" or mode == "\22" or mode == "s" or mode == "S" or mode == "\19"
end

local function clear_marks(bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  end
end

local function is_enabled(bufnr)
  return vim.b[bufnr][enabled_key] == true
end

local function apply_fold_options(bufnr)
  local winids = vim.fn.win_findbuf(bufnr)
  if not fold_states[bufnr] then
    fold_states[bufnr] = {}
  end

  for _, winid in ipairs(winids) do
    if vim.api.nvim_win_is_valid(winid) then
      if not fold_states[bufnr][winid] then
        fold_states[bufnr][winid] = {
          foldmethod = vim.wo[winid].foldmethod,
          foldmarker = vim.wo[winid].foldmarker,
          foldtext = vim.wo[winid].foldtext,
        }
      end

      vim.wo[winid].foldmethod = active_foldmethod
      vim.wo[winid].foldmarker = active_foldmarker
      vim.wo[winid].foldtext = active_foldtext
    end
  end
end

local function restore_fold_options(bufnr)
  local states = fold_states[bufnr]
  if not states then
    return
  end

  for winid, state in pairs(states) do
    if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == bufnr then
      vim.wo[winid].foldmethod = state.foldmethod
      vim.wo[winid].foldmarker = state.foldmarker
      vim.wo[winid].foldtext = state.foldtext
    end
  end

  fold_states[bufnr] = nil
end

local function update_marks()
  local bufnr = vim.api.nvim_get_current_buf()

  if not is_enabled(bufnr) then
    clear_marks(bufnr)
    return
  end

  if not is_visual_mode() then
    clear_marks(bufnr)
    return
  end

  local start_line = vim.fn.getpos("v")[2]
  local end_line = vim.fn.line(".")

  if start_line == 0 or end_line == 0 then
    clear_marks(bufnr)
    return
  end

  local top = math.min(start_line, end_line) - 1
  local bottom = math.max(start_line, end_line) - 1

  clear_marks(bufnr)

  local duration_text = duration_for_lines(bufnr, top, bottom) or "invalid timestamp"

  vim.api.nvim_buf_set_extmark(bufnr, ns, top, 0, {
    virt_text = { { duration_text, "Comment" } },
    virt_text_pos = "eol",
  })

  vim.api.nvim_buf_set_extmark(bufnr, ns, bottom, 0, {
    virt_text = { { duration_text, "Comment" } },
    virt_text_pos = "eol",
  })
end

function M.foldtext()
  local bufnr = vim.api.nvim_get_current_buf()
  if not is_enabled(bufnr) then
    return vim.fn.foldtext()
  end

  local start_idx = vim.v.foldstart - 1
  local end_idx = vim.v.foldend - 1
  local duration_text = duration_for_lines(bufnr, start_idx, end_idx) or "invalid timestamp"
  local line_count = vim.v.foldend - vim.v.foldstart + 1
  local group_name = group_name_for_line(bufnr, start_idx)

  if group_name then
    return string.format("%s | %s (%d lines)", group_name, duration_text, line_count)
  end

  return string.format("%s (%d lines)", duration_text, line_count)
end

local function delete_buffer_autocmds(bufnr)
  local ids = buffer_autocmd_ids[bufnr]
  if not ids then
    return
  end

  for _, id in ipairs(ids) do
    pcall(vim.api.nvim_del_autocmd, id)
  end
  buffer_autocmd_ids[bufnr] = nil
end

local function ensure_buffer_autocmds(bufnr)
  if buffer_autocmd_ids[bufnr] then
    return
  end

  buffer_autocmd_ids[bufnr] = {
    vim.api.nvim_create_autocmd({
      "ModeChanged",
      "CursorMoved",
      "CursorMovedI",
      "BufEnter",
      "WinEnter",
    }, {
      group = augroup,
      buffer = bufnr,
      callback = function(args)
        if is_enabled(args.buf) then
          apply_fold_options(args.buf)
        end
        update_marks()
      end,
    }),
    vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "BufHidden" }, {
      group = augroup,
      buffer = bufnr,
      callback = function(args)
        clear_marks(args.buf)
      end,
    }),
  }
end

local function start_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.b[bufnr][enabled_key] = true
  ensure_buffer_autocmds(bufnr)
  apply_fold_options(bufnr)
  update_marks()
end

local function stop_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.b[bufnr][enabled_key] = false
  delete_buffer_autocmds(bufnr)
  restore_fold_options(bufnr)
  clear_marks(bufnr)
end

function M.setup()
  if setup_done then
    return
  end
  setup_done = true

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = augroup,
    callback = function(args)
      vim.b[args.buf][enabled_key] = false
      delete_buffer_autocmds(args.buf)
      restore_fold_options(args.buf)
      clear_marks(args.buf)
    end,
  })

  vim.api.nvim_create_user_command("LogDurationStart", start_current_buffer, {
    desc = "Enable log-duration virtual text for current buffer",
  })
  vim.api.nvim_create_user_command("LogDurationStop", stop_current_buffer, {
    desc = "Disable log-duration virtual text for current buffer",
  })
end

return M
