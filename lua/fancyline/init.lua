require("fancyline.types")

local M = {}

---@type FancylineConfig|nil
local config = nil
local enabled = false
local timer = nil

-- Debounce timers for CursorMoved/CursorMovedI
local _debounce_timers = {
  cursor_moved = nil,
  cursor_moved_i = nil,
}

-- Debounce helper using vim.defer_fn for performance
---@param fn function The function to debounce
---@param timer_key string Key to store timer reference
---@param delay number Delay in milliseconds
local function debounced_refresh(fn, timer_key, delay)
  return function()
    -- Cancel existing timer if any
    if _debounce_timers[timer_key] then
      vim.fn.timer_stop(_debounce_timers[timer_key])
    end
    -- Start new timer
    _debounce_timers[timer_key] = vim.fn.timer_start(delay, function()
      _debounce_timers[timer_key] = nil
      fn()
    end)
  end
end

---@type string
local current_statusline = ""

-- Rate limiting for refreshes (minimum time between renders in ms)
local last_render_time = 0
local MIN_RENDER_INTERVAL = 16 -- ~60fps, cap at 60 renders per second

-- Cached module references for performance (avoids require() in autocmds)
---@type table<string, any>
local _cached = {
  git = nil,
  diagnostics = nil,
  renderer = nil,
  lsp = nil,
  statusline = nil,
}

local function load_config(opts)
  local default_config = require("fancyline.config")

  -- Default to "default" preset if none specified
  if not opts then opts = {} end
  if not opts.preset then opts.preset = "default" end

  local presets = require("fancyline.presets")
  local preset_config = presets.load(opts.preset)
  
  config = vim.tbl_deep_extend("force", default_config, preset_config, opts or {})

  return config
end

---@type table<string, string>
local mode_highlights = {
  n = "FancylineModeNormal",
  i = "FancylineModeInsert",
  v = "FancylineModeVisual",
  t = "FancylineModeTerminal",
  c = "FancylineModeCommand",
  r = "FancylineModeReplace",
  s = "FancylineModeSelect",
}

