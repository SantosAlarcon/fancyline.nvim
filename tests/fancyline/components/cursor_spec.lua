local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local cursor = require("fancyline.components.cursor")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.cursor", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  it("returns formatted cursor position", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.fn.line = function() return 42 end
    vim.fn.col = function() return 15 end
    vim.api.nvim_buf_line_count = function() return 100 end

    local opts = { format = "Ln %l, Col %c" }
    local result = cursor.provider(opts, ctx)

    assert.equals("Ln 42, Col 15", result.text)
    assert.equals("FancylineCursor", result.highlight)
  end)

  it("returns total lines with %L", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.fn.line = function() return 10 end
    vim.fn.col = function() return 5 end
    vim.api.nvim_buf_line_count = function() return 250 end

    local opts = { format = "Lines: %L" }
    local result = cursor.provider(opts, ctx)

    assert.equals("Lines: 250", result.text)
  end)

  it("returns percentage with %p", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.fn.line = function() return 25 end
    vim.fn.col = function() return 1 end
    vim.api.nvim_buf_line_count = function() return 100 end

    local opts = { format = "%p%%" }
    local result = cursor.provider(opts, ctx)

    assert.equals("25%", result.text)
  end)

  it("uses default format when not provided", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.fn.line = function() return 1 end
    vim.fn.col = function() return 1 end
    vim.api.nvim_buf_line_count = function() return 100 end

    local opts = {}
    local result = cursor.provider(opts, ctx)

    assert.equals("Ln 1, Col 1", result.text)
  end)

  it("returns icon from opts", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.fn.line = function() return 5 end
    vim.fn.col = function() return 3 end
    vim.api.nvim_buf_line_count = function() return 20 end

    local opts = {
      icon = { symbol = "X", fg = "#ff0000" },
      format = "Ln %l"
    }
    local result = cursor.provider(opts, ctx)

    assert.equals("X", result.icon.symbol)
    assert.equals("#ff0000", result.icon.fg)
  end)

  it("returns all config fields", function()
    local ctx = { bufnr = 1, winid = 1 }
    vim.fn.line = function() return 1 end
    vim.fn.col = function() return 1 end
    vim.api.nvim_buf_line_count = function() return 100 end

    local opts = {
      icon = { symbol = "X" },
      style = "none",
      fg = "#fff",
      bg = "#000",
      format = "%l:%c",
      border = { left = { style = "round", fg = "#f00" } }
    }
    local result = cursor.provider(opts, ctx)

    assert.equals("X", result.icon.symbol)
    assert.equals("none", result.style)
    assert.equals("#fff", result.fg)
    assert.equals("#000", result.bg)
    assert.is_table(result.border)
    assert.equals("n", result.state)
  end)
end)
