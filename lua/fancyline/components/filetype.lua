local M = {}

-- Hoist require to module level for performance
local devicons = require("fancyline.utils.devicons")

-- Fallback icon map (usado si no hay plugins de iconos)
local fallback_icons = {
  lua = "󰢱",
  python = "󰌠",
  javascript = "󰌞",
  typescript = "󰛦",
  javascriptreact = "󰌗",
  typescriptreact = "󰌗",
  rust = "󱘗",
  go = "󰟓",
  ruby = "󰴽",
  java = "󰌱",
  c = "󰃡",
  cpp = "󰙱",
  csharp = "󰌛",
  php = "󰌗",
  html = "󰌝",
  css = "󰌜",
  scss = "󰌜",
  sass = "󰌜",
  less = "󰌜",
  json = "󰘦",
  yaml = "󰗩",
  yml = "󰗩",
  toml = "󰗩",
  xml = "󰗱",
  markdown = "󰍔",
  md = "󰍔",
  sh = "�云龙",
  bash = "�云龙",
  zsh = "󰍨",
  fish = "󰚎",
  vim = "󰌃",
  tex = "󰎔",
  sql = "󰌆",
  dockerfile = "󰡨",
  text = "󰍔",
  txt = "󰍔",
  jsonc = "󰘦",
  vue = "󰌗",
  svelte = "󰗠",
  jsx = "󰌗",
  tsx = "󰌗",
  default = "󰈔",
}

-- Lazy detection of icon providers
local function get_icon_for_filetype(filetype)
  -- 1. Try mini.icons first (priority)
  local ok, result = pcall(function()
    if _G.MiniIcons then
      return _G.MiniIcons.get('filetype', filetype)
    end
  end)
  if ok and result then
    return result
  end

  -- 2. Try nvim-web-devicons (use module-level require)
  local icon = devicons.get_icon_by_filetype(filetype)
  if icon then
    return icon
  end

  -- 3. Fallback to static map
  local lower_ft = filetype:lower()
  return fallback_icons[lower_ft] or fallback_icons.default
end

---Provider function for the filetype component.
---@param opts? FancylineFiletypeComponent
---@param ctx FancylineContext
---@return FancylineComponentResult?
function M.provider(opts, ctx)
  local filetype = vim.bo[ctx.bufnr].filetype

  if filetype == "" then
    return nil
  end

  -- Determine icon
  local icon_symbol
  local icon_fg
  local icon_bg

  -- Check if user provided a custom icon with colors (table with symbol)
  local has_custom_icon = type(opts.icon) == "table" and opts.icon.symbol

  -- Use custom icon only if explicitly provided as table with colors
  -- Otherwise, use icon providers (mini.icons > devicons > fallback)
  if has_custom_icon then
    icon_symbol = opts.icon.symbol
    icon_fg = opts.icon.fg
    icon_bg = opts.icon.bg
  else
    -- Use icon providers for automatic icon detection
    icon_symbol = get_icon_for_filetype(filetype)
  end

  local display_ft = filetype
  if opts.lowercase then
    display_ft = string.lower(filetype)
  elseif opts.titlecase then
    display_ft = filetype:sub(1, 1):upper() .. filetype:sub(2):lower()
  elseif opts.uppercase then
    display_ft = string.upper(filetype)
  end

  -- Determine what to show
  local show_text = opts.show_text ~= false

  -- Build text (without icon - icon is separate)
  local text = show_text and display_ft or ""

  -- Build icon config
  local icon_cfg = { symbol = icon_symbol, fg = icon_fg, bg = icon_bg }

  return {
    text = text,
    icon = icon_cfg,
    style = opts.style or "none",
    highlight = "FancylineFiletype",
    fg = opts.fg,
    bg = opts.bg,
    border = opts.border,
    state = "n",
  }
end

return M
