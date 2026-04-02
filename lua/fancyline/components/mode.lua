local M = {}

-- Hoist require to module level for performance
local theme = require("fancyline.themes")

-- Map main modes to their highlight group name
local mode_highlights = {
	n = "FancylineModeNormal",
	i = "FancylineModeInsert",
	v = "FancylineModeVisual",
	t = "FancylineModeTerminal",
	c = "FancylineModeCommand",
	r = "FancylineModeReplace",
	s = "FancylineModeSelect",
}

-- Map main modes to theme colors
local mode_theme_keys = {
	n = "n",
	i = "i",
	v = "v",
	t = "t",
	c = "c",
	r = "r",
	s = "s",
}

-- Default text for main modes (shown when no custom text is configured)
local default_mode_text = {
	n = "N",
	i = "I",
	v = "V",
	t = "T",
	c = ":",
	r = "R",
	s = "S",
	["\22"] = "V-BLOCK",
	["\19"] = "S-BLOCK",
}

-- Normalize mode variants to main modes
---@param mode string
---@return string
local function normalize_mode(mode)
	-- Main modes
	if mode == "n" or mode == "i" or mode == "v" or mode == "t" or mode == "c" or mode == "r" or mode == "s" then
		return mode
	end
	-- Operator-pending modes (no*, noc*, nov*, ci*, ic*, etc.) -> treat as normal or command
	if mode:sub(1, 2) == "no" then
		return "n"
	end
	-- Command-line modes (c*, cv, ce, ci, etc.) -> treat as command mode
	if mode:sub(1, 1) == "c" then
		return "c"
	end
	-- Command-line operator-pending (ic, ix, etc.) -> treat as insert mode
	if mode:sub(1, 1) == "i" and mode ~= "i" then
		return "i"
	end
	local byte = string.byte(mode)
	if mode == "V" or byte == 22 then -- 22 = Ctrl-V (Visual Block)
		return "v"
	end
	if mode == "R" or mode == "rv" then
		return "r"
	end
	if mode == "S" or byte == 19 then -- 19 = Ctrl-S (Select)
		return "s"
	end
	if mode == "!" then
		return "t"
	end
	return mode
end

---Provider function for the mode component.
---@param opts? FancylineModeComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
	-- Get raw mode string (vim.fn.mode(1) returns "^V" for visual block, etc.)
	local raw_mode = vim.fn.mode(1)
	local current_mode = normalize_mode(raw_mode)

	-- If opts is a function, call it with the raw mode
	if type(opts) == "function" then
		local result = opts(raw_mode)
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

	local text = mode_map[raw_mode] or mode_map[current_mode]
	if not text then
		text = default_mode_text[raw_mode] or default_mode_text[current_mode] or current_mode
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

	-- Get mode color from theme (use module-level require)
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
		text = " " .. text,
		icon = icon_cfg,
		style = opts.style or "round",
		highlight = highlight,
		fg = fg,
		bg = bg,
		bold = opts.bold,
		state = current_mode,
		border = opts.border,
	}
end

return M
