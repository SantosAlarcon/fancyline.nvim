local M = {}

-- Find the plugin directory
local function get_plugin_dir()
  -- Try multiple methods to find the plugin directory
  
  -- Method 1: Try to find via package.loaded
  local ok, mod = pcall(require, "fancyline")
  if ok and mod and mod._MODULE_INFO then
    -- Some plugins store their path
  end
  
  -- Method 2: Use runtimepath
  for _, path in ipairs(vim.opt.rtp:get()) do
    local test_path = path .. "/lua/fancyline/init.lua"
    if vim.fn.filereadable(test_path) == 1 then
      return path
    end
  end
  
  -- Method 3: Use package.path
  local init_path = package.searchpath("fancyline", package.path)
  if init_path then
    return vim.fn.fnamemodify(init_path, ":h:h:h")
  end
  
  return nil
end

local function list_files_in_dir(dir, ext)
  if not dir or not vim.fn.isdirectory(dir) then
    return {}
  end
  local files = {}
  local handle = vim.loop.fs_scandir(dir)
  if handle then
    while true do
      local name = vim.loop.fs_scandir_next(handle)
      if not name then break end
      if not vim.startswith(name, ".") then
        local file_path = dir .. "/" .. name
        local stat = vim.loop.fs_stat(file_path)
        if stat and stat.type == "file" then
          if ext then
            local matched = name:match("%.lua$")
            if matched then
              local base_name = name:gsub("%.lua$", "")
              table.insert(files, base_name)
            end
          else
            table.insert(files, name)
          end
        end
      end
    end
  end
  return files
end

-- Cache the plugin directory for performance
local plugin_dir = nil

local function get_plugin_dir_cached()
  if plugin_dir then
    return plugin_dir
  end
  plugin_dir = get_plugin_dir()
  return plugin_dir
end

function M.list_themes()
  local base = get_plugin_dir_cached()
  if not base then
    return { "dracula", "nord", "tokyonight", "gruvbox", "catppuccin" } -- Fallback
  end
  local themes_dir = base .. "/lua/fancyline/themes/themes"
  local themes = list_files_in_dir(themes_dir, true)
  table.sort(themes)
  if #themes == 0 then
    return { "dracula", "nord", "tokyonight", "gruvbox", "catppuccin" } -- Fallback
  end
  return themes
end

function M.list_presets()
  local base = get_plugin_dir_cached()
  if not base then
    return { "default" } -- Fallback
  end
  local presets_dir = base .. "/lua/fancyline/presets"
  local presets = list_files_in_dir(presets_dir, true)
  local filtered = {}
  for _, name in ipairs(presets) do
    if name ~= "init" then
      table.insert(filtered, name)
    end
  end
  table.sort(filtered)
  if #filtered == 0 then
    return { "default" } -- Fallback
  end
  return filtered
end

local function complete(_, line)
  local l = vim.split(vim.trim(line), "%s+")
  local n = #l - 1

  if n == 0 then
    return { "enable", "disable", "toggle", "refresh", "reload", "theme", "preset", "config" }
  end

  if n == 1 then
    local subcmd = l[2]
    if subcmd == "theme" then
      return M.list_themes()
    elseif subcmd == "preset" then
      return M.list_presets()
    end
    return {}
  end

  return {}
end

local function cmd_enable()
  require("fancyline").enable()
  vim.notify("[FancyLine] Enabled", vim.log.levels.INFO)
end

local function cmd_disable()
  require("fancyline").disable()
  vim.notify("[FancyLine] Disabled", vim.log.levels.INFO)
end

local function cmd_toggle()
  local fancyline = require("fancyline")
  if fancyline.is_enabled() then
    fancyline.disable()
    vim.notify("[FancyLine] Disabled", vim.log.levels.INFO)
  else
    fancyline.enable()
    vim.notify("[FancyLine] Enabled", vim.log.levels.INFO)
  end
end

local function cmd_refresh()
  require("fancyline").refresh()
end

local function cmd_reload()
  require("fancyline").reload()
  vim.notify("[FancyLine] Highlights reloaded", vim.log.levels.INFO)
end

local function cmd_theme(args)
  local theme_name = vim.split(args, "%s+")[1]
  if not theme_name or theme_name == "" then
    vim.notify("[FancyLine] Usage: FancyLine theme <name>", vim.log.levels.WARN)
    return
  end

  local themes = require("fancyline.themes")
  local ok, theme_def = pcall(themes.get, theme_name)
  if not ok then
    vim.notify("[FancyLine] Unknown theme: " .. theme_name, vim.log.levels.ERROR)
    return
  end

  -- Update global theme config so renderer uses correct theme
  _G.fancyline_theme_config = _G.fancyline_theme_config or {}
  _G.fancyline_theme_config.name = theme_name
  _G.fancyline_theme_config.variant = theme_def.variant

  themes.apply(theme_def)
  require("fancyline.renderer").invalidate()
  require("fancyline").refresh()
  vim.notify("[FancyLine] Theme: " .. theme_name, vim.log.levels.INFO)
end

local function cmd_preset(args)
  local preset_name = vim.split(args, "%s+")[1]
  if not preset_name or preset_name == "" then
    vim.notify("[FancyLine] Usage: FancyLine preset <name>", vim.log.levels.WARN)
    return
  end

  local ok = require("fancyline").set_preset(preset_name)
  if ok then
    vim.notify("[FancyLine] Preset: " .. preset_name, vim.log.levels.INFO)
  else
    vim.notify("[FancyLine] Unknown preset: " .. preset_name, vim.log.levels.ERROR)
  end
end

local function cmd_config()
  local config = require("fancyline").get_config()
  if config then
    local lines = {}
    table.insert(lines, "=== FancyLine Config ===")
    if config.preset then
      table.insert(lines, "Preset: " .. config.preset)
    end
    if config.theme then
      local theme_name = type(config.theme) == "table" and config.theme.name or config.theme
      table.insert(lines, "Theme: " .. theme_name)
    end
    table.insert(lines, "")
    table.insert(lines, vim.inspect(config, { depth = 3 }))
    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "FancyLine Config" })
  end
end

local subcommands = {
  enable = cmd_enable,
  disable = cmd_disable,
  toggle = cmd_toggle,
  refresh = cmd_refresh,
  reload = cmd_reload,
  theme = cmd_theme,
  preset = cmd_preset,
  config = cmd_config,
}

local function execute_command(args)
  local parts = vim.split(vim.trim(args), "%s+", { trimempty = true })
  local subcmd = parts[1] or ""
  local subargs = table.concat(vim.list_slice(parts, 2), " ")

  local fn = subcommands[subcmd]
  if fn then
    fn(subargs)
  else
    vim.notify("[FancyLine] Unknown command: " .. subcmd .. "\nUse :FancyLine with no args to see available commands", vim.log.levels.ERROR)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("FancyLine", function(opts)
    if opts.args and opts.args ~= "" then
      execute_command(opts.args)
    else
      vim.notify(
        "FancyLine commands:\n"
        .. "  enable       - Enable statusline\n"
        .. "  disable      - Disable statusline\n"
        .. "  toggle       - Toggle enable/disable\n"
        .. "  refresh      - Force refresh\n"
        .. "  reload       - Reload highlights\n"
        .. "  theme <name> - Change theme\n"
        .. "  preset <name> - Change preset\n"
        .. "  config       - Show current config",
        vim.log.levels.INFO,
        { title = "FancyLine" }
      )
    end
  end, {
    nargs = "*",
    complete = complete,
    desc = "Control FancyLine statusline",
  })
end

return M
