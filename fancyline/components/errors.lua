local M = {}

local diag_utils = require("fancyline.utils.diagnostics")

local DIAG_STATE = { hl = "FancylineDiagError", fg = "#f44336" }

function M.provider(opts, ctx)
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
  }
end

return M
