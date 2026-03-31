local M = {}

---Provider function for the branch_status component.
---@param opts? FancylineBranchStatusComponent
---@param ctx FancylineContext
---@return FancylineComponentResult[]?
function M.provider(opts, ctx)
  local has_git, _ = pcall(require, "fancyline.utils.git")
  if not has_git then
    return nil
  end

  local git_utils = require("fancyline.utils.git")
  local ahead, behind = git_utils.get_ahead_behind()

  if not ahead and not behind then
    return nil
  end

  local parts = {}

  if ahead and ahead > 0 then
    local icon = (opts.icons and opts.icons.ahead) or "↑"
    table.insert(parts, {
      text = icon .. ahead,
      highlight = "FancylineGitAhead",
      style = "none",
      bold = opts.bold,
    })
  end

  if behind and behind > 0 then
    local icon = (opts.icons and opts.icons.behind) or "↓"
    table.insert(parts, {
      text = icon .. behind,
      highlight = "FancylineGitBehind",
      style = "none",
      bold = opts.bold,
    })
  end

  if #parts == 0 then
    return nil
  end

  return parts
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineGitAhead", { fg = "#4caf50", bold = false })
  vim.api.nvim_set_hl(0, "FancylineGitBehind", { fg = "#f44336", bold = false })
end

return M
