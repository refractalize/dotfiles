function concat(t1, t2)
  for i = 1, #t2 do
    t1[#t1 + 1] = t2[i]
  end
  return t1
end

function all_plugins(specs)
  local plugins = {}

  function add_plugins(specs)
    for i, v in ipairs(specs) do
      if type(v) == "table" then
        if type(v[1]) == "string" then
          table.insert(plugins, { name = v[1], config = v })
        else
          add_plugins(v)
        end
      else
        table.insert(plugins, { name = v, config = v })
      end
    end
  end

  add_plugins(specs)

  return plugins
end

return function()
  local module_files = vim.fs.find(function(name, path)
    return name:match("%.lua$")
  end, { path = vim.fn.stdpath('config') .. "/lua/plugins", limit = math.huge })
  local module_names = vim.tbl_map(function(filename)
    return "plugins." .. vim.fn.fnamemodify(filename, ":t:r")
  end, module_files)
  -- print(vim.inspect(module_names))
  local loaded_modules = vim.tbl_map(require, module_names)
  local plugins = all_plugins(loaded_modules)
  -- print("plugins: " .. vim.inspect(plugins))
end
