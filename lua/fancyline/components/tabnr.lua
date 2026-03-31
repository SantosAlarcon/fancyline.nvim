local M = {}

---Provider function for the tabnr component.
---@param opts? FancylineTabnrComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local tabpage = vim.api.nvim_get_current_tabpage()
  local tab_count = #vim.api.nvim_list_tabpages()
  local tab_num = vim.fn.tabpagenr()

  local text = tostring(tab_num) .. "/" .. tostring(tab_count)

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
    highlight = "FancylineTabnr",
    fg = opts.fg,
    bg = opts.bg,
    bold = opts.bold,
    border = opts.border,
  }
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineTabnr", { fg = "#78909c", bold = false })
end

return M
