local M = {}

-- Hoist require to module level for performance
local devicons_ok, devicons = pcall(require, "fancyline.utils.devicons")

---Provider function for the file component.
---@param opts? FancylineFileComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
	local bufnr = ctx.bufnr
	local filename = vim.api.nvim_buf_get_name(bufnr)

	-- Determine file state
	local modified = vim.bo[bufnr].modified
	local readonly = vim.bo[bufnr].readonly

	local state = "normal"
	local state_icon = ""
	local state_highlight = "FancylineFile"

	if modified then
		state = "modified"
		state_icon = opts.icons and opts.icons.modified or "●"
		state_highlight = "FancylineFileModified"
	elseif readonly then
		state = "readonly"
		state_icon = opts.icons and opts.icons.readonly or "󰌾"
		state_highlight = "FancylineFileReadonly"
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

	-- Append state indicator to filename
	if state_icon ~= "" then
		display_name = display_name .. " " .. state_icon
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
			-- Get icon for filetype using module-level devicons
			local devicon = devicons_ok and devicons.get_filetype_icon(bufnr) or nil
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
		highlight = state_highlight,
		state = state,
		fg = opts.fg,
		bg = opts.bg,
		border = opts.border,
	}
end

function M.setup_highlights()
	vim.api.nvim_set_hl(0, "FancylineFile", { fg = "#abb2bf", bold = false })
	vim.api.nvim_set_hl(0, "FancylineFileModified", { fg = "#e5c07b", bold = true })
	vim.api.nvim_set_hl(0, "FancylineFileReadonly", { fg = "#e06c75", bold = false })
end

return M
