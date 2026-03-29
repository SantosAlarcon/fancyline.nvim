local M = {}

function M.provider(opts, ctx)
  local bufname = vim.api.nvim_buf_get_name(ctx.bufnr)
  if bufname == "" then
    return nil
  end

  local has_gitsigns, gitsigns = pcall(require, "gitsigns")
  if not has_gitsigns then
    return nil
  end

  local signs = gitsigns.get_hunks(ctx.bufnr)
  if not signs or #signs == 0 then
    return nil
  end

  local added = 0
  local changed = 0
  local deleted = 0

  for _, hunk in ipairs(signs) do
    if hunk.type == "add" then
      added = added + 1
    elseif hunk.type == "change" then
      changed = changed + 1
    elseif hunk.type == "delete" then
      deleted = deleted + 1
    end
  end

  if added == 0 and changed == 0 and deleted == 0 then
    return nil
  end

  local sections = {}
  local icon_added = (opts.icons and opts.icons.added) or "│"
  local icon_changed = (opts.icons and opts.icons.changed) or "▎"
  local icon_deleted = (opts.icons and opts.icons.deleted) or "┌"

  if added > 0 then
    table.insert(sections, {
      text = icon_added,
      highlight = "FancylineGitAdded",
      style = "none",
    })
  end

  if changed > 0 then
    table.insert(sections, {
      text = icon_changed,
      highlight = "FancylineGitChanged",
      style = "none",
    })
  end

  if deleted > 0 then
    table.insert(sections, {
      text = icon_deleted,
      highlight = "FancylineGitDeleted",
      style = "none",
    })
  end

  if #sections == 0 then
    return nil
  end

  return sections
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FancylineGitAdded", { fg = "#4caf50", bold = false })
  vim.api.nvim_set_hl(0, "FancylineGitChanged", { fg = "#ff9800", bold = false })
  vim.api.nvim_set_hl(0, "FancylineGitDeleted", { fg = "#f44336", bold = false })
end

return M
