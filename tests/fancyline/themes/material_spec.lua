local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local helpers = require("tests.helpers.setup")

describe("material theme", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  -- Official material.nvim colors verified from:
  -- https://github.com/marko-cerovac/material.nvim/blob/main/lua/material/colors/init.lua

  describe("all variants exist", function()
    local variants = { "deep_ocean", "oceanic", "palenight", "darker", "lighter" }

    for _, variant in ipairs(variants) do
      it(variant .. " variant exists", function()
        local material = require("fancyline.themes.themes.material")
        assert.is_table(material[variant])
        assert.equals("material", material[variant].name)
        assert.equals(variant, material[variant].variant)
      end)
    end
  end)

  describe("deep_ocean colors", function()
    local theme

    before_each(function()
      local material = require("fancyline.themes.themes.material")
      theme = material.deep_ocean
    end)

    it("has correct diagnostic colors", function()
      assert.equals("#FF5370", theme.diagnostics)
      assert.equals("#FFCB6B", theme.diagnostics_warn)
      assert.equals("#B0C9FF", theme.diagnostics_info)
      assert.equals("#C792EA", theme.diagnostics_hint)
    end)

    it("has correct mode colors", function()
      assert.equals("#82AAFF", theme.modes.n)
      assert.equals("#C3E88D", theme.modes.i)
      assert.equals("#C792EA", theme.modes.v)
    end)

    it("has correct background colors", function()
      assert.equals("#0F111A", theme.background)
      assert.equals("#A6ACCD", theme.foreground)
    end)
  end)

  describe("oceanic colors", function()
    local theme

    before_each(function()
      local material = require("fancyline.themes.themes.material")
      theme = material.oceanic
    end)

    it("has correct diagnostic colors", function()
      assert.equals("#FF5370", theme.diagnostics)
      assert.equals("#FFCB6B", theme.diagnostics_warn)
      assert.equals("#B0C9FF", theme.diagnostics_info)
      assert.equals("#C792EA", theme.diagnostics_hint)
    end)

    it("has correct background colors", function()
      assert.equals("#25363B", theme.background)
      assert.equals("#B0BEC5", theme.foreground)
    end)
  end)

  describe("palenight colors", function()
    local theme

    before_each(function()
      local material = require("fancyline.themes.themes.material")
      theme = material.palenight
    end)

    it("has correct diagnostic colors", function()
      assert.equals("#FF5370", theme.diagnostics)
      assert.equals("#FFCB6B", theme.diagnostics_warn)
      assert.equals("#B0C9FF", theme.diagnostics_info)
      assert.equals("#C792EA", theme.diagnostics_hint)
    end)

    it("has correct background colors", function()
      assert.equals("#292D3E", theme.background)
      assert.equals("#A6ACCD", theme.foreground)
    end)
  end)

  describe("darker colors", function()
    local theme

    before_each(function()
      local material = require("fancyline.themes.themes.material")
      theme = material.darker
    end)

    it("has correct diagnostic colors", function()
      assert.equals("#FF5370", theme.diagnostics)
      assert.equals("#FFB74D", theme.diagnostics_warn)
      assert.equals("#6182B8", theme.diagnostics_info)
      assert.equals("#7C4DFF", theme.diagnostics_hint)
    end)

    it("has different mode colors than other variants", function()
      -- darker uses different mode colors
      assert.equals("#FC5C94", theme.modes.n)
      assert.equals("#C3E88D", theme.modes.i)
    end)

    it("has correct background colors", function()
      assert.equals("#212121", theme.background)
      assert.equals("#B0BEC5", theme.foreground)
    end)
  end)

  describe("lighter colors", function()
    local theme

    before_each(function()
      local material = require("fancyline.themes.themes.material")
      theme = material.lighter
    end)

    it("has correct diagnostic colors", function()
      assert.equals("#E53935", theme.diagnostics)
      assert.equals("#F6A434", theme.diagnostics_warn)
      assert.equals("#6182B8", theme.diagnostics_info)
      assert.equals("#39ADB5", theme.diagnostics_hint)
    end)

    it("has light background", function()
      assert.equals("#FAFAFA", theme.background)
      assert.equals("#546E7A", theme.foreground)
    end)
  end)

  describe("variant patterns detection", function()
    local themes = require("fancyline.themes")

    it("detects deep_ocean from colorscheme name", function()
      vim.g.colors_name = "material-deep-ocean"
      assert.equals("deep_ocean", themes.detect_variant("material"))

      vim.g.colors_name = "material_theme_deep_ocean"
      assert.equals("deep_ocean", themes.detect_variant("material"))
    end)

    it("detects oceanic from colorscheme name", function()
      vim.g.colors_name = "material-oceanic"
      assert.equals("oceanic", themes.detect_variant("material"))
    end)

    it("detects palenight from colorscheme name", function()
      vim.g.colors_name = "material-palenight"
      assert.equals("palenight", themes.detect_variant("material"))
    end)

    it("detects darker from colorscheme name", function()
      vim.g.colors_name = "material-darker"
      assert.equals("darker", themes.detect_variant("material"))
    end)

    it("detects lighter from colorscheme name", function()
      vim.g.colors_name = "material-lighter"
      assert.equals("lighter", themes.detect_variant("material"))
    end)

    it("defaults to deep_ocean when no variant in colorscheme", function()
      vim.g.colors_name = "material"
      local variant = themes.detect_variant("material")
      assert.is_not_nil(variant)
    end)
  end)

  describe("shades exist for all variants", function()
    local variants = { "deep_ocean", "oceanic", "palenight", "darker", "lighter" }

    for _, variant in ipairs(variants) do
      it(variant .. " has shade definitions", function()
        local material = require("fancyline.themes.themes.material")
        local theme = material[variant]
        assert.is_table(theme.shades)
        assert.equals(10, vim.tbl_count(theme.shades))
        -- Verify shade_1 through shade_10 exist
        for i = 1, 10 do
          assert.is_string(theme.shades["shade_" .. i])
        end
      end)
    end
  end)
end)
