local M = {}

---Provider function for the encoding component.
---@param opts? FancylineEncodingComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local encoding = vim.opt_local.fileencoding:get()
  if not encoding or encoding == "" then
    encoding = "UTF-8"
  end

  local icon = opts.icon or "󰈔"
  local text = string.upper(encoding)

  return {
    text = icon .. " " .. text,
    highlight = "FancylineEncoding",
    style = opts.style or "none",
    fg = opts.fg,
    bg = opts.bg,
    bold = opts.bold,
  }
end

return M
