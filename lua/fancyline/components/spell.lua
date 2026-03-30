local M = {}

---Provider function for the spell component.
---@param opts? FancylineSpellComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local spell = vim.wo.spell
  if not spell then
    return nil
  end

  local icon = (opts.icon and opts.icon.symbol) or "Spell"
  local text = icon

  return {
    text = text,
    icon = {
      symbol = " ",
      fg = opts.icon and opts.icon.fg,
      bg = opts.icon and opts.icon.bg,
    },
    style = opts.style or "none",
    highlight = "FancylineSpell",
    fg = opts.fg,
    bg = opts.bg,
    border = opts.border,
  }
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineSpell", { fg = "#9c27b0", bold = false })
end

return M
