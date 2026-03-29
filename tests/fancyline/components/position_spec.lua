local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local position = require("fancyline.components.position")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.position", function()
  before_each(function()
    helpers.cleanup()
    helpers.mock_buf_line_count(1, 100)
  end)

  after_each(function()
    helpers.cleanup()
  end)

  it("returns position with default format", function()
    vim.fn.line = function() return 42 end
    vim.fn.col = function() return 15 end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = position.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.equals("Ln 42, Col 15", result.text)
    assert.equals("FancylinePosition", result.highlight)
    assert.equals("none", result.style)
    assert.is_table(result.icon)
  end)

  it("returns custom format from opts", function()
    vim.fn.line = function() return 10 end
    vim.fn.col = function() return 5 end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { format = "L%l:C%c" }
    local result = position.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("L10:C5", result.text)
  end)

  it("supports all format placeholders", function()
    vim.fn.line = function() return 50 end
    vim.fn.col = function() return 25 end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { format = "L%l C%c T%L P%p%%P" }
    local result = position.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("L50 C25 T100 P50%50%", result.text)
  end)

  it("returns custom icon from opts", function()
    vim.fn.line = function() return 1 end
    vim.fn.col = function() return 1 end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { icon = "󰀹" }
    local result = position.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result.icon)
    assert.equals("󰀹", result.icon.symbol)
  end)

  it("returns icon as table with symbol, fg, bg", function()
    vim.fn.line = function() return 1 end
    vim.fn.col = function() return 1 end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { icon = { symbol = "P", fg = "#ffffff", bg = "#000000" } }
    local result = position.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result.icon)
    assert.equals("P", result.icon.symbol)
    assert.equals("#ffffff", result.icon.fg)
    assert.equals("#000000", result.icon.bg)
  end)

  it("returns custom style from opts", function()
    vim.fn.line = function() return 1 end
    vim.fn.col = function() return 1 end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { style = "round" }
    local result = position.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("round", result.style)
  end)

  it("returns vscode preset icon", function()
    vim.fn.line = function() return 42 end
    vim.fn.col = function() return 15 end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { icon = "󰀹", style = "none" }
    local result = position.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("Ln 42, Col 15", result.text)
    assert.equals("none", result.style)
  end)
end)
