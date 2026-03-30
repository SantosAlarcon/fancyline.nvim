local M = {
  minimal = require("fancyline.presets.minimal"),
  default = require("fancyline.presets.default"),
  standard = require("fancyline.presets.standard"),
  full = require("fancyline.presets.full"),
  ["git-focused"] = require("fancyline.presets.git-focused"),
  vscode = require("fancyline.presets.vscode"),
  pill = require("fancyline.presets.pill"),
  slim = require("fancyline.presets.slim"),
  rounded = require("fancyline.presets.rounded"),
  angular = require("fancyline.presets.angular"),
  diagonal = require("fancyline.presets.diagonal"),
  arrows = require("fancyline.presets.arrows"),
}

function M.load(preset_name)
  local preset = M[preset_name]
  if not preset then
    vim.notify("[Fancyline] Unknown preset: " .. preset_name, vim.log.levels.warn)
    return {}
  end
  return preset
end

return M
