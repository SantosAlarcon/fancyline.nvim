local M = {}

---@type table<number, {error: number, warn: number, info: number, hint: number}|nil
local diag_cache = {}

function M.get_counts(bufnr)
  bufnr = bufnr or 0

  local cached = diag_cache[bufnr]
  if cached then
    return cached
  end

  local counts = {
    error = 0,
    warn = 0,
    info = 0,
    hint = 0,
  }

  local ok_diag, diagnostics = pcall(vim.diagnostic.count, bufnr)
  if not ok_diag or not diagnostics then
    diag_cache[bufnr] = counts
    return counts
  end

  counts.error = diagnostics[vim.diagnostic.severity.ERROR] or 0
  counts.warn = diagnostics[vim.diagnostic.severity.WARN] or 0
  counts.info = diagnostics[vim.diagnostic.severity.INFO] or 0
  counts.hint = diagnostics[vim.diagnostic.severity.HINT] or 0

  diag_cache[bufnr] = counts
  return counts
end

function M.format(counts, icons, separator)
  separator = separator or " "
  local parts = {}

  if counts.error > 0 then
    table.insert(parts, icons.error .. counts.error)
  end
  if counts.warn > 0 then
    table.insert(parts, icons.warn .. counts.warn)
  end
  if counts.info > 0 then
    table.insert(parts, icons.info .. counts.info)
  end
  if counts.hint > 0 then
    table.insert(parts, icons.hint .. counts.hint)
  end

  return #parts > 0 and table.concat(parts, separator) or nil
end

function M.has_diagnostics(bufnr)
  local counts = M.get_counts(bufnr)
  return counts.error > 0 or counts.warn > 0 or counts.info > 0 or counts.hint > 0
end

function M.invalidate_buf(bufnr)
  if bufnr then
    diag_cache[bufnr] = nil
  else
    diag_cache = {}
  end
end

function M.invalidate_all()
  diag_cache = {}
end

return M
