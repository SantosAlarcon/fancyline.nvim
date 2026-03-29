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

function M.mock_buf_option(bufnr, option, value)
  vim.bo[bufnr] = vim.bo[bufnr] or {}
  vim.bo[bufnr][option] = value
end

function M.mock_modified(bufnr, modified)
  M.mock_buf_option(bufnr, "modified", modified)
end

function M.mock_readonly(bufnr, readonly)
  M.mock_buf_option(bufnr, "readonly", readonly)
end

function M.mock_fileformat(bufnr, format)
  M.mock_buf_option(bufnr, "fileformat", format)
end

function M.mock_filetype(bufnr, ft)
  M.mock_buf_option(bufnr, "filetype", ft)
end

function M.mock_searchcount(count)
  vim.fn.searchcount = function(opts)
    if opts and opts.recompute then
      return count
    end
    return count
  end
end

function M.mock_reg_recording(reg)
  vim.fn.reg_recording = function()
    return reg
  end
end

function M.mock_vim_opt(option, value)
  if option == "paste" then
    vim.opt.paste = value
  elseif option == "spell" then
    vim.wo.spell = value
  end
end

function M.mock_vim_b(key, value, bufnr)
  bufnr = bufnr or 0
  vim.b[bufnr] = vim.b[bufnr] or {}
  vim.b[bufnr][key] = value
end

function M.mock_gitsigns(mock_module)
  package.loaded["gitsigns"] = mock_module
end

function M.mock_dap(mock_module)
  package.loaded["dap"] = mock_module
end

function M.mock_treesitter(mock_module)
  package.loaded["nvim-treesitter"] = mock_module
  package.loaded["nvim-treesitter.info"] = mock_module
end

function M.mock_lsp(clients)
  vim.lsp.get_active_clients = function(opts)
    if opts and opts.bufnr then
      return clients or {}
    end
    return clients or {}
  end
end

function M.mock_lspconfig(ok)
  if ok then
    package.loaded["lspconfig.util"] = {}
  else
    package.loaded["lspconfig.util"] = nil
  end
end

function M.mock_git_utils(mock_module)
  package.loaded["fancyline.utils.git"] = mock_module
end

function M.mock_vim_loop_fs_stat(bufname, stat_result)
  vim.loop = vim.loop or {}
  vim.loop.fs_stat = function(path)
    if path == bufname then
      return stat_result
    end
    return nil
  end
end

function M.mock_getcwd(cwd)
  vim.fn.getcwd = function()
    return cwd
  end
end

function M.mock_buf_name(bufnr, name)
  vim.api.nvim_buf_get_name = function(buf)
    if buf == bufnr then
      return name
    end
    return ""
  end
end

function M.mock_win_buf(winid, bufnr)
  vim.api.nvim_get_current_win = function()
    return winid
  end
  vim.api.nvim_get_current_buf = function()
    return bufnr
  end
end

function M.mock_tabpages(tabs)
  vim.api.nvim_list_tabpages = function()
    return tabs
  end
  vim.api.nvim_get_current_tabpage = function()
    return tabs[1] or 1
  end
  vim.fn.tabpagenr = function()
    return 1
  end
end

function M.mock_getpos(marks)
  vim.fn.getpos = function(which)
    return marks[which] or {0, 1, 1, 0}
  end
end

function M.mock_vim_fn_systemlist(result)
  vim.fn.systemlist = function(cmd)
    return result
  end
end

function M.mock_qflist(items)
  vim.fn.getqflist = function()
    return items
  end
end

function M.mock_loclist(items)
  vim.fn.getloclist = function(winid)
    return items
  end
end

function M.mock_line_col(line, col)
  vim.fn.line = function(which)
    if which == "." then return line end
    return 1
  end
  vim.fn.col = function(which)
    if which == "." then return col end
    return 1
  end
end

return M
