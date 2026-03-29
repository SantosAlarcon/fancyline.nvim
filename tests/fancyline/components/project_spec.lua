local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local project = require("fancyline.components.project")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.project", function()
  before_each(function()
    helpers.cleanup()
    package.loaded["fancyline.utils.git"] = nil
  end)

  after_each(function()
    helpers.cleanup()
    package.loaded["fancyline.utils.git"] = nil
  end)

  describe("basic functionality", function()
    it("returns nil when git utils not available", function()
      package.loaded["fancyline.utils.git"] = nil

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = project.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when not in git repo", function()
      local git_mock = {
        get_root = function() return nil end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = project.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns project name from git root", function()
      local git_mock = {
        get_root = function() return "/home/user/my-project" end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = project.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals("my-project", result.text)
      assert.equals("FancylineProject", result.highlight)
    end)
  end)

  describe("icon configuration", function()
    it("returns default icon symbol", function()
      local git_mock = {
        get_root = function() return "/home/user/project" end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = project.provider(opts, ctx)

      assert.equals(" ", result.icon.symbol)
    end)

    it("uses string icon from opts.icon", function()
      local git_mock = {
        get_root = function() return "/home/user/project" end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = "PROJ" }
      local result = project.provider(opts, ctx)

      assert.equals("PROJ", result.icon.symbol)
    end)

    it("uses table icon from opts.icon", function()
      local git_mock = {
        get_root = function() return "/home/user/project" end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = { symbol = "P", fg = "#ff0000" } }
      local result = project.provider(opts, ctx)

      assert.equals("P", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      local git_mock = {
        get_root = function() return "/home/user/project" end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = project.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      local git_mock = {
        get_root = function() return "/home/user/project" end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = project.provider(opts, ctx)

      assert.equals("round", result.style)
    end)

    it("returns fg and bg colors", function()
      local git_mock = {
        get_root = function() return "/home/user/project" end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { fg = "#ff0000", bg = "#0000ff" },
        fg = "#ffffff",
        bg = "#000000"
      }
      local result = project.provider(opts, ctx)

      assert.equals("#ffffff", result.fg)
      assert.equals("#000000", result.bg)
    end)
  end)
end)
