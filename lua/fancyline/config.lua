---@return FancylineConfig
return {
	sections = {
		left = { "mode", "git_branch", "git_diff" },
		center = { "file" },
		right = { "diagnostics", "lsp", "filetype", "position" },
	},

	components = {
		mode = {
			icon = "neovim",
			text = {
				n = "NORMAL",
				i = "INSERT",
				v = "VISUAL",
				V = "V-LINE",
				["^V"] = "V-BLOCK",
				t = "TERMINAL",
				["!"] = "TERMINAL",
				c = "COMMAND",
				r = "REPLACE",
				R = "V-REPLACE",
				rv = "V-REPLACE",
				s = "SELECT",
				S = "S-LINE",
				["^S"] = "S-BLOCK",
			},
			style = "round",
			colors = {},
		},
		git_branch = { icon = "", style = "none" },
		git_diff = { icon = "±", style = "none" },
		file = { icon = "󰈔", use_devicon = true, style = "square" },
		diagnostics = {
			icon = "󰅴",
			icons = { error = "", warn = "", info = "", hint = "💡" },
			style = "none",
		},
		lsp = {
			icon = "⚙",
			style = "round",
		},
		filetype = { icon = "󰘴", style = "square" },
		position = { icon = "󰁕", format = "Ln %l, Col %c", style = "round" },
	},

	style = {
		square = { left = "󰝤", right = "󰝤", icon_gap = " " },
		round = { left = "", right = "", icon_gap = " " },
		slanted = { left = "", right = "", icon_gap = " " },
		arrow = { left = "", right = "", icon_gap = " " },
		none = { left = "", right = "", icon_gap = " " },
	},

	separator = " │ ",

	refresh = {
		enabled = false,
		interval = 100,
	},

	highlights = {
		mode = "FancylineMode",
		git_branch = "FancylineGitBranch",
		git_diff = "FancylineGitDiff",
		file = "FancylineFile",
		diagnostics = "FancylineDiagnostics",
		filetype = "FancylineFiletype",
		position = "FancylinePosition",
		separator = "FancylineSeparator",
	},

	theme = "auto",

	extensions = {
		telescope = true,
		oil = true,
	},
}
