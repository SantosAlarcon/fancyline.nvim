local M = {}

function M.provider(opts, ctx)
  local bufname = vim.api.nvim_buf_get_name(ctx.bufnr)
  if bufname == "" then
    return nil
  end

  local ok, stat = pcall(vim.loop.fs_stat, bufname)
  if not ok or not stat then
    return nil
  end

  local size = stat.size
  if size == 0 then
    return nil
  end

  local units = { "B", "KB", "MB", "GB", "TB" }
  local unit_index = 1
  local display_size = size

  while display_size >= 1024 and unit_index < #units do
    display_size = display_size / 1024
    unit_index = unit_index + 1
  end

  local text
  if unit_index == 1 then
    text = tostring(display_size) .. " " .. units[unit_index]
  else
    text = string.format("%.1f %s", display_size, units[unit_index])
  end

  local icon_symbol = " "
  if opts.icon then
    if type(opts.icon) == "table" and opts.icon.symbol then
      icon_symbol = opts.icon.symbol
    elseif type(opts.icon) == "string" then
      icon_symbol = opts.icon
    end
  end

  return {
    text = text,
    icon = {
      symbol = icon_symbol,
      fg = opts.icon and opts.icon.fg,
      bg = opts.icon and opts.icon.bg,
    },
    style = opts.style or "none",
    highlight = "FancylineFilesize",
    fg = opts.fg,
    bg = opts.bg,
    border = opts.border,
  }
end

return M
