local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local lsp_progress = require("fancyline.components.lsp_progress")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.lsp_progress", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  it("returns nil when lsp is not available", function()
    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = lsp_progress.provider(opts, ctx)

    assert.is_nil(result)
  end)

  it("returns nil when no progress messages", function()
    vim.lsp = {
      util = {
        get_progress_messages = function() return {} end
      }
    }

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = lsp_progress.provider(opts, ctx)

    assert.is_nil(result)
  end)

  it("returns spinner when progress message exists", function()
    vim.lsp = {
      util = {
        get_progress_messages = function()
          return {
            { name = "test-lsp", percentage = 50, title = "Indexing" }
          }
        end
      }
    }

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = lsp_progress.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.is_string(result.text)
    assert.equals("FancylineLspProgress", result.highlight)
    assert.equals("default", result.style)
    assert.contains(result.text, "50%")
    assert.contains(result.text, "Indexing")
  end)

  it("returns only spinner when no percentage", function()
    vim.lsp = {
      util = {
        get_progress_messages = function()
          return {
            { name = "test-lsp", title = "Loading" }
          }
        end
      }
    }

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = lsp_progress.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.contains(result.text, "Loading")
    assert.not_match("%%", result.text)
  end)

  it("returns custom style from opts", function()
    vim.lsp = {
      util = {
        get_progress_messages = function()
          return {
            { name = "test-lsp", percentage = 25 }
          }
        end
      }
    }

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { style = "none" }
    local result = lsp_progress.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("none", result.style)
  end)

  it("uses first message when multiple messages", function()
    vim.lsp = {
      util = {
        get_progress_messages = function()
          return {
            { name = "lsp-1", percentage = 75, title = "First" },
            { name = "lsp-2", percentage = 30, title = "Second" }
          }
        end
      }
    }

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = lsp_progress.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.contains(result.text, "First")
    assert.not_contains(result.text, "Second")
  end)
end)
