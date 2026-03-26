local M = {}

local border = require("fancyline.renderer.border")

-- Helper for checking if value is an array (handles different Neovim versions)
local function is_array(val)
  if type(val) ~= "table" then return false end
  -- Check if table has sequential numeric keys starting from 1
  local i = 0
  for _ in pairs(val) do
    i = i + 1
    if val[i] == nil then return false end
  end
  return i > 0
end

local component_providers = {
  mode = require("fancyline.components.mode"),
  git_branch = require("fancyline.components.git_branch"),
  git_diff = require("fancyline.components.git_diff"),
  file = require("fancyline.components.file"),
  diagnostics = require("fancyline.components.diagnostics"),
  errors = require("fancyline.components.errors"),
  warnings = require("fancyline.components.warnings"),
  infos = require("fancyline.components.infos"),
  hints = require("fancyline.components.hints"),
  lsp = require("fancyline.components.lsp"),
  lsp_progress = require("fancyline.components.lsp_progress"),
  filetype = require("fancyline.components.filetype"),
  encoding = require("fancyline.components.encoding"),
  indent = require("fancyline.components.indent"),
  position = require("fancyline.components.position"),
  cursor = require("fancyline.components.cursor"),
}

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
      local provider = component_providers[name]
      local comp_opts = config.components and config.components[name] or {}

      if provider then
        local result = provider.provider(comp_opts, ctx)
        if result then
          -- Handle array of sections (like multi-color diagnostics)
          if is_array(result) then
            for _, item in ipairs(result) do
              local rendered = border.render_component(
                item.icon,
                item.text,
                item.style or "none",
                item.highlight,
                item.fg,
                item.bg,
                item.state
              )
              if rendered and rendered ~= "" then
                table.insert(parts, rendered)
              end
            end
          else
            -- Single result (existing behavior)
            local rendered

            -- Check for custom border config first
            if result.border then
              rendered = border.render_custom_border(
                result.border,
                result.icon,
                result.text,
                result.highlight,
                result.fg,
                result.bg,
                result.state
              )
            -- Check if using new icon structure (with symbol)
            elseif border.parse_icon(result.icon).symbol and border.parse_icon(result.icon).symbol ~= "" then
              -- Use new render_with_icon for separate icon
              rendered = border.render_with_icon(
                result.icon,
                result.text,
                result.style or "none",
                result.highlight,
                result.fg,
                result.bg,
                result.state
              )
            else
              -- Fallback to old render_component
              rendered = border.render_component(
                result.icon,
                result.text,
                result.style or "none",
                result.highlight,
                result.fg,
                result.bg,
                result.state
              )
            end

            if rendered and rendered ~= "" then
              table.insert(parts, rendered)
            end
          end
        end
      end
    end

    return table.concat(parts, " ")
  end

  local left_content = render_section(sections.left or {})
  local center_content = render_section(sections.center or {})
  local right_content = render_section(sections.right or {})

  local separator = "  " .. (config.separator or "│") .. "  "

  -- Build statusline with proper alignment
  -- [left] %= [center] %= [right]
  local parts = {}

  -- Left section
  if left_content ~= "" then
    table.insert(parts, left_content)
  end

  -- Center section (with %= to push to middle)
  if center_content ~= "" then
    if #parts > 0 then
      table.insert(parts, "%=")
    end
    table.insert(parts, center_content)
  end

  -- Right section (with %= to push to right)
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

function M.register_component(name, provider)
  component_providers[name] = provider
end

function M.get_component(name)
  return component_providers[name]
end

return M
