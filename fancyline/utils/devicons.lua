local M = {}

local devicons = nil

local function ensure_loaded()
  if devicons ~= nil then
    return
  end

  -- Use nvim-web-devicons for file icons
  local ok, icons = pcall(require, "nvim-web-devicons")
  if ok then
    devicons = icons
  end
end

-- Get icon for filename + extension
function M.get_icon(filename, ext, opts)
  ensure_loaded()

  if not devicons then
    return opts and opts.fallback_icon or nil
  end

  opts = opts or {}
  local icon = devicons.get_icon(filename, ext, {
    default = opts.default or false,
  })

  return icon, nil
end

-- Get icon with highlight
function M.get_icon_colored(filename, ext)
  ensure_loaded()

  if not devicons then
    return nil
  end

  local icon, hl = devicons.get_icon(filename, ext, { default = true })
  return icon, hl
end

-- Get icon for current buffer filetype
function M.get_filetype_icon(bufnr)
  bufnr = bufnr or 0

  ensure_loaded()

  if not devicons then
    return nil
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return nil
  end

  local ext = vim.fn.fnamemodify(filename, ":e")
  return devicons.get_icon(filename, ext, { default = true })
end

return M
