local M = {}

---@type table<string, FancylineStyleDefinition>
M.styles = {
	square = { left = "█", right = "█", icon_gap = " " },
	round = { left = "", right = "", icon_gap = " " },
	slanted = { left = "", right = "█", icon_gap = " " },
	arrow = { left = "", right = "█", icon_gap = " " },
	none = { left = "", right = "", icon_gap = " " },
	tagged = { left = "█", right = " ", icon_gap = " " },
}

---Separate caches for content and border highlights
---@type table<string, string>
local content_cache = {}
---@type table<string, string>
local border_cache = {}
local content_hl_counter = 0
local border_hl_counter = 0
local _pregenerated = false

---Cached theme data
local cached_theme = nil
local cached_modes = nil
local cached_shades = nil

---Update cached theme data
local function update_theme_cache()
	local theme = require("fancyline.themes")
	-- Use user's configured theme instead of auto-detecting
	local theme_cfg = _G.fancyline_theme_config or {}
	local current = theme.get(theme_cfg.name or "auto", theme_cfg.variant)
	cached_theme = current
	cached_modes = current.modes or {}
	cached_shades = current.shades or {}
end

---Common color combinations for pre-generated highlights
local COMMON_COLORS = {
	"#61afef", -- Blue (Normal mode)
	"#98c379", -- Green (Insert mode)
	"#c678dd", -- Purple (Visual mode)
	"#e5c07b", -- Yellow (Terminal/Command mode)
	"#e06c75", -- Red (Replace mode)
	"#ABB2BF", -- Gray (default)
	"#5c6370", -- Dark gray (border)
	"NONE", -- Transparent
}

---Pre-generate common highlight groups
local function pregenerate_highlights()
	if _pregenerated then
		return
	end
	_pregenerated = true

	local base_names = { "FancylineMode", "FancylineComponent", "Icon", "FancylineGitBranch", "FancylineLsp" }
	local bg_colors = { "NONE", "#1e1e1e", "#252526", "#282c34" }

	for _, base in ipairs(base_names) do
		for _, fg in ipairs(COMMON_COLORS) do
			for _, bg in ipairs(bg_colors) do
				if fg == "NONE" and bg == "NONE" then
				else
					local key = string.format("%s_%s_%s", base, fg or "", bg or "")
					if not content_cache[key] then
						content_hl_counter = content_hl_counter + 1
						local hl_name = "FancylineDynamic" .. content_hl_counter
						vim.api.nvim_set_hl(0, hl_name, {
							fg = fg == "NONE" and "NONE" or fg,
							bg = bg == "NONE" and "NONE" or bg,
							bold = false,
						})
						content_cache[key] = hl_name
					end
				end
			end
		end
	end

	for _, fg in ipairs(COMMON_COLORS) do
		for _, bg in ipairs(bg_colors) do
			if fg ~= "NONE" or bg ~= "NONE" then
				local key = string.format("border_%s_%s", fg or "", bg or "")
				if not border_cache[key] then
					border_hl_counter = border_hl_counter + 1
					local hl_name = "FancylineBorderDynamic" .. border_hl_counter
					vim.api.nvim_set_hl(0, hl_name, {
						fg = fg == "NONE" and "NONE" or fg,
						bg = bg == "NONE" and "NONE" or bg,
					})
					border_cache[key] = hl_name
				end
			end
		end
	end
end

---Resolve "mode" to the actual mode color from theme
---@param color_spec? string
---@param state? string
---@return string?
local function resolve_mode_color(color_spec, state)
	if color_spec ~= "mode" then
		return color_spec
	end

	if not cached_theme then
		update_theme_cache()
	end

	local mode_map = {
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
		["^S"] = "s"
	}

	local mode_key = mode_map[state] or "n"
	return cached_modes[mode_key] or "#ABB2BF"
end

---Resolve shade color references
---@param color_spec? string
---@return string?
local function resolve_shade_color(color_spec)
	if type(color_spec) ~= "string" then
		return color_spec
	end

	local shade_match = color_spec:match("^shade_(%d+)$")
	if shade_match then
		if not cached_theme then
			update_theme_cache()
		end
		local shade_key = "shade_" .. shade_match
		if cached_shades[shade_key] then
			return cached_shades[shade_key]
		end
	end

	return color_spec
end

---Invalidate theme cache
function M.invalidate_theme_cache()
	cached_theme = nil
	cached_modes = nil
	cached_shades = nil
