local M = {}

function M.provider(opts, ctx)
  local lsp_utils_ok, lsp_utils = pcall(require, "fancyline.utils.lsp")
  if not lsp_utils_ok then
    return nil
  end

  local servers = lsp_utils.get_active(ctx.bufnr)

  if #servers == 0 then
    return nil
  end

  -- Build icon config
  local icon_cfg
  if type(opts.icon) == "table" and opts.icon.symbol then
    icon_cfg = { symbol = opts.icon.symbol, fg = opts.icon.fg, bg = opts.icon.bg }
  else
    icon_cfg = { symbol = opts.icon or "⚙", fg = nil, bg = nil }
  end

  return {
    text = " " .. table.concat(servers, ", "),
    icon = icon_cfg,
    style = opts.style or "round",
    highlight = "FancylineLsp",
    state = #servers > 0 and "connected" or "disconnected",
    fg = opts.fg,
    bg = opts.bg,
    border = opts.border,
  }
end

return M
