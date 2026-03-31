local M = {}

---Provider function for the cwd component.
---@param opts? FancylineCwdComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local cwd = vim.fn.getcwd()
  if not cwd or cwd == "" then
    return nil
  end

  local git_utils_ok, git_utils = pcall(require, "fancyline.utils.git")
  local project_root = git_utils_ok and git_utils.get_root() or nil

  local display_path
  if project_root and cwd:find(project_root, 1, true) == 1 then
    display_path = cwd:gsub(project_root, "")
    if display_path == "" then
      display_path = "."
    elseif display_path:sub(1, 1) == "/" then
      display_path = display_path:sub(2)
    end
  else
    display_path = cwd
    if opts.max_length then
      local parts = {}
      for part in display_path:gmatch("[^/]+") do
        table.insert(parts, part)
      end
      if #parts > opts.max_length then
        display_path = table.concat(parts, "/", #parts - opts.max_length + 1)
      end
    end
  end

  if display_path == "" then
    display_path = "~"
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
    text = display_path,
    icon = {
      symbol = icon_symbol,
      fg = opts.icon and opts.icon.fg,
      bg = opts.icon and opts.icon.bg,
    },
    style = opts.style or "none",
    highlight = "FancylineCwd",
    fg = opts.fg,
    bg = opts.bg,
    bold = opts.bold,
    border = opts.border,
  }
end

return M
