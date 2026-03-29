local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local fileformat = require("fancyline.components.fileformat")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.fileformat", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("basic functionality", function()
    it("returns LF for unix fileformat", function()
      helpers.mock_buf_option(1, "fileformat", "unix")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = fileformat.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("LF", result.text)
      assert.equals("FancylineFileformat", result.highlight)
    end)

    it("returns CRLF for dos fileformat", function()
      helpers.mock_buf_option(1, "fileformat", "dos")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = fileformat.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("CRLF", result.text)
      assert.equals("FancylineFileformatDos", result.highlight)
    end)

    it("returns CR for mac fileformat", function()
      helpers.mock_buf_option(1, "fileformat", "mac")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = fileformat.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("CR", result.text)
      assert.equals("FancylineFileformatMac", result.highlight)
    end)
  end)

  describe("icon configuration", function()
    it("returns default icon symbol", function()
      helpers.mock_buf_option(1, "fileformat", "unix")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = fileformat.provider(opts, ctx)

      assert.equals(" ", result.icon.symbol)
    end)

    it("uses string icon from opts.icon", function()
      helpers.mock_buf_option(1, "fileformat", "unix")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = "FF" }
      local result = fileformat.provider(opts, ctx)

      assert.equals("FF", result.icon.symbol)
    end)

    it("uses table icon from opts.icon", function()
      helpers.mock_buf_option(1, "fileformat", "unix")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = { symbol = "UNIX", fg = "#ff0000" } }
      local result = fileformat.provider(opts, ctx)

      assert.equals("UNIX", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      helpers.mock_buf_option(1, "fileformat", "unix")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = fileformat.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      helpers.mock_buf_option(1, "fileformat", "unix")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = fileformat.provider(opts, ctx)

      assert.equals("round", result.style)
    end)

    it("returns fg and bg colors", function()
      helpers.mock_buf_option(1, "fileformat", "unix")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { fg = "#ff0000", bg = "#0000ff" },
        fg = "#ffffff",
        bg = "#000000"
      }
      local result = fileformat.provider(opts, ctx)

      assert.equals("#ffffff", result.fg)
      assert.equals("#000000", result.bg)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineFileformat highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineFileformat" then
          called = true
          assert.equals("#607d8b", highlights.fg)
        end
      end

      fileformat.setup_highlights()
      assert.is_true(called)
    end)

    it("sets up FancylineFileformatDos highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineFileformatDos" then
          called = true
          assert.equals("#4caf50", highlights.fg)
        end
      end

      fileformat.setup_highlights()
      assert.is_true(called)
    end)

    it("sets up FancylineFileformatMac highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineFileformatMac" then
          called = true
          assert.equals("#ff9800", highlights.fg)
        end
      end

      fileformat.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
