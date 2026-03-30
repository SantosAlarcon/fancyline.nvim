local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("FancylineTelescope", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "TelescopePrompt",
    callback = function()
      vim.o.statusline = "%#FancylineMode# Telescope %=%*"
    end,
  })
end

return M
