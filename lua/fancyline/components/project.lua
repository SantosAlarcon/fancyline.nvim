local M = {}

---Provider function for the project component.
---@param opts? FancylineProjectComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local git_utils_ok, git_utils = pcall(require, "fancyline.utils.git")
  if not git_utils_ok then
    return nil
  end

  local root = git_utils.get_root()
  if not root then
    return nil
  end

  local project_name = vim.fn.fnamemodify(root, ":t")
  if not project_name or project_name == "" then
    return nil
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
    text = project_name,
    icon = {
      symbol = icon_symbol,
      fg = opts.icon and opts.icon.fg,
      bg = opts.icon and opts.icon.bg,
    },
    style = opts.style or "none",
    highlight = "FancylineProject",
    fg = opts.fg,
    bg = opts.bg,
    bold = opts.bold,
    border = opts.border,
  }
end

return M
