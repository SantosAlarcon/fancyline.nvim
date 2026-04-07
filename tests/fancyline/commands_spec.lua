local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local helpers = require("tests.helpers.setup")

describe("fancyline.commands", function()
  local commands

  before_each(function()
    helpers.cleanup()
    commands = require("fancyline.commands")
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("setup", function()
    it("registers FancyLine user command", function()
      commands.setup()
      local ok = pcall(vim.api.nvim_get_command, { name = "FancyLine" })
      assert.is_true(ok)
    end)
  end)

  describe("list_themes", function()
    it("returns a table", function()
      local themes = commands.list_themes()
      assert.is_table(themes)
    end)

    it("returns non-empty table", function()
      local themes = commands.list_themes()
      assert.is_true(#themes > 0)
    end)

    it("contains common themes", function()
      local themes = commands.list_themes()
      local found = false
      for _, theme in ipairs(themes) do
        if theme == "dracula" or theme == "nord" or theme == "tokyonight" then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)
  end)

  describe("list_presets", function()
    it("returns a table", function()
      local presets = commands.list_presets()
      assert.is_table(presets)
    end)

    it("returns non-empty table", function()
      local presets = commands.list_presets()
      assert.is_true(#presets > 0)
    end)

    it("contains common presets", function()
      local presets = commands.list_presets()
      local found_default = false
      local found_slim = false
      for _, preset in ipairs(presets) do
        if preset == "default" then
          found_default = true
        elseif preset == "slim" then
          found_slim = true
        end
      end
      assert.is_true(found_default)
      assert.is_true(found_slim)
    end)
  end)

  describe("list_components", function()
    it("returns a table", function()
      local components = commands.list_components()
      assert.is_table(components)
    end)

    it("returns non-empty table", function()
      local components = commands.list_components()
      assert.is_true(#components > 0)
    end)

    it("contains mode component", function()
      local components = commands.list_components()
      local found = false
      for _, component in ipairs(components) do
        if component == "mode" then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)
  end)
end)
