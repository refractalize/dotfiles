local directory = vim.fn.stdpath("state") .. "/sessions"
vim.fn.mkdir(directory, "p")
local filename = directory .. "/" .. vim.fn.substitute(vim.fn.getcwd(), "/", "%", "g") .. ".vim"
local is_resetting = false

local function save()
  if not is_resetting and vim.fn.getcmdwintype() == "" then
    vim.cmd("mks! " .. vim.fn.fnameescape(filename))
  end
end

local function load()
  if vim.fn.filereadable(filename) == 1 then
    local status, err = pcall(function()
      vim.cmd("source " .. vim.fn.fnameescape(filename))
    end)

    if not status then
      vim.notify(vim.inspect(err))
    end
  else
    vim.notify("No session found: " .. filename)
  end
end

local function win_is_floating(winid)
  local config = vim.api.nvim_win_get_config(winid)
  return config.relative ~= ""
end

local function throttle_fn(fn)
  local running = false
  return function()
    if not running then
      running = true
      vim.defer_fn(function()
        fn()
        running = false
      end, 1000)
    end
  end
end

local function setup(config)
  config = vim.tbl_extend("force", {
    load_session = false,
  }, config)

  if vim.fn.execute("args") == "" then
    config.load_session = false
  end

  vim.api.nvim_create_autocmd("StdinReadPre", {
    callback = function()
      config.load_session = false
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    nested = true,
    callback = function()
      if vim.g.intersession_load_session ~= nil then
        config.load_session = vim.g.intersession_load_session
      end

      if config.load_session then
        load()
      end

      vim.api.nvim_create_autocmd("ExitPre", {
        callback = function()
          save()
        end,
      })

      local throttled_save = throttle_fn(save)

      vim.api.nvim_create_autocmd({ "WinNew", "WinClosed", "TabNew", "TabClosed", "BufWinEnter" }, {
        callback = function(e)
          if not (e.event == "WinClosed" and win_is_floating(tonumber(e.file))) then
            throttled_save()
          end
        end,
      })
    end,
  })
end

local function reset()
  vim.fn.delete(filename)
  is_resetting = true
end

return {
  filename = filename,
  reset = reset,
  setup = setup,
  save = save,
  load = load,
}
