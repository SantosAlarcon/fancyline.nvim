local lua_path = vim.api.nvim_get_runtime_file("lua/fancyline/init.lua", false)[1]
if lua_path then
  vim.opt.runtimepath:prepend(vim.fn.fnamemodify(lua_path, ":h:h"))
end

local helpers = require("tests.helpers.setup")

describe("fancyline", function()
  before_each(function()
    helpers.cleanup()
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("setup", function()
    it("creates statusline option", function()
      require("fancyline").setup()
      assert.is_string(vim.o.statusline)
      assert.is_true(vim.o.statusline:match("fancyline") ~= nil)
    end)

    it("accepts custom config with theme", function()
      require("fancyline").setup({
        theme = "dracula",
        sections = {
          left = { "mode" },
          center = {},
          right = { "cursor" },
        },
      })
      local config = require("fancyline").get_config()
      assert.equals("dracula", config.theme)
    end)

    it("accepts custom config with sections", function()
      require("fancyline").setup({
        sections = {
          left = { "mode", "git_branch" },
          center = { "file" },
          right = { "diagnostics", "lsp", "filetype", "cursor" },
        },
      })
      local config = require("fancyline").get_config()
      assert.equals("mode", config.sections.left[1])
      assert.equals("git_branch", config.sections.left[2])
      assert.equals("lsp", config.sections.right[2])
    end)

    it("sets default config values", function()
      require("fancyline").setup({})
      local config = require("fancyline").get_config()
      assert.is_not_nil(config.sections)
      assert.is_not_nil(config.components)
      assert.is_not_nil(config.refresh)
    end)

    it("creates Fancyline autocmd group", function()
      require("fancyline").setup()
      local exists = pcall(vim.api.nvim_get_autocmds, { group = "Fancyline" })
      assert.is_true(exists)
    end)
  end)

  describe("enable/disable", function()
    it("can disable statusline", function()
      require("fancyline").setup()
      require("fancyline").disable()
      assert.equals("", vim.o.statusline)
    end)

    it("can re-enable after disable", function()
      require("fancyline").setup()
      require("fancyline").disable()
      require("fancyline").enable()
      assert.is_true(vim.o.statusline:match("fancyline") ~= nil)
    end)

    it("enable does nothing if already enabled", function()
      require("fancyline").setup()
      local statusline_before = vim.o.statusline
      require("fancyline").enable()
      assert.equals(statusline_before, vim.o.statusline)
    end)

    it("disable sets statusline to empty string", function()
      require("fancyline").setup()
      require("fancyline").disable()
      assert.equals("", vim.o.statusline)
    end)
  end)

  describe("render", function()
    it("returns string", function()
      require("fancyline").setup()
      local result = require("fancyline").render()
      assert.is_string(result)
    end)

    it("returns empty string when not enabled", function()
      require("fancyline").disable()
      local result = require("fancyline").render()
      assert.equals("", result)
    end)

    it("render includes vim statusline format sequences", function()
      require("fancyline").setup()
      local result = require("fancyline").render()
      assert.is_true(result:match("%%#") ~= nil)
    end)
  end)

  describe("get_config", function()
    it("returns current configuration", function()
      require("fancyline").setup({
        theme = "tokyonight",
        separator = " | ",
      })
      local config = require("fancyline").get_config()
      assert.is_table(config)
      assert.equals("tokyonight", config.theme)
      assert.equals(" | ", config.separator)
    end)

    it("returns empty config before setup", function()
      local config = require("fancyline").get_config()
      assert.is_table(config)
    end)
  end)

  describe("refresh", function()
    it("refresh does not error when called after setup", function()
      require("fancyline").setup()
      require("fancyline").refresh()
    end)

    it("refresh does nothing when not enabled", function()
      require("fancyline").refresh()
    end)
  end)

  describe("reload", function()
    it("reload does not error when called after setup", function()
      require("fancyline").setup()
      require("fancyline").reload()
    end)

    it("reload recreates highlights", function()
      require("fancyline").setup()
      require("fancyline").reload()
      local mode_hl = vim.api.nvim_get_hl(0, { name = "FancylineMode" })
      assert.is_not_nil(mode_hl)
    end)
  end)

  describe("set_preset", function()
    it("changes preset successfully", function()
      require("fancyline").setup({ preset = "default" })
      local result = require("fancyline").set_preset("minimal")
      assert.is_true(result)
      local config = require("fancyline").get_config()
      assert.equals("minimal", config.preset)
    end)

    it("returns false for unknown preset", function()
      require("fancyline").setup({ preset = "default" })
      local result = require("fancyline").set_preset("nonexistent-preset")
      assert.is_false(result)
    end)

    it("returns false for empty preset name", function()
      require("fancyline").setup({ preset = "default" })
      local result = require("fancyline").set_preset("")
      assert.is_false(result)
    end)

    it("returns false for nil preset name", function()
      require("fancyline").setup({ preset = "default" })
      local result = require("fancyline").set_preset(nil)
      assert.is_false(result)
    end)

    it("updates sections when preset changes", function()
      require("fancyline").setup({ preset = "default" })
      local default_config = require("fancyline").get_config()
      require("fancyline").set_preset("minimal")
      local new_config = require("fancyline").get_config()
      assert.is_true(#new_config.sections.left <= #default_config.sections.left)
    end)
  end)

  describe("themes", function()
    it("applies theme highlight on setup", function()
      require("fancyline").setup({ theme = "dracula" })
      local mode_hl = vim.api.nvim_get_hl(0, { name = "FancylineModeNormal" })
      assert.is_not_nil(mode_hl)
      assert.is_not_nil(mode_hl.fg)
    end)

    it("applies auto theme based on colorscheme", function()
      require("fancyline").setup({ theme = "auto" })
      local config = require("fancyline").get_config()
      assert.equals("auto", config.theme)
    end)
  end)

  describe("extensions", function()
    it("sets up extensions when enabled", function()
      require("fancyline").setup({
        extensions = {
          telescope = true,
          oil = true,
        },
      })
      local config = require("fancyline").get_config()
      assert.is_true(config.extensions.telescope)
      assert.is_true(config.extensions.oil)
    end)

    it("works without extensions", function()
      require("fancyline").setup({
        extensions = {},
      })
      local config = require("fancyline").get_config()
      assert.is_table(config.extensions)
    end)
  end)

  describe("refresh timer", function()
    it("creates refresh timer when enabled", function()
      require("fancyline").setup({
        refresh = {
          enabled = true,
          interval = 100,
        },
      })
      local config = require("fancyline").get_config()
      assert.is_true(config.refresh.enabled)
      assert.equals(100, config.refresh.interval)
    end)

    it("does not create timer when disabled", function()
      require("fancyline").setup({
        refresh = {
          enabled = false,
        },
      })
      local config = require("fancyline").get_config()
      assert.is_false(config.refresh.enabled)
    end)
  end)
end)
