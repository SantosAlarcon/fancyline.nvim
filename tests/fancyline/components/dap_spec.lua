local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local dap = require("fancyline.components.dap")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.dap", function()
  before_each(function()
    helpers.cleanup()
    package.loaded["dap"] = nil
  end)

  after_each(function()
    helpers.cleanup()
    package.loaded["dap"] = nil
  end)

  describe("basic functionality", function()
    it("returns nil when dap not available", function()
      package.loaded["dap"] = nil

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = dap.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when no active session", function()
      helpers.mock_dap({
        session = function() return nil end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = dap.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns running state", function()
      helpers.mock_dap({
        session = function() return { state = "running" } end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = dap.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_true(result.text:match("running") ~= nil)
      assert.equals("FancylineDapRunning", result.highlight)
    end)

    it("returns stopped state", function()
      helpers.mock_dap({
        session = function() return { state = "stopped" } end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = dap.provider(opts, ctx)

      assert.equals("FancylineDapStopped", result.highlight)
      assert.is_true(result.text:match("stopped") ~= nil)
    end)

    it("returns breakpoint state", function()
      helpers.mock_dap({
        session = function() return { state = "breakpoint" } end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = dap.provider(opts, ctx)

      assert.equals("FancylineDap", result.highlight)
      assert.is_true(result.text:match("breakpoint") ~= nil)
    end)

    it("returns exception state", function()
      helpers.mock_dap({
        session = function() return { state = "exception" } end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = dap.provider(opts, ctx)

      assert.equals("FancylineDapException", result.highlight)
      assert.is_true(result.text:match("exception") ~= nil)
    end)
  end)

  describe("custom icons", function()
    it("uses state-specific icons from opts.icons", function()
      helpers.mock_dap({
        session = function() return { state = "running" } end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icons = { running = "RUN" }
      }
      local result = dap.provider(opts, ctx)

      assert.is_true(result.text:match("RUN") ~= nil)
    end)

    it("falls back to opts.icon when state icon not set", function()
      helpers.mock_dap({
        session = function() return { state = "running" } end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = "DBG"
      }
      local result = dap.provider(opts, ctx)

      assert.is_true(result.text:match("DBG") ~= nil)
    end)
  end)

  describe("icon configuration", function()
    it("returns default icon symbol", function()
      helpers.mock_dap({
        session = function() return { state = "running" } end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = dap.provider(opts, ctx)

      assert.equals(" ", result.icon.symbol)
    end)

    it("uses string icon from opts.icon", function()
      helpers.mock_dap({
        session = function() return { state = "running" } end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = "DAP" }
      local result = dap.provider(opts, ctx)

      assert.equals("DAP", result.icon.symbol)
    end)

    it("uses table icon from opts.icon", function()
      helpers.mock_dap({
        session = function() return { state = "running" } end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = { symbol = "D", fg = "#ff0000" } }
      local result = dap.provider(opts, ctx)

      assert.equals("D", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      helpers.mock_dap({
        session = function() return { state = "running" } end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = dap.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      helpers.mock_dap({
        session = function() return { state = "running" } end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = dap.provider(opts, ctx)

      assert.equals("round", result.style)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineDap highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineDap" then
          called = true
          assert.equals("#4caf50", highlights.fg)
        end
      end

      dap.setup_highlights()
      assert.is_true(called)
    end)

    it("sets up FancylineDapRunning highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineDapRunning" then
          called = true
          assert.equals("#4caf50", highlights.fg)
          assert.equals(true, highlights.bold)
        end
      end

      dap.setup_highlights()
      assert.is_true(called)
    end)

    it("sets up FancylineDapStopped highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineDapStopped" then
          called = true
          assert.equals("#ff9800", highlights.fg)
          assert.equals(true, highlights.bold)
        end
      end

      dap.setup_highlights()
      assert.is_true(called)
    end)

    it("sets up FancylineDapException highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineDapException" then
          called = true
          assert.equals("#f44336", highlights.fg)
          assert.equals(true, highlights.bold)
        end
      end

      dap.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
