local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local search_stats = require("fancyline.components.search_stats")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.search_stats", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("basic functionality", function()
    it("returns nil when no search count", function()
      helpers.mock_searchcount({ current = 0, total = 0 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = search_stats.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when search_count returns nil", function()
      vim.fn.searchcount = function()
        return nil
      end

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = search_stats.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns formatted search count", function()
      helpers.mock_searchcount({ current = 2, total = 5 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = search_stats.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_true(result.text:match("2") ~= nil)
      assert.is_true(result.text:match("5") ~= nil)
      assert.equals("FancylineSearchStats", result.highlight)
    end)

    it("uses custom format from opts", function()
      helpers.mock_searchcount({ current = 3, total = 10 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { format = "Match %d of %d" }
      local result = search_stats.provider(opts, ctx)

      assert.is_true(result.text:match("Match") ~= nil)
    end)
  end)

  describe("highlight states", function()
    it("returns FancylineSearchNoMatch when current is 0", function()
      helpers.mock_searchcount({ current = 0, total = 5 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = search_stats.provider(opts, ctx)

      assert.equals("FancylineSearchNoMatch", result.highlight)
    end)

    it("returns FancylineSearchStats when current > 0", function()
      helpers.mock_searchcount({ current = 1, total = 5 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = search_stats.provider(opts, ctx)

      assert.equals("FancylineSearchStats", result.highlight)
    end)
  end)

  describe("icon configuration", function()
    it("returns default icon symbol", function()
      helpers.mock_searchcount({ current = 1, total = 5 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = search_stats.provider(opts, ctx)

      assert.equals(" ", result.icon.symbol)
    end)

    it("uses string icon from opts.icon", function()
      helpers.mock_searchcount({ current = 1, total = 5 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = "/" }
      local result = search_stats.provider(opts, ctx)

      assert.equals("/", result.icon.symbol)
    end)

    it("uses table icon from opts.icon", function()
      helpers.mock_searchcount({ current = 1, total = 5 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = { symbol = "?", fg = "#ff0000" } }
      local result = search_stats.provider(opts, ctx)

      assert.equals("?", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineSearchStats highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineSearchStats" then
          called = true
          assert.equals("#ff9800", highlights.fg)
        end
      end

      search_stats.setup_highlights()
      assert.is_true(called)
    end)

    it("sets up FancylineSearchNoMatch highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineSearchNoMatch" then
          called = true
          assert.equals("#f44336", highlights.fg)
        end
      end

      search_stats.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
