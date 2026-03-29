local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local git_signs = require("fancyline.components.git_signs")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.git_signs", function()
  before_each(function()
    helpers.cleanup()
    package.loaded["gitsigns"] = nil
  end)

  after_each(function()
    helpers.cleanup()
    package.loaded["gitsigns"] = nil
  end)

  describe("basic functionality", function()
    it("returns nil for empty buffer name", function()
      helpers.mock_buf_name(1, "")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = git_signs.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when gitsigns not available", function()
      package.loaded["gitsigns"] = nil

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = git_signs.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns nil when no hunks", function()
      helpers.mock_gitsigns({
        get_hunks = function() return {} end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = git_signs.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns sections for added hunks", function()
      helpers.mock_gitsigns({
        get_hunks = function(bufnr)
          return { { type = "add" }, { type = "add" } }
        end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = git_signs.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_table(result)
      assert.equals(1, #result)
      assert.equals("FancylineGitAdded", result[1].highlight)
    end)

    it("returns sections for changed hunks", function()
      helpers.mock_gitsigns({
        get_hunks = function(bufnr)
          return { { type = "change" } }
        end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = git_signs.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals(1, #result)
      assert.equals("FancylineGitChanged", result[1].highlight)
    end)

    it("returns sections for deleted hunks", function()
      helpers.mock_gitsigns({
        get_hunks = function(bufnr)
          return { { type = "delete" } }
        end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = git_signs.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals(1, #result)
      assert.equals("FancylineGitDeleted", result[1].highlight)
    end)

    it("returns multiple sections for mixed hunks", function()
      helpers.mock_gitsigns({
        get_hunks = function(bufnr)
          return {
            { type = "add" },
            { type = "change" },
            { type = "delete" }
          }
        end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = git_signs.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.equals(3, #result)
    end)
  end)

  describe("custom icons", function()
    it("uses custom icons from opts.icons", function()
      helpers.mock_gitsigns({
        get_hunks = function(bufnr)
          return { { type = "add" } }
        end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {
        icons = {
          added = "+",
          changed = "~",
          deleted = "-"
        }
      }
      local result = git_signs.provider(opts, ctx)

      assert.equals("+", result[1].text)
    end)

    it("uses default icons when not provided", function()
      helpers.mock_gitsigns({
        get_hunks = function(bufnr)
          return { { type = "add" } }
        end
      })

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = git_signs.provider(opts, ctx)

      assert.equals("│", result[1].text)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineGitAdded highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineGitAdded" then
          called = true
          assert.equals("#4caf50", highlights.fg)
        end
      end

      git_signs.setup_highlights()
      assert.is_true(called)
    end)

    it("sets up FancylineGitChanged highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineGitChanged" then
          called = true
          assert.equals("#ff9800", highlights.fg)
        end
      end

      git_signs.setup_highlights()
      assert.is_true(called)
    end)

    it("sets up FancylineGitDeleted highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineGitDeleted" then
          called = true
          assert.equals("#f44336", highlights.fg)
        end
      end

      git_signs.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
