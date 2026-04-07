---@type FancylineConfig
return {
	separator = "",
	sections = {
		left = { "mode", "file", "git_branch", "git_diff" },
		center = { "errors", "warnings", "infos", "hints" },
		right = { "filetype", "lsp", "encoding", "fileformat", "indent", "position" },
	},
	components = {
		mode = {
			icon = "",
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
			style = "none",
			bg = "mode",
			fg = "#111111",
			border = {
				left = { fg = "mode", style = "square" },
				right = { fg = "mode", style = "square" },
			},
		},
		file = {
			icon = {
				bg = "shade_2"
			},
			use_devicon = false,
			style = "none",
			padding_left = 1,
			padding_right = 1,
			bg = "shade_2",
			border = {
				left = { style = "square", fg = "shade_2" },
				right = { style = "none" }
			}
		},
		git_branch = {
			icon = " ",
			style = "none",
		},
		git_diff = {
			icon = "",
			style = "none",
		},
		diagnostics = {
			icon = "",
			style = "none",
		},
		filetype = {
			icon = {
				bg = "shade_5",
			},
			border = {
				left = {
					style = "square",
					fg = "shade_5"
				},
				right = {
					style = "none"
				}
			},
			use_devicon = false,
			style = "none",
			bg = "shade_5",
			padding_left = 1,
			padding_right = 1
		},
		lsp = {
			icon = "",
			style = "none",
			bg = "shade_6",
			padding_left = 1,
			padding_right = 1
		},
		encoding = {
			icon = "",
			bg = "shade_7",
			padding_right = 1
		},
		fileformat = {
			icon = "",
			bg = "shade_8",
			padding_left = 1,
			padding_right = 1
		},
		indent = {
			icon = "",
			bg = "shade_9",
			padding_right = 1
		},
		position = {
			icon = "",
			format = "%l | %c",
			bg = "shade_10",
			padding_left = 1,
			padding_right = 1,
			style = "none",
		},
	},
}
