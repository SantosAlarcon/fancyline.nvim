local M = {}

local DIAG_STATE = { hl = "FancylineDiagInfo", fg = "#56b6c2" }

function M.provider(opts, ctx)
  local diag_utils_ok, diag_utils = pcall(require, "fancyline.utils.diagnostics")
  if not diag_utils_ok then
    return nil
  end

  local counts = diag_utils.get_counts(ctx.bufnr)

  if counts.info == 0 then
    return nil
  end

  local icon = opts.icon or "󰀿"

  return {
    text = icon .. " " .. counts.info,
    highlight = DIAG_STATE.hl,
    fg = DIAG_STATE.fg,
    style = opts.style or "none",
  }
end

return M