end

---Pre-generate common highlight groups for faster first render
function M.pregenerate_highlights()
	pregenerate_highlights()
end

---@param name string
---@param fg? string
---@param bg? string
---@param bold? boolean
---@return string
local function get_hl_name(name, fg, bg, bold)
	if not fg and not bg and bold ~= true then
		return name
	end

	local key = string.format("%s_%s_%s_%s", name, fg or "", bg or "", bold and "1" or "0")
	if not content_cache[key] then
		content_hl_counter = content_hl_counter + 1
		local hl_name = "FancylineDynamic" .. content_hl_counter
		vim.api.nvim_set_hl(0, hl_name, {
			fg = fg,
			bg = bg,
			bold = bold or false,
		})
		content_cache[key] = hl_name
	end
	return content_cache[key]
end

---@param fg? string
---@param bg? string
---@return string
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

---Get a style definition by name
---@param style_name? string
---@return FancylineStyleDefinition
function M.get_style(style_name)
	return M.styles[style_name] or M.styles.none
end

---Parse icon config: can be string or table
---@param icon_cfg? string|FancylineIconConfig|table
---@return FancylineIconConfig
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
		return { symbol = icon_cfg.icon or "", fg = nil, bg = nil, states = nil }
	end
	return { symbol = "", fg = nil, bg = nil, states = nil }
end

---Get colors for a specific state
---@param icon_cfg? FancylineIconConfig
---@param state? string
---@return string?, string?
function M.get_icon_colors(icon_cfg, state)
	if icon_cfg and icon_cfg.states and icon_cfg.states[state] then
		local state_cfg = icon_cfg.states[state]
		return state_cfg.fg, state_cfg.bg
	end
	return nil, nil
end

---Render a component with a simple border
---@param icon? string|FancylineIconConfig
---@param text? string
---@param style_name? string
---@param highlight? string
---@param fg? string
---@param bg? string
---@param state? string
---@param text_bold? boolean Bold text only (not icon/border)
---@param padding_left? number Padding spaces before text
---@param padding_right? number Padding spaces after text
---@return string
function M.render_component(icon, text, style_name, highlight, fg, bg, state, text_bold, padding_left, padding_right)
	local style = M.get_style(style_name)
	local base_hl = highlight or "FancylineComponent"

	-- Resolve "mode" and "shade_X" colors
	fg = resolve_shade_color(resolve_mode_color(fg, state))
	bg = resolve_shade_color(resolve_mode_color(bg, state))

	-- Get dynamic highlight with custom fg/bg if provided
	local hl = get_hl_name(base_hl, fg, bg, text_bold)
	local hl_prefix = "%#" .. hl .. "#"

	if style_name == "none" then
		local parts = {}
		if text and text ~= "" then
			-- Text with padding
			table.insert(parts, hl_prefix)
			table.insert(parts, string.rep(" ", padding_left or 0))
			table.insert(parts, text)
			table.insert(parts, string.rep(" ", padding_right or 0))
			table.insert(parts, "%#FancylineReset#")
		elseif (padding_left or 0) > 0 or (padding_right or 0) > 0 then
			table.insert(parts, hl_prefix)
			table.insert(parts, string.rep(" ", (padding_left or 0) + (padding_right or 0)))
			table.insert(parts, "%#FancylineReset#")
		end
		return table.concat(parts, "")
	end

	-- Create border highlight with bg if specified
	local border_hl = "%#FancylineBorder#"
	if bg then
		border_hl = "%#" .. get_border_hl("#5C6370", bg) .. "#"
	end

	local parts = {
		border_hl .. style.left,
		hl_prefix,
		string.rep(" ", padding_left or 0),
	}

	if text and text ~= "" then
		table.insert(parts, text)
	end

	table.insert(parts, string.rep(" ", padding_right or 0))
	table.insert(parts, border_hl .. style.right .. "%#FancylineReset#")

	return table.concat(parts, "")
end

