local global_options = {
  host_args = {},
  filetypes = {
    ["text/html"] = "html",
    ["text/markdown"] = "markdown",
    ["application/json"] = "json",
    ["application/xml"] = "xml",
    ["text/xml"] = "xml",
    ["text/plain"] = "text",
  },
}

local function read_content_type_from_tempfile(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or not lines then
    return nil
  end
  local data = table.concat(lines, "\n"):gsub("\r\n", "\n")
  local blocks = vim.split(data, "\n\n+", { plain = false })
  for i = #blocks, 1, -1 do
    for line in blocks[i]:gmatch("[^\n]+") do
      local v = line:match("^%s*[Cc]ontent%-[Tt]ype:%s*(.-)%s*$")
      if v then
        local mime = v:match("^%s*([^;]+)")
        if mime then
          mime = mime:gsub("^%s+", ""):gsub("%s+$", "")
          return mime
        end
        return v
      end
    end
  end
  return nil
end

local function get_host_from_url(url, callback)
  vim.system({ "trurl", url, "--json" }, { text = true }, function(output)
    vim.schedule(function()
      if output.code ~= 0 then
        vim.notify("trurl failed " .. output.code .. "\n" .. output.stderr, vim.log.levels.ERROR, { title = "curl" })
        callback("trurl failed")
      end

      local url_json_string = output.stdout
      local url_json = vim.fn.json_decode(url_json_string)[1].parts
      local host = url_json.host .. (url_json.port and ":" .. url_json.port or "")

      if not host then
        vim.notify("Could not parse host from URL: " .. url, vim.log.levels.ERROR, { title = "curl" })
        callback("Could not parse host")
        return
      end

      callback(nil, host)
    end)
  end)
end

local function setup(options)
  vim.tbl_extend("force", global_options, options or {})

  vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = { "http://*", "https://*" },
    callback = function()
      local url = vim.fn.expand("%")
      get_host_from_url(url, function(err, host)
        if err then
          return
        end

        local args = global_options.host_args[host] or {}
        local tempfile = vim.fn.tempname()
        local args_list = vim.list_extend({ "curl", "-sL", "--dump-header", tempfile, url }, args)

        vim.system(args_list, { text = true }, function(output)
          vim.schedule(function()
            local content_type = read_content_type_from_tempfile(tempfile)
            local filetype = global_options.filetypes[content_type or ""] or "text"

            vim.uv.fs_unlink(tempfile)

            if output.code ~= 0 then
              vim.notify("curl failed " .. output.code .. "\n" .. output.stderr, vim.log.levels.ERROR, { title = "curl" })
              return
            end
            local lines = vim.split(output.stdout, "\n", { plain = true })
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            vim.bo.buftype = "nofile"
            vim.bo.filetype = filetype
          end)
        end)
      end)
    end,
  })
end

return {
  setup = setup,
}
