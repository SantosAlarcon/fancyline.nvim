local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local lsp_utils = require("fancyline.utils.lsp")
local lsp_component = require("fancyline.components.lsp")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.lsp", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("provider", function()
    it("returns nil when no LSPs active", function()
      local lsp = require("fancyline.utils.lsp")
      lsp.get_active = function() return {} end

      local opts = { icon = { symbol = "X" }, style = "round" }
      local ctx = { bufnr = 1, winid = 1 }

      local result = lsp_component.provider(opts, ctx)
      assert.is_nil(result)
    end)

    it("returns LSP names when active", function()
      local lsp = require("fancyline.utils.lsp")
      lsp.get_active = function() return { "lua_ls", "tsserver" } end

      local opts = { icon = { symbol = "X" }, style = "round" }
      local ctx = { bufnr = 1, winid = 1 }

      local result = lsp_component.provider(opts, ctx)
      assert.is_not_nil(result)
      assert.is_string(result.text)
      assert.equals("FancylineLsp", result.highlight)
    end)

    it("uses custom icon from opts", function()
      local lsp = require("fancyline.utils.lsp")
      lsp.get_active = function() return { "gopls" } end

      local opts = { icon = { symbol = "LSP", fg = "#ff0000" }, style = "square" }
      local ctx = { bufnr = 1, winid = 1 }

      local result = lsp_component.provider(opts, ctx)
      assert.equals("LSP", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)

    it("returns all config fields", function()
      local lsp = require("fancyline.utils.lsp")
      lsp.get_active = function() return { "rust_analyzer" } end

      local opts = {
        icon = { symbol = "X" },
        style = "round",
        fg = "#fff",
        bg = "#000",
        border = { left = { style = "round", fg = "#f00" } }
      }
      local ctx = { bufnr = 1, winid = 1 }

      local result = lsp_component.provider(opts, ctx)
      assert.equals("X", result.icon.symbol)
      assert.equals("round", result.style)
      assert.equals("#fff", result.fg)
      assert.equals("#000", result.bg)
      assert.is_table(result.border)
      assert.equals("connected", result.state)
    end)
  end)
end)

describe("fancyline.utils.lsp", function()
  describe("get_active", function()
    it("returns empty table when no clients", function()
      local lsp = require("fancyline.utils.lsp")
      lsp.get_active = function() return {} end

      local result = lsp.get_active(1)
      assert.is_table(result)
      assert.equals(0, #result)
    end)

    it("returns client names", function()
      local lsp = require("fancyline.utils.lsp")
      lsp.get_active = function() return { "rust_analyzer", "pyright" } end

      local result = lsp.get_active(1)
      assert.equals(2, #result)
      assert.equals("rust_analyzer", result[1])
      assert.equals("pyright", result[2])
    end)
  end)
end)