local function create_highlights(theme_name, theme_variant)
  local theme = require("fancyline.themes")
  local current_theme = theme.get(theme_name, theme_variant)

  theme.apply(current_theme)

  local mode_colors = config.components and config.components.mode and config.components.mode.colors or {}

  for mode, hl_name in pairs(mode_highlights) do
    local user_color = mode_colors[mode]
    if user_color then
      vim.api.nvim_set_hl(0, hl_name, { fg = user_color, bg = "NONE", bold = false })
    end
  end

  local diagnostics = require("fancyline.components.diagnostics")
  diagnostics.setup_highlights()

  vim.api.nvim_set_hl(0, "FancylineComponentBg", { fg = "NONE", bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineReset", { fg = "NONE", bg = "NONE" })
end

local function is_git_repo(cwd)
  if not cwd or cwd == "" then
    return false
  end
  -- Neovim 0.10+ required - vim.fs.root should always exist
  local root = vim.fs.root(cwd, { ".git" })
  return root ~= nil
end

local function ensure_git_utils()
  if not _cached.git then
    local cwd = vim.fn.getcwd()
    if cwd and cwd ~= "" and vim.fs.root(cwd, { ".git" }) then
      _cached.git = require("fancyline.utils.git")
    end
  end
  return _cached.git
end

local function invalidate_git_if_loaded()
  local git = ensure_git_utils()
  if git then
    git.invalidate()
  end
end

local function setup_autocmds()
  local augroup = vim.api.nvim_create_augroup("Fancyline", { clear = false })

  local function safe_autocmd(event, opts)
    local ok = pcall(vim.api.nvim_create_autocmd, event, opts)
  end

  local function render_callback()
    if enabled then
      M.refresh()
    end
  end

  safe_autocmd("BufEnter", {
    group = augroup,
    callback = function()
      invalidate_git_if_loaded()
      _cached.diagnostics.invalidate_buf(vim.api.nvim_get_current_buf())
      _cached.renderer.invalidate({ "file", "git_branch", "git_diff", "git_signs", "branch_status", "diagnostics", "errors", "warnings", "infos", "hints" })
      render_callback()
    end,
  })

  safe_autocmd("BufReadPost", {
    group = augroup,
    callback = function()
      -- Re-render after file is read so buffer name is available
      _cached.renderer.invalidate({ "file" })
      render_callback()
    end,
  })

  safe_autocmd("WinEnter", {
    group = augroup,
    callback = function()
      invalidate_git_if_loaded()
      _cached.renderer.invalidate({ "git_branch", "git_diff", "git_signs", "branch_status" })
      render_callback()
    end,
  })

  safe_autocmd("FileType", {
    group = augroup,
    callback = render_callback,
  })

  -- CursorMoved - ONLY invalidate position, DO NOT re-render
  -- Rendering on every cursor move is the main performance killer
  local cursor_moved_debounced = debounced_refresh(function()
    -- Only invalidate position cache, don't re-render
    _cached.renderer.invalidate({ "position" })
  end, "cursor_moved", 100)
  safe_autocmd("CursorMoved", {
    group = augroup,
    callback = cursor_moved_debounced,
  })

  -- CursorMovedI - ONLY invalidate position, DO NOT re-render
  local cursor_moved_i_debounced = debounced_refresh(function()
    _cached.renderer.invalidate({ "position" })
  end, "cursor_moved_i", 100)
  safe_autocmd("CursorMovedI", {
    group = augroup,
    callback = cursor_moved_i_debounced,
  })

  safe_autocmd("BufWritePost", {
    group = augroup,
    callback = function()
      _cached.diagnostics.invalidate_buf(vim.api.nvim_get_current_buf())
      _cached.renderer.invalidate({ "file", "diagnostics", "errors", "warnings", "infos", "hints" })
      M.refresh()
    end,
  })

  safe_autocmd("TextChangedI", {
    group = augroup,
    callback = function()
      _cached.diagnostics.invalidate_buf(vim.api.nvim_get_current_buf())
      _cached.renderer.invalidate({ "diagnostics", "errors", "warnings", "infos", "hints" })
      render_callback()
    end,
  })

  safe_autocmd("InsertLeave", {
    group = augroup,
    callback = function()
      _cached.diagnostics.invalidate_buf(vim.api.nvim_get_current_buf())
      _cached.renderer.invalidate({ "diagnostics", "errors", "warnings", "infos", "hints" })
      render_callback()
    end,
  })

  safe_autocmd("ModeChanged", {
    group = augroup,
    callback = function()
      -- Cancel pending debounce timers for immediate mode change response
      if _debounce_timers.cursor_moved then
        vim.fn.timer_stop(_debounce_timers.cursor_moved)
        _debounce_timers.cursor_moved = nil
      end
      if _debounce_timers.cursor_moved_i then
        vim.fn.timer_stop(_debounce_timers.cursor_moved_i)
        _debounce_timers.cursor_moved_i = nil
      end
      _cached.renderer.invalidate({ "mode" })
      M.refresh()
    end,
  })

  -- REMOVED: CursorHold was causing unnecessary re-renders every few seconds
  -- The statusline will still update on actual events (BufEnter, ModeChanged, etc.)
  -- safe_autocmd("CursorHold", {
  --   group = augroup,
  --   callback = render_callback,
  -- })

  safe_autocmd("DiagnosticChanged", {
    group = augroup,
    callback = function()
      _cached.diagnostics.invalidate_all()
      _cached.renderer.invalidate({ "diagnostics", "errors", "warnings", "infos", "hints" })
      M.refresh()
    end,
  })

  safe_autocmd("LspProgressUpdate", {
    group = augroup,
    callback = function()
      _cached.renderer.invalidate({ "lsp_progress" })
      M.refresh()
    end,
  })

  safe_autocmd("GitSignsUpdate", {
    group = augroup,
    callback = function()
      invalidate_git_if_loaded()
      _cached.renderer.invalidate({ "git_branch", "git_diff", "git_signs", "branch_status" })
      M.refresh()
    end,
  })

  safe_autocmd("User", {
    pattern = "GitSignsRefreshed",
    group = augroup,
    callback = function()
      invalidate_git_if_loaded()
      _cached.renderer.invalidate({ "git_diff", "git_signs" })
      M.refresh()
    end,
  })

  safe_autocmd("LspAttach", {
    group = augroup,
    callback = function()
      _cached.lsp.invalidate_all()
      _cached.renderer.invalidate({ "lsp", "lsp_progress", "lsp_clients" })
      M.refresh()
    end,
  })

  safe_autocmd("LspDetach", {
    group = augroup,
    callback = function()
      _cached.lsp.invalidate_all()
      _cached.renderer.invalidate({ "lsp", "lsp_progress", "lsp_clients" })
      M.refresh()
    end,
  })

  safe_autocmd("ColorScheme", {
    group = augroup,
    callback = function()
      local theme = require("fancyline.themes")
      -- Use the stored user config instead of re-extracting from config.theme
      local theme_cfg = _G.fancyline_theme_config or {}
      local theme_name = theme_cfg.name or "auto"
      local forced_variant = theme_cfg.variant
      require("fancyline.renderer.border").clear_cache()
      require("fancyline.renderer.border").invalidate_theme_cache()
      theme.apply(theme.get(theme_name, forced_variant))
      _cached.renderer.invalidate()
      M.refresh()
    end,
  })
end

local function setup_refresh_timer()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end

  if not config.refresh.enabled then
    return
  end

  local interval = config.refresh.interval or 250

  timer = assert(vim.loop.new_timer())
  timer:start(0, interval, vim.schedule_wrap(function()
    if enabled then
      M.refresh()
    end
  end))
end

---Setup Fancyline with the given options.
---@param opts? FancylineConfig
function M.setup(opts)
  -- Check Neovim version (requires 0.10+)
  local major, minor = vim.version().major, vim.version().minor
  if major < 0 or (major == 0 and minor < 10) then
    vim.notify("[Fancyline] Requires Neovim 0.10+. Current: " .. vim.version().major .. "." .. vim.version().minor, vim.log.levels.ERROR)
    return
  end

  config = load_config(opts)

  _G.fancyline_theme_config = {
    name = config.theme and config.theme.name or config.theme or "auto",
    variant = config.theme and config.theme.variant or nil,
  }

  vim.schedule(function()
    local theme = require("fancyline.themes")
    local theme_name = _G.fancyline_theme_config.name
    local theme_variant = _G.fancyline_theme_config.variant

    local current_theme = theme.get(theme_name, theme_variant)
    theme.apply(current_theme)

    config._theme_name = theme_name
    config._theme_variant = theme_variant

    create_highlights(theme_name, theme_variant)

    require("fancyline.renderer.border").pregenerate_highlights()

    _cached.diagnostics = require("fancyline.utils.diagnostics")
    _cached.renderer = require("fancyline.renderer")
    _cached.lsp = require("fancyline.utils.lsp")
    _cached.statusline = require("fancyline.statusline")

    setup_autocmds()
    setup_refresh_timer()

    if config.extensions then
      require("fancyline.extensions").setup(config.extensions)
    end

    enabled = true
    M.refresh()
  end)
end

function M.render()
  if not enabled then
    return ""
  end
  return _cached.statusline.render(config)
end

function M.enable()
  if enabled then
    return
  end
  enabled = true
  M.refresh()
end

function M.disable()
  enabled = false
  vim.o.statusline = ""
  current_statusline = ""
end

function M.refresh()
  if not enabled then
    return
  end
  
  -- Rate limiting: don't render more than MIN_RENDER_INTERVAL
  local now = vim.loop.now()
  if now - last_render_time < MIN_RENDER_INTERVAL then
    return
  end
  last_render_time = now
  
  local new_status = _cached.statusline.render(config)
  if new_status ~= current_statusline then
    current_statusline = new_status
    vim.o.statusline = new_status
  end
end

function M.get_config()
  return config
end

function M.reload()
  create_highlights()
  require("fancyline.renderer").invalidate()
  M.refresh()
end

return M
