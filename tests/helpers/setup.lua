local M = {}

function M.setup()
  vim.opt.runtimepath:append(".")
  vim.opt.runtimepath:append("..")
end

function M.cleanup()
  vim.o.statusline = ""

  pcall(vim.api.nvim_del_augroup_by_name, "Fancyline")
  pcall(vim.api.nvim_del_augroup_by_name, "FancylineTelescope")
  pcall(vim.api.nvim_del_augroup_by_name, "FancylineOil")
end

function M.mock_vim_fn(mode_value)
  vim.fn.mode = function()
    return mode_value
  end
end

function M.mock_buf_line_count(bufnr, count)
  vim.api.nvim_buf_line_count = function(buf)
    if buf == bufnr then
      return count
    end
    return 1
  end
end

function M.mock_vim_variables(vars)
  for key, value in pairs(vars) do
    vim.b[key] = value
  end
end

return M
