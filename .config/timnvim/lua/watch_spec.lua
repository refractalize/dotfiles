-- nvim --headless -c 'PlenaryBustedFile .config/nvim/lua/watch_spec.lua'

local watch = require('watch')

function find_window_for_buffer(buf)
  local windows = vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_buf(win) == buf
  end, vim.api.nvim_list_wins())

  return windows[1]
end

function select_buffer_window(buf)
  local win = find_window_for_buffer(buf)

  vim.api.nvim_set_current_win(win)
end

function buf_set_lines(buf, lines)
  select_buffer_window(buf)

  vim.api.nvim_buf_set_lines(
    buf,
    0,
    -1,
    true,
    lines
  )
end

function buf_get_lines(buf)
  return vim.api.nvim_buf_get_lines(
    buf,
    0,
    -1,
    true
  )
end

function start(cmd, options)
  local co = coroutine.running()
  local on_updated_options = {
    on_updated = function()
      coroutine.resume(co)
    end
  }
  options = vim.tbl_deep_extend('force', on_updated_options, options or {})
  watch.start(cmd, options)
  return watch.current()
end

function delete_all_buffers()
  local buffers = vim.api.nvim_list_bufs()
  for _, buffer in pairs(buffers) do
    vim.api.nvim_buf_delete(buffer, { force = true })
  end
end

function sort(t)
  local sorted = vim.tbl_values(t)
  table.sort(sorted)
  return sorted
end

function assert_same_ignore_order(expected, actual)
  assert.are.same(sort(expected), sort(actual))
end

function assert_buffers_shown(expected_buffers)
  local windows = vim.api.nvim_list_wins()
  local buffers = vim.tbl_map(function (win)
    return vim.api.nvim_win_get_buf(win)
  end, windows)

  assert_same_ignore_order(expected_buffers, buffers)
end

describe("watch", function()
  before_each(function()
    watch.stop()
    delete_all_buffers()
  end)

  it("runs a command with a buffer as an argument", function()
    local buf = vim.api.nvim_get_current_buf()
    local watcher = start('echo {}')
    coroutine.yield()

    buf_set_lines(buf, {
      'asdf'
    })
    coroutine.yield()

    local lines = buf_get_lines(watcher.result_buf)
    assert.are.same({ 'asdf' }, lines)
  end)

  it("runs a command with a buffer as stdin", function()
    local buf = vim.api.nvim_get_current_buf()
    local watcher = start('cat', {
      stdin = true
    })
    coroutine.yield()

    buf_set_lines(buf, {
      'asdf'
    })
    coroutine.yield()

    local lines = buf_get_lines(watcher.result_buf)
    assert.are.same({ 'asdf' }, lines)
  end)

  it("creates a new buffer and sets the filetype", function()
    local buf = vim.api.nvim_get_current_buf()
    local watcher = start('echo {new:json}')
    coroutine.yield()

    assert.are.equal(1, #watcher.attached_buffers)
    local json_buffer = watcher.attached_buffers[1]
    assert.are.equal('json', vim.api.nvim_buf_get_option(json_buffer, 'filetype'))

    assert_buffers_shown({ watcher.result_buf, json_buffer, buf })
  end)

  it("can watch two buffers", function()
    local buf1 = vim.api.nvim_get_current_buf()
    vim.cmd('vnew')
    local buf2 = vim.api.nvim_get_current_buf()

    local watcher = start('echo {' .. buf1 .. '} {' .. buf2 .. '}')

    assert_same_ignore_order({ buf1, buf2 }, watcher.attached_buffers)

    coroutine.yield()

    buf_set_lines(buf1, {
      'beep'
    })
    coroutine.yield()

    assert.are.same({ 'beep ' }, buf_get_lines(watcher.result_buf))

    buf_set_lines(buf2, {
      'boop'
    })
    coroutine.yield()

    assert.are.same({ 'beep boop' }, buf_get_lines(watcher.result_buf))
  end)
end)
