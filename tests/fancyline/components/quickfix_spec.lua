local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local quickfix = require("fancyline.components.quickfix")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.quickfix", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("basic functionality", function()
    it("returns nil when quickfix list is empty", function()
      helpers.mock_qflist({})

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = quickfix.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when quickfix has no valid items", function()
      helpers.mock_qflist({
        { valid = false },
        { valid = false }
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = quickfix.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns quickfix count when valid items exist", function()
      helpers.mock_qflist({
        { valid = true },
        { valid = true },
        { valid = true }
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = quickfix.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_true(result.text:match("3") ~= nil)
      assert.is_true(result.text:match("quickfix") ~= nil)
      assert.equals("FancylineQuickfix", result.highlight)
    end)

    it("returns correct count with mixed valid items", function()
      helpers.mock_qflist({
        { valid = true },
        { valid = false },
        { valid = true }
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = quickfix.provider(opts, ctx)

      assert.is_true(result.text:match("2") ~= nil)
    end)
  end)

  describe("icon configuration", function()
    it("returns default icon symbol", function()
      helpers.mock_qflist({ { valid = true } })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = quickfix.provider(opts, ctx)

      assert.equals(" ", result.icon.symbol)
    end)

    it("uses string icon from opts.icon", function()
      helpers.mock_qflist({ { valid = true } })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = "QF" }
      local result = quickfix.provider(opts, ctx)

      assert.equals("QF", result.icon.symbol)
    end)

    it("uses table icon from opts.icon", function()
      helpers.mock_qflist({ { valid = true } })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = { symbol = "Q", fg = "#ff0000" } }
      local result = quickfix.provider(opts, ctx)

      assert.equals("Q", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      helpers.mock_qflist({ { valid = true } })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = quickfix.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      helpers.mock_qflist({ { valid = true } })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = quickfix.provider(opts, ctx)

      assert.equals("round", result.style)
    end)

    it("returns fg and bg colors", function()
      helpers.mock_qflist({ { valid = true } })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { fg = "#ff0000", bg = "#0000ff" },
        fg = "#ffffff",
        bg = "#000000"
      }
      local result = quickfix.provider(opts, ctx)

      assert.equals("#ffffff", result.fg)
      assert.equals("#000000", result.bg)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineQuickfix highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineQuickfix" then
          called = true
          assert.equals("#ff9800", highlights.fg)
          assert.equals(false, highlights.bold)
        end
      end

      quickfix.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
