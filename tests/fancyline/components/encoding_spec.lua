local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local encoding = require("fancyline.components.encoding")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.encoding", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  it("returns encoding with default icon", function()
    vim.opt_local.fileencoding = "utf-8"

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = encoding.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.equals("󰈔 UTF-8", result.text)
    assert.equals("FancylineEncoding", result.highlight)
    assert.equals("none", result.style)
  end)

  it("returns uppercase encoding", function()
    vim.opt_local.fileencoding = "latin1"

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = encoding.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("LATIN1", result.text:match(".*%s+(.*)"))
  end)

  it("returns UTF-8 when fileencoding is empty", function()
    vim.opt_local.fileencoding = ""

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = encoding.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("UTF-8", result.text:match(".*%s+(.*)"))
  end)

  it("returns custom icon from opts", function()
    vim.opt_local.fileencoding = "utf-8"

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { icon = "" }
    local result = encoding.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals(" UTF-8", result.text)
  end)

  it("returns empty icon for vscode preset", function()
    vim.opt_local.fileencoding = "utf-8"

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { icon = "" }
    local result = encoding.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals(" UTF-8", result.text)
  end)

  it("returns custom style from opts", function()
    vim.opt_local.fileencoding = "utf-8"

    local ctx = { bufnr = 1, winid = 1 }
    local opts = { style = "round" }
    local result = encoding.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.equals("round", result.style)
  end)
end)
