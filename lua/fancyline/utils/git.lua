local M = {}

local cache = require("fancyline.utils.cache")

-- Longer cache TTL to avoid spawning shell processes on every render
-- 30 seconds instead of 2 seconds - acceptable staleness for git info
local GIT_CACHE_TTL = 30000

function M.get_root()
  local cached = cache.get("git_root")
  if cached ~= nil then
    return cached
  end

  local cwd = vim.fn.getcwd()
  if not cwd or cwd == "" then
    cache.set("git_root", nil, GIT_CACHE_TTL)
    return nil
  end

  local handle = io.popen("cd " .. cwd .. " && git rev-parse --show-toplevel 2>/dev/null")
  if handle then
    local root = handle:read("*a"):gsub("%s+", ""):gsub("\n", "")
    handle:close()
    if root and root ~= "" then
      cache.set("git_root", root, GIT_CACHE_TTL)
      return root
    end
  end

  cache.set("git_root", nil, GIT_CACHE_TTL)
  return nil
end

function M.get_ahead_behind()
  local cached = cache.get("git_ahead_behind")
  if cached ~= nil then
    return cached[1], cached[2]
  end

  local cwd = vim.fn.getcwd()
  if not cwd or cwd == "" then
    cache.set("git_ahead_behind", { nil, nil }, GIT_CACHE_TTL)
    return nil, nil
  end

  local ahead = 0
  local behind = 0

  local rev_list = io.popen("cd " .. cwd .. " && git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null")
  if rev_list then
    local output = rev_list:read("*a"):gsub("%s+", ""):gsub("\n", "")
    rev_list:close()
    if output and output:match("^%d+%d+$") then
      local ahead_behind = {}
      for num in output:gmatch("%d+") do
        table.insert(ahead_behind, tonumber(num))
      end
      if #ahead_behind >= 2 then
        ahead = ahead_behind[1]
        behind = ahead_behind[2]
      end
    end
  end

  local result = { ahead, behind }
  if ahead == 0 and behind == 0 then
    cache.set("git_ahead_behind", { nil, nil }, GIT_CACHE_TTL)
    return nil, nil
  end

  cache.set("git_ahead_behind", result, GIT_CACHE_TTL)
  return ahead, behind
end

function M.get_branch()
  local cached = cache.get("git_branch")
  if cached ~= nil then
    return cached
  end

  local cwd = vim.fn.getcwd()
  if cwd and cwd ~= "" then
    local handle = io.popen("cd " .. cwd .. " && git branch --show-current 2>/dev/null")
    if handle then
      local branch = handle:read("*a"):gsub("%s+", ""):gsub("\n", "")
      handle:close()
      if branch and branch ~= "" then
        cache.set("git_branch", branch, GIT_CACHE_TTL)
        return branch
      end
    end
  end

  local ok, gitsigns = pcall(require, "gitsigns")
  if ok and gitsigns then
    local bufnr = vim.api.nvim_get_current_buf()
    local head = vim.b[bufnr].gitsigns_head
    if not head then
      head = vim.b[0].gitsigns_head
    end
    if head then
      cache.set("git_branch", head, GIT_CACHE_TTL)
      return head
    end
  end

  cache.set("git_branch", nil, GIT_CACHE_TTL)
  return nil
end

function M.get_status_dict(bufnr)
  bufnr = bufnr or 0
  local status = vim.b[bufnr].gitsigns_status_dict
  if status then
    return status
  end
  return nil
end

function M.get_diff_counts()
  local cached = cache.get("git_diff_counts")
  if cached ~= nil then
    return cached
  end

  local cwd = vim.fn.getcwd()
  if not cwd or cwd == "" then
    cache.set("git_diff_counts", nil, GIT_CACHE_TTL)
    return nil
  end

  local added = 0
  local changed = 0
  local untracked = 0

  local staged_cmd = io.popen("cd " .. cwd .. " && git diff --cached --name-status 2>/dev/null")
  if staged_cmd then
    for _ in staged_cmd:lines() do added = added + 1 end
    staged_cmd:close()
  end

  local unstaged_cmd = io.popen("cd " .. cwd .. " && git diff --name-status 2>/dev/null")
  if unstaged_cmd then
    for _ in unstaged_cmd:lines() do changed = changed + 1 end
    unstaged_cmd:close()
  end

  local untracked_cmd = io.popen("cd " .. cwd .. " && git ls-files --others --exclude-standard 2>/dev/null | wc -l")
  if untracked_cmd then
    local n = untracked_cmd:read("*a"):match("%d+")
    untracked = tonumber(n) or 0
    untracked_cmd:close()
  end

  if added > 0 or changed > 0 or untracked > 0 then
    local result = { added = added, changed = changed, untracked = untracked }
    cache.set("git_diff_counts", result, GIT_CACHE_TTL)
    return result
  end

  cache.set("git_diff_counts", nil, GIT_CACHE_TTL)
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

function M.invalidate()
  cache.clear("git_branch")
  cache.clear("git_diff_counts")
  cache.clear("git_ahead_behind")
  cache.clear("git_root")
end

return M
