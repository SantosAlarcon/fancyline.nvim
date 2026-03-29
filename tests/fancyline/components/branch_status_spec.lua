local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local branch_status = require("fancyline.components.branch_status")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.branch_status", function()
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
      local result = branch_status.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when get_ahead_behind returns nil", function()
      local git_mock = {
        get_ahead_behind = function() return nil end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = branch_status.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when both ahead and behind are 0", function()
      local git_mock = {
        get_ahead_behind = function() return 0, 0 end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = branch_status.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns ahead section when ahead > 0", function()
      local git_mock = {
        get_ahead_behind = function() return 3, 0 end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = branch_status.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_table(result)
      assert.is_true(#result >= 1)
      assert.is_true(result[1].text:match("3") ~= nil)
      assert.equals("FancylineGitAhead", result[1].highlight)
    end)

    it("returns behind section when behind > 0", function()
      local git_mock = {
        get_ahead_behind = function() return 0, 2 end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = branch_status.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_table(result)
      assert.is_true(result[1].text:match("2") ~= nil)
      assert.equals("FancylineGitBehind", result[1].highlight)
    end)

    it("returns both sections when both ahead and behind > 0", function()
      local git_mock = {
        get_ahead_behind = function() return 3, 2 end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = branch_status.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals(2, #result)
    end)
  end)

  describe("custom icons", function()
    it("uses custom ahead icon from opts.icons", function()
      local git_mock = {
        get_ahead_behind = function() return 5, 0 end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icons = { ahead = "^" }
      }
      local result = branch_status.provider(opts, ctx)

      assert.is_true(result[1].text:match("^") ~= nil)
    end)

    it("uses custom behind icon from opts.icons", function()
      local git_mock = {
        get_ahead_behind = function() return 0, 3 end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icons = { behind = "v" }
      }
      local result = branch_status.provider(opts, ctx)

      assert.is_true(result[1].text:match("v") ~= nil)
    end)

    it("uses default icons when not provided", function()
      local git_mock = {
        get_ahead_behind = function() return 1, 1 end
      }
      helpers.mock_git_utils(git_mock)

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = branch_status.provider(opts, ctx)

      assert.is_true(result[1].text:match("↑") ~= nil)
      assert.is_true(result[2].text:match("↓") ~= nil)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineGitAhead highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineGitAhead" then
          called = true
          assert.equals("#4caf50", highlights.fg)
          assert.equals(false, highlights.bold)
        end
      end

      branch_status.setup_highlights()
      assert.is_true(called)
    end)

    it("sets up FancylineGitBehind highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineGitBehind" then
          called = true
          assert.equals("#f44336", highlights.fg)
          assert.equals(false, highlights.bold)
        end
      end

      branch_status.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
