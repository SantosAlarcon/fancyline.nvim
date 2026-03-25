local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local git_branch = require("fancyline.components.git_branch")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.git_branch", function()
  local mock_get_branch

  before_each(function()
    helpers.cleanup()
    vim.b = {}
    -- Mock the git utils
    local git = require("fancyline.utils.git")
    mock_get_branch = function() return nil end
    git.get_branch = function()
      return mock_get_branch()
    end
  end)

  after_each(function()
    helpers.cleanup()
    vim.b = {}
  end)

  it("returns nil when no branch is set", function()
    mock_get_branch = function() return nil end

    local opts = {
      icon = { symbol = "X" },
      style = "round",
    }
    local ctx = { bufnr = 1, winid = 1 }

    local result = git_branch.provider(opts, ctx)
    assert.is_nil(result)
  end)

  it("returns nil when branch is empty", function()
    mock_get_branch = function() return "" end

    local opts = {
      icon = { symbol = "X" },
      style = "round",
    }
    local ctx = { bufnr = 1, winid = 1 }

    local result = git_branch.provider(opts, ctx)
    assert.is_nil(result)
  end)

  it("returns branch text when branch is set", function()
    mock_get_branch = function() return "main" end

    local opts = {
      icon = { symbol = "X" },
      style = "round",
    }
    local ctx = { bufnr = 1, winid = 1 }

    local result = git_branch.provider(opts, ctx)
    assert.is_not_nil(result)
    assert.equals("main", result.text)
    assert.equals("X", result.icon.symbol)
    assert.equals("round", result.style)
    assert.equals("FancylineGitBranch", result.highlight)
  end)

  it("returns custom icon from opts", function()
    mock_get_branch = function() return "main" end

    local opts = {
      icon = { symbol = "BR", fg = "#ff0000", bg = "#0000ff" },
      style = "round",
    }
    local ctx = { bufnr = 1, winid = 1 }

    local result = git_branch.provider(opts, ctx)
    assert.equals("BR", result.icon.symbol)
    -- fg and bg come from top-level opts, not from icon table
    -- so result.icon.fg and result.icon.bg will be nil
    -- and result.fg and result.bg will also be nil (not passed at top level)
  end)

  it("returns all config fields", function()
    mock_get_branch = function() return "main" end

    local opts = {
      icon = { symbol = "X" },
      style = "round",
      fg = "#fff",
      bg = "#000",
      border = { left = { style = "round", fg = "#f00" } }
    }
    local ctx = { bufnr = 1, winid = 1 }

    local result = git_branch.provider(opts, ctx)
    assert.equals("#fff", result.fg)
    assert.equals("#000", result.bg)
    assert.is_table(result.border)
  end)

  it("returns state as clean", function()
    mock_get_branch = function() return "main" end

    local opts = {
      icon = { symbol = "X" },
    }
    local ctx = { bufnr = 1, winid = 1 }

    local result = git_branch.provider(opts, ctx)
    assert.is_string(result.state)
    assert.equals("clean", result.state)
  end)

  it("uses default icon when not specified", function()
    mock_get_branch = function() return "feature-branch" end

    local opts = {}
    local ctx = { bufnr = 1, winid = 1 }

    local result = git_branch.provider(opts, ctx)
    assert.is_not_nil(result)
    assert.equals(" ", result.icon.symbol)
  end)

  it("uses default style when not specified", function()
    mock_get_branch = function() return "main" end

    local opts = {}
    local ctx = { bufnr = 1, winid = 1 }

    local result = git_branch.provider(opts, ctx)
    assert.equals("none", result.style)
  end)
end)
