local M = {}

local mappings = require("fancyline.themes.colorscheme_mappings")

-- Variant detection patterns for each theme
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

function M.get(name)
  if name == "auto" then
    name = M.detect()
  end

  local variant = M.detect_variant(name)

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
  local defaults = { "main", "default", "nord", "night", "mocha", "dracula", "tokyonight" }
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

function M.apply(theme)
  if not theme then
    theme = M.get("tokyonight")
  end

  -- Mode highlights
  vim.api.nvim_set_hl(0, "FancylineModeNormal", { fg = theme.modes.n, bg = "NONE", bold = true })
  vim.api.nvim_set_hl(0, "FancylineModeInsert", { fg = theme.modes.i, bg = "NONE", bold = true })
  vim.api.nvim_set_hl(0, "FancylineModeVisual", { fg = theme.modes.v, bg = "NONE", bold = true })
  vim.api.nvim_set_hl(0, "FancylineModeSelect", { fg = theme.modes.s, bg = "NONE", bold = true })
  vim.api.nvim_set_hl(0, "FancylineModeTerminal", { fg = theme.modes.t, bg = "NONE", bold = true })
  vim.api.nvim_set_hl(0, "FancylineModeCommand", { fg = theme.modes.c, bg = "NONE", bold = true })
  vim.api.nvim_set_hl(0, "FancylineModeReplace", { fg = theme.modes.r, bg = "NONE", bold = true })

  -- Git highlights
  vim.api.nvim_set_hl(0, "FancylineGitBranch", { fg = theme.git_branch, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineGitAdded", { fg = theme.git_added, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineGitRemoved", { fg = theme.git_removed, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineGitChanged", { fg = theme.git_changed, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineGitUntracked", { fg = theme.git_untracked or theme.git_changed, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineGitDiff", { fg = theme.git_diff or theme.git_added, bg = "NONE" })

  -- File highlights
  vim.api.nvim_set_hl(0, "FancylineFile", { fg = theme.file, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineFileModified", { fg = theme.file_modified, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineFileReadonly", { fg = theme.file_readonly, bg = "NONE" })

  -- Diagnostics highlights
  vim.api.nvim_set_hl(0, "FancylineDiagnostics", { fg = theme.diagnostics, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineDiagError", { fg = theme.diagnostics, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineDiagWarn", { fg = theme.diagnostics_warn, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineDiagInfo", { fg = theme.diagnostics_info, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineDiagHint", { fg = theme.diagnostics_hint, bg = "NONE" })

  -- Other highlights
  vim.api.nvim_set_hl(0, "FancylineLsp", { fg = theme.lsp, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineFiletype", { fg = theme.filetype, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineCursor", { fg = theme.cursor, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineSeparator", { fg = theme.separator, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FancylineBorder", { fg = theme.border, bg = "NONE" })

  -- Apply StatusLine background based on theme setting
  if theme.background == "transparent" then
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE", fg = "NONE" })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE", fg = "NONE" })
  elseif theme.background then
    vim.api.nvim_set_hl(0, "StatusLine", { bg = theme.background, fg = "NONE" })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = theme.background, fg = "NONE" })
  end
end

return M
