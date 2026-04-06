local M = {}

local _selected_preset = nil
local _preset_modules = nil

function M.load(preset_name)
	if type(preset_name) == "table" then
		preset_name = preset_name.preset
	end

	if not preset_name or preset_name == "" then
		preset_name = "default"
	end

	if _preset_modules and _preset_modules[preset_name] then
		return _preset_modules[preset_name]
	end

	local ok, preset = pcall(require, "fancyline.presets." .. preset_name)
	if not ok or type(preset) ~= "table" then
		if not ok then
			vim.notify("[Fancyline] Unknown preset: " .. tostring(preset_name), vim.log.levels.warn)
		end
		return {}
	end

	_preset_modules = _preset_modules or {}
	_preset_modules[preset_name] = preset
	_selected_preset = preset
	return preset
end

function M.get(name)
	return M.load(name)
end

function M.reset()
	_selected_preset = nil
	_preset_modules = nil
end

return M
