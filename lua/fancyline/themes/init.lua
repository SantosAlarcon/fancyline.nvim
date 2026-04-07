local M = {}

local mappings = require("fancyline.themes.colorscheme_mappings")

-- Module-level theme cache for performance optimization
---@type { theme: string|nil, variant: string|nil, data: FancylineThemeDefinition|nil }
local _theme_cache = {
  theme = nil,
  variant = nil,
  data = nil,
}

---@class FancylineThemeDefinition
---@field name? string Theme name
---@field variant? string Theme variant
---@field modes? table<string, string> Mode colors
---@field git_branch? string
---@field git_added? string
---@field git_removed? string
---@field git_changed? string
---@field git_untracked? string
---@field git_diff? string
---@field file? string
---@field file_modified? string
---@field file_readonly? string
---@field diagnostics? string
---@field diagnostics_warn? string
---@field diagnostics_info? string
---@field diagnostics_hint? string
---@field lsp? string
---@field filetype? string
---@field cursor? string
---@field separator? string
---@field border? string
---@field foreground? string Default text color for statusline
---@field background? string
---@field primary? string
---@field shades? table<string, string>

---@return string?
local function get_colorscheme_background()
  local statusline_bg = vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg
  if statusline_bg then
    if type(statusline_bg) == "number" then
      return string.format("#%06x", statusline_bg)
    end
    return statusline_bg
  end

  local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
  if normal_bg then
    if type(normal_bg) == "number" then
      return string.format("#%06x", normal_bg)
    end
    return normal_bg
  end

  return nil
end

---Variant detection patterns for each theme
---@type table<string, table<string, string[]>>
local variant_patterns = {
  tokyonight = {
    night = { "night" },
    storm = { "storm" },
    moon = { "moon" },
    day = { "day" },
  },
  catppuccin = {
    mocha = { "mocha" },
    frappe = { "frappe" },
    macchiato = { "macchiato" },
    latte = { "latte" },
  },
  kanagawa = {
    wave = { "wave" },
    dragon = { "dragon" },
    lotus = { "lotus" },
  },
  rose_pine = {
    main = { "main" },
    moon = { "moon" },
    dawn = { "dawn" },
  },
  github = {
    dark = { "dark" },
    light = { "light" },
  },
  dracula = {
    dracula = { "soft" },
  },
  material = {
    deep_ocean = { "deep-ocean", "deep_ocean" },
    oceanic = { "oceanic" },
    palenight = { "palenight" },
    darker = { "darker" },
    lighter = { "lighter" },
  },
}

---Get a theme by name or detect from colorscheme
---@param name? string Theme name ("auto" to detect)
---@param forced_variant? string Force a specific variant
---@return FancylineThemeDefinition
function M.get(name, forced_variant)
  -- Check cache first for performance
  if _theme_cache.data and _theme_cache.theme == name and _theme_cache.variant == forced_variant then
    return _theme_cache.data
  end

  if not name or name == "auto" then
    name = M.detect()
  end

  -- Use forced variant if provided, otherwise detect from colorscheme
  local variant = forced_variant or M.detect_variant(name)

  -- Try to load the theme module
  local ok, theme = pcall(require, "fancyline.themes.themes." .. name)
  local result
  if not ok then
    -- Fallback to tokyonight if theme not found
    ok, theme = pcall(require, "fancyline.themes.themes.tokyonight")
    if not ok then
      result = M.get_default()
    else
      result = theme[variant] or theme.night or M.get_default()
    end
  else
    -- Get the variant or the default/first variant
    if variant and theme[variant] then
      result = theme[variant]
    else
      -- Try common default variants
      local defaults = { "main", "default", "nord", "night", "mocha", "dracula", "tokyonight", "dark", "light" }
      for _, v in ipairs(defaults) do
        if theme[v] then
          result = theme[v]
          break
        end
      end
      -- Return first available variant if no default found
      if not result then
        for _, v in pairs(theme) do
          result = v
          break
        end
      end
    end
  end

  if not result then
    result = M.get_default()
  end

  -- Cache the result for performance
  _theme_cache = {
    theme = name,
    variant = forced_variant,
    data = result,
  }

  return result
end

---Detect the theme from the current colorscheme
---@return string
function M.detect()
  local colorscheme = vim.g.colors_name or ""

  for theme_name, names in pairs(mappings) do
    for _, name in ipairs(names) do
      if colorscheme:find(name, 1, true) then
        return theme_name
      end
    end
  end

  -- Default fallback
  return "tokyonight"
end

---Detect the theme variant from the current colorscheme
---@param theme_name string
---@return string?
function M.detect_variant(theme_name)
  local colorscheme = vim.g.colors_name or ""

  local patterns = variant_patterns[theme_name]
  if not patterns then
    return nil
  end

  for variant_name, _ in pairs(patterns) do
    if colorscheme:find(variant_name, 1, true) then
      return variant_name
    end
  end

  -- Return first variant as default for this theme
  for variant_name, _ in pairs(patterns) do
    return variant_name
  end

  return nil
end

