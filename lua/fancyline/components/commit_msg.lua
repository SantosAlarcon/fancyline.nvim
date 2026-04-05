local M = {}

---Provider function for the commit_msg component.
---@param opts? FancylineCommitMsgComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local cwd = vim.fn.getcwd()
  if not cwd or cwd == "" then
    return nil
  end

  if not vim.fs.root(cwd, { ".git" }) then
    return nil
  end

  local result
  if vim.system then
    local cmd = { "git", "-C", cwd, "log", "-1", "--pretty=%B" }
    local proc = vim.system(cmd, { text = true }):wait()
    result = proc.stdout
  else
    local ok, out = pcall(vim.fn.systemlist, {
      "git",
      "-C",
      cwd,
      "log",
      "-1",
      "--pretty=%B"
    })
    if not ok or not out or #out == 0 then
      return nil
    end
    result = out[1]
  end

  if not result or result == "" then
    return nil
  end

  local message = type(result) == "string" and result or result[1] or ""
  if message == "" then
    return nil
  end

  if opts.max_length and #message > opts.max_length then
    message = message:sub(1, opts.max_length) .. "…"
  end

  local icon_symbol = " "
  if opts.icon then
    if type(opts.icon) == "table" and opts.icon.symbol then
      icon_symbol = opts.icon.symbol
    elseif type(opts.icon) == "string" then
      icon_symbol = opts.icon
    end
  end

  return {
    text = message,
    icon = {
      symbol = icon_symbol,
      fg = opts.icon and opts.icon.fg,
      bg = opts.icon and opts.icon.bg,
    },
    style = opts.style or "none",
    highlight = "FancylineCommitMsg",
    fg = opts.fg,
    bg = opts.bg,
    bold = opts.bold,
    border = opts.border,
  }
end

return M
