local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local mode = require("fancyline.components.mode")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.mode", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("table-based config", function()
    it("returns mode text from config", function()
      local opts = {
        icon = "X",
        text = {
          n = "NORMAL",
          i = "INSERT",
        },
        style = "round",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.equals("NORMAL", result.text)
      assert.equals("round", result.style)
      assert.equals("FancylineModeNormal", result.highlight)
    end)

    it("returns INSERT for insert mode", function()
      local opts = {
        icon = "X",
        text = {
          n = "NORMAL",
          i = "INSERT",
        },
        style = "square",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("i")

      local result = mode.provider(opts, ctx)
      assert.equals("INSERT", result.text)
      assert.equals("square", result.style)
      assert.equals("FancylineModeInsert", result.highlight)
    end)

    it("returns mode string if not in config", function()
      local opts = {
        icon = "X",
        text = {},
        style = "square",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("x")

      local result = mode.provider(opts, ctx)
      assert.equals("x", result.text)
      assert.equals("FancylineModeNormal", result.highlight)
    end)

    it("returns icon as table with symbol", function()
      local opts = {
        icon = "X",
        text = { n = "NORMAL" },
        style = "round",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.equals("X", result.icon.symbol)
    end)

    it("returns fg and bg from opts", function()
      local opts = {
        icon = "X",
        text = { n = "NORMAL" },
        style = "round",
        fg = "#ff0000",
        bg = "#0000ff",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.equals("#ff0000", result.fg)
      assert.equals("#0000ff", result.bg)
    end)

    it("returns border config from opts", function()
      local opts = {
        icon = "X",
        text = { n = "NORMAL" },
        style = "round",
        border = {
          left = { style = "round", fg = "#ff0000" },
          right = { style = "round", fg = "#00ff00" }
        }
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.is_table(result.border)
      assert.equals("round", result.border.left.style)
      assert.equals("#ff0000", result.border.left.fg)
    end)

    it("returns state as current mode", function()
      local opts = {
        icon = "X",
        text = { n = "NORMAL" },
        style = "round",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("i")

      local result = mode.provider(opts, ctx)
      assert.equals("i", result.state)
    end)

    it("uses icon colors from opts.icon", function()
      local opts = {
        icon = { symbol = "X", fg = "#ff0000", bg = "#0000ff" },
        text = { n = "NORMAL" },
        style = "round",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.equals("#ff0000", result.icon.fg)
      assert.equals("#0000ff", result.icon.bg)
    end)
  end)

  describe("function-based config", function()
    it("accepts function as component config", function()
      local opts = function(mode_name)
        if mode_name == "n" then
          return {
            text = "NORMAL",
            icon = "X",
            style = "round",
          }
        end
        return nil
      end
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.is_not_nil(result)
      assert.equals("NORMAL", result.text)
      assert.equals("round", result.style)
    end)

    it("returns custom fg and bg from function", function()
      local opts = function(mode_name)
        return {
          text = "INSERT",
          icon = "X",
          fg = "#FFFFFF",
          bg = "#98C379",
          style = "round",
        }
      end
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("i")

      local result = mode.provider(opts, ctx)
      assert.equals("#FFFFFF", result.fg)
      assert.equals("#98C379", result.bg)
    end)

    it("returns nil when function returns nil", function()
      local opts = function(mode_name)
        return nil
      end
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.is_nil(result)
    end)

    it("can define different configs per mode", function()
      local opts = function(mode_name)
        local configs = {
          n = { text = "NORMAL", icon = "N", fg = "#0000FF", bg = "#000033", style = "round" },
          i = { text = "INSERT", icon = "I", fg = "#00FF00", bg = "#003300", style = "round" },
          v = { text = "VISUAL", icon = "V", fg = "#FF00FF", bg = "#330033", style = "round" },
        }
        return configs[mode_name]
      end
      local ctx = { bufnr = 1, winid = 1 }

      -- Test NORMAL mode
      helpers.mock_vim_fn("n")
      local result = mode.provider(opts, ctx)
      assert.equals("NORMAL", result.text)
      assert.equals("#0000FF", result.fg)
      assert.equals("#000033", result.bg)

      -- Test INSERT mode
      helpers.mock_vim_fn("i")
      result = mode.provider(opts, ctx)
      assert.equals("INSERT", result.text)
      assert.equals("#00FF00", result.fg)
      assert.equals("#003300", result.bg)
    end)
  end)

  describe("legacy icon handling", function()
    it("handles neovim icon special value", function()
      local opts = {
        icon = "neovim",
        text = { n = "NORMAL" },
        style = "round",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.equals("", result.icon.symbol)
    end)

    it("handles vim icon special value", function()
      local opts = {
        icon = "vim",
        text = { n = "NORMAL" },
        style = "round",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.equals("", result.icon.symbol)
    end)

    it("handles false icon to hide it", function()
      local opts = {
        icon = false,
        text = { n = "NORMAL" },
        style = "round",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.equals("", result.icon.symbol)
    end)

    it("handles icon table with symbol string", function()
      local opts = {
        icon = { symbol = "X", fg = "#ff0000" },
        text = { n = "NORMAL" },
        style = "round",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.equals("X", result.icon.symbol)
      assert.equals("#ff0000", result.icon.fg)
    end)
  end)

  describe("icon colors", function()
    it("icon inherits mode color when no fg specified", function()
      local opts = {
        icon = "neovim",
        text = { n = "NORMAL" },
        style = "round",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      -- icon.fg should be resolved to mode color by renderer, not by component
      assert.is_not_nil(result.icon.fg)
    end)

    it("icon uses custom fg when specified", function()
      local opts = {
        icon = { symbol = "X", fg = "#ff0000" },
        text = { n = "NORMAL" },
        style = "round",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.equals("#ff0000", result.icon.fg)
    end)

    it("icon uses custom bg when specified", function()
      local opts = {
        icon = { symbol = "X", bg = "#0000ff" },
        text = { n = "NORMAL" },
        style = "round",
      }
      local ctx = { bufnr = 1, winid = 1 }

      helpers.mock_vim_fn("n")

      local result = mode.provider(opts, ctx)
      assert.equals("#0000ff", result.icon.bg)
    end)
  end)
end)
