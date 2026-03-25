local M = {}

function M.get_active(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local ok, clients = pcall(vim.lsp.get_clients, { bufnr = bufnr })
  if not ok or not clients or #clients == 0 then
    return {}
  end

  local names = {}
  for _, client in ipairs(clients) do
    if client.name then
      table.insert(names, client.name)
    end
  end

  return names
end

return M
