local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local diagnostics = require("fancyline.components.diagnostics")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.diagnostics", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  it("returns nil when no diagnostics", function()
    local diag = require("fancyline.utils.diagnostics")
    diag.get_counts = function() return { error = 0, warn = 0, info = 0, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = diagnostics.provider(opts, ctx)

    assert.is_nil(result)
  end)

  it("returns error section when errors present", function()
    local diag = require("fancyline.utils.diagnostics")
    diag.get_counts = function() return { error = 2, warn = 0, info = 0, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = diagnostics.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.is_true(#result >= 1)
    assert.equals(" 2", result[1].text)
    assert.equals("FancylineDiagError", result[1].highlight)
    assert.equals("none", result[1].style)
  end)

  it("returns warn section when warns present", function()
    local diag = require("fancyline.utils.diagnostics")
    diag.get_counts = function() return { error = 0, warn = 1, info = 0, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = diagnostics.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.is_true(#result >= 1)
    assert.equals(" 1", result[1].text)
    assert.equals("FancylineDiagWarn", result[1].highlight)
  end)

  it("returns info section when info present", function()
    local diag = require("fancyline.utils.diagnostics")
    diag.get_counts = function() return { error = 0, warn = 0, info = 1, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = diagnostics.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.is_true(#result >= 1)
    assert.equals(" 1", result[1].text)
    assert.equals("FancylineDiagInfo", result[1].highlight)
  end)

  it("returns hint section when hint present", function()
    local diag = require("fancyline.utils.diagnostics")
    diag.get_counts = function() return { error = 0, warn = 0, info = 0, hint = 1 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = diagnostics.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.is_true(#result >= 1)
    assert.equals("💡 1", result[1].text)
    assert.equals("FancylineDiagHint", result[1].highlight)
  end)

  it("returns multiple sections for multiple diagnostic types", function()
    local diag = require("fancyline.utils.diagnostics")
    diag.get_counts = function() return { error = 2, warn = 1, info = 1, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = diagnostics.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.equals(3, #result)
    -- First should be error (highest priority)
    assert.equals(" 2", result[1].text)
    assert.equals("FancylineDiagError", result[1].highlight)
    -- Second should be warn
    assert.equals(" 1", result[2].text)
    assert.equals("FancylineDiagWarn", result[2].highlight)
    -- Third should be info
    assert.equals(" 1", result[3].text)
    assert.equals("FancylineDiagInfo", result[3].highlight)
  end)

  it("returns custom icons from opts", function()
    local diag = require("fancyline.utils.diagnostics")
    diag.get_counts = function() return { error = 1, warn = 1, info = 0, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {
      icons = {
        error = "E",
        warn = "W",
        info = "I",
        hint = "H"
      }
    }
    local result = diagnostics.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.equals("E 1", result[1].text)
    assert.equals("W 1", result[2].text)
  end)

  it("returns sections with fg color", function()
    local diag = require("fancyline.utils.diagnostics")
    diag.get_counts = function() return { error = 1, warn = 0, info = 0, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = diagnostics.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("#f44336", result[1].fg)
  end)
end)
