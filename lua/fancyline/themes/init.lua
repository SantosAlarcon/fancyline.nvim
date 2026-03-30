local M = {}

local mappings = require("fancyline.themes.colorscheme_mappings")

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
}

---Get a theme by name or detect from colorscheme
---@param name? string Theme name ("auto" to detect)
---@param forced_variant? string Force a specific variant
---@return FancylineThemeDefinition
function M.get(name, forced_variant)
  if not name or name == "auto" then
    name = M.detect()
  end

  -- Use forced variant if provided, otherwise detect from colorscheme
  local variant = forced_variant or M.detect_variant(name)

  -- Try to load the theme module
  local ok, theme = pcall(require, "fancyline.themes.themes." .. name)
  if not ok then
    -- Fallback to tokyonight if theme not found
    ok, theme = pcall(require, "fancyline.themes.themes.tokyonight")
    if not ok then
      return M.get_default()
    end
    return theme[variant] or theme.night or M.get_default()
  end

  -- Get the variant or the default/first variant
  if variant and theme[variant] then
    return theme[variant]
  end

  -- Try common default variants
  local defaults = { "main", "default", "nord", "night", "mocha", "dracula", "tokyonight", "dark", "light" }
  for _, v in ipairs(defaults) do
    if theme[v] then
      return theme[v]
    end
  end

  -- Return first available variant
  for _, v in pairs(theme) do
    return v
  end

  return M.get_default()
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
      V = "#c678dd",
      ["^V"] = "#c678dd",
      t = "#e5c07b",
      ["!"] = "#e5c07b",
      c = "#e5c07b",
      r = "#e06c75",
      R = "#e06c75",
      s = "#98c379",
      S = "#98c379",
      ["^S"] = "#98c379",
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
    background = "transparent",
  }
end

---Apply a theme's colors to Neovim highlight groups
---@param theme? FancylineThemeDefinition
function M.apply(theme)
  if not theme then
    theme = M.get("tokyonight")
  end

  -- Mode highlights
  vim.api.nvim_set_hl(0, "FancylineModeNormal", { fg = theme.modes.n, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineModeInsert", { fg = theme.modes.i, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineModeVisual", { fg = theme.modes.v, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineModeSelect", { fg = theme.modes.s, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineModeTerminal", { fg = theme.modes.t, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineModeCommand", { fg = theme.modes.c, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineModeReplace", { fg = theme.modes.r, bg = "NONE", bold = false })

  -- Git highlights
  vim.api.nvim_set_hl(0, "FancylineGitBranch", { fg = theme.git_branch, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineGitAdded", { fg = theme.git_added, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineGitRemoved", { fg = theme.git_removed, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineGitChanged", { fg = theme.git_changed, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineGitUntracked", { fg = theme.git_untracked or theme.git_changed, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineGitDiff", { fg = theme.git_diff or theme.git_added, bg = "NONE", bold = false })

  -- File highlights
  vim.api.nvim_set_hl(0, "FancylineFile", { fg = theme.file, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineFileModified", { fg = theme.file_modified, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineFileReadonly", { fg = theme.file_readonly, bg = "NONE", bold = false })

  -- Diagnostics highlights
  vim.api.nvim_set_hl(0, "FancylineDiagnostics", { fg = theme.diagnostics, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineDiagError", { fg = theme.diagnostics, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineDiagWarn", { fg = theme.diagnostics_warn, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineDiagInfo", { fg = theme.diagnostics_info, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineDiagHint", { fg = theme.diagnostics_hint, bg = "NONE", bold = false })

  -- Other highlights
  vim.api.nvim_set_hl(0, "FancylineLsp", { fg = theme.lsp, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineFiletype", { fg = theme.filetype, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineCursor", { fg = theme.cursor, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineSeparator", { fg = theme.separator, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "FancylineBorder", { fg = theme.border, bg = "NONE", bold = false })

  -- Apply StatusLine background based on theme setting
  if theme.background == "auto" then
    local bg = get_colorscheme_background()
    if bg then
      vim.api.nvim_set_hl(0, "StatusLine", { bg = bg, fg = "NONE", bold = false })
      vim.api.nvim_set_hl(0, "StatusLineNC", { bg = bg, fg = "NONE", bold = false })
    else
      vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE", fg = "NONE", bold = false })
      vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE", fg = "NONE", bold = false })
    end
  elseif theme.background == "transparent" then
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE", fg = "NONE", bold = false })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE", fg = "NONE", bold = false })
  elseif theme.background then
    vim.api.nvim_set_hl(0, "StatusLine", { bg = theme.background, fg = "NONE", bold = false })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = theme.background, fg = "NONE", bold = false })
  end

  -- Apply shade highlights if defined
  if theme.shades then
    for i = 1, 10 do
      local shade_key = "shade_" .. i
      local shade_color = theme.shades[shade_key]
      if shade_color then
        vim.api.nvim_set_hl(0, "FancylineShade" .. i, { fg = theme.primary or "#ffffff", bg = shade_color })
      end
    end
  end
end

return M
