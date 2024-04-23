local namespace = vim.api.nvim_create_namespace("diagnostic_lines")

function add(message)
  if message == "" then
    message = nil
  end

  local current = vim.diagnostic.get(0, { namespace = namespace })

  local without = vim.tbl_filter(function(item)
    return not (item.bufnr == vim.fn.bufnr("%") and item.lnum == vim.fn.line(".") - 1)
  end, current)

  if #current == #without then
    table.insert(current, {
      lnum = vim.fn.line(".") - 1,
      col = 0,
      severity = vim.diagnostic.severity.INFO,
      message = message or "note",
    })
  else
    current = without
  end

  vim.diagnostic.set(namespace, 0, current)
end

function quickfix()
  vim.diagnostic.setqflist({
    namespace = namespace,
  })
end

function clear()
  vim.diagnostic.reset(namespace)
end

return {
  namespace = namespace,
  add = add,
  quickfix = quickfix,
  clear = clear,
}