---Render full component with separate icon
---@param icon_cfg? string|FancylineIconConfig
---@param text? string
---@param style_name? string
---@param highlight? string
---@param text_fg? string
---@param text_bg? string
---@param state? string
---@param text_bold? boolean Bold text only (not icon)
---@param padding_left? number Padding spaces before text (after icon gap)
---@param padding_right? number Padding spaces after text
---@return string
function M.render_with_icon(icon_cfg, text, style_name, highlight, text_fg, text_bg, state, text_bold, padding_left, padding_right)
	local style = M.get_style(style_name)

	-- Parse icon config
	local icon_data = M.parse_icon(icon_cfg)

	-- Get colors for the state
	local icon_fg, icon_bg = M.get_icon_colors(icon_data, state)

	-- If no specific icon state colors, use defaults from icon_cfg
	if not icon_fg then icon_fg = icon_data.fg end
	if not icon_bg then icon_bg = icon_data.bg end

	-- Resolve "mode" and "shade_X" colors
	icon_fg = resolve_shade_color(resolve_mode_color(icon_fg, state))
	icon_bg = resolve_shade_color(resolve_mode_color(icon_bg, state))
	text_fg = resolve_shade_color(resolve_mode_color(text_fg, state))
	text_bg = resolve_shade_color(resolve_mode_color(text_bg, state))

	-- Determine text colors
	local base_hl = highlight or "FancylineComponent"
	local txt_fg = text_fg
	local txt_bg = text_bg or icon_bg -- Share bg with text if icon has bg

	-- Get highlights - bold only applies to text, not icon
	local text_hl = get_hl_name(base_hl, txt_fg, txt_bg, text_bold)
	local icon_hl = get_hl_name("Icon", icon_fg, icon_bg, false)

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
		if text and text ~= "" then
			-- Text with padding
			table.insert(parts, "%#" .. text_hl .. "#")
			table.insert(parts, string.rep(" ", padding_left or 0))
			table.insert(parts, text)
			table.insert(parts, string.rep(" ", padding_right or 0))
			table.insert(parts, "%#FancylineReset#")
		elseif (padding_left or 0) > 0 or (padding_right or 0) > 0 then
			table.insert(parts, "%#" .. text_hl .. "#")
			table.insert(parts, string.rep(" ", (padding_left or 0) + (padding_right or 0)))
			table.insert(parts, "%#FancylineReset#")
		end
		return table.concat(parts, "")
	end

	-- None style: no borders, just icon and text with spacing
	if style_name == "none" then
		if icon_data.symbol and icon_data.symbol ~= "" then
			table.insert(parts, "%#" .. icon_hl .. "#" .. icon_data.symbol)
		end
		if text and text ~= "" then
			-- Text with padding
			table.insert(parts, "%#" .. text_hl .. "#")
			table.insert(parts, string.rep(" ", padding_left or 0))
			table.insert(parts, text)
			table.insert(parts, string.rep(" ", padding_right or 0))
			table.insert(parts, "%#FancylineReset#")
		elseif (padding_left or 0) > 0 or (padding_right or 0) > 0 then
			table.insert(parts, "%#" .. text_hl .. "#")
			table.insert(parts, string.rep(" ", (padding_left or 0) + (padding_right or 0)))
			table.insert(parts, "%#FancylineReset#")
		end
		return table.concat(parts, "")
	end

	-- Normal style: border around everything
	table.insert(parts, border_hl .. style.left)

	-- Icon (rendered separately with its own color)
	if icon_data.symbol and icon_data.symbol ~= "" then
		table.insert(parts, "%#" .. icon_hl .. "#" .. icon_data.symbol)
	end

	-- Text with padding
	if text and text ~= "" then
		table.insert(parts, "%#" .. text_hl .. "#")
		table.insert(parts, string.rep(" ", padding_left or 0))
		table.insert(parts, text)
		table.insert(parts, string.rep(" ", padding_right or 0))
		table.insert(parts, "%#FancylineReset#")
	elseif (padding_left or 0) > 0 or (padding_right or 0) > 0 then
		-- Padding without text
		table.insert(parts, "%#" .. text_hl .. "#")
		table.insert(parts, string.rep(" ", (padding_left or 0) + (padding_right or 0)))
		table.insert(parts, "%#FancylineReset#")
	end

	-- Border end
	table.insert(parts, border_hl .. style.right .. "%#FancylineReset#")

	return table.concat(parts, "")
end

---Register additional styles
---@param styles table<string, FancylineStyleDefinition>
function M.register_styles(styles)
	for name, def in pairs(styles) do
		M.styles[name] = def
	end
end

