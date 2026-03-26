local M = {}

function M.provider(opts, ctx)
  local encoding = vim.opt_local.fileencoding:get()
  if not encoding or encoding == "" then
    encoding = "utf-8"
  end

  local icon = opts.icon or "󰈔"
  local text = encoding

  return {
    text = icon .. " " .. text,
    highlight = "FancylineEncoding",
    style = opts.style or "none",
  }
end

return M