---Get the default theme
---@return FancylineThemeDefinition
function M.get_default()
  return {
    name = "default",
    variant = "default",
    modes = {
      n = "#61afef",
      i = "#98c379",
      v = "#c678dd",
      t = "#e5c07b",
      c = "#e5c07b",
      r = "#e06c75",
      s = "#98c379",
    },
    git_branch = "#61afef",
    git_added = "#98c379",
    git_removed = "#e06c75",
    git_changed = "#e5c07b",
    git_untracked = "#e5c07b",
    git_diff = "#98c379",
    file = "#98c379",
    file_modified = "#e5c07b",
    file_readonly = "#e06c75",
    diagnostics = "#e06c75",
    diagnostics_warn = "#d19a66",
    diagnostics_info = "#56b6c2",
    diagnostics_hint = "#61afef",
    lsp = "#61afef",
    filetype = "#c678dd",
    cursor = "#abb2bf",
    separator = "#5c6370",
    border = "#5c6370",
    foreground = "#abb2bf",
    background = "transparent",
  }
end

---Invalidate the theme cache (call after colorscheme change)
function M.invalidate_cache()
  _theme_cache.data = nil
end

-- Cache invalidation on colorscheme change
vim.api.nvim_create_autocmd("Colorscheme", {
  callback = function()
    _theme_cache.data = nil
  end,
})

---Apply a theme's colors to Neovim highlight groups
---@param theme? FancylineThemeDefinition
function M.apply(theme)
  if not theme then
    theme = M.get("tokyonight")
  end

  -- Invalidate theme cache so renderer gets fresh colors
  M.invalidate_cache()

  -- Helper to batch set highlights
  local function set_hl(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- Mode highlights (batched)
  local mode_mappings = {
    { "FancylineModeNormal", theme.modes.n },
    { "FancylineModeInsert", theme.modes.i },
    { "FancylineModeVisual", theme.modes.v },
    { "FancylineModeSelect", theme.modes.s },
    { "FancylineModeTerminal", theme.modes.t },
    { "FancylineModeCommand", theme.modes.c },
    { "FancylineModeReplace", theme.modes.r },
  }
  for _, m in ipairs(mode_mappings) do
    set_hl(m[1], { fg = m[2], bg = "NONE", bold = false })
  end

  -- Git highlights (batched)
  local git_mappings = {
    { "FancylineGitBranch", theme.git_branch },
    { "FancylineGitAdded", theme.git_added },
    { "FancylineGitRemoved", theme.git_removed },
    { "FancylineGitChanged", theme.git_changed },
    { "FancylineGitUntracked", theme.git_untracked or theme.git_changed },
    { "FancylineGitDiff", theme.git_diff or theme.git_added },
  }
  for _, g in ipairs(git_mappings) do
    set_hl(g[1], { fg = g[2], bg = "NONE", bold = false })
  end

  -- File highlights (batched)
  local file_mappings = {
    { "FancylineFile", theme.file },
    { "FancylineFileModified", theme.file_modified },
    { "FancylineFileReadonly", theme.file_readonly },
  }
  for _, f in ipairs(file_mappings) do
    set_hl(f[1], { fg = f[2], bg = "NONE", bold = false })
  end

  -- Diagnostics highlights (batched)
  local diag_mappings = {
    { "FancylineDiagnostics", theme.diagnostics },
    { "FancylineDiagError", theme.diagnostics },
    { "FancylineDiagWarn", theme.diagnostics_warn },
    { "FancylineDiagInfo", theme.diagnostics_info },
    { "FancylineDiagHint", theme.diagnostics_hint },
  }
  for _, d in ipairs(diag_mappings) do
    set_hl(d[1], { fg = d[2], bg = "NONE", bold = false })
  end

  -- Other highlights (batched)
  local other_mappings = {
    { "FancylineLsp", theme.lsp },
    { "FancylineFiletype", theme.filetype },
    { "FancylineCursor", theme.cursor },
    { "FancylineSeparator", theme.separator },
  }
  for _, o in ipairs(other_mappings) do
    set_hl(o[1], { fg = o[2], bg = "NONE", bold = false })
  end
  
  -- Set FancylineBorder separately with bg
  set_hl("FancylineBorder", { 
    fg = theme.border or "#5c6370", 
    bg = theme.background == "transparent" and "NONE" or (theme.background or "NONE"), 
    bold = false 
  })

  -- Apply StatusLine background based on theme setting
  local statusline_opts = {}
  if theme.background == "auto" then
    local bg = get_colorscheme_background()
    statusline_opts.bg = bg or "NONE"
    statusline_opts.fg = theme.foreground or "NONE"
  elseif theme.background == "transparent" then
    statusline_opts.bg = "NONE"
    statusline_opts.fg = theme.foreground or "NONE"
  elseif theme.background then
    statusline_opts.bg = theme.background
    statusline_opts.fg = theme.foreground or "NONE"
  else
    statusline_opts.bg = "NONE"
    statusline_opts.fg = "NONE"
  end
  vim.api.nvim_set_hl(0, "StatusLine", statusline_opts)
  vim.api.nvim_set_hl(0, "StatusLineNC", statusline_opts)

  -- Apply shade highlights if defined (batched)
  if theme.shades then
    for i = 1, 10 do
      local shade_key = "shade_" .. i
      local shade_color = theme.shades[shade_key]
      if shade_color then
        set_hl("FancylineShade" .. i, { fg = theme.primary or "#ffffff", bg = shade_color })
      end
    end
  end

  -- Create padding highlight with primary color for horizontal padding (right side only)
  if theme.primary then
    set_hl("FancylinePaddingRight", { fg = theme.primary, bg = theme.primary })
  end
end

return M
