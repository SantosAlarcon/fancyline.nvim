local M = {}

function M.provider(opts, ctx)
  local quickfix_list = vim.fn.getqflist()
  local count = 0

  for _, item in ipairs(quickfix_list) do
    if item.valid then
      count = count + 1
    end
  end

  if count == 0 then
    return nil
  end

  local text = tostring(count) .. " quickfix"

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
    highlight = "FancylineQuickfix",
    fg = opts.fg,
    bg = opts.bg,
    border = opts.border,
  }
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineQuickfix", { fg = "#ff9800", bold = false })
end

return M
