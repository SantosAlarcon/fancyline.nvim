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
      require("fancyline.utils.git").invalidate()
      require("fancyline.utils.diagnostics").invalidate_buf(vim.api.nvim_get_current_buf())
      require("fancyline.renderer").invalidate({ "git_branch", "git_diff", "git_signs", "branch_status", "diagnostics", "errors", "warnings", "infos", "hints" })
      render_callback()
    end,
  })

  safe_autocmd("WinEnter", {
    group = augroup,
    callback = function()
      require("fancyline.utils.git").invalidate()
      require("fancyline.renderer").invalidate({ "git_branch", "git_diff", "git_signs", "branch_status" })
      render_callback()
    end,
  })

  safe_autocmd("FileType", {
    group = augroup,
    callback = render_callback,
  })

  -- Debounced CursorMoved (50ms delay to reduce refresh frequency)
  local cursor_moved_debounced = debounced_refresh(render_callback, "cursor_moved", 50)
  safe_autocmd("CursorMoved", {
    group = augroup,
    callback = cursor_moved_debounced,
  })

  -- Debounced CursorMovedI (50ms delay for insert mode)
  local cursor_moved_i_debounced = debounced_refresh(render_callback, "cursor_moved_i", 50)
  safe_autocmd("CursorMovedI", {
    group = augroup,
    callback = cursor_moved_i_debounced,
  })

  safe_autocmd("BufWritePost", {
    group = augroup,
    callback = function()
      require("fancyline.utils.diagnostics").invalidate_buf(vim.api.nvim_get_current_buf())
      require("fancyline.renderer").invalidate({ "file", "diagnostics", "errors", "warnings", "infos", "hints" })
      M.refresh()
    end,
  })

  safe_autocmd("TextChangedI", {
    group = augroup,
    callback = function()
      require("fancyline.utils.diagnostics").invalidate_buf(vim.api.nvim_get_current_buf())
      require("fancyline.renderer").invalidate({ "diagnostics", "errors", "warnings", "infos", "hints" })
      render_callback()
    end,
  })

  safe_autocmd("InsertLeave", {
    group = augroup,
    callback = function()
      require("fancyline.utils.diagnostics").invalidate_buf(vim.api.nvim_get_current_buf())
      require("fancyline.renderer").invalidate({ "diagnostics", "errors", "warnings", "infos", "hints" })
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
      require("fancyline.renderer").invalidate({ "mode" })
      M.refresh()
    end,
  })

  safe_autocmd("CursorHold", {
    group = augroup,
    callback = render_callback,
  })

  safe_autocmd("DiagnosticChanged", {
    group = augroup,
    callback = function()
      require("fancyline.renderer").invalidate({ "diagnostics", "errors", "warnings", "infos", "hints" })
      M.refresh()
    end,
  })

  safe_autocmd("LspProgressUpdate", {
    group = augroup,
    callback = function()
      require("fancyline.renderer").invalidate({ "lsp_progress" })
      M.refresh()
    end,
  })

  safe_autocmd("GitSignsUpdate", {
    group = augroup,
    callback = function()
      require("fancyline.utils.git").invalidate()
      require("fancyline.renderer").invalidate({ "git_branch", "git_diff", "git_signs", "branch_status" })
      M.refresh()
    end,
  })

  safe_autocmd("User", {
    pattern = "GitSignsRefreshed",
    group = augroup,
    callback = function()
      require("fancyline.utils.git").invalidate()
      require("fancyline.renderer").invalidate({ "git_diff", "git_signs" })
      M.refresh()
    end,
  })

  safe_autocmd("LspAttach", {
    group = augroup,
    callback = function()
      require("fancyline.utils.lsp").invalidate_all()
      require("fancyline.renderer").invalidate({ "lsp", "lsp_progress", "lsp_clients" })
      M.refresh()
    end,
  })

  safe_autocmd("LspDetach", {
    group = augroup,
    callback = function()
      require("fancyline.utils.lsp").invalidate_all()
      require("fancyline.renderer").invalidate({ "lsp", "lsp_progress", "lsp_clients" })
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
      require("fancyline.renderer").invalidate()
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
  config = load_config(opts)

  local theme = require("fancyline.themes")
  local theme_name = config.theme
  local theme_variant = nil

  if type(theme_name) == "table" and theme_name.name then
    theme_variant = theme_name.variant
    theme_name = theme_name.name
  end

  local current_theme = theme.get(theme_name, theme_variant)
  theme.apply(current_theme)

  config._theme_name = theme_name
  config._theme_variant = theme_variant

  -- Store user's theme config globally so it can be reused by border.lua and autocmds
  _G.fancyline_theme_config = {
    name = theme_name,
    variant = theme_variant,
  }

  create_highlights(theme_name, theme_variant)
  require("fancyline.renderer.border").pregenerate_highlights()
  setup_autocmds()
  setup_refresh_timer()
  require("fancyline.renderer").preload_modules()

  if config.extensions then
    require("fancyline.extensions").setup(config.extensions)
  end

  enabled = true
  M.refresh()
end

function M.render()
  if not enabled then
    return ""
  end
  return require("fancyline.statusline").render(config)
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
  
  local new_status = require("fancyline.statusline").render(config)
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
