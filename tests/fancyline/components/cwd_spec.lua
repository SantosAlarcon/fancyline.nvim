local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local cwd = require("fancyline.components.cwd")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.cwd", function()
  before_each(function()
    helpers.cleanup()
    package.loaded["fancyline.utils.git"] = nil
  end)

  after_each(function()
    helpers.cleanup()
    package.loaded["fancyline.utils.git"] = nil
  end)

  describe("basic functionality", function()
    it("returns nil when getcwd returns empty", function()
      helpers.mock_getcwd("")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = cwd.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns current working directory", function()
      helpers.mock_getcwd("/home/user/project")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = cwd.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("/home/user/project", result.text)
      assert.equals("FancylineCwd", result.highlight)
    end)

    it("returns relative path when in project", function()
      helpers.mock_getcwd("/home/user/project/src")

      local git_mock = {
        get_root = function() return "/home/user/project" end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = cwd.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("src", result.text)
    end)

    it("returns dot when at project root", function()
      helpers.mock_getcwd("/home/user/project")

      local git_mock = {
        get_root = function() return "/home/user/project" end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = cwd.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals(".", result.text)
    end)
  end)

  describe("max_length option", function()
    it("truncates path when exceeding max_length", function()
      helpers.mock_getcwd("/a/b/c/d/e/f")

      local git_mock = {
        get_root = function() return nil end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { max_length = 2 }
      local result = cwd.provider(opts, ctx)

      assert.is_not_nil(result)
    end)
  end)

  describe("icon configuration", function()
    it("returns default icon symbol", function()
      helpers.mock_getcwd("/home/user")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = cwd.provider(opts, ctx)

      assert.equals(" ", result.icon.symbol)
    end)

    it("uses string icon from opts.icon", function()
      helpers.mock_getcwd("/home/user")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = "CWD" }
      local result = cwd.provider(opts, ctx)

      assert.equals("CWD", result.icon.symbol)
    end)

    it("uses table icon from opts.icon", function()
      helpers.mock_getcwd("/home/user")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = { symbol = "~", fg = "#ff0000" } }
      local result = cwd.provider(opts, ctx)

      assert.equals("~", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      helpers.mock_getcwd("/home/user")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = cwd.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      helpers.mock_getcwd("/home/user")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = cwd.provider(opts, ctx)

      assert.equals("round", result.style)
    end)

    it("returns fg and bg colors", function()
      helpers.mock_getcwd("/home/user")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { fg = "#ff0000", bg = "#0000ff" },
        fg = "#ffffff",
        bg = "#000000"
      }
      local result = cwd.provider(opts, ctx)

      assert.equals("#ffffff", result.fg)
      assert.equals("#000000", result.bg)
    end)
  end)
end)
