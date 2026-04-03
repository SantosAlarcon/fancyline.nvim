local function add_helptags()
  local doc_path = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.expand('<sfile>:p')), ':h:h') .. '/doc/'
  if vim.fn.isdirectory(doc_path) == 1 then
    vim.cmd('helptags ' .. vim.fn.fnameescape(doc_path))
  end
end
add_helptags()

-- Defer loading to avoid blocking Neovim startup
-- The actual require will happen on first statusline render
vim.defer_fn(function()
  require("fancyline")
end, 0)
