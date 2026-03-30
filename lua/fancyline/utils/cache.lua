local M = {}

---@class FancylineCacheEntry
---@field value any
---@field expires number

---@type table<string, FancylineCacheEntry>
local cache = {}

---Get a cached value
---@param key string Cache key
---@return any|nil
function M.get(key)
  local entry = cache[key]
  if entry then
    if entry.expires == 0 or entry.expires > vim.loop.now() then
      return entry.value
    end
    cache[key] = nil
  end
  return nil
end

---Set a cached value with TTL in milliseconds (0 = no expiry)
---@param key string Cache key
---@param value any Value to cache
---@param ttl number Time to live in ms (0 = never expires)
function M.set(key, value, ttl)
  ttl = ttl or 0
  local expires = ttl > 0 and (vim.loop.now() + ttl) or 0
  cache[key] = { value = value, expires = expires }
end

---Clear a specific cache entry
---@param key string Cache key
function M.clear(key)
  cache[key] = nil
end

---Clear all cache entries
function M.clear_all()
  cache = {}
end

---Get or set a cached value
---@param key string Cache key
---@param ttl number Time to live in ms
---@param compute fun():any Function to compute value if not cached
---@return any
function M.get_or_set(key, ttl, compute)
  local value = M.get(key)
  if value == nil then
    value = compute()
    M.set(key, value, ttl)
  end
  return value
end

return M
