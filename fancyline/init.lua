local M = {}

local config = {}
local enabled = false
local render_fn = nil
local timer = nil
local throttle = require("fancyline.utils.throttle")

local function load_config(opts)
  local default_config = require("fancyline.config")

  -- Load preset if specified
  if opts and opts.preset then
    local presets = require("fancyline.presets")
    local preset_config = presets.load(opts.preset)
    -- Merge preset with user opts (user opts override preset)
    config = vim.tbl_deep_extend("force", default_config, preset_config, opts or {})
  else
    config = vim.tbl_deep_extend("force", default_config, opts or {})
  end

  return config
end

-- Mode highlight names mapping
local mode_highlights = {
  n = "FancylineModeNormal",
  i = "FancylineModeInsert",
  v = "FancylineModeVisual",
  V = "FancylineModeVisual",
  ["^V"] = "FancylineModeVisual",
  t = "FancylineModeTerminal",
  ["!"] = "FancylineModeTerminal",
  c = "FancylineModeCommand",
  r = "FancylineModeReplace",
  R = "FancylineModeReplace",
  rv = "FancylineModeReplace",
  s = "FancylineModeSelect",
  S = "FancylineModeSelect",
  ["^S"] = "FancylineModeSelect",
}

local function create_highlights()
  local theme = require("fancyline.themes")
  local current_theme = theme.get(config.theme)

  -- Apply theme base highlights
  theme.apply(current_theme)

  -- Apply user overrides for mode colors
  local mode_colors = config.components and config.components.mode and config.components.mode.colors or {}

  for mode, hl_name in pairs(mode_highlights) do
    local user_color = mode_colors[mode]
    if user_color then
      vim.api.nvim_set_hl(0, hl_name, { fg = user_color, bg = "NONE", bold = true })
    end
  end

  -- Diagnostic highlights (each type has its own color)
  local diagnostics = require("fancyline.components.diagnostics")
  diagnostics.setup_highlights()

  -- Other component defaults
  vim.api.nvim_set_hl(0, "FancylineComponentBg", { fg = "NONE", bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineReset", { fg = "NONE", bg = "NONE" })
end

local function setup_autocmds()
  local augroup = vim.api.nvim_create_augroup("Fancyline", { clear = false })

  -- Safe autocmd creation (ignore events that don't exist)
  local function safe_autocmd(event, opts)
    local ok, err = pcall(vim.api.nvim_create_autocmd, event, opts)
    if not ok then
      -- Event might not exist (e.g., GitSignsUpdate without gitsigns)
      -- Silently ignore
    end
  end

  -- Core events that always exist
  local core_events = {
    "ModeChanged",
    "BufEnter",
    "WinEnter",
    "FileType",
  }

  for _, event in ipairs(core_events) do
    safe_autocmd(event, {
      group = augroup,
      callback = function()
        if enabled and render_fn then
          render_fn()
        end
      end,
    })
  end

  -- Optional events (may not exist without plugins)
  safe_autocmd("DiagnosticChanged", {
    group = augroup,
    callback = function()
      if enabled and render_fn then
        render_fn()
      end
    end,
  })

  safe_autocmd("GitSignsUpdate", {
    group = augroup,
    callback = function()
      if enabled and render_fn then
        render_fn()
      end
    end,
  })

  -- LSP events
  safe_autocmd("LspAttach", {
    group = augroup,
    callback = function()
      if enabled and render_fn then
        render_fn()
      end
    end,
  })

  safe_autocmd("LspDetach", {
    group = augroup,
    callback = function()
      if enabled and render_fn then
        render_fn()
      end
    end,
  })

  -- Reapply theme on colorscheme change
  safe_autocmd("ColorScheme", {
    group = augroup,
    callback = function()
      local theme = require("fancyline.themes")
      theme.apply(theme.get(config.theme))
      if enabled and render_fn then
        render_fn()
      end
    end,
  })
end

local function setup_refresh_timer()
  if timer then
    timer:stop()
    timer:close()
  end

  if not config.refresh.enabled then
    return
  end

  timer = vim.loop.new_timer()
  timer:start(0, config.refresh.interval, vim.schedule_wrap(function()
    if enabled and render_fn then
      render_fn()
    end
  end))
end

function M.setup(opts)
  config = load_config(opts)

  local theme = require("fancyline.themes")
  local current_theme = theme.get(config.theme)
  theme.apply(current_theme)

  create_highlights()
  setup_autocmds()
  setup_refresh_timer()

  if config.extensions then
    require("fancyline.extensions").setup(config.extensions)
  end

  render_fn = function()
    local statusline = require("fancyline.statusline")
    vim.o.statusline = statusline.render(config)
  end

  vim.o.statusline = "%!v:lua.require('fancyline').render()"

  enabled = true
end

function M.render()
  if not enabled then
    return ""
  end
  if not render_fn then
    return ""
  end
  local statusline = require("fancyline.statusline")
  return statusline.render(config)
end

function M.enable()
  if enabled then
    return
  end
  enabled = true
  if render_fn then
    vim.o.statusline = "%!v:lua.require('fancyline').render()"
  end
end

function M.disable()
  enabled = false
  vim.o.statusline = ""
end

function M.refresh()
  if enabled and render_fn then
    render_fn()
  end
end

function M.get_config()
  return config
end

function M.reload()
  create_highlights()
  if enabled and render_fn then
    render_fn()
  end
end

return M
