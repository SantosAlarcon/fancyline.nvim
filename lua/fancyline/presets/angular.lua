---@type FancylineConfig
return {
	separator = " ",
	sections = {
		left = { "mode", "file", "git_branch", "git_diff" },
		center = {},
		right = { "diagnostics", "lsp", "position" },
	},
	components = {
		mode = {
			icon = {
				symbol = "neovim",
				fg = "#111111",
				bg = "mode"
			},
			padding_left = 1,
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
			border = {
				left = { style = "square", fg = "mode", bg = "shade_5" },
				right = { style = "slanted", fg = "mode" },
			},
			fg = "#111111",
			bg = "mode",
			bold = true

		},
		file = {
			icon = "󰈚",
			padding_left = 1,
			border = {
				left = { style = "slanted", fg = "shade_4" },
				right = { style = "slanted", fg = "shade_4" },
			},
			bg = "shade_4",
			icon = {
				bg = "shade_4"
			},
		},
		git_branch = {
			icon = " ",
			border = {
				left = { style = "none" },
				right = { style = "none" },
			},
		},
		git_diff = {
			border = {
				left = { style = "none" },
				right = { style = "none" },
			},
		},
		lsp_progress = {
			border = {
				left = { style = "square", fg = "#56b6c2", bg = "shade_5" },
				right = { style = "slanted", fg = "#56b6c2", bg = "shade_5" },
			},
		},
		diagnostics = {
			icons = { error = "󰅜", warn = "󰀦", info = "󰀿", hint = "󰛿" },
			border = {
				left = { style = "square", fg = "#e06c75", bg = "shade_5" },
				right = { style = "slanted", fg = "#e06c75", bg = "shade_5" },
			},
		},
		lsp = {
			icon = "",
			padding_left = 1,
			padding_right = 1,
			border = {
				left = { style = "none" },
				right = { style = "none" },
			},
		},
		position = {
			padding_left = 1,
			format = "%l:%c",
			border = {
				left = { style = "square", fg = "shade_10" },
				right = { style = "slanted", fg = "shade_10" },
			},
			icon = {
				symbol = "",
				fg = "#111111",
				bg = "shade_10"
			},
			bg = "shade_10"
		},
	},
}
