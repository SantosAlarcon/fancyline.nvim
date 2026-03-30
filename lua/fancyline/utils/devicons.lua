local M = {}

local devicons = nil

-- Static icon map for fallback (when no icon plugins available)
local static_icon_map = {
  -- Programming languages
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
  swift = "󰌛",
  kotlin = "󰼈",
  scala = "󰚔",
  r = "󰟊",
  perl = "󰚠",
  haskell = "󰌠",
  erlang = "󰌭",
  elixir = "󰌭",
  clojure = "󰌭",
  fsharp = "󰌞",
  dart = "󰀥",

  -- Web
  html = "󰌝",
  css = "󰌜",
  scss = "󰌜",
  sass = "󰌜",
  less = "󰌜",
  json = "󰘦",
  jsonc = "󰘦",
  xml = "󰗱",
  svg = "󰜰",

  -- Config & Data
  yaml = "󰗩",
  yml = "󰗩",
  toml = "󰀭",
  ini = "󰀭",
  cfg = "󰀭",
  conf = "󰀭",
  dockerfile = "󰡨",

  -- Docs & Text
  markdown = "󰍔",
  tex = "󰎔",
  pdf = "󰦝",
  txt = "󰍔",
  text = "󰍔",

  -- Shell
  sh = "󰆍",
  bash = "�EBUG",
  zsh = "�EBUG",
  fish = "�ाण",
  ps1 = "󰨝",

  -- Database
  sql = "󰌆",
  mysql = "󰌆",
  postgres = "󰌆",
  sqlite = "󰌆",

  -- Build & Tools
  makefile = "󰂭",
  cmake = "󰂭",
  gradle = "󰂭",

  -- Version Control
  gitcommit = "󰊥",
  gitignore = "󰊥",
  gitconfig = "󰊥",

  -- Special
  vim = "󰌃",
  terminal = "󰞒",
  netrw = "󰍔",
  help = "󰌥",
  qf = "󰍔",

  -- Extensions (for file-based detection)
  py = "󰌠",
  rs = "󱘗",
  js = "󰌞",
  ts = "󰛦",
  rb = "󰴽",
  h = "󰃡",
  hpp = "󰙱",
  md = "󰍔",

  -- Misc
  default = "󰈔",
}

local function ensure_loaded()
  if devicons ~= nil then
    return
  end

  -- Try nvim-web-devicons first
  local ok, icons = pcall(require, "nvim-web-devicons")
  if ok then
    devicons = icons
  end
end

-- Get icon for filename + extension
function M.get_icon(filename, ext, opts)
  ensure_loaded()

  if devicons then
    return devicons.get_icon(filename, ext, opts)
  end

  -- Fallback: use static map based on extension
  if ext and ext ~= "" then
    local icon = static_icon_map[ext:lower()]
    return icon or static_icon_map.default
  end

  return opts and opts.fallback_icon or nil
end

-- Get icon with highlight (devicons only)
function M.get_icon_colored(filename, ext)
  ensure_loaded()

  if not devicons then
    return nil
  end

  return devicons.get_icon(filename, ext, { default = true })
end

-- Get icon for current buffer filetype
function M.get_filetype_icon(bufnr)
  bufnr = bufnr or 0

  ensure_loaded()

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return nil
  end

  local ext = vim.fn.fnamemodify(filename, ":e")

  if devicons then
    return devicons.get_icon(filename, ext, { default = true })
  end

  -- Fallback
  if ext and ext ~= "" then
    return static_icon_map[ext:lower()] or static_icon_map.default
  end

  return static_icon_map.default
end

-- Get icon for filetype string directly
function M.get_icon_by_filetype(filetype)
  ensure_loaded()

  if not filetype or filetype == "" then
    return static_icon_map.default
  end

  -- Try nvim-web-devicons first
  if devicons and devicons.get_icon_by_filetype then
    local icon = devicons.get_icon_by_filetype(filetype)
    if icon then
      return icon
    end
  end

  -- Try nvim-web-devicons with file extension trick
  if devicons then
    local ext_map = {
      lua = "lua", javascript = "js", typescript = "ts",
      python = "py", rust = "rs", go = "go", ruby = "rb",
      java = "java", c = "c", cpp = "cpp", html = "html",
      css = "css", json = "json", yaml = "yaml", markdown = "md",
      vim = "vim", sh = "sh", bash = "bash",
    }
    local ext = ext_map[filetype:lower()]
    if ext then
      local icon = devicons.get_icon("file." .. ext, ext, { default = true })
      if icon then
        return icon
      end
    end
  end

  -- Fallback to static map
  local lower_ft = filetype:lower()
  return static_icon_map[lower_ft] or static_icon_map.default
end

return M
