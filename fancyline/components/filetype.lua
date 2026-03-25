local M = {}

function M.provider(opts, ctx)
  local filetype = vim.bo[ctx.bufnr].filetype

  if filetype == "" then
    return nil
  end

  local display_ft = filetype

  if opts.lowercase then
    display_ft = string.lower(filetype)
  elseif opts.titlecase then
    display_ft = filetype:sub(1, 1):upper() .. filetype:sub(2):lower()
  end

  -- Build icon config
  local icon_cfg
  if type(opts.icon) == "table" and opts.icon.symbol then
    icon_cfg = { symbol = opts.icon.symbol, fg = opts.icon.fg, bg = opts.icon.bg }
  else
    icon_cfg = { symbol = opts.icon or " ", fg = nil, bg = nil }
  end

  return {
    text = display_ft,
    icon = icon_cfg,
    style = opts.style or "square",
    highlight = "FancylineFiletype",
    fg = opts.fg,
    bg = opts.bg,
    border = opts.border,
    state = "n",  -- default state for "mode" color resolution
  }
end

return M
