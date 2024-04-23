local directory = vim.fn.stdpath("state") .. "/sessions"
vim.fn.mkdir(directory, 'p')
local filename = directory .. "/" .. vim.fn.substitute(vim.fn.getcwd(), "/", "%", "g") .. ".vim"
local is_resetting = false

local function save()
  if not is_resetting and vim.fn.getcmdwintype() == "" then
    vim.cmd("mks! " .. vim.fn.fnameescape(filename))
  end
end

local function load()
  vim.cmd("source " .. vim.fn.fnameescape(filename))
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

local function setup()
  local load_session = vim.fn.execute("args") == ""

  if load_session then
    vim.api.nvim_create_autocmd("StdinReadPre", {
      callback = function()
        load_session = false
      end,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      nested = true,
      callback = function()
        if vim.g.intersession_load_session ~= nil then
          load_session = vim.g.intersession_load_session
        end

        if load_session then
          if vim.fn.filereadable(filename) == 1 then
            local status, err = pcall(function()
              load()
            end)

            if not status then
              vim.notify(vim.inspect(err))
            end
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
        end
      end,
    })
  end
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
