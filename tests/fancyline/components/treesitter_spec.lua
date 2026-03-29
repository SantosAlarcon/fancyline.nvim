local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local treesitter = require("fancyline.components.treesitter")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.treesitter", function()
  before_each(function()
    helpers.cleanup()
    package.loaded["nvim-treesitter"] = nil
    package.loaded["nvim-treesitter.info"] = nil
  end)

  after_each(function()
    helpers.cleanup()
    package.loaded["nvim-treesitter"] = nil
    package.loaded["nvim-treesitter.info"] = nil
  end)

  describe("basic functionality", function()
    it("returns nil when nvim-treesitter not available", function()
      package.loaded["nvim-treesitter"] = nil
      package.loaded["nvim-treesitter.info"] = nil

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = treesitter.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when parser is not available", function()
      local mock_ts = {
        get_parser = function() return nil end
      }
      helpers.mock_treesitter(mock_ts)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = treesitter.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns treesitter info when parser is valid", function()
      local mock_parser = {
        is_valid = function() return true end
      }
      local mock_ts = {
        get_parser = function() return mock_parser end,
        get_buf_lang = function() return "lua" end
      }
      helpers.mock_treesitter(mock_ts)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = treesitter.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_true(result.text:match("TS") ~= nil)
      assert.is_true(result.text:match("lua") ~= nil)
      assert.equals("FancylineTreesitter", result.highlight)
    end)

    it("returns nil when parser is invalid", function()
      local mock_parser = {
        is_valid = function() return false end
      }
      local mock_ts = {
        get_parser = function() return mock_parser end
      }
      helpers.mock_treesitter(mock_ts)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = treesitter.provider(opts, ctx)

      assert.is_nil(result)
    end)
  end)

  describe("icon configuration", function()
    it("uses default icon when no icon provided", function()
      local mock_parser = {
        is_valid = function() return true end
      }
      local mock_ts = {
        get_parser = function() return mock_parser end,
        get_buf_lang = function() return "lua" end
      }
      helpers.mock_treesitter(mock_ts)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = treesitter.provider(opts, ctx)

      assert.is_true(result.text:match("TS") ~= nil)
    end)

    it("uses custom icon symbol from opts.icon", function()
      local mock_parser = {
        is_valid = function() return true end
      }
      local mock_ts = {
        get_parser = function() return mock_parser end,
        get_buf_lang = function() return "lua" end
      }
      helpers.mock_treesitter(mock_ts)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { symbol = "PARSER" }
      }
      local result = treesitter.provider(opts, ctx)

      assert.is_true(result.text:match("PARSER") ~= nil)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      local mock_parser = {
        is_valid = function() return true end
      }
      local mock_ts = {
        get_parser = function() return mock_parser end,
        get_buf_lang = function() return "lua" end
      }
      helpers.mock_treesitter(mock_ts)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = treesitter.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      local mock_parser = {
        is_valid = function() return true end
      }
      local mock_ts = {
        get_parser = function() return mock_parser end,
        get_buf_lang = function() return "lua" end
      }
      helpers.mock_treesitter(mock_ts)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = treesitter.provider(opts, ctx)

      assert.equals("round", result.style)
    end)

    it("returns fg and bg colors", function()
      local mock_parser = {
        is_valid = function() return true end
      }
      local mock_ts = {
        get_parser = function() return mock_parser end,
        get_buf_lang = function() return "lua" end
      }
      helpers.mock_treesitter(mock_ts)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { fg = "#ff0000", bg = "#0000ff" },
        fg = "#ffffff",
        bg = "#000000"
      }
      local result = treesitter.provider(opts, ctx)

      assert.equals("#ff0000", result.icon.fg)
      assert.equals("#0000ff", result.icon.bg)
      assert.equals("#ffffff", result.fg)
      assert.equals("#000000", result.bg)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineTreesitter highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineTreesitter" then
          called = true
          assert.equals("#4caf50", highlights.fg)
          assert.equals(false, highlights.bold)
        end
      end

      treesitter.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
