local M = {}

function M.setup(config)
  if config.telescope ~= false then
    require("fancyline.extensions.telescope").setup()
  end

  if config.oil ~= false then
    require("fancyline.extensions.oil").setup()
  end
end

return M
