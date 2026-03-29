local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local indent = require("fancyline.components.indent")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.indent", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  it("returns spaces with default icon", function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = indent.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.equals("󰌒 spaces: 2", result.text)
    assert.equals("FancylineIndent", result.highlight)
    assert.equals("none", result.style)
  end)

  it("returns tabs when expandtab is false", function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = indent.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("󰌒 tabs: 4", result.text)
  end)

  it("returns spaces with different shiftwidth", function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = indent.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("󰌒 spaces: 4", result.text)
  end)

  it("returns custom style from opts", function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { style = "round" }
    local result = indent.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("round", result.style)
  end)
end)
