local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local filesize = require("fancyline.components.filesize")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.filesize", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("basic functionality", function()
    it("returns nil for empty buffer name", function()
      helpers.mock_buf_name(1, "")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = filesize.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when fs_stat fails", function()
      helpers.mock_buf_name(1, "/path/to/file.lua")
      helpers.mock_vim_loop_fs_stat("/path/to/file.lua", nil)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = filesize.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil for zero size file", function()
      helpers.mock_buf_name(1, "/path/to/file.lua")
      helpers.mock_vim_loop_fs_stat("/path/to/file.lua", { size = 0 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = filesize.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns file size in bytes", function()
      helpers.mock_buf_name(1, "/path/to/file.lua")
      helpers.mock_vim_loop_fs_stat("/path/to/file.lua", { size = 500 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = filesize.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_true(result.text:match("500") ~= nil)
      assert.is_true(result.text:match("B") ~= nil)
      assert.equals("FancylineFilesize", result.highlight)
    end)

    it("returns file size in KB", function()
      helpers.mock_buf_name(1, "/path/to/file.lua")
      helpers.mock_vim_loop_fs_stat("/path/to/file.lua", { size = 2048 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = filesize.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_true(result.text:match("KB") ~= nil)
    end)

    it("returns file size in MB", function()
      helpers.mock_buf_name(1, "/path/to/file.lua")
      helpers.mock_vim_loop_fs_stat("/path/to/file.lua", { size = 2097152 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = filesize.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_true(result.text:match("MB") ~= nil)
    end)
  end)

  describe("icon configuration", function()
    it("returns default icon symbol", function()
      helpers.mock_buf_name(1, "/path/to/file.lua")
      helpers.mock_vim_loop_fs_stat("/path/to/file.lua", { size = 100 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = filesize.provider(opts, ctx)

      assert.equals(" ", result.icon.symbol)
    end)

    it("uses string icon from opts.icon", function()
      helpers.mock_buf_name(1, "/path/to/file.lua")
      helpers.mock_vim_loop_fs_stat("/path/to/file.lua", { size = 100 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = "SIZE" }
      local result = filesize.provider(opts, ctx)

      assert.equals("SIZE", result.icon.symbol)
    end)

    it("uses table icon from opts.icon", function()
      helpers.mock_buf_name(1, "/path/to/file.lua")
      helpers.mock_vim_loop_fs_stat("/path/to/file.lua", { size = 100 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = { symbol = "B", fg = "#ff0000" } }
      local result = filesize.provider(opts, ctx)

      assert.equals("B", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      helpers.mock_buf_name(1, "/path/to/file.lua")
      helpers.mock_vim_loop_fs_stat("/path/to/file.lua", { size = 100 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = filesize.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      helpers.mock_buf_name(1, "/path/to/file.lua")
      helpers.mock_vim_loop_fs_stat("/path/to/file.lua", { size = 100 })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = filesize.provider(opts, ctx)

      assert.equals("round", result.style)
    end)
  end)
end)
