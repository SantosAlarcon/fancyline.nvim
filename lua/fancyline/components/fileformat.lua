local M = {}

---Provider function for the fileformat component.
---@param opts? FancylineFileformatComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local fileformat = vim.bo.fileformat
  local text

  if fileformat == "unix" then
    text = "LF"
  elseif fileformat == "dos" then
    text = "CRLF"
  elseif fileformat == "mac" then
    text = "CR"
  else
    text = fileformat:upper()
  end

  local icon_symbol = " "
  if opts.icon then
    if type(opts.icon) == "table" and opts.icon.symbol then
      icon_symbol = opts.icon.symbol
    elseif type(opts.icon) == "string" then
      icon_symbol = opts.icon
    end
  end

  local highlight = "FancylineFileformat"
  if fileformat == "dos" then
    highlight = "FancylineFileformatDos"
  elseif fileformat == "mac" then
    highlight = "FancylineFileformatMac"
  end

  return {
    text = text,
    icon = {
      symbol = icon_symbol,
      fg = opts.icon and opts.icon.fg,
      bg = opts.icon and opts.icon.bg,
    },
    style = opts.style or "none",
    highlight = highlight,
    fg = opts.fg,
    bg = opts.bg,
    bold = opts.bold,
    border = opts.border,
  }
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineFileformat", { fg = "#607d8b", bold = false })
  vim.api.nvim_set_hl(0, "FancylineFileformatDos", { fg = "#4caf50", bold = false })
  vim.api.nvim_set_hl(0, "FancylineFileformatMac", { fg = "#ff9800", bold = false })
end

return M
