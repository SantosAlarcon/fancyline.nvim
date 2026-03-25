local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local border = require("fancyline.renderer.border")
local helpers = require("tests.helpers.setup")

describe("fancyline.renderer.border", function()
  before_each(function()
    helpers.cleanup()
    border.clear_cache()
  end)

  describe("get_style", function()
    it("returns round style with Nerd Font chars", function()
      local style = border.get_style("round")
      assert.equals("", style.left)
      assert.equals("", style.right)
      assert.equals("  ", style.icon_gap)
    end)

    it("returns square style", function()
      local style = border.get_style("square")
      assert.equals("󰝤", style.left)
      assert.equals("󰝤", style.right)
      assert.equals("  ", style.icon_gap)
    end)

    it("returns slanted style", function()
      local style = border.get_style("slanted")
      assert.equals("", style.left)
      assert.equals("", style.right)
    end)

    it("returns arrow style", function()
      local style = border.get_style("arrow")
      assert.equals("", style.left)
      assert.equals("", style.right)
    end)

    it("returns none style with empty chars", function()
      local style = border.get_style("none")
      assert.equals("", style.left)
      assert.equals("", style.right)
      assert.equals(" ", style.icon_gap)
    end)

    it("returns unknown style as none", function()
      local style = border.get_style("invalid")
      assert.equals("", style.left)
      assert.equals("", style.right)
    end)
  end)

  describe("parse_icon", function()
    it("parses string icon", function()
      local result = border.parse_icon("X")
      assert.equals("X", result.symbol)
      assert.is_nil(result.fg)
      assert.is_nil(result.bg)
    end)

    it("parses table icon with symbol", function()
      local result = border.parse_icon({ symbol = "X", fg = "#fff", bg = "#000" })
      assert.equals("X", result.symbol)
      assert.equals("#fff", result.fg)
      assert.equals("#000", result.bg)
    end)

    it("parses legacy format { icon = 'X' }", function()
      local result = border.parse_icon({ icon = "X" })
      assert.equals("X", result.symbol)
    end)

    it("handles nil icon", function()
      local result = border.parse_icon(nil)
      assert.equals("", result.symbol)
    end)
  end)

  describe("render_component", function()
    it("renders round style correctly", function()
      local result = border.render_component("I", "TEXT", "round", "FancylineMode", nil, nil, "n")
      assert.is_string(result)
      assert.is_true(result:match("") ~= nil)
      assert.is_true(result:match("TEXT") ~= nil)
      assert.is_true(result:match("FancylineReset") ~= nil)
    end)

    it("renders with custom fg color", function()
      local result = border.render_component("I", "TEXT", "round", "FancylineMode", "#ff0000", nil, "n")
      assert.is_string(result)
      assert.is_true(result:match("#ff0000") ~= nil or result:match("FancylineDynamic") ~= nil)
    end)

    it("renders with custom bg color", function()
      local result = border.render_component("I", "TEXT", "round", "FancylineMode", nil, "#0000ff", "n")
      assert.is_string(result)
      assert.is_true(result:match("#0000ff") ~= nil or result:match("FancylineDynamic") ~= nil)
    end)

    it("renders none style without borders", function()
      local result = border.render_component("I", "TEXT", "none", "FancylineMode", nil, nil, "n")
      assert.is_string(result)
      assert.is_true(result:find("") == nil)
      assert.is_true(result:match("TEXT") ~= nil)
    end)
  end)

  describe("render_with_icon", function()
    it("renders icon and text separately", function()
      local result = border.render_with_icon(
        { symbol = "I", fg = "#ffffff" },
        "TEXT",
        "round",
        "FancylineMode",
        "#ffffff",
        nil,
        "n"
      )
      assert.is_string(result)
      assert.is_true(result:match("I") ~= nil)
      assert.is_true(result:match("TEXT") ~= nil)
    end)

    it("renders tagged style with icon pill", function()
      local result = border.render_with_icon(
        { symbol = "I", fg = "#ffffff" },
        "TEXT",
        "tagged",
        "FancylineMode",
        "#ffffff",
        nil,
        "n"
      )
      assert.is_string(result)
      assert.is_true(result:match("I") ~= nil)
    end)

    it("resolves 'mode' color to actual color", function()
      local result = border.render_with_icon(
        { symbol = "I", fg = "mode" },
        "TEXT",
        "round",
        "FancylineMode",
        "mode",
        nil,
        "n"
      )
      assert.is_string(result)
      -- Should resolve to actual theme color, not "mode" string
      assert.is_true(result:match("mode") == nil)
    end)
  end)

  describe("render_custom_border", function()
    it("renders custom border with left and right styles", function()
      local border_cfg = {
        left = { style = "round", fg = "#ff0000" },
        right = { style = "arrow", fg = "#00ff00" }
      }
      local result = border.render_custom_border(
        border_cfg,
        { symbol = "I" },
        "TEXT",
        "FancylineMode",
        "#ffffff",
        nil,
        "n"
      )
      assert.is_string(result)
      assert.is_true(result:match("TEXT") ~= nil)
      assert.is_true(result:match("I") ~= nil)
    end)

    it("renders custom border with bg colors", function()
      local border_cfg = {
        left = { style = "round", fg = "#ff0000", bg = "#0000ff" },
        right = { style = "round", fg = "#00ff00", bg = "#000000" }
      }
      local result = border.render_custom_border(
        border_cfg,
        { symbol = "I" },
        "TEXT",
        "FancylineMode",
        "#ffffff",
        nil,
        "n"
      )
      assert.is_string(result)
      assert.is_true(result:match("TEXT") ~= nil)
    end)

    it("resolves 'mode' color in border", function()
      local border_cfg = {
        left = { style = "round", fg = "mode" },
        right = { style = "round", fg = "mode" }
      }
      local result = border.render_custom_border(
        border_cfg,
        { symbol = "I" },
        "TEXT",
        "FancylineMode",
        "mode",
        nil,
        "n"
      )
      assert.is_string(result)
      -- Should resolve to actual theme color
      assert.is_true(result:match("mode") == nil)
    end)

    it("uses default style when not specified", function()
      local border_cfg = {
        left = { fg = "#ff0000" },
        right = { fg = "#00ff00" }
      }
      local result = border.render_custom_border(
        border_cfg,
        { symbol = "I" },
        "TEXT",
        "FancylineMode",
        "#ffffff",
        nil,
        "n"
      )
      assert.is_string(result)
      -- Should use 'round' as default
      assert.is_true(result:match("TEXT") ~= nil)
    end)
  end)

  describe("get_icon_colors", function()
    it("returns state colors when defined", function()
      local icon_cfg = {
        symbol = "X",
        states = {
          modified = { fg = "#ff0000", bg = "#0000ff" }
        }
      }
      local fg, bg = border.get_icon_colors(icon_cfg, "modified")
      assert.equals("#ff0000", fg)
      assert.equals("#0000ff", bg)
    end)

    it("returns nil when state not found", function()
      local icon_cfg = {
        symbol = "X",
        states = {}
      }
      local fg, bg = border.get_icon_colors(icon_cfg, "modified")
      assert.is_nil(fg)
      assert.is_nil(bg)
    end)

    it("returns nil for nil icon_cfg", function()
      local fg, bg = border.get_icon_colors(nil, "modified")
      assert.is_nil(fg)
      assert.is_nil(bg)
    end)
  end)

  describe("register_styles", function()
    it("registers new custom style", function()
      border.register_styles({
        custom = { left = "[ ", right = " ]", icon_gap = " " },
      })
      local style = border.get_style("custom")
      assert.equals("[ ", style.left)
      assert.equals(" ]", style.right)
      assert.equals(" ", style.icon_gap)
    end)
  end)

  describe("clear_cache", function()
    it("clears all caches", function()
      -- Create some highlights first
      border.render_component("I", "T", "round", "Test", "#ffffff", "#000000", "n")
      -- Clear cache
      border.clear_cache()
      -- Should work without error after clear
      local result = border.render_component("I", "T", "round", "Test", "#ff0000", "#00ff00", "n")
      assert.is_string(result)
    end)
  end)
end)
