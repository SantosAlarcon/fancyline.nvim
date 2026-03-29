local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local hints = require("fancyline.components.hints")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.hints", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  it("returns nil when no hints", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 0, info = 0, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = hints.provider(opts, ctx)

    assert.is_nil(result)
  end)

  it("returns hint section when hints present", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 0, info = 0, hint = 5 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = hints.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.equals("󰛿 5", result.text)
    assert.equals("FancylineDiagHint", result.highlight)
    assert.equals("#61afef", result.fg)
    assert.equals("none", result.style)
  end)

  it("returns custom icon from opts", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 0, info = 0, hint = 1 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { icon = "H" }
    local result = hints.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("H 1", result.text)
  end)

  it("returns custom style from opts", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 0, info = 0, hint = 1 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { style = "round" }
    local result = hints.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("round", result.style)
  end)

  it("returns vscode icon when preset", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 0, info = 0, hint = 3 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { icon = "" }
    local result = hints.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals(" 3", result.text)
  end)
end)
