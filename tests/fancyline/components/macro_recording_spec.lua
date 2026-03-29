local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local macro_recording = require("fancyline.components.macro_recording")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.macro_recording", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("basic functionality", function()
    it("returns nil when not recording", function()
      helpers.mock_reg_recording("")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = macro_recording.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when reg_recording returns nil", function()
      helpers.mock_reg_recording(nil)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = macro_recording.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns recording text when recording macro", function()
      helpers.mock_reg_recording("q")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = macro_recording.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_true(result.text:match("q") ~= nil)
      assert.equals("FancylineMacroRecording", result.highlight)
    end)
  end)

  describe("icon configuration", function()
    it("uses default icon when no icon provided", function()
      helpers.mock_reg_recording("a")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = macro_recording.provider(opts, ctx)

      assert.is_true(result.text:match("●") ~= nil)
    end)

    it("uses custom icon symbol from opts.icon", function()
      helpers.mock_reg_recording("b")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { symbol = "REC" }
      }
      local result = macro_recording.provider(opts, ctx)

      assert.is_true(result.text:match("REC") ~= nil)
    end)

    it("returns icon config with symbol", function()
      helpers.mock_reg_recording("c")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = macro_recording.provider(opts, ctx)

      assert.equals(" ", result.icon.symbol)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      helpers.mock_reg_recording("d")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = macro_recording.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      helpers.mock_reg_recording("e")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = macro_recording.provider(opts, ctx)

      assert.equals("round", result.style)
    end)

    it("returns fg and bg colors", function()
      helpers.mock_reg_recording("f")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { fg = "#ff0000", bg = "#0000ff" },
        fg = "#ffffff",
        bg = "#000000"
      }
      local result = macro_recording.provider(opts, ctx)

      assert.equals("#ff0000", result.icon.fg)
      assert.equals("#0000ff", result.icon.bg)
      assert.equals("#ffffff", result.fg)
      assert.equals("#000000", result.bg)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineMacroRecording highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineMacroRecording" then
          called = true
          assert.equals("#f44336", highlights.fg)
          assert.equals(true, highlights.bold)
        end
      end

      macro_recording.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
