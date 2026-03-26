local M = {}

local diag_utils = require("fancyline.utils.diagnostics")

local DIAG_STATE = { hl = "FancylineDiagWarn", fg = "#ff9800" }

function M.provider(opts, ctx)
  local counts = diag_utils.get_counts(ctx.bufnr)

  if counts.warn == 0 then
    return nil
  end

  local icon = opts.icon or "󰀦"

  return {
    text = icon .. " " .. counts.warn,
    highlight = DIAG_STATE.hl,
    fg = DIAG_STATE.fg,
    style = opts.style or "none",
  }
end

return M
