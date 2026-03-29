local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local tabnr = require("fancyline.components.tabnr")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.tabnr", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("basic functionality", function()
    it("returns tab number format", function()
      helpers.mock_tabpages({ 1, 2, 3 })
      vim.fn.tabpagenr = function() return 1 end

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = tabnr.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("1/3", result.text)
      assert.equals("FancylineTabnr", result.highlight)
    end)

    it("returns correct tab number for current tab", function()
      helpers.mock_tabpages({ 1, 2, 3 })
      vim.fn.tabpagenr = function() return 2 end

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = tabnr.provider(opts, ctx)

      assert.equals("2/3", result.text)
    end)
  end)

  describe("icon configuration", function()
    it("returns default icon symbol", function()
      helpers.mock_tabpages({ 1, 2 })
      vim.fn.tabpagenr = function() return 1 end

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = tabnr.provider(opts, ctx)

      assert.equals(" ", result.icon.symbol)
    end)

    it("uses string icon from opts.icon", function()
      helpers.mock_tabpages({ 1, 2 })
      vim.fn.tabpagenr = function() return 1 end

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = "TAB" }
      local result = tabnr.provider(opts, ctx)

      assert.equals("TAB", result.icon.symbol)
    end)

    it("uses table icon from opts.icon", function()
      helpers.mock_tabpages({ 1, 2 })
      vim.fn.tabpagenr = function() return 1 end

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = { symbol = "T", fg = "#ff0000" } }
      local result = tabnr.provider(opts, ctx)

      assert.equals("T", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      helpers.mock_tabpages({ 1 })
      vim.fn.tabpagenr = function() return 1 end

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = tabnr.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      helpers.mock_tabpages({ 1 })
      vim.fn.tabpagenr = function() return 1 end

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = tabnr.provider(opts, ctx)

      assert.equals("round", result.style)
    end)

    it("returns fg and bg colors", function()
      helpers.mock_tabpages({ 1 })
      vim.fn.tabpagenr = function() return 1 end

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { fg = "#ff0000", bg = "#0000ff" },
        fg = "#ffffff",
        bg = "#000000"
      }
      local result = tabnr.provider(opts, ctx)

      assert.equals("#ffffff", result.fg)
      assert.equals("#000000", result.bg)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineTabnr highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineTabnr" then
          called = true
          assert.equals("#78909c", highlights.fg)
          assert.equals(false, highlights.bold)
        end
      end

      tabnr.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
