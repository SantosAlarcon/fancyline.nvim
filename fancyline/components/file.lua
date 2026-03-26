local M = {}

local devicons = require("fancyline.utils.devicons")

function M.provider(opts, ctx)
	local bufnr = ctx.bufnr
	local filename = vim.api.nvim_buf_get_name(bufnr)

	-- Determine file state
	local modified = vim.bo[bufnr].modified
	local readonly = vim.bo[bufnr].readonly

	local state = "normal"
	if modified then
		state = "modified"
	elseif readonly then
		state = "readonly"
	end

	-- Build display name
	local display_name
	if filename == "" then
		-- Use custom empty name or default
		display_name = opts.empty_name or "[Empty]"
	else
		-- Use filename only (no path) - :t = tail
		display_name = vim.fn.fnamemodify(filename, ":t")
	end

	-- Build icon config with devicon
	local icon_cfg
	if type(opts.icon) == "table" and opts.icon.symbol then
		-- User defined icon with symbol - use their colors or defaults
		icon_cfg = {
			symbol = opts.icon.symbol,
			fg = opts.icon.fg,
			bg = opts.icon.bg,
		}
	else
		local icon_symbol = " "
		local icon_fg = opts.icon and opts.icon.fg
		local icon_bg = opts.icon and opts.icon.bg

		if opts.use_devicon ~= false then
			-- Get icon for filetype using get_filetype_icon
			local devicon = devicons.get_filetype_icon(bufnr)
			if devicon then
				icon_symbol = devicon
			end
		end

		icon_cfg = {
			symbol = icon_symbol,
			fg = icon_fg,
			bg = icon_bg,
		}
	end

	return {
		text = display_name,
		icon = icon_cfg,
		style = opts.style or "square",
		highlight = "FancylineFile",
		state = state,
		fg = opts.fg,
		bg = opts.bg,
		border = opts.border,
	}
end

return M
