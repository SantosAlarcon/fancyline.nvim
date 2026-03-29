local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local lsp_clients = require("fancyline.components.lsp_clients")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.lsp_clients", function()
  before_each(function()
    helpers.cleanup()
    package.loaded["lspconfig.util"] = nil
  end)

  after_each(function()
    helpers.cleanup()
    package.loaded["lspconfig.util"] = nil
  end)

  describe("basic functionality", function()
    it("returns nil when no active clients", function()
      helpers.mock_lsp({})
      helpers.mock_lspconfig(false)
      helpers.mock_filetype(1, "lua")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = lsp_clients.provider(opts, ctx)

      assert.is_nil(result)
    end)

    it("returns client names when clients are active", function()
      helpers.mock_lsp({
        { name = "lua_ls", config = { filetypes = { "lua" } } },
        { name = "tsserver", config = { filetypes = { "javascript" } } }
      })
      helpers.mock_lspconfig(false)
      helpers.mock_filetype(1, "lua")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = lsp_clients.provider(opts, ctx)

      assert.is_not_nil(result)
      assert.is_true(result.text:match("lua_ls") ~= nil)
      assert.equals("FancylineLspClients", result.highlight)
    end)

    it("shows version when available", function()
      helpers.mock_lsp({
        { name = "lua_ls", version = "1.2.3", config = { filetypes = { "lua" } } }
      })
      helpers.mock_lspconfig(false)
      helpers.mock_filetype(1, "lua")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = lsp_clients.provider(opts, ctx)

      assert.is_true(result.text:match("1.2") ~= nil)
    end)
  end)

  describe("max_clients option", function()
    it("limits displayed clients", function()
      helpers.mock_lsp({
        { name = "client1", config = { filetypes = { "lua" } } },
        { name = "client2", config = { filetypes = { "lua" } } },
        { name = "client3", config = { filetypes = { "lua" } } },
        { name = "client4", config = { filetypes = { "lua" } } }
      })
      helpers.mock_lspconfig(false)
      helpers.mock_filetype(1, "lua")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { max_clients = 2 }
      local result = lsp_clients.provider(opts, ctx)

      assert.is_true(result.text:match("%+2") ~= nil)
    end)
  end)

  describe("show_version option", function()
    it("hides version when disabled", function()
      helpers.mock_lsp({
        { name = "lua_ls", version = "1.0.0", config = { filetypes = { "lua" } } }
      })
      helpers.mock_lspconfig(false)
      helpers.mock_filetype(1, "lua")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { show_version = false }
      local result = lsp_clients.provider(opts, ctx)

      assert.equals("lua_ls", result.text)
    end)
  end)

  describe("icon configuration", function()
    it("returns default icon symbol", function()
      helpers.mock_lsp({
        { name = "lua_ls", config = { filetypes = { "lua" } } }
      })
      helpers.mock_lspconfig(false)
      helpers.mock_filetype(1, "lua")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = {}
      local result = lsp_clients.provider(opts, ctx)

      assert.equals(" ", result.icon.symbol)
    end)

    it("uses string icon from opts.icon", function()
      helpers.mock_lsp({
        { name = "lua_ls", config = { filetypes = { "lua" } } }
      })
      helpers.mock_lspconfig(false)
      helpers.mock_filetype(1, "lua")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = "LSP" }
      local result = lsp_clients.provider(opts, ctx)

      assert.equals("LSP", result.icon.symbol)
    end)

    it("uses table icon from opts.icon", function()
      helpers.mock_lsp({
        { name = "lua_ls", config = { filetypes = { "lua" } } }
      })
      helpers.mock_lspconfig(false)
      helpers.mock_filetype(1, "lua")

      local ctx = { bufnr = 1, winid = 1 }
      local opts = { icon = { symbol = "L", fg = "#ff0000" } }
      local result = lsp_clients.provider(opts, ctx)

      assert.equals("L", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)
  end)

  describe("setup_highlights", function()
    it("sets up FancylineLspClients highlight", function()
      local called = false
      vim.api.nvim_set_hl = function(namespace, name, highlights)
        if name == "FancylineLspClients" then
          called = true
          assert.equals("#4caf50", highlights.fg)
          assert.equals(false, highlights.bold)
        end
      end

      lsp_clients.setup_highlights()
      assert.is_true(called)
    end)
  end)
end)
