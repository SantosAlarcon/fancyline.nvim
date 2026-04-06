-- Minimal init for test suite
-- Sets up the plugin path for testing

-- Add the plugin to the runtimepath
local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

-- Set a minimal colorscheme for theme tests
vim.opt.termguicolors = true
