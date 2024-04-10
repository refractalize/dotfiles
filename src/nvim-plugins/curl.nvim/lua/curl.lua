local function shell(cmd, cb)
  local output = { "" }

  local function append_output(lines)
    output[#output] = output[#output] .. lines[1]
    vim.list_extend(output, vim.list_slice(lines, 2))
  end

  vim.fn.jobstart(cmd, {
    on_exit = function(_, code)
      if code ~= 0 then
        vim.notify(
          cmd .. " failed " .. code .. "\n" .. vim.fn.join(output, "\n"),
          vim.log.levels.ERROR,
          { title = "curl" }
        )
        cb()
      else
        cb(output)
      end
    end,
    on_stdout = function(_, lines)
      append_output(lines)
    end,
    on_stderr = function(_, lines)
      append_output(lines)
    end,
  })
end

local function host_args(host)
  local filename = vim.fn.findfile('.curl.nvim.json', ";.")
  if vim.fn.filereadable(filename) == 0 then
    return
  end

  print('filename: ' .. vim.inspect(filename))

  return vim.fn.json_decode(vim.fn.readfile(filename))[host]
end

local function setup()
  vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = { "http://*", "https://*" },
    callback = function()
      local url = vim.fn.expand("%")
      shell("trurl " .. vim.fn.shellescape(url) .. " --json", function(url_json_string)
        local url_json = vim.fn.json_decode(url_json_string)[1].parts
        local host = url_json.host .. (url_json.port and ":" .. url_json.port or "")
        print('host: ' .. vim.inspect(host))
        if not host then
          return
        end
        local args = host_args(host) or ""
        print('args: ' .. vim.inspect(args))
        local lines = shell("curl -s " .. args .. " " .. vim.fn.shellescape(url), function(lines)
          print('lines: ' .. vim.inspect(lines))
          if not lines then
            return
          end
          vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
          vim.bo.buftype = "nofile"
        end)
      end)
    end,
  })
end

return {
  setup = setup,
}
