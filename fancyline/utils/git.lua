local M = {}

function M.get_branch()
  -- Try git command first (always works if in a git repo)
  local cwd = vim.fn.getcwd()
  if cwd and cwd ~= "" then
    local handle = io.popen("cd " .. cwd .. " && git branch --show-current 2>/dev/null")
    if handle then
      local branch = handle:read("*a"):gsub("%s+", ""):gsub("\n", "")
      handle:close()
      if branch and branch ~= "" then
        return branch
      end
    end
  end

  -- Fallback to gitsigns if git command failed
  local ok, _ = pcall(require, "gitsigns")
  if ok then
    local bufnr = vim.api.nvim_get_current_buf()
    local head = vim.b[bufnr].gitsigns_head
    if not head then
      head = vim.b[0].gitsigns_head
    end
    if head then return head end
  end

  return nil
end

function M.get_status_dict(bufnr)
  bufnr = bufnr or 0
  return vim.b[bufnr].gitsigns_status_dict
end

function M.get_diff_counts()
  local cwd = vim.fn.getcwd()
  if not cwd or cwd == "" then return nil end

  local added = 0
  local changed = 0
  local untracked = 0

  -- Count staged files
  local staged_cmd = io.popen("cd " .. cwd .. " && git diff --cached --name-status 2>/dev/null")
  if staged_cmd then
    for _ in staged_cmd:lines() do added = added + 1 end
    staged_cmd:close()
  end

  -- Count unstaged changes
  local unstaged_cmd = io.popen("cd " .. cwd .. " && git diff --name-status 2>/dev/null")
  if unstaged_cmd then
    for _ in unstaged_cmd:lines() do changed = changed + 1 end
    unstaged_cmd:close()
  end

  -- Count untracked files
  local untracked_cmd = io.popen("cd " .. cwd .. " && git ls-files --others --exclude-standard 2>/dev/null | wc -l")
  if untracked_cmd then
    local n = untracked_cmd:read("*a"):match("%d+")
    untracked = tonumber(n) or 0
    untracked_cmd:close()
  end

  if added > 0 or changed > 0 or untracked > 0 then
    return { added = added, changed = changed, untracked = untracked }
  end

  return nil
end

function M.get_diff()
  local counts = M.get_diff_counts()
  if not counts then return nil end

  local parts = {}
  if counts.added > 0 then table.insert(parts, "+" .. counts.added) end
  if counts.changed > 0 then table.insert(parts, "~" .. counts.changed) end
  if counts.untracked > 0 then table.insert(parts, "?" .. counts.untracked) end

  if #parts > 0 then
    return table.concat(parts, " ")
  end

  return nil
end

function M.get_status()
  return {
    branch = M.get_branch(),
    diff = M.get_diff(),
    has_changes = M.get_diff() ~= nil,
  }
end

return M
