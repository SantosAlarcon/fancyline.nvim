local M = {}

---Provider function for the lsp_clients component.
---@param opts? FancylineLspClientsComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local lsp_ok, lsp_util = pcall(require, "lspconfig.util")
  if not lsp_ok then
    local active_clients = vim.lsp.get_active_clients({ bufnr = ctx.bufnr })
    if #active_clients == 0 then
      return nil
    end
    return M._format_clients(active_clients, opts)
  end

  local buf_ft = vim.api.nvim_buf_get_option(ctx.bufnr, "filetype")
  local clients = vim.lsp.get_active_clients({ bufnr = ctx.bufnr })

  local relevant_clients = {}
  for _, client in ipairs(clients) do
    local client_ft = client.config and client.config.filetypes
    if client_ft then
      for _, ft in ipairs(client_ft) do
        if ft == buf_ft then
          table.insert(relevant_clients, client)
          break
        end
      end
    end
  end

  if #relevant_clients == 0 and #clients == 0 then
    return nil
  end

  local display_clients = #relevant_clients > 0 and relevant_clients or clients
  return M._format_clients(display_clients, opts)
end

function M._format_clients(clients, opts)
  local max_clients = opts.max_clients or 3
  local show_versions = opts.show_version ~= false

  local names = {}
  for i, client in ipairs(clients) do
    if i > max_clients then
      break
    end
    local name = client.name or "LSP"
    if show_versions and client.version then
      local version = client.version:match("^([%d%.]+)")
      if version then
        name = name .. " " .. version
      end
    end
    table.insert(names, name)
  end

  local extra = #clients - max_clients
  if extra > 0 then
    table.insert(names, "+" .. tostring(extra))
  end

  if #names == 0 then
    return nil
  end

  local text = table.concat(names, ", ")

  local icon_symbol = " "
  if opts.icon then
    if type(opts.icon) == "table" and opts.icon.symbol then
      icon_symbol = opts.icon.symbol
    elseif type(opts.icon) == "string" then
      icon_symbol = opts.icon
    end
  end

  return {
    text = text,
    icon = {
      symbol = icon_symbol,
      fg = opts.icon and opts.icon.fg,
      bg = opts.icon and opts.icon.bg,
    },
    style = opts.style or "none",
    highlight = "FancylineLspClients",
    fg = opts.fg,
    bg = opts.bg,
    bold = opts.bold,
    border = opts.border,
  }
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineLspClients", { fg = "#4caf50", bold = false })
end

return M
