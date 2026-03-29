local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local infos = require("fancyline.components.infos")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.infos", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  it("returns nil when no infos", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 0, info = 0, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = infos.provider(opts, ctx)

    assert.is_nil(result)
  end)

  it("returns info section when infos present", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 0, info = 4, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = infos.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.equals("󰀿 4", result.text)
    assert.equals("FancylineDiagInfo", result.highlight)
    assert.equals("#56b6c2", result.fg)
    assert.equals("none", result.style)
  end)

  it("returns custom icon from opts", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 0, info = 1, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { icon = "I" }
    local result = infos.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("I 1", result.text)
  end)

  it("returns custom style from opts", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 0, info = 1, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { style = "round" }
    local result = infos.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("round", result.style)
  end)

  it("returns vscode icon when preset", function()
    local diag_utils = require("fancyline.utils.diagnostics")
    diag_utils.get_counts = function() return { error = 0, warn = 0, info = 2, hint = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { icon = "" }
    local result = infos.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals(" 2", result.text)
  end)
end)
