local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("FancylineOil", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "oil",
    callback = function()
      local dir = vim.fn.expand("%:p")
      local name = dir:gsub(vim.env.HOME, "~")
      vim.o.statusline = "%#FancylineFile# " .. name .. " %=%*"
    end,
  })
end

return M
