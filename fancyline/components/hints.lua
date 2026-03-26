local M = {}

local diag_utils = require("fancyline.utils.diagnostics")

local DIAG_STATE = { hl = "FancylineDiagHint", fg = "#61afef" }

function M.provider(opts, ctx)
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
  }
end

return M