---Clear the highlight caches
function M.clear_cache()
	content_cache = {}
	border_cache = {}
	content_hl_counter = 0
	border_hl_counter = 0
	_pregenerated = false
	cached_theme = nil
	cached_modes = nil
	cached_shades = nil
end

---Render with custom border (separate fg/bg for left/right)
---@param border_cfg? FancylineBorder
---@param icon_cfg? string|FancylineIconConfig
---@param text? string
---@param highlight? string
---@param fg? string
---@param bg? string
---@param state? string
---@param text_bold? boolean Bold text only (not icon/border)
---@param padding_left? number Padding spaces before text (after icon gap)
---@param padding_right? number Padding spaces after text
---@return string
function M.render_custom_border(border_cfg, icon_cfg, text, highlight, fg, bg, state, text_bold, padding_left, padding_right)
	local theme = require("fancyline.themes")
	local default_border = theme.get_default().border or "#5c6370"

	-- Parse icon config
	local icon_data = M.parse_icon(icon_cfg)

	-- Get icon colors for state
	local icon_fg, icon_bg = M.get_icon_colors(icon_data, state)
	if not icon_fg then icon_fg = icon_data.fg end
	if not icon_bg then icon_bg = icon_data.bg end

	-- Resolve "mode" and "shade" colors
	icon_fg = resolve_shade_color(resolve_mode_color(icon_fg, state))
	icon_bg = resolve_shade_color(resolve_mode_color(icon_bg, state))
	fg = resolve_shade_color(resolve_mode_color(fg, state))
	bg = resolve_shade_color(resolve_mode_color(bg, state))

	-- Get style for each side
	local left_style_name = border_cfg.left and border_cfg.left.style or "round"
	local right_style_name = border_cfg.right and border_cfg.right.style or "round"
	local left_style = M.get_style(left_style_name)
	local right_style = M.get_style(right_style_name)

	-- Border colors with defaults from theme and resolve "mode" and "shade_X"
	local left_fg = resolve_shade_color(resolve_mode_color(border_cfg.left and border_cfg.left.fg, state)) or
		default_border
	local left_bg = resolve_shade_color(resolve_mode_color(border_cfg.left and border_cfg.left.bg, state)) or "NONE"
	local right_fg = resolve_shade_color(resolve_mode_color(border_cfg.right and border_cfg.right.fg, state)) or
		default_border
	local right_bg = resolve_shade_color(resolve_mode_color(border_cfg.right and border_cfg.right.bg, state)) or "NONE"

	-- Content gap between icon and text
	local content_gap = border_cfg.content_gap or " "

	-- Get border highlights
	local left_hl = "%#" .. get_border_hl(left_fg, left_bg) .. "#"
	local right_hl = "%#" .. get_border_hl(right_fg, right_bg) .. "#"

	-- Content highlight - bold only applies to text, not icon
	local base_hl = highlight or "FancylineComponent"
	local content_hl = get_hl_name(base_hl, fg, bg, text_bold)
	local icon_hl = get_hl_name("Icon", icon_fg, icon_bg, false)

	-- Build parts
	local parts = {}

	-- Left border
	table.insert(parts, left_hl .. left_style.left)

	-- Icon
	if icon_data.symbol and icon_data.symbol ~= "" then
		table.insert(parts, "%#" .. icon_hl .. "#" .. icon_data.symbol)
	end

	-- Padding after icon (before text)
	table.insert(parts, string.rep(" ", padding_left or 0))

	-- Text with padding
	if text and text ~= "" then
		table.insert(parts, "%#" .. content_hl .. "#")
		table.insert(parts, string.rep(" ", padding_left or 0))
		table.insert(parts, text)
		table.insert(parts, string.rep(" ", padding_right or 0))
		table.insert(parts, "%#FancylineReset#")
	elseif (padding_left or 0) > 0 or (padding_right or 0) > 0 then
		-- Padding without text
		table.insert(parts, "%#" .. content_hl .. "#")
		table.insert(parts, string.rep(" ", (padding_left or 0) + (padding_right or 0)))
		table.insert(parts, "%#FancylineReset#")
	end

	-- Right border
	table.insert(parts, right_hl .. right_style.right .. "%#FancylineReset#")

	return table.concat(parts, "")
end

-- Invalidate theme cache on colorscheme change
vim.api.nvim_create_autocmd("Colorscheme", {
	callback = function()
		cached_theme = nil
		cached_modes = nil
		cached_shades = nil
	end,
})

return M
