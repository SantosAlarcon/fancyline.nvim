local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local commit_msg = require("fancyline.components.commit_msg")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.commit_msg", function()
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
      local result = commit_msg.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when get_root returns nil", function()
      local git_mock = {
        get_root = function() return nil end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = commit_msg.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when git log fails", function()
      local git_mock = {
        get_root = function() return "/path/to/repo" end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = commit_msg.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns commit message when git log succeeds", function()
      local git_mock = {
        get_root = function() return "/path/to/repo" end
      }
      helpers.mock_git_utils(git_mock)
      helpers.mock_vim_fn_systemlist({ "feat: add new feature" })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = commit_msg.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_true(result.text:match("feat: add new feature") ~= nil)
      assert.equals("FancylineCommitMsg", result.highlight)
    end)

    it("returns nil when message is empty", function()
      local git_mock = {
        get_root = function() return "/path/to/repo" end
      }
      helpers.mock_git_utils(git_mock)
      helpers.mock_vim_fn_systemlist({ "" })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = commit_msg.provider(opts, ctx)

      assert.is_nil(result)
    end)
  end)

  describe("max_length option", function()
    it("truncates long messages", function()
      local git_mock = {
        get_root = function() return "/path/to/repo" end
      }
      helpers.mock_git_utils(git_mock)
      helpers.mock_vim_fn_systemlist({ "this is a very long commit message that should be truncated" })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { max_length = 20 }
      local result = commit_msg.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals(23, #result.text)
      assert.is_true(result.text:match("…") ~= nil)
    end)
  end)

  describe("icon configuration", function()
    it("returns default icon symbol", function()
      local git_mock = {
        get_root = function() return "/path/to/repo" end
      }
      helpers.mock_git_utils(git_mock)
      helpers.mock_vim_fn_systemlist({ "fix: bug" })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = commit_msg.provider(opts, ctx)

      assert.equals(" ", result.icon.symbol)
    end)

    it("uses string icon from opts.icon", function()
      local git_mock = {
        get_root = function() return "/path/to/repo" end
      }
      helpers.mock_git_utils(git_mock)
      helpers.mock_vim_fn_systemlist({ "fix: bug" })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = "MSG" }
      local result = commit_msg.provider(opts, ctx)

      assert.equals("MSG", result.icon.symbol)
    end)

    it("uses table icon from opts.icon", function()
      local git_mock = {
        get_root = function() return "/path/to/repo" end
      }
      helpers.mock_git_utils(git_mock)
      helpers.mock_vim_fn_systemlist({ "fix: bug" })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = { symbol = "C", fg = "#ff0000" } }
      local result = commit_msg.provider(opts, ctx)

      assert.equals("C", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)
  end)

  describe("style and colors", function()
    it("returns default style as none", function()
      local git_mock = {
        get_root = function() return "/path/to/repo" end
      }
      helpers.mock_git_utils(git_mock)
      helpers.mock_vim_fn_systemlist({ "fix: bug" })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = commit_msg.provider(opts, ctx)

      assert.equals("none", result.style)
    end)

    it("returns custom style from opts", function()
      local git_mock = {
        get_root = function() return "/path/to/repo" end
      }
      helpers.mock_git_utils(git_mock)
      helpers.mock_vim_fn_systemlist({ "fix: bug" })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { style = "round" }
      local result = commit_msg.provider(opts, ctx)

      assert.equals("round", result.style)
    end)

    it("returns fg and bg colors", function()
      local git_mock = {
        get_root = function() return "/path/to/repo" end
      }
      helpers.mock_git_utils(git_mock)
      helpers.mock_vim_fn_systemlist({ "fix: bug" })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icon = { fg = "#ff0000", bg = "#0000ff" },
        fg = "#ffffff",
        bg = "#000000"
      }
      local result = commit_msg.provider(opts, ctx)

      assert.equals("#ffffff", result.fg)
      assert.equals("#000000", result.bg)
    end)
  end)
end)
