local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local reload = require("fancyline.components.reload")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.reload", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("basic functionality", function()
    it("returns nil when not reloading", function()
      vim.v.reload_buf = 0

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = reload.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns reload indicator when reloading", function()
      vim.v.reload_buf = 1

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = reload.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("RELOAD", result.text)
      assert.equals("FancylineReload", result.highlight)
    end)
  end)

  describe("icon configuration", function()
    it("uses default icon when no icon provided", function()
      vim.v.reload_buf = 1

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = reload.provider(opts, ctx)

      assert.equals("RELOAD", result.text)
    end)

    it("uses custom icon symbol from opts.icon", function()
      vim.v.reload_buf = 1

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { symbol = "REFRESH" }
      }
      local result = reload.provider(opts, ctx)

      assert.equals("REFRESH", result.text)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      vim.v.reload_buf = 1

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = reload.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      vim.v.reload_buf = 1

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = reload.provider(opts, ctx)

      assert.equals("round", result.style)
    end)

    it("returns fg and bg colors", function()
      vim.v.reload_buf = 1

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { fg = "#ff0000", bg = "#0000ff" },
        fg = "#ffffff",
        bg = "#000000"
      }
      local result = reload.provider(opts, ctx)

      assert.equals("#ff0000", result.icon.fg)
      assert.equals("#0000ff", result.icon.bg)
      assert.equals("#ffffff", result.fg)
      assert.equals("#000000", result.bg)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineReload highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineReload" then
          called = true
          assert.equals("#2196f3", highlights.fg)
          assert.equals(true, highlights.bold)
        end
      end

      reload.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
