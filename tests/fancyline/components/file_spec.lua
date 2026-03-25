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
      vim.bo[1].modified = false
      vim.bo[1].readonly = false

      local opts = {}
      local result = file.provider(opts, ctx)

      assert.equals(" file.lua", result.text)
    end)

    it("returns empty_name for unnamed buffers", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return ""
      end

      local opts = { empty_name = "[No Name]" }
      local result = file.provider(opts, ctx)

      assert.equals(" [No Name]", result.text)
    end)

    it("returns state as normal for unmodified file", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      vim.bo[1].modified = false
      vim.bo[1].readonly = false

      local opts = {}
      local result = file.provider(opts, ctx)

      assert.equals("normal", result.state)
    end)

    it("returns state as modified when buffer is modified", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      vim.bo[1].modified = true
      vim.bo[1].readonly = false

      local opts = {}
      local result = file.provider(opts, ctx)

      assert.equals("modified", result.state)
    end)

    it("returns state as readonly for readonly buffers", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      vim.bo[1].modified = false
      vim.bo[1].readonly = true

      local opts = {}
      local result = file.provider(opts, ctx)

      assert.equals("readonly", result.state)
    end)
  end)

  describe("icon configuration", function()
    it("returns icon from opts when symbol is provided", function()
      local ctx = { bufnr = 1, winid = 1 }
      vim.api.nvim_buf_get_name = function(buf)
        return "/path/to/file.lua"
      end
      vim.bo[1].modified = false
      vim.bo[1].readonly = false

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
      vim.bo[1].modified = false
      vim.bo[1].readonly = false

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
      vim.bo[1].modified = false
      vim.bo[1].readonly = false

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

      assert.equals(" file.lua", result.text)
      assert.equals("X", result.icon.symbol)
      assert.equals("round", result.style)
      assert.equals("FancylineFile", result.highlight)
      assert.equals("normal", result.state)
      assert.equals("#fff", result.fg)
      assert.equals("#000", result.bg)
      assert.is_table(result.border)
    end)
  end)
end)
