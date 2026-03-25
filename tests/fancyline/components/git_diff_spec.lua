local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local git_diff = require("fancyline.components.git_diff")
local helpers = require("tests.helpers.setup")

describe("fancyline.components.git_diff", function()
  local mock_get_diff_counts

  before_each(function()
    helpers.cleanup()
    -- Mock the git utils
    local git = require("fancyline.utils.git")
    mock_get_diff_counts = function() end
    git.get_diff_counts = function()
      return mock_get_diff_counts()
    end
  end)

  after_each(function()
    helpers.cleanup()
  end)

  it("returns nil when no diff", function()
    mock_get_diff_counts = function() return nil end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = git_diff.provider(opts, ctx)

    assert.is_nil(result)
  end)

  it("returns empty table when all counts are zero", function()
    mock_get_diff_counts = function() return { added = 0, changed = 0, untracked = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = git_diff.provider(opts, ctx)

    -- Component returns empty table when all counts are zero
    assert.is_table(result)
    assert.equals(0, #result)
  end)

  it("returns added section when added changes present", function()
    mock_get_diff_counts = function() return { added = 2, changed = 0, untracked = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = git_diff.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.is_true(#result >= 1)
    assert.equals(" 2", result[1].text)
    assert.equals("FancylineGitAdded", result[1].highlight)
    assert.equals("none", result[1].style)
  end)

  it("returns changed section when changes present", function()
    mock_get_diff_counts = function() return { added = 0, changed = 1, untracked = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = git_diff.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.is_true(#result >= 1)
    assert.equals(" 1", result[1].text)
    assert.equals("FancylineGitChanged", result[1].highlight)
  end)

  it("returns untracked section when untracked files present", function()
    mock_get_diff_counts = function() return { added = 0, changed = 0, untracked = 3 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = git_diff.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.is_true(#result >= 1)
    assert.equals(" 3", result[1].text)
    assert.equals("FancylineGitUntracked", result[1].highlight)
  end)

  it("returns multiple sections for multiple diff types", function()
    mock_get_diff_counts = function() return { added = 2, changed = 1, untracked = 3 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = git_diff.provider(opts, ctx)

    assert.is_not_nil(result)
    assert.is_table(result)
    assert.equals(3, #result)
    assert.equals(" 2", result[1].text)
    assert.equals("FancylineGitAdded", result[1].highlight)
    assert.equals(" 1", result[2].text)
    assert.equals("FancylineGitChanged", result[2].highlight)
    assert.equals(" 3", result[3].text)
    assert.equals("FancylineGitUntracked", result[3].highlight)
  end)

  it("does not have icon field in result", function()
    mock_get_diff_counts = function() return { added = 1, changed = 0, untracked = 0 } end

    local ctx = { bufnr = 1, winid = 1 }
    local opts = {}
    local result = git_diff.provider(opts, ctx)

    assert.is_nil(result[1].icon)
  end)
end)
