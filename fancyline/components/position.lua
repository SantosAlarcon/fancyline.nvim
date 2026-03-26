local M = {}

function M.provider(opts, ctx)
  local format = opts.format or "Ln %l, Col %c"

  local line = vim.fn.line(".")
  local col = vim.fn.col(".")
  local total_lines = vim.api.nvim_buf_line_count(ctx.bufnr)
  local percentage = math.floor((line / total_lines) * 100)

  local text = format
  text = text:gsub("%%%%", "%%")
  text = text:gsub("%%l", tostring(line))
  text = text:gsub("%%c", tostring(col))
  text = text:gsub("%%L", tostring(total_lines))
  text = text:gsub("%%p", tostring(percentage))
  text = text:gsub("%%P", tostring(percentage) .. "%")

  local icon_cfg
  if type(opts.icon) == "table" and opts.icon.symbol then
    icon_cfg = { symbol = opts.icon.symbol, fg = opts.icon.fg, bg = opts.icon.bg }
  else
    icon_cfg = { symbol = opts.icon or " ", fg = nil, bg = nil }
  end

  return {
    text = text,
    icon = icon_cfg,
    style = opts.style or "none",
    highlight = "FancylinePosition",
    fg = opts.fg,
    bg = opts.bg,
    border = opts.border,
    state = "n",
  }
end

return M
