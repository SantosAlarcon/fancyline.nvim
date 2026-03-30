local M = {}

local cache = require("fancyline.utils.cache")

local LSP_CACHE_TTL = 5000

---@type table<number, string[]>
local lsp_cache = {}

function M.get_active(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local cached = lsp_cache[bufnr]
  if cached then
    return cached
  end

  local ok, clients = pcall(vim.lsp.get_clients, { bufnr = bufnr })
  if not ok or not clients or #clients == 0 then
    lsp_cache[bufnr] = {}
    return {}
  end

  local names = {}
  for _, client in ipairs(clients) do
    if client.name then
      table.insert(names, client.name)
    end
  end

  lsp_cache[bufnr] = names
  return names
end

function M.invalidate_buf(bufnr)
  if bufnr then
    lsp_cache[bufnr] = nil
  else
    lsp_cache = {}
  end
end

function M.invalidate_all()
  lsp_cache = {}
end

return M
