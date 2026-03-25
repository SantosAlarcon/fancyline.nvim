local M = {}

local git_utils = require("fancyline.utils.git")

function M.provider(opts, ctx)
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
