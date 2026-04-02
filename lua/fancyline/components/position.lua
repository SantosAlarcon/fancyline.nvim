local M = {}

---Provider function for the position component.
---Uses native statusline escape sequences for instant updates.
---@param opts? FancylinePositionComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
	local format = opts.format or "Ln %l, Col %c"

	local text = format
	text = text:gsub("%%%%", "%%")

	local icon_cfg
	if type(opts.icon) == "table" and opts.icon.symbol then
		icon_cfg = { symbol = opts.icon.symbol, fg = opts.icon.fg, bg = opts.icon.bg }
	else
		icon_cfg = { symbol = opts.icon or " ", fg = nil, bg = nil }
	end

	return {
		text = text,
		icon = icon_cfg,
		style = opts.style or "none",
		highlight = "FancylinePosition",
		fg = opts.fg,
		bg = opts.bg,
		bold = opts.bold,
		border = opts.border,
		state = "n",
	}
end

return M
