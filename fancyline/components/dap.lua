local M = {}

function M.provider(opts, ctx)
  local has_dap, dap = pcall(require, "dap")
  if not has_dap then
    return nil
  end

  local session = dap.session()
  if not session then
    return nil
  end

  local state = session.state or "unknown"
  local icon = (opts.icons and opts.icons[state]) or opts.icon or "DAP"
  local text

  if state == "running" then
    text = icon .. " running"
  elseif state == "stopped" then
    text = icon .. " stopped"
  elseif state == "breakpoint" then
    text = icon .. " breakpoint"
  elseif state == "exception" then
    text = icon .. " exception"
  else
    text = icon
  end

  local icon_symbol = " "
  if opts.icon then
    if type(opts.icon) == "table" and opts.icon.symbol then
      icon_symbol = opts.icon.symbol
    elseif type(opts.icon) == "string" then
      icon_symbol = opts.icon
    end
  end

  local highlight = "FancylineDap"
  if state == "running" then
    highlight = "FancylineDapRunning"
  elseif state == "stopped" then
    highlight = "FancylineDapStopped"
  elseif state == "exception" then
    highlight = "FancylineDapException"
  end

  return {
    text = text,
    icon = {
      symbol = icon_symbol,
      fg = opts.icon and opts.icon.fg,
      bg = opts.icon and opts.icon.bg,
    },
    style = opts.style or "none",
    highlight = highlight,
    fg = opts.fg,
    bg = opts.bg,
    border = opts.border,
  }
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineDap", { fg = "#4caf50", bold = false })
  vim.api.nvim_set_hl(0, "FancylineDapRunning", { fg = "#4caf50", bold = true })
  vim.api.nvim_set_hl(0, "FancylineDapStopped", { fg = "#ff9800", bold = true })
  vim.api.nvim_set_hl(0, "FancylineDapException", { fg = "#f44336", bold = true })
end

return M
