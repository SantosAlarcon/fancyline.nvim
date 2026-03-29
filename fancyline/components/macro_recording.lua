local M = {}

function M.provider(opts, ctx)
  local recording = vim.fn.reg_recording()
  if not recording or recording == "" then
    return nil
  end

  local icon = (opts.icon and opts.icon.symbol) or "●"
  local text = icon .. " " .. recording

  return {
    text = text,
    icon = {
      symbol = " ",
      fg = opts.icon and opts.icon.fg,
      bg = opts.icon and opts.icon.bg,
    },
    style = opts.style or "none",
    highlight = "FancylineMacroRecording",
    fg = opts.fg,
    bg = opts.bg,
    border = opts.border,
  }
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineMacroRecording", { fg = "#f44336", bold = true })
end

return M
