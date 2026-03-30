local M = {}

local border = require("fancyline.renderer.border")
local cache = require("fancyline.utils.cache")

---Lazy-loaded component providers
---@type table<string, FancylineProvider|false>
local component_providers = {}

---Module loading state
---@type table<string, boolean>
local modules_loaded = {}

---Component names for preloading
---@type string[]
local COMPONENT_NAMES = {
  "mode", "git_branch", "git_diff", "file", "diagnostics",
  "errors", "warnings", "infos", "hints", "lsp", "lsp_progress",
  "filetype", "encoding", "indent", "position", "branch_status",
  "bufnr", "checktime", "commit_msg", "cwd", "dap", "fileformat",
  "filesize", "git_signs", "lsp_clients", "macro_recording",
  "project", "quickfix", "reload", "search_stats", "spell",
  "tabnr", "treesitter",
}

---Components that should never be cached (always re-render)
---@type table<string, true>
local UNCACHED_COMPONENTS = {
  position = true,
  macro_recording = true,
  search_stats = true,
  mode = true,
  diagnostics = true,
  errors = true,
  warnings = true,
  infos = true,
  hints = true,
  git_diff = true,
  git_branch = true,
  git_signs = true,
  branch_status = true,
  lsp = true,
  lsp_progress = true,
  lsp_clients = true,
}

---Load a component module on demand
---@param name string
---@return FancylineProvider?
local function load_component(name)
  if modules_loaded[name] then
    return component_providers[name]
  end
  local ok, provider = pcall(require, "fancyline.components." .. name)
  if ok and provider then
    component_providers[name] = provider
    modules_loaded[name] = true
    return provider
  end
  component_providers[name] = false
  modules_loaded[name] = true
  return nil
end

---Preload all component modules
function M.preload_modules()
  for _, name in ipairs(COMPONENT_NAMES) do
    load_component(name)
  end
end

---Component render cache
---@type table<string, {rendered: string, ctx_hash: number}|nil>
local component_cache = {}

---Compute a simple hash from context
---@param ctx FancylineContext
---@return number
local function ctx_hash(ctx)
  return ctx.bufnr + ctx.winid * 1000000
end

---@param val any
---@return boolean
local function is_array(val)
  if type(val) ~= "table" then return false end
  local i = 0
  for _ in pairs(val) do
    i = i + 1
    if val[i] == nil then return false end
  end
  return i > 0
end

---@param name string
---@param opts table
---@param ctx FancylineContext
---@return string
local function render_component(name, opts, ctx)
  local cache_key = name .. "_" .. ctx_hash(ctx)
  local current_hash = ctx_hash(ctx)

  if not UNCACHED_COMPONENTS[name] then
    local cached = component_cache[cache_key]
    if cached and cached.ctx_hash == current_hash then
      return cached.rendered
    end
  end

  local provider = load_component(name)
  if not provider then
    return ""
  end

  local comp_opts = opts or {}
  local result = provider.provider(comp_opts, ctx)

  if not result then
    component_cache[cache_key] = nil
    return ""
  end

  local rendered = ""

  if is_array(result) then
    local parts = {}
    for _, item in ipairs(result) do
      local item_rendered = border.render_component(
        item.icon,
        item.text,
        item.style or "none",
        item.highlight,
        item.fg,
        item.bg,
        item.state
      )
      if item_rendered and item_rendered ~= "" then
        table.insert(parts, item_rendered)
      end
    end
    rendered = table.concat(parts, "  ")
  else
    local item_rendered

    if result.border then
      item_rendered = border.render_custom_border(
        result.border,
        result.icon,
        result.text,
        result.highlight,
        result.fg,
        result.bg,
        result.state
      )
    elseif border.parse_icon(result.icon).symbol and border.parse_icon(result.icon).symbol ~= "" then
      item_rendered = border.render_with_icon(
        result.icon,
        result.text,
        result.style or "none",
        result.highlight,
        result.fg,
        result.bg,
        result.state
      )
    else
      item_rendered = border.render_component(
        result.icon,
        result.text,
        result.style or "none",
        result.highlight,
        result.fg,
        result.bg,
        result.state
      )
    end

    rendered = item_rendered or ""
  end

  if not UNCACHED_COMPONENTS[name] then
    component_cache[cache_key] = { rendered = rendered, ctx_hash = current_hash }
  end
  return rendered
end

---Render the statusline based on the given configuration.
---@param config FancylineConfig
---@return string
function M.render(config)
  local sections = config.sections or {
    left = { "mode" },
    center = { "file" },
    right = { "cursor" },
  }

  local ctx = {
    bufnr = vim.api.nvim_get_current_buf(),
    winid = vim.api.nvim_get_current_win(),
  }

  local function render_section(section_names)
    local parts = {}

    for _, name in ipairs(section_names) do
      local comp_opts = config.components and config.components[name] or {}
      local rendered = render_component(name, comp_opts, ctx)
      if rendered and rendered ~= "" then
        table.insert(parts, rendered)
      end
    end

    return table.concat(parts, "  ")
  end

  local left_content = render_section(sections.left or {})
  local center_content = render_section(sections.center or {})
  local right_content = render_section(sections.right or {})

  local separator = "  " .. (config.separator or "│") .. "  "

  local parts = {}

  if left_content ~= "" then
    table.insert(parts, left_content)
  end

  if center_content ~= "" then
    if #parts > 0 then
      table.insert(parts, "%=")
    end
    table.insert(parts, center_content)
  end

  if right_content ~= "" then
    if #parts > 0 then
      table.insert(parts, "%=")
    end
    table.insert(parts, right_content)
  end

  if #parts == 0 then
    return "%="
  end

  return table.concat(parts, separator)
end

---Invalidate cache for specific components or all
---@param names? string[] Component names to invalidate, or nil for all
function M.invalidate(names)
  if names then
    for _, name in ipairs(names) do
      component_cache[name] = nil
    end
  else
    component_cache = {}
  end
end

---Register a custom component provider.
---@param name string
---@param provider FancylineProvider
function M.register_component(name, provider)
  component_providers[name] = provider
  modules_loaded[name] = true
  component_cache[name] = nil
end

---Get a registered component provider.
---@param name string
---@return FancylineProvider?
function M.get_component(name)
  return component_providers[name]
end

return M
