local M = {}

---Provider function for the indent component.
---@param opts? FancylineIndentComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
	local expandtab = vim.opt_local.expandtab:get()
	local tabstop = vim.opt_local.tabstop:get()

	local icon = opts.icon or "󰌒"
	local text

	local spaces_text, tabs_text = opts.spaces_text, opts.tabs_text

	if expandtab then
		local shiftwidth = vim.opt_local.shiftwidth:get()
		if spaces_text then
			text = spaces_text .. ": " .. shiftwidth
		else
			text = "Spaces: " .. shiftwidth
		end
	else
		if tabs_text then
			text = tabs_text .. ": " .. tabstop
		else
			text = "Tabs: " .. tabstop
		end
	end

	return {
		text = icon .. " " .. text,
		highlight = "FancylineIndent",
		style = opts.style or "none",
	}
end

return M
