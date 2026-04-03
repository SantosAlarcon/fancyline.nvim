local function add_helptags()
  local doc_path = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.expand('<sfile>:p')), ':h:h') .. '/doc/'
  if vim.fn.isdirectory(doc_path) == 1 then
    vim.cmd('helptags ' .. vim.fn.fnameescape(doc_path))
  end
end
add_helptags()

-- Don't load fancyline at startup - it will be loaded by lazy.nvim config
-- This keeps startup fast, the plugin loads only when statusline is rendered
