local M = {}

function M.render(config)
  local statusline = require("fancyline.renderer")
  return statusline.render(config)
end

return M
