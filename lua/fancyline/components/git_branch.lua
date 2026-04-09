local M = {}

-- Hoist require to module level for performance
local git_utils_ok, git_utils = pcall(require, "fancyline.utils.git")

---Provider function for the git_branch component.
---@param opts? FancylineGitBranchComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  -- Use module-level git_utils (hoisted for performance)
  if not git_utils_ok then
    return nil
  end

  local branch = git_utils.get_branch()
  if not branch or branch == "" then
    return nil
  end

  -- Get icon only if explicitly configured
  local icon = nil
  if opts.icon then
    local icon_symbol = ""
    if type(opts.icon) == "table" and opts.icon.symbol then
      icon_symbol = opts.icon.symbol
    elseif type(opts.icon) == "string" then
      icon_symbol = opts.icon
    end
    if icon_symbol and icon_symbol ~= "" then
      icon = { symbol = icon_symbol, fg = opts.fg, bg = opts.bg }
    end
  end

  return {
    text = branch,
    icon = icon,
    style = opts.style or "none",
    highlight = "FancylineGitBranch",
    state = "clean",
    fg = opts.fg,
    bg = opts.bg,
    bold = opts.bold,
    border = opts.border,
  }
end

return M
