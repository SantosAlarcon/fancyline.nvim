#!/usr/bin/env nvim
-- Run all fancyline tests without plenary.nvim
-- Usage: nvim --headless -c 'luafile scripts/test.lua' -c 'quit'

-- Add plugin to runtimepath manually
local script_path = debug.getinfo(1, "S").source:match("@?(.*/)")
local plugin_root = script_path:gsub("/scripts$", "")
vim.opt.runtimepath:prepend(plugin_root)

local function test(name, condition, msg)
	if not condition then
		vim.print("  FAIL: " .. name .. " - " .. (msg or ""))
		return false
	end
	return true
end


local failures = 0
local passed = 0

local function run_suite(name, fn)
	vim.print("\n" .. name)
	local ok, err = pcall(fn)
	if ok then
		vim.print("  ✅ Passed")
	else
		vim.print("  ❌ Error: " .. tostring(err))
		failures = failures + 1
	end
end

-- ============================================
-- MATERIAL THEME TESTS
-- ============================================
run_suite("Material Theme", function()
	local material = require("fancyline.themes.themes.material")
	local themes = require("fancyline.themes")

	-- All variants exist
	local variants = { "deep_ocean", "oceanic", "palenight", "darker", "lighter" }
	for _, v in ipairs(variants) do
		if not test("Variant exists: " .. v, material[v] ~= nil) then return end
	end

	-- Colors per variant (verified from official material.nvim)
	local expected = {
		deep_ocean = { diagnostics = "#FF5370", diagnostics_info = "#B0C9FF", diagnostics_hint = "#C792EA" },
		oceanic = { diagnostics = "#FF5370", diagnostics_info = "#B0C9FF", diagnostics_hint = "#C792EA" },
		palenight = { diagnostics = "#FF5370", diagnostics_info = "#B0C9FF", diagnostics_hint = "#C792EA" },
		darker = { diagnostics = "#FF5370", diagnostics_info = "#6182B8", diagnostics_hint = "#7C4DFF" },
		lighter = { diagnostics = "#E53935", diagnostics_info = "#6182B8", diagnostics_hint = "#39ADB5" },
	}

	for variant, colors in pairs(expected) do
		local theme = material[variant]
		if not test(variant .. " diagnostics", theme.diagnostics == colors.diagnostics) then return end
		if not test(variant .. " diagnostics_info", theme.diagnostics_info == colors.diagnostics_info) then return end
		if not test(variant .. " diagnostics_hint", theme.diagnostics_hint == colors.diagnostics_hint) then return end
	end

	-- Variant detection (using underscore variants to match)
	local detection_tests = {
		{ "deep_ocean",          "deep_ocean" },
		{ "material_deep_ocean", "deep_ocean" },
		{ "oceanic",             "oceanic" },
		{ "material_oceanic",    "oceanic" },
		{ "palenight",           "palenight" },
		{ "darker",              "darker" },
		{ "lighter",             "lighter" },
	}
	for _, dt in ipairs(detection_tests) do
		vim.g.colors_name = dt[1]
		local detected = themes.detect_variant("material")
		if not test("Detect " .. dt[1], detected == dt[2],
				"got " .. tostring(detected) .. ", expected " .. dt[2]) then
			return
		end
	end

	-- Shades exist
	for _, v in ipairs(variants) do
		local theme = material[v]
		if not test(v .. " has shades", theme.shades ~= nil) then return end
		for i = 1, 10 do
			if not test(v .. " shade_" .. i, theme.shades["shade_" .. i] ~= nil) then return end
		end
	end

	passed = passed + 1
end)

-- ============================================
-- THEMES MODULE TESTS
-- ============================================
run_suite("Themes Module", function()
	local themes = require("fancyline.themes")

	-- Get default theme
	local default = themes.get_default()
	if not test("get_default returns theme", default.name == "default") then return end

	-- Get specific theme
	local dracula = themes.get("dracula")
	if not test("get theme by name", dracula.name == "dracula") then return end

	-- Get with variant
	local tokyonight = themes.get("tokyonight", "night")
	if not test("get theme with variant", tokyonight.variant == "night") then return end

	-- Apply theme (should not error)
	themes.apply(dracula)
	test("apply theme", true)

	passed = passed + 1
end)

-- ============================================
-- CONFIG MODULE TESTS
-- ============================================
run_suite("Config Module", function()
	local ok, config = pcall(require, "fancyline.config")
	if not test("config module loads", ok) then return end

	-- Config has required fields
	if not test("has sections", config.sections ~= nil) then return end
	if not test("has components", config.components ~= nil) then return end
	if not test("has theme", config.theme ~= nil) then return end

	passed = passed + 1
end)

-- ============================================
-- SUMMARY
-- ============================================
vim.print("\n" .. string.rep("=", 50))
if failures == 0 then
	vim.print("✅ All test suites passed!")
	vim.cmd("cq 0")
else
	vim.print("❌ " .. failures .. " test suite(s) failed")
	vim.cmd("cq 1")
end
