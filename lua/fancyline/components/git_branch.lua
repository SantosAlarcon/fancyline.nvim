local M = {}

---Provider function for the git_branch component.
---@param opts? FancylineGitBranchComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local git_utils_ok, git_utils = pcall(require, "fancyline.utils.git")
  if not git_utils_ok then
    return nil
  end

  local branch = git_utils.get_branch()
  if not branch or branch == "" then
    return nil
  end

  -- Get icon from opts or use default
  local icon_symbol = " "
  if opts.icon then
    if type(opts.icon) == "table" and opts.icon.symbol then
      icon_symbol = opts.icon.symbol
    elseif type(opts.icon) == "string" then
      icon_symbol = opts.icon
    end
  end

  -- Get style
  local style = opts.style or "none"

  -- Get colors
  local fg = opts.fg
  local bg = opts.bg

  -- Get border config
  local border = opts.border

  return {
    text = branch,
    icon = { symbol = icon_symbol, fg = fg, bg = bg },
    style = style,
    highlight = "FancylineGitBranch",
    state = "clean",
    fg = fg,
    bg = bg,
    border = border,
  }
end

return M
