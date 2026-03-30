local M = {}

---Provider function for the search_stats component.
---@param opts? FancylineSearchStatsComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local search_count = vim.fn.searchcount({ recompute = 1 })
  if not search_count or search_count.total == 0 then
    local has_nvim_09 = vim.fn.has("nvim-0.9") == 1
    if not has_nvim_09 then
      return nil
    end
    local result = vim.fn.searchcount()
    if not result or result.total == 0 then
      return nil
    end
    search_count = result
  end

  local current = search_count.current or 0
  local total = search_count.total or 0

  if total == 0 then
    return nil
  end

  local format = opts.format or "%d/%d"
  local text = string.format(format, current, total)

  local icon_symbol = " "
  if opts.icon then
    if type(opts.icon) == "table" and opts.icon.symbol then
      icon_symbol = opts.icon.symbol
    elseif type(opts.icon) == "string" then
      icon_symbol = opts.icon
    end
  end

  local highlight = "FancylineSearchStats"
  if current == 0 and total > 0 then
    highlight = "FancylineSearchNoMatch"
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
  vim.api.nvim_set_hl(0, "FancylineSearchStats", { fg = "#ff9800", bold = false })
  vim.api.nvim_set_hl(0, "FancylineSearchNoMatch", { fg = "#f44336", bold = false })
end

return M
