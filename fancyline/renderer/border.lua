local M = {}

M.styles = {
  square = { left = "󰝤", right = "󰝤", icon_gap = "  " },
  round = { left = "", right = "", icon_gap = "  " },
  slanted = { left = "", right = "", icon_gap = "  " },
  arrow = { left = "", right = "", icon_gap = "  " },
  none = { left = "", right = "", icon_gap = " " },
  -- Tagged style: icon has its own pill, text follows
  tagged = { left = "█", right = " ", icon_gap = " " },
}

-- Separate caches for content and border highlights
local content_cache = {}
local border_cache = {}
local content_hl_counter = 0
local border_hl_counter = 0

-- Resolve "mode" to the actual mode color from theme
local function resolve_mode_color(color_spec, state)
  if color_spec ~= "mode" then
    return color_spec
  end

  local theme = require("fancyline.themes")
  local current_theme = theme.get("auto")

  local mode_map = {
    n = "n", i = "i", v = "v", V = "v", ["^V"] = "v",
    t = "t", ["!"] = "t", c = "c",
    r = "r", R = "r", rv = "r",
    s = "s", S = "s", ["^S"] = "s"
  }

  local mode_key = mode_map[state] or "n"
  return current_theme.modes[mode_key] or "#ABB2BF"
end

local function get_hl_name(name, fg, bg)
  -- If no custom fg/bg, use the original highlight name directly
  if not fg and not bg then
    return name
  end

  local key = string.format("%s_%s_%s", name, fg or "", bg or "")
  if not content_cache[key] then
    content_hl_counter = content_hl_counter + 1
    local hl_name = "FancylineDynamic" .. content_hl_counter
    vim.api.nvim_set_hl(0, hl_name, {
      fg = fg,
      bg = bg,
      bold = true,
    })
    content_cache[key] = hl_name
  end
  return content_cache[key]
end

local function get_border_hl(fg, bg)
  local key = string.format("border_%s_%s", fg or "", bg or "")
  if not border_cache[key] then
    border_hl_counter = border_hl_counter + 1
    local hl_name = "FancylineBorderDynamic" .. border_hl_counter
    vim.api.nvim_set_hl(0, hl_name, {
      fg = fg,
      bg = bg,
    })
    border_cache[key] = hl_name
  end
  return border_cache[key]
end

function M.get_style(style_name)
  return M.styles[style_name] or M.styles.none
end

-- Parse icon config: can be string or table
function M.parse_icon(icon_cfg)
  if type(icon_cfg) == "string" then
    return { symbol = icon_cfg, fg = nil, bg = nil, states = nil }
  elseif type(icon_cfg) == "table" and icon_cfg.symbol then
    return {
      symbol = icon_cfg.symbol,
      fg = icon_cfg.fg,
      bg = icon_cfg.bg,
      states = icon_cfg.states,
    }
  elseif type(icon_cfg) == "table" then
    -- Backward compatibility: table without symbol (old format like { icon = "X" })
    return { symbol = icon_cfg.icon or "", fg = nil, bg = nil, states = nil }
  end
  return { symbol = "", fg = nil, bg = nil, states = nil }
end

-- Get colors for a specific state
function M.get_icon_colors(icon_cfg, state)
  if icon_cfg and icon_cfg.states and icon_cfg.states[state] then
    local state_cfg = icon_cfg.states[state]
    return state_cfg.fg, state_cfg.bg
  end
  return nil, nil
end

function M.render_component(icon, text, style_name, highlight, fg, bg, state)
  local style = M.get_style(style_name)
  local base_hl = highlight or "FancylineComponent"

  -- Resolve "mode" color
  fg = resolve_mode_color(fg, state)
  bg = resolve_mode_color(bg, state)

  -- Get dynamic highlight with custom fg/bg if provided
  local hl = get_hl_name(base_hl, fg, bg)
  local hl_prefix = "%#" .. hl .. "#"

  if style_name == "none" then
    local parts = {}
    if text and text ~= "" then
      table.insert(parts, hl_prefix .. text)
    end
    return table.concat(parts, " ") .. "%#FancylineReset#"
  end

  -- Create border highlight with bg if specified
  local border_hl = "%#FancylineBorder#"
  if bg then
    border_hl = "%#" .. get_border_hl("#5C6370", bg) .. "#"
  end

  local parts = {
    border_hl .. style.left,
    hl_prefix,
  }

  if text and text ~= "" then
    table.insert(parts, text)
  end

  table.insert(parts, border_hl .. style.right .. "%#FancylineReset#")

  return table.concat(parts, "")
end

