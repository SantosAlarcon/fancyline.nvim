local M = {}

local cache = require("fancyline.utils.cache")

local CACHE_TTL = 30000

local _state = {
	root = nil,
	branch = nil,
	ahead = 0,
	behind = 0,
	staged = 0,
	modified = 0,
	untracked = 0,
	timestamp = 0,
}

local function is_git_repo(cwd)
	if not cwd or cwd == "" then
		return false
	end
	return vim.fs.root(cwd, { ".git" }) ~= nil
end

local function parse_porcelain_status(output)
	local staged = 0
	local modified = 0
	local untracked = 0

	for line in output:gmatch("[^\r\n]+") do
		if #line >= 2 then
			local index_status = line:sub(1, 1)
			local worktree_status = line:sub(2, 2)

			if index_status == "?" and worktree_status == "?" then
				untracked = untracked + 1
			elseif index_status ~= " " and index_status ~= "?" then
				staged = staged + 1
			end

			if worktree_status ~= " " and worktree_status ~= "?" and worktree_status ~= index_status then
				modified = modified + 1
			end
		end
	end

	return staged, modified, untracked
end

local function parse_status_header(header)
	local branch = nil
	local ahead = 0
	local behind = 0

	for line in header:gmatch("[^\r\n]+") do
		local branch_match = line:match("^## ([^%s].*)$")
		if branch_match then
			local ahead_match = branch_match:match("ahead%s+(%d+)")
			local behind_match = branch_match:match("behind%s+(%d+)")

			if ahead_match then
				ahead = tonumber(ahead_match) or 0
			end
			if behind_match then
				behind = tonumber(behind_match) or 0
			end

			-- local branch_only = branch_match:gsub("%s+", " "):gsub("%s+ahead%s+%d+", "")
			-- 	:gsub("%s+behind%s+%d+", ""):gsub("%s+", "")
			local branch_only = branch_match.gsub(branch_match, "%S.......", "")
			if branch_only and branch_only ~= "" and branch_only ~= "(no branch)" then
				branch = branch_only
			elseif not branch then
				branch = ""
			end
		end
	end

	return branch, ahead, behind
end

local function update_git_state(cwd)
	local timestamp = vim.loop.now()
	if _state.timestamp > 0 and (timestamp - _state.timestamp) < CACHE_TTL then
		return
	end

	_state.root = nil
	_state.branch = nil
	_state.ahead = 0
	_state.behind = 0
	_state.staged = 0
	_state.modified = 0
	_state.untracked = 0

	if not is_git_repo(cwd) then
		_state.timestamp = timestamp
		cache.set("git_root", nil, CACHE_TTL)
		cache.set("git_branch", nil, CACHE_TTL)
		cache.set("git_ahead_behind", { nil, nil }, CACHE_TTL)
		cache.set("git_diff_counts", nil, CACHE_TTL)
		return
	end

	_state.root = vim.fs.root(cwd, { ".git" })
	cache.set("git_root", _state.root, CACHE_TTL)

	local cmd = { "git", "-C", cwd, "-c", "color.status=no", "status", "--porcelain=v1", "-b", "-uall" }
	local output

	if vim.system then
		local result = vim.system(cmd, { text = true }):wait()
		output = result.stdout or ""
	else
		local args = table.concat(cmd, " ")
		local handle = io.popen(args)
		output = handle and handle:read("*a") or ""
		if handle then
			handle:close()
		end
	end

	local header_end = output:find("\n[^#]")
	local header = header_end and output:sub(1, header_end - 1) or output
	local body = header_end and output:sub(header_end + 1) or ""

	_state.branch, _state.ahead, _state.behind = parse_status_header(header)
	_state.staged, _state.modified, _state.untracked = parse_porcelain_status(body)

	_state.timestamp = timestamp

	if _state.branch then
		cache.set("git_branch", _state.branch, CACHE_TTL)
	end

	if _state.ahead > 0 or _state.behind > 0 then
		cache.set("git_ahead_behind", { _state.ahead, _state.behind }, CACHE_TTL)
	else
		cache.set("git_ahead_behind", { nil, nil }, CACHE_TTL)
	end

	if _state.staged > 0 or _state.modified > 0 or _state.untracked > 0 then
		cache.set("git_diff_counts", {
			added = _state.staged,
			changed = _state.modified,
			untracked = _state.untracked,
		}, CACHE_TTL)
	else
		cache.set("git_diff_counts", nil, CACHE_TTL)
	end
end

function M.get_root()
	local cwd = vim.fn.getcwd()
	if not cwd or cwd == "" then
		return nil
	end

	local cached = cache.get("git_root")
	if cached ~= nil then
		return cached
	end

	update_git_state(cwd)
	return _state.root
end

function M.get_branch()
	local cwd = vim.fn.getcwd()
	if not cwd or cwd == "" then
		return nil
	end

	local cached = cache.get("git_branch")
	if cached ~= nil then
		return cached
	end

	update_git_state(cwd)
	return _state.branch
end

function M.get_ahead_behind()
	local cwd = vim.fn.getcwd()
	if not cwd or cwd == "" then
		return nil, nil
	end

	local cached = cache.get("git_ahead_behind")
	if cached ~= nil then
		return cached[1], cached[2]
	end

	update_git_state(cwd)
	return _state.ahead > 0 and _state.ahead or nil,
		_state.behind > 0 and _state.behind or nil
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
	local cwd = vim.fn.getcwd()
	if not cwd or cwd == "" then
		return nil
	end

	local cached = cache.get("git_diff_counts")
	if cached ~= nil then
		return cached
	end

	update_git_state(cwd)

	if _state.staged > 0 or _state.modified > 0 or _state.untracked > 0 then
		return {
			added = _state.staged,
			changed = _state.modified,
			untracked = _state.untracked,
		}
	end

	return nil
end

function M.get_diff()
	local counts = M.get_diff_counts()
	if not counts then
		return nil
	end

	local parts = {}
	if counts.added > 0 then
		table.insert(parts, "+" .. counts.added)
	end
	if counts.changed > 0 then
		table.insert(parts, "~" .. counts.changed)
	end
	if counts.untracked > 0 then
		table.insert(parts, "?" .. counts.untracked)
	end

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
	_state.timestamp = 0
	cache.clear("git_branch")
	cache.clear("git_diff_counts")
	cache.clear("git_ahead_behind")
	cache.clear("git_root")
end

return M
