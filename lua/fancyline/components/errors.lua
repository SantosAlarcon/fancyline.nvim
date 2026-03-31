local M = {}

local DIAG_STATE = { hl = "FancylineDiagError", fg = "#f44336" }

---Provider function for the errors component.
---@param opts? FancylineErrorsComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local diag_utils_ok, diag_utils = pcall(require, "fancyline.utils.diagnostics")
  if not diag_utils_ok then
    return nil
  end

  local counts = diag_utils.get_counts(ctx.bufnr)

  if counts.error == 0 then
    return nil
  end

  local icon = opts.icon or "󰅜"

  return {
    text = icon .. " " .. counts.error,
    highlight = DIAG_STATE.hl,
    fg = DIAG_STATE.fg,
    style = opts.style or "none",
    fg = opts.fg,
    bg = opts.bg,
    bold = opts.bold,
  }
end

return M
