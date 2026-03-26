local M = {}

function M.provider(opts, ctx)
  local expandtab = vim.opt_local.expandtab:get()
  local tabstop = vim.opt_local.tabstop:get()

  local icon = opts.icon or "󰌒"
  local text

  if expandtab then
    local shiftwidth = vim.opt_local.shiftwidth:get()
    text = "spaces: " .. shiftwidth
  else
    text = "tabs"
  end

  return {
    text = icon .. " " .. text,
    highlight = "FancylineIndent",
    style = opts.style or "none",
  }
end

return M
