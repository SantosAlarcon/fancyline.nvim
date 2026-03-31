local M = {}

---Provider function for the reload component.
---@param opts? FancylineReloadComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local reloading = (vim.v.reload_buf or 0) > 0
  if not reloading then
    return nil
  end

  local icon = (opts.icon and opts.icon.symbol) or "RELOAD"
  local text = icon

  return {
    text = text,
    icon = {
      symbol = " ",
      fg = opts.icon and opts.icon.fg,
      bg = opts.icon and opts.icon.bg,
    },
    style = opts.style or "none",
    highlight = "FancylineReload",
    fg = opts.fg,
    bg = opts.bg,
    bold = opts.bold,
    border = opts.border,
  }
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineReload", { fg = "#2196f3", bold = true })
end

return M
