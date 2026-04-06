local M = {}

local border = require("fancyline.renderer.border")
local cache = require("fancyline.utils.cache")

---Lazy-loaded component providers
---@type table<string, FancylineProvider|false>
local component_providers = {}

---Module loading state
---@type table<string, boolean>
local modules_loaded = {}

---Component names for preloading
---@type string[]
local COMPONENT_NAMES = {
	"mode", "git_branch", "git_diff", "file", "diagnostics",
	"errors", "warnings", "infos", "hints", "lsp", "lsp_progress",
	"filetype", "encoding", "indent", "position", "branch_status",
	"bufnr", "checktime", "commit_msg", "cwd", "dap", "fileformat",
	"filesize", "git_signs", "lsp_clients", "macro_recording",
	"project", "quickfix", "reload", "search_stats", "spell",
	"tabnr", "treesitter",
}

---Components that should never be cached (always re-render)
--- Only components that change on EVERY cursor move should be here
---@type table<string, true>
local UNCACHED_COMPONENTS = {
	position = true,
	mode = true,
	-- All other components are now cached and invalidated via autocmds
}

---Load a component module on demand
---@param name string
---@return FancylineProvider?
local function load_component(name)
	if modules_loaded[name] then
		return component_providers[name]
	end
	local ok, provider = pcall(require, "fancyline.components." .. name)
	if ok and provider then
		component_providers[name] = provider
		modules_loaded[name] = true
		return provider
	end
	component_providers[name] = false
	modules_loaded[name] = true
	return nil
end

---Preload all component modules
function M.preload_modules()
	for _, name in ipairs(COMPONENT_NAMES) do
		load_component(name)
	end
end

---Component render cache
---@type table<string, {rendered: string, ctx_hash: number}|nil>
local component_cache = {}

---Compute a hash from context including buffer state
---@param ctx FancylineContext
---@return number
local function ctx_hash(ctx)
	-- Simple hash using bufnr and winid - sufficient for unique identification
	-- The buffer name hash is unnecessary since bufnr is unique per buffer
	return ctx.bufnr + ctx.winid * 1000000
end

---@param val any
---@return boolean
local function is_array(val)
	if type(val) ~= "table" then return false end
	local i = 0
	for _ in pairs(val) do
		i = i + 1
		if val[i] == nil then return false end
	end
	return i > 0
end

---@param name string
---@param opts table
---@param ctx FancylineContext
---@return string
local function render_component(name, opts, ctx)
	local cache_key = name .. "_" .. ctx_hash(ctx)
	local current_hash = ctx_hash(ctx)

	if not UNCACHED_COMPONENTS[name] then
		local cached = component_cache[cache_key]
		if cached and cached.ctx_hash == current_hash then
			return cached.rendered
		end
	end

	local provider = load_component(name)
	if not provider then
		return ""
	end

	local comp_opts = opts or {}
	local result = provider.provider(comp_opts, ctx)

	if not result then
		component_cache[cache_key] = nil
		return ""
	end

	local rendered = ""

	-- Get padding from component options
	local padding_left = comp_opts.padding_left or 0
	local padding_right = comp_opts.padding_right or 0

	if is_array(result) then
		local parts = {}
		for _, item in ipairs(result) do
			local item_rendered = border.render_component(
				item.icon,
				item.text,
				item.style or "none",
				item.highlight,
				item.fg,
				item.bg,
				item.state,
				item.bold,
				padding_left,
				padding_right
			)
			if item_rendered and item_rendered ~= "" then
				table.insert(parts, item_rendered)
			end
		end
		rendered = table.concat(parts, "  ")
	else
		local item_rendered

		if result.border then
			item_rendered = border.render_custom_border(
				result.border,
				result.icon,
				result.text,
				result.highlight,
				result.fg,
				result.bg,
				result.state,
				result.bold,
				padding_left,
				padding_right
			)
		else
			local icon_parsed = border.parse_icon(result.icon)
			local has_icon = icon_parsed.symbol and icon_parsed.symbol ~= ""
			if has_icon then
				item_rendered = border.render_with_icon(
					result.icon,
					result.text,
					result.style or "none",
					result.highlight,
					result.fg,
					result.bg,
					result.state,
					result.bold,
					padding_left,
					padding_right
				)
			else
				item_rendered = border.render_component(
					result.icon,
					result.text,
					result.style or "none",
					result.highlight,
					result.fg,
					result.bg,
					result.state,
					result.bold,
					padding_left,
					padding_right
				)
			end
		end

		rendered = item_rendered or ""
	end

	if not UNCACHED_COMPONENTS[name] then
		component_cache[cache_key] = { rendered = rendered, ctx_hash = current_hash }
	end
	return rendered
