local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local spell = require("fancyline.components.spell")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.spell", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("basic functionality", function()
    it("returns nil when spell is disabled", function()
      vim.wo.spell = false

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = spell.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns spell indicator when spell is enabled", function()
      vim.wo.spell = true

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = spell.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("Spell", result.text)
      assert.equals("FancylineSpell", result.highlight)
    end)
  end)

  describe("icon configuration", function()
    it("uses default icon when no icon provided", function()
      vim.wo.spell = true

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = spell.provider(opts, ctx)

      assert.equals("Spell", result.text)
    end)

    it("uses custom icon symbol from opts.icon", function()
      vim.wo.spell = true

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { symbol = "SPELL" }
      }
      local result = spell.provider(opts, ctx)

      assert.equals("SPELL", result.text)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      vim.wo.spell = true

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = spell.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      vim.wo.spell = true

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = spell.provider(opts, ctx)

      assert.equals("round", result.style)
    end)

    it("returns fg and bg colors", function()
      vim.wo.spell = true

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { fg = "#ff0000", bg = "#0000ff" },
        fg = "#ffffff",
        bg = "#000000"
      }
      local result = spell.provider(opts, ctx)

      assert.equals("#ff0000", result.icon.fg)
      assert.equals("#0000ff", result.icon.bg)
      assert.equals("#ffffff", result.fg)
      assert.equals("#000000", result.bg)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineSpell highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineSpell" then
          called = true
          assert.equals("#9c27b0", highlights.fg)
          assert.equals(false, highlights.bold)
        end
      end

      spell.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