-- Render full component with separate icon
function M.render_with_icon(icon_cfg, text, style_name, highlight, text_fg, text_bg, state)
  local style = M.get_style(style_name)

  -- Parse icon config
  local icon_data = M.parse_icon(icon_cfg)

  -- Get colors for the state
  local icon_fg, icon_bg = M.get_icon_colors(icon_data, state)

  -- If no specific icon state colors, use defaults from icon_cfg
  if not icon_fg then icon_fg = icon_data.fg end
  if not icon_bg then icon_bg = icon_data.bg end

  -- Resolve "mode" colors
  icon_fg = resolve_mode_color(icon_fg, state)
  icon_bg = resolve_mode_color(icon_bg, state)
  text_fg = resolve_mode_color(text_fg, state)
  text_bg = resolve_mode_color(text_bg, state)

  -- Determine text colors
  local base_hl = highlight or "FancylineComponent"
  local txt_fg = text_fg
  local txt_bg = text_bg or icon_bg  -- Share bg with text if icon has bg

  -- Get highlights
  local text_hl = get_hl_name(base_hl, txt_fg, txt_bg)
  local icon_hl = get_hl_name("Icon", icon_fg, icon_bg)

  -- Build parts
  local parts = {}

  -- Border highlight for icon
  local border_hl = "%#FancylineBorder#"
  if icon_bg then
    border_hl = "%#" .. get_border_hl("#5C6370", icon_bg) .. "#"
  end

  -- Tagged style: icon as a pill/tag, text follows without border
  if style_name == "tagged" and icon_data.symbol and icon_data.symbol ~= "" then
    table.insert(parts, border_hl .. style.left)
    table.insert(parts, "%#" .. icon_hl .. "#" .. icon_data.symbol)
    table.insert(parts, border_hl .. style.right)
    table.insert(parts, style.icon_gap)
    if text and text ~= "" then
      table.insert(parts, "%#" .. text_hl .. "#" .. text)
    end
    table.insert(parts, "%#FancylineReset#")
    return table.concat(parts, "")
  end

  -- None style: no borders, just icon and text with spacing
  if style_name == "none" then
    if icon_data.symbol and icon_data.symbol ~= "" then
      table.insert(parts, "%#" .. icon_hl .. "#" .. icon_data.symbol .. style.icon_gap)
    end
    if text and text ~= "" then
      table.insert(parts, "%#" .. text_hl .. "#" .. text)
    end
    if #parts > 0 then
      table.insert(parts, "%#FancylineReset#")
    end
    return table.concat(parts, "")
  end

  -- Normal style: border around everything
  table.insert(parts, border_hl .. style.left)

  -- Icon (rendered separately with its own color)
  if icon_data.symbol and icon_data.symbol ~= "" then
    table.insert(parts, "%#" .. icon_hl .. "#" .. icon_data.symbol .. style.icon_gap)
  end

  -- Text
  if text and text ~= "" then
    table.insert(parts, "%#" .. text_hl .. "#" .. text)
  end

  -- Border end
  table.insert(parts, border_hl .. style.right .. "%#FancylineReset#")

  return table.concat(parts, "")
end

function M.register_styles(styles)
  for name, def in pairs(styles) do
    M.styles[name] = def
  end
end

function M.clear_cache()
  content_cache = {}
  border_cache = {}
  content_hl_counter = 0
  border_hl_counter = 0
end

-- Render with custom border (separate fg/bg for left/right)
function M.render_custom_border(border_cfg, icon_cfg, text, highlight, fg, bg, state)
  local theme = require("fancyline.themes")
  local default_border = theme.get_default().border or "#5c6370"

  -- Parse icon config
  local icon_data = M.parse_icon(icon_cfg)

  -- Get icon colors for state
  local icon_fg, icon_bg = M.get_icon_colors(icon_data, state)
  if not icon_fg then icon_fg = icon_data.fg end
  if not icon_bg then icon_bg = icon_data.bg end

  -- Resolve "mode" colors
  icon_fg = resolve_mode_color(icon_fg, state)
  icon_bg = resolve_mode_color(icon_bg, state)
  fg = resolve_mode_color(fg, state)
  bg = resolve_mode_color(bg, state)

  -- Get style for each side
  local left_style_name = border_cfg.left and border_cfg.left.style or "round"
  local right_style_name = border_cfg.right and border_cfg.right.style or "round"
  local left_style = M.get_style(left_style_name)
  local right_style = M.get_style(right_style_name)

  -- Border colors with defaults from theme and resolve "mode"
  local left_fg = resolve_mode_color(border_cfg.left and border_cfg.left.fg, state) or default_border
  local left_bg = resolve_mode_color(border_cfg.left and border_cfg.left.bg, state) or "NONE"
  local right_fg = resolve_mode_color(border_cfg.right and border_cfg.right.fg, state) or default_border
  local right_bg = resolve_mode_color(border_cfg.right and border_cfg.right.bg, state) or "NONE"

  -- Content gap between icon and text
  local content_gap = border_cfg.content_gap or " "

  -- Get border highlights
  local left_hl = "%#" .. get_border_hl(left_fg, left_bg) .. "#"
  local right_hl = "%#" .. get_border_hl(right_fg, right_bg) .. "#"

  -- Content highlight
  local base_hl = highlight or "FancylineComponent"
  local content_hl = get_hl_name(base_hl, fg, bg)
  local icon_hl = get_hl_name("Icon", icon_fg, icon_bg)

  -- Build parts
  local parts = {}

  -- Left border
  table.insert(parts, left_hl .. left_style.left)

  -- Icon
  if icon_data.symbol and icon_data.symbol ~= "" then
    table.insert(parts, "%#" .. icon_hl .. "#" .. icon_data.symbol .. content_gap)
  end

  -- Text
  if text and text ~= "" then
    table.insert(parts, "%#" .. content_hl .. "#" .. text)
  end

  -- Right border
  table.insert(parts, right_hl .. right_style.right .. "%#FancylineReset#")

  return table.concat(parts, "")
end

return M
