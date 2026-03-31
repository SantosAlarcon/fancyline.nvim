local M = {}

---Provider function for the git_diff component.
---@param opts? FancylineGitDiffComponent
---@param ctx FancylineContext
---@return FancylineComponentResult[]?
function M.provider(opts, ctx)
  local git_utils_ok, git_utils = pcall(require, "fancyline.utils.git")
  if not git_utils_ok then
    return nil
  end

  local counts = git_utils.get_diff_counts()
  if not counts then
    return nil
  end

  -- Build sections with colors
  local sections = {}

  if counts.added > 0 then
    table.insert(sections, {
      text = " " .. counts.added,
      highlight = "FancylineGitAdded",
      style = "none",
      bold = opts.bold,
    })
  end

  if counts.changed > 0 then
    table.insert(sections, {
      text = " " .. counts.changed,
      highlight = "FancylineGitChanged",
      style = "none",
      bold = opts.bold,
    })
  end

  if counts.untracked > 0 then
    table.insert(sections, {
      text = " " .. counts.untracked,
      highlight = "FancylineGitUntracked",
      style = "none",
      bold = opts.bold,
    })
  end

  return sections
end

return M
