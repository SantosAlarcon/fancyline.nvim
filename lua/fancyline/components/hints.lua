local M = {}

local DIAG_STATE = { hl = "FancylineDiagHint", fg = "#61afef" }

---Provider function for the hints component.
---@param opts? FancylineHintsComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local diag_utils_ok, diag_utils = pcall(require, "fancyline.utils.diagnostics")
  if not diag_utils_ok then
    return nil
  end

  local counts = diag_utils.get_counts(ctx.bufnr)

  if counts.hint == 0 then
    return nil
  end

  local icon = opts.icon or "󰛿"

  return {
    text = icon .. " " .. counts.hint,
    highlight = DIAG_STATE.hl,
    fg = DIAG_STATE.fg,
    style = opts.style or "none",
    fg = opts.fg,
    bg = opts.bg,
    bold = opts.bold,
  }
end

return M
