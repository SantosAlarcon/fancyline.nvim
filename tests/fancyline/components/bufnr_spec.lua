local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local bufnr = require("fancyline.components.bufnr")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.bufnr", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("basic functionality", function()
    it("returns buffer number with hash prefix", function()
      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = bufnr.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("#1", result.text)
      assert.equals("FancylineBufnr", result.highlight)
    end)

    it("returns correct buffer number from context", function()
      local ctx = { bufnr = 5, winid = 1 }
      local opts = {}
      local result = bufnr.provider(opts, ctx)

      assert.equals("#5", result.text)
    end)
  end)

  describe("icon configuration", function()
    it("returns default icon symbol", function()
      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = bufnr.provider(opts, ctx)

      assert.equals(" ", result.icon.symbol)
    end)

    it("uses string icon from opts.icon", function()
      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = "BUF" }
      local result = bufnr.provider(opts, ctx)

      assert.equals("BUF", result.icon.symbol)
    end)

    it("uses table icon from opts.icon", function()
      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = { symbol = "#", fg = "#ff0000" } }
      local result = bufnr.provider(opts, ctx)

      assert.equals("#", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = bufnr.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = bufnr.provider(opts, ctx)

      assert.equals("round", result.style)
    end)

    it("returns fg and bg colors", function()
      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { fg = "#ff0000", bg = "#0000ff" },
        fg = "#ffffff",
        bg = "#000000"
      }
      local result = bufnr.provider(opts, ctx)

      assert.equals("#ffffff", result.fg)
      assert.equals("#000000", result.bg)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineBufnr highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineBufnr" then
          called = true
          assert.equals("#78909c", highlights.fg)
          assert.equals(false, highlights.bold)
        end
      end

      bufnr.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
