local M = {}

-- Hoist require to module level for performance
local diag_utils_ok, diag_utils = pcall(require, "fancyline.utils.diagnostics")

-- Define diagnostic states with their colors
local DIAG_STATES = {
  error = { hl = "FancylineDiagError", fg = "#f44336" },
  warn = { hl = "FancylineDiagWarn", fg = "#ff9800" },
  info = { hl = "FancylineDiagInfo", fg = "#2196f3" },
  hint = { hl = "FancylineDiagHint", fg = "#4caf50" },
}

---Provider function for the diagnostics component.
---@param opts? FancylineDiagnosticsComponent
---@param ctx FancylineContext
---@return FancylineComponentResult[]?
function M.provider(opts, ctx)
  -- Use module-level diag_utils (hoisted for performance)
  if not diag_utils_ok then
    return nil
  end

  local counts = diag_utils.get_counts(ctx.bufnr)

  local has_errors = counts.error > 0
  local has_warns = counts.warn > 0
  local has_infos = counts.info > 0
  local has_hints = counts.hint > 0

  if not (has_errors or has_warns or has_infos or has_hints) then
    return nil
  end

  -- Build individual sections for each diagnostic type
  local sections = {}

  if has_errors then
    local icon = (opts.icons and opts.icons.error) or ""
    table.insert(sections, {
      text = icon .. " " .. counts.error,
      highlight = DIAG_STATES.error.hl,
      fg = DIAG_STATES.error.fg,
      style = "none",
    })
  end

  if has_warns then
    local icon = (opts.icons and opts.icons.warn) or ""
    table.insert(sections, {
      text = icon .. " " .. counts.warn,
      highlight = DIAG_STATES.warn.hl,
      fg = DIAG_STATES.warn.fg,
      style = "none",
    })
  end

  if has_infos then
    local icon = (opts.icons and opts.icons.info) or ""
    table.insert(sections, {
      text = icon .. " " .. counts.info,
      highlight = DIAG_STATES.info.hl,
      fg = DIAG_STATES.info.fg,
      style = "none",
    })
  end

  if has_hints then
    local icon = (opts.icons and opts.icons.hint) or "💡"
    table.insert(sections, {
      text = icon .. " " .. counts.hint,
      highlight = DIAG_STATES.hint.hl,
      fg = DIAG_STATES.hint.fg,
      style = "none",
    })
  end

  return sections
end

-- Register diagnostic highlight groups
function M.setup_highlights()
  for name, colors in pairs(DIAG_STATES) do
    vim.api.nvim_set_hl(0, colors.hl, { fg = colors.fg, bold = false })
  end
end

return M
