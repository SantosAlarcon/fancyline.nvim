local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local checktime = require("fancyline.components.checktime")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.checktime", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("basic functionality", function()
    it("returns nil when not checking and no gitsigns status", function()
      helpers.mock_vim_b("fugitive_checking", nil, 1)
      helpers.mock_vim_b("gitsigns_status", nil, 1)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = checktime.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns indicator when fugitive is checking", function()
      helpers.mock_vim_b("fugitive_checking", true, 1)
      helpers.mock_vim_b("gitsigns_status", nil, 1)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = checktime.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("...", result.text)
      assert.equals("FancylineChecktime", result.highlight)
    end)

    it("returns indicator when gitsigns status is present", function()
      helpers.mock_vim_b("fugitive_checking", nil, 1)
      helpers.mock_vim_b("gitsigns_status", "some status", 1)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = checktime.provider(opts, ctx)

      assert.is_not_nil(result)
    end)
  end)

  describe("icon configuration", function()
    it("uses default icon when no icon provided", function()
      helpers.mock_vim_b("fugitive_checking", true, 1)
      helpers.mock_vim_b("gitsigns_status", nil, 1)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = checktime.provider(opts, ctx)

      assert.equals("...", result.text)
    end)

    it("uses custom icon symbol from opts.icon", function()
      helpers.mock_vim_b("fugitive_checking", true, 1)
      helpers.mock_vim_b("gitsigns_status", nil, 1)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { symbol = "CHECK" }
      }
      local result = checktime.provider(opts, ctx)

      assert.equals("CHECK", result.text)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      helpers.mock_vim_b("fugitive_checking", true, 1)
      helpers.mock_vim_b("gitsigns_status", nil, 1)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = checktime.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      helpers.mock_vim_b("fugitive_checking", true, 1)
      helpers.mock_vim_b("gitsigns_status", nil, 1)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = checktime.provider(opts, ctx)

      assert.equals("round", result.style)
    end)

    it("returns fg and bg colors", function()
      helpers.mock_vim_b("fugitive_checking", true, 1)
      helpers.mock_vim_b("gitsigns_status", nil, 1)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { fg = "#ff0000", bg = "#0000ff" },
        fg = "#ffffff",
        bg = "#000000"
      }
      local result = checktime.provider(opts, ctx)

      assert.equals("#ff0000", result.icon.fg)
      assert.equals("#0000ff", result.icon.bg)
      assert.equals("#ffffff", result.fg)
      assert.equals("#000000", result.bg)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineChecktime highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineChecktime" then
          called = true
          assert.equals("#ff9800", highlights.fg)
          assert.equals(true, highlights.bold)
        end
      end

      checktime.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
