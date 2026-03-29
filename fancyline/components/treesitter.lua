local M = {}

function M.provider(opts, ctx)
  -- Check if vim.treesitter.get_buf_lang is available (Neovim 0.10+)
  if not rawget(vim, "treesitter") or not vim.treesitter then
    return nil
  end
  if not vim.treesitter.get_buf_lang then
    return nil
  end

  local buf = ctx.bufnr
  local lang = vim.treesitter.get_buf_lang(buf)
  if not lang or lang == "" then
    return nil
  end

  local icon = (opts.icon and opts.icon.symbol) or "TS"
  local text = icon .. " " .. lang

  local icon_symbol = " "
  if opts.icon then
    if type(opts.icon) == "table" and opts.icon.symbol then
      icon_symbol = opts.icon.symbol
    elseif type(opts.icon) == "string" then
      icon_symbol = opts.icon
    end
  end

  return {
    text = text,
    icon = {
      symbol = icon_symbol,
      fg = opts.icon and opts.icon.fg,
      bg = opts.icon and opts.icon.bg,
    },
    style = opts.style or "none",
    highlight = "FancylineTreesitter",
    fg = opts.fg,
    bg = opts.bg,
    border = opts.border,
  }
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineTreesitter", { fg = "#4caf50", bold = false })
end

return M
