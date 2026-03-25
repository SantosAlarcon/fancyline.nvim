local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local filetype = require("fancyline.components.filetype")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.filetype", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  it("returns nil for empty filetype", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.bo[1].filetype = ""

    local opts = {}
    local result = filetype.provider(opts, ctx)

    assert.is_nil(result)
  end)

  it("returns filetype name", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.bo[1].filetype = "lua"

    local opts = {}
    local result = filetype.provider(opts, ctx)

    assert.equals("lua", result.text)
    assert.equals("FancylineFiletype", result.highlight)
  end)

  it("returns lowercase when option is set", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.bo[1].filetype = "Lua"

    local opts = { lowercase = true }
    local result = filetype.provider(opts, ctx)

    assert.equals("lua", result.text)
  end)

  it("returns titlecase when option is set", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.bo[1].filetype = "lua"

    local opts = { titlecase = true }
    local result = filetype.provider(opts, ctx)

    assert.equals("Lua", result.text)
  end)

  it("returns custom icon from opts", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.bo[1].filetype = "lua"

    local opts = {
      icon = { symbol = "FT", fg = "#ff0000" }
    }
    local result = filetype.provider(opts, ctx)

    assert.equals("FT", result.icon.symbol)
    assert.equals("#ff0000", result.icon.fg)
  end)

  it("returns all config fields", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.bo[1].filetype = "lua"

    local opts = {
      icon = { symbol = "X" },
      style = "square",
      fg = "#fff",
      bg = "#000",
      border = { left = { style = "round", fg = "#f00" } }
    }
    local result = filetype.provider(opts, ctx)

    assert.equals("lua", result.text)
    assert.equals("X", result.icon.symbol)
    assert.equals("square", result.style)
    assert.equals("#fff", result.fg)
    assert.equals("#000", result.bg)
    assert.is_table(result.border)
  end)

  it("returns state as n", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.bo[1].filetype = "lua"

    local opts = {}
    local result = filetype.provider(opts, ctx)

    assert.equals("n", result.state)
  end)
end)
