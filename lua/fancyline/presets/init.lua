local M = {
	minimal = require("fancyline.presets.minimal"),
	default = require("fancyline.presets.default"),
	standard = require("fancyline.presets.standard"),
	full = require("fancyline.presets.full"),
	["git-focused"] = require("fancyline.presets.git-focused"),
	vscode = require("fancyline.presets.vscode"),
	pill = require("fancyline.presets.pill"),
	brick = require("fancyline.presets.brick"),
	slim = require("fancyline.presets.slim"),
	rounded = require("fancyline.presets.rounded"),
	angular = require("fancyline.presets.angular"),
	diagonal = require("fancyline.presets.diagonal"),
	arrows = require("fancyline.presets.arrows"),
}

function M.load(preset_name)
	-- Handle table input (e.g., from theme config)
	if type(preset_name) == "table" then
		preset_name = preset_name.preset
	end
	
	-- Handle nil/empty
	if not preset_name or preset_name == "" then
		preset_name = "default"
	end
	
	local preset = M[preset_name]
	if not preset then
		vim.notify("[Fancyline] Unknown preset: " .. tostring(preset_name), vim.log.levels.warn)
		return {}
	end
	return preset
end

return M
