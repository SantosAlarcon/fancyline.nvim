local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local warnings = require("fancyline.components.warnings")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.warnings", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  it("returns nil when no warnings", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 0, info = 0, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = warnings.provider(opts, ctx)

    assert.is_nil(result)
  end)

  it("returns warning section when warnings present", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 3, info = 0, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = warnings.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.equals("󰀦 3", result.text)
    assert.equals("FancylineDiagWarn", result.highlight)
    assert.equals("#ff9800", result.fg)
    assert.equals("none", result.style)
  end)

  it("returns custom icon from opts", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 1, info = 0, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { icon = "W" }
    local result = warnings.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("W 1", result.text)
  end)

  it("returns custom style from opts", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 1, info = 0, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { style = "round" }
    local result = warnings.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("round", result.style)
  end)

  it("returns vscode icon when preset", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 2, info = 0, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { icon = "" }
    local result = warnings.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals(" 2", result.text)
  end)
end)
