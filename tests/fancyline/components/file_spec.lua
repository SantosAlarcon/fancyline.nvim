local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local file = require("fancyline.components.file")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.file", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("basic functionality", function()
    it("returns file name from buffer", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        if buf == 1 then return "/path/to/file.lua" end
        return ""
      end
      helpers.mock_buf_option(1, "modified", false)
      helpers.mock_buf_option(1, "readonly", false)

      local opts = {}
      local result = file.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("file.lua", result.text)
      assert.equals("FancylineFile", result.highlight)
      assert.equals("normal", result.state)
    end)

    it("returns empty_name for unnamed buffers", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return ""
      end

      local opts = { empty_name = "[No Name]" }
      local result = file.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("[No Name]", result.text)
    end)

    it("returns state as normal for unmodified file", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      helpers.mock_buf_option(1, "modified", false)
      helpers.mock_buf_option(1, "readonly", false)

      local opts = {}
      local result = file.provider(opts, ctx)

      assert.equals("normal", result.state)
      assert.equals("FancylineFile", result.highlight)
    end)
  end)

  describe("modified state", function()
    it("returns modified icon and highlight when buffer is modified", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      helpers.mock_buf_option(1, "modified", true)
      helpers.mock_buf_option(1, "readonly", false)

      local opts = {}
      local result = file.provider(opts, ctx)

      assert.equals("modified", result.state)
      assert.equals("FancylineFileModified", result.highlight)
      assert.is_true(result.text:match("●") ~= nil)
    end)

    it("uses custom modified icon from opts.icons", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      helpers.mock_buf_option(1, "modified", true)
      helpers.mock_buf_option(1, "readonly", false)

      local opts = {
        icons = { modified = "M" }
      }
      local result = file.provider(opts, ctx)

      assert.is_true(result.text:match("M") ~= nil)
    end)

    it("modified takes precedence over readonly", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      helpers.mock_buf_option(1, "modified", true)
      helpers.mock_buf_option(1, "readonly", true)

      local opts = {}
      local result = file.provider(opts, ctx)

      assert.equals("modified", result.state)
      assert.equals("FancylineFileModified", result.highlight)
    end)
  end)

  describe("readonly state", function()
    it("returns readonly icon and highlight when buffer is readonly", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      helpers.mock_buf_option(1, "modified", false)
      helpers.mock_buf_option(1, "readonly", true)

      local opts = {}
      local result = file.provider(opts, ctx)

      assert.equals("readonly", result.state)
      assert.equals("FancylineFileReadonly", result.highlight)
      assert.is_true(result.text:match("󰌾") ~= nil)
    end)

    it("uses custom readonly icon from opts.icons", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      helpers.mock_buf_option(1, "modified", false)
      helpers.mock_buf_option(1, "readonly", true)

      local opts = {
        icons = { readonly = "R" }
      }
      local result = file.provider(opts, ctx)

      assert.is_true(result.text:match("R") ~= nil)
    end)
  end)

  describe("icon configuration", function()
    it("returns icon from opts when symbol is provided", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      helpers.mock_buf_option(1, "modified", false)
      helpers.mock_buf_option(1, "readonly", false)

      local opts = {
        icon = { symbol = "X", fg = "#ff0000", bg = "#0000ff" }
      }
      local result = file.provider(opts, ctx)

      assert.equals("X", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
      assert.equals("#0000ff", result.icon.bg)
    end)

    it("returns use_devicon = false icon symbol", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      helpers.mock_buf_option(1, "modified", false)
      helpers.mock_buf_option(1, "readonly", false)

      local opts = {
        icon = { symbol = "Y" },
        use_devicon = false
      }
      local result = file.provider(opts, ctx)

      assert.equals("Y", result.icon.symbol)
    end)
  end)

  describe("returns expected fields", function()
    it("returns all required fields", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      helpers.mock_buf_option(1, "modified", false)
      helpers.mock_buf_option(1, "readonly", false)

      local opts = {
        icon = { symbol = "X" },
        style = "round",
        fg = "#fff",
        bg = "#000",
        border = {
          left = { style = "round", fg = "#f00" }
        }
      }
      local result = file.provider(opts, ctx)

      assert.is_true(result.text:match("file.lua") ~= nil)
      assert.equals("X", result.icon.symbol)
      assert.equals("round", result.style)
      assert.equals("FancylineFile", result.highlight)
      assert.equals("normal", result.state)
      assert.equals("#fff", result.fg)
      assert.equals("#000", result.bg)
      assert.is_table(result.border)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up file highlight groups", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineFile" then
          called = true
          assert.equals("#abb2bf", highlights.fg)
          assert.equals(false, highlights.bold)
        end
      end

      file.setup_highlights()
      assert.is_true(called)
    end)

    it("sets up modified highlight with bold", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineFileModified" then
          called = true
          assert.equals("#e5c07b", highlights.fg)
          assert.equals(true, highlights.bold)
        end
      end

      file.setup_highlights()
      assert.is_true(called)
    end)

    it("sets up readonly highlight without bold", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineFileReadonly" then
          called = true
          assert.equals("#e06c75", highlights.fg)
          assert.equals(false, highlights.bold)
        end
      end

      file.setup_highlights()
      assert.is_true(called)
    end)
  end)

  describe("devicons failure handling", function()
    it("returns result when devicons fails", function()
      package.loaded["fancyline.utils.devicons"] = nil
      local failed = false
      package.loaders[2] = function(name)
        if name:match("devicons") then
          failed = true
          return function() error("module not found") end
        end
      end

      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      helpers.mock_buf_option(1, "modified", false)
      helpers.mock_buf_option(1, "readonly", false)

      local opts = {}
      local result = file.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("file.lua", result.text)

      package.loaders[2] = nil
    end)
  end)
end)
