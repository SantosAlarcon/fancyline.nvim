local M = {}

function M.provider(opts, ctx)
  local bufnr = ctx.bufnr
  
  -- Get git status from gitsigns
  local status_dict = vim.b[bufnr].gitsigns_status_dict
  
  -- If no git info, don't show anything
  if not status_dict or status_dict.head == "" or status_dict.head == nil then
    return nil
  end
  
  local icon = opts.icon and (opts.icon.symbol or opts.icon) or " "
  
  -- Show git status summary
  local changed = status_dict.changed or 0
  local added = status_dict.added or 0
  local removed = status_dict.removed or 0
  local parts = {}
  
  if added > 0 then table.insert(parts, "+" .. added) end
  if changed > 0 then table.insert(parts, "~" .. changed) end
  if removed > 0 then table.insert(parts, "-" .. removed) end
  
  local text = #parts > 0 and table.concat(parts, " ") or ""
  
  if text == "" then
    return nil
  end
  
  return {
    text = text,
    icon = {
      symbol = icon,
      fg = opts.icon and opts.icon.fg,
      bg = opts.icon and opts.icon.bg,
    },
    style = opts.style or "none",
    highlight = "FancylineChecktime",
    fg = opts.fg,
    bg = opts.bg,
    border = opts.border,
  }
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineChecktime", { fg = "#ff9800", bold = true })
end

return M
