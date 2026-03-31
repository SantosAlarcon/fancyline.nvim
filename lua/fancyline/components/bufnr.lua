local M = {}

---Provider function for the bufnr component.
---@param opts? FancylineBufnrComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local bufnr = ctx.bufnr
  local text = "#" .. bufnr

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
    highlight = "FancylineBufnr",
    fg = opts.fg,
    bg = opts.bg,
    bold = opts.bold,
    border = opts.border,
  }
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineBufnr", { fg = "#78909c", bold = false })
end

return M
