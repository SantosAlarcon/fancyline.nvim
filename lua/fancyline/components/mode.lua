local M = {}

-- Map modes to their highlight group name
local mode_highlights = {
  n = "FancylineModeNormal",
  i = "FancylineModeInsert",
  v = "FancylineModeVisual",
  V = "FancylineModeVisual",
  ["^V"] = "FancylineModeVisual",
  t = "FancylineModeTerminal",
  ["!"] = "FancylineModeTerminal",
  c = "FancylineModeCommand",
  r = "FancylineModeReplace",
  R = "FancylineModeReplace",
  rv = "FancylineModeReplace",
  s = "FancylineModeSelect",
  S = "FancylineModeSelect",
  ["^S"] = "FancylineModeSelect",
}

-- Map modes to theme colors
local mode_theme_keys = {
  n = "n",
  i = "i",
  v = "v",
  V = "v",
  ["^V"] = "v",
  t = "t",
  ["!"] = "t",
  c = "c",
  r = "r",
  R = "r",
  rv = "r",
  s = "s",
  S = "s",
  ["^S"] = "s",
}

---Provider function for the mode component.
---@param opts? FancylineModeComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local current_mode = vim.fn.mode(1)

  -- If opts is a function, call it with the current mode
  if type(opts) == "function" then
    local result = opts(current_mode)
    if result then
      -- Parse icon if it's a table with symbol
      local icon_cfg = result.icon
      if type(icon_cfg) == "string" then
        icon_cfg = { symbol = icon_cfg }
      elseif type(icon_cfg) == "table" and not icon_cfg.symbol then
        icon_cfg = { symbol = icon_cfg.icon or "" }
      end

      return {
        text = result.text or current_mode,
        icon = icon_cfg,
        fg = result.fg,
        bg = result.bg,
        style = result.style or "round",
        highlight = result.highlight or mode_highlights[current_mode] or "FancylineModeNormal",
        state = current_mode,
        border = result.border,
      }
    end
    return nil
  end

  -- Original table-based config
  local mode_map = opts.text or {}

  local text = mode_map[current_mode]
  if not text then
    text = current_mode
  end

  -- Handle icon special values
  local icon_cfg
  local icon_type = type(opts.icon)

  if icon_type == "table" then
    local symbol = opts.icon.symbol
    if symbol == "neovim" then
      icon_cfg = { symbol = "", fg = opts.icon.fg, bg = opts.icon.bg }
    elseif symbol == "vim" then
      icon_cfg = { symbol = "", fg = opts.icon.fg, bg = opts.icon.bg }
    elseif symbol == false then
      icon_cfg = { symbol = "" }
    else
      icon_cfg = { symbol = symbol or "", fg = opts.icon.fg, bg = opts.icon.bg }
    end
  elseif icon_type == "string" then
    -- Handle special string values
    if opts.icon == "neovim" then
      icon_cfg = { symbol = "", fg = nil, bg = nil }
    elseif opts.icon == "vim" then
      icon_cfg = { symbol = "", fg = nil, bg = nil }
    elseif opts.icon == "false" then
      icon_cfg = { symbol = "" }
    else
      icon_cfg = { symbol = opts.icon, fg = nil, bg = nil }
    end
  else
    icon_cfg = { symbol = "", fg = nil, bg = nil }
  end

  -- Get highlight based on current mode
  local highlight = mode_highlights[current_mode] or "FancylineModeNormal"

  -- Get mode color from theme
  local theme = require("fancyline.themes")
  local current_theme = theme.get("auto")
  local mode_color = current_theme.modes[mode_theme_keys[current_mode]] or "#ABB2BF"

  -- Use icon colors from config or fallback to mode color
  if not icon_cfg.fg then
    icon_cfg.fg = mode_color
  end

  -- Use colors from config or fallback to mode color
  local fg = opts.fg or mode_color
  local bg = opts.bg

  return {
    text = text,
    icon = icon_cfg,
    style = opts.style or "round",
    highlight = highlight,
    fg = fg,
    bg = bg,
    state = current_mode,
    border = opts.border,
  }
end

return M