end

---Render the statusline based on the given configuration.
---@param config FancylineConfig
---@return string
function M.render(config)
	local sections = config.sections or {
		left = { "mode" },
		center = { "file" },
		right = { "cursor" },
	}

	-- Check if current window is floating
	-- In Neovim 0.11, relative is a string like "editor" for floating windows
	local function is_float_win(win)
		local cfg = vim.api.nvim_win_get_config(win)
		if not cfg then return false end
		local rel = cfg.relative
		-- If relative is a non-empty string, it's floating
		if type(rel) == "string" and rel ~= "" then
			return true
		end
		return false
	end

	local current_win = vim.api.nvim_get_current_win()
	local win_is_floating = is_float_win(current_win)

	-- If current window is floating, find the last non-floating window
	local ctx_bufnr
	local ctx_winid
	if win_is_floating then
		-- Find the first non-floating window
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if not is_float_win(win) then
				ctx_winid = win
				ctx_bufnr = vim.api.nvim_win_get_buf(win)
				break
			end
		end
		-- Fallback to current if no non-floating found
		if not ctx_bufnr then
			ctx_bufnr = vim.api.nvim_get_current_buf()
			ctx_winid = current_win
		end
	else
		ctx_bufnr = vim.api.nvim_get_current_buf()
		ctx_winid = current_win
	end

	local ctx = {
		bufnr = ctx_bufnr,
		winid = ctx_winid,
	}

	local function render_section(section_names)
		local parts = {}

		for _, name in ipairs(section_names) do
			local comp_opts = config.components and config.components[name] or {}
			local rendered = render_component(name, comp_opts, ctx)
			if rendered and rendered ~= "" then
				table.insert(parts, rendered)
			end
		end

		return table.concat(parts, " ")
	end

	local left_content = render_section(sections.left or {})
	local center_content = render_section(sections.center or {})
	local right_content = render_section(sections.right or {})

	-- Add horizontal padding (left: spaces, right: primary color)
	if left_content ~= "" then
		left_content = " " .. left_content
	end

	if right_content ~= "" then
		right_content = right_content .. " %#FancylinePaddingRight#%*"
	end

	local separator = " " .. (config.separator or "│") .. " "

	local parts = {}

	if left_content ~= "" then
		table.insert(parts, left_content)
	end

	if center_content ~= "" then
		if #parts > 0 then
			table.insert(parts, "%=")
		end
		table.insert(parts, center_content)
	end

	if right_content ~= "" then
		if #parts > 0 then
			table.insert(parts, "%=")
		end
		table.insert(parts, right_content)
	end

	if #parts == 0 then
		return "%="
	end

	local result = table.concat(parts, separator)
	return result
end

---Invalidate cache for specific components or all
---@param names? string[] Component names to invalidate, or nil for all
function M.invalidate(names)
	if names then
		for _, name in ipairs(names) do
			-- Invalidate all cache entries for this component
			-- Cache keys are "name_hash", so we need to match the prefix
			for key in pairs(component_cache) do
				if key:match("^" .. name .. "_") then
					component_cache[key] = nil
				end
			end
		end
	else
		component_cache = {}
	end
end

---Register a custom component provider.
---@param name string
---@param provider FancylineProvider
function M.register_component(name, provider)
	component_providers[name] = provider
	modules_loaded[name] = true
	component_cache[name] = nil
end

---Get a registered component provider.
---@param name string
---@return FancylineProvider?
function M.get_component(name)
	return component_providers[name]
end

return M
