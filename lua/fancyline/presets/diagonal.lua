---@type FancylineConfig
return {
	separator = "",
	sections = {
		left = { "mode", "file", "git_branch", "git_diff" },
		center = {},
		right = { "encoding", "errors", "warnings", "infos", "hints", "lsp", "project",  "position" },
	},
	components = {
		mode = {
			icon = {
				symbol = "neovim",
				fg = "#111111",
				bg = "mode"
			},
			padding_left = 1,
			border = {
				left = {
					style = "slanted", fg = "mode"
				},
				right = {
					style = "slanted", fg = "shade_4"
				}
			},
			fg = "mode",
			bg = "shade_4",
			bold = true
		},
		git_branch = {
			icon = "",
			padding_left = 1
		},
		file = {
			icon = {
				fg = "#111111",
				bg = "shade_9"
			},
			padding_left = 1,
			border = {
				left = {
					style = "slanted",
					fg = "shade_9"
				},
				right = {
					style = "slanted",
					fg = "shade_2"
				}
			},
			bg = "shade_2"
		},
		cwd = {
			icon = {
				symbol = " ",
				fg = "#111111",
				bg = "shade_9"
			},
			padding_left = 1,
			border = {
				left = {
					style = "slanted",
					fg = "shade_9"
				},
				right = {
					style = "slanted",
					fg = "shade_2"
				}
			},
			bg = "shade_2"
		},
		project = {
			icon = {
				symbol = "",
				fg = "#111111",
				bg = "shade_9"
			},
			padding_left = 1,
			border = {
				left = {
					style = "slanted",
					fg = "shade_9"
				},
				right = {
					style = "slanted",
					fg = "shade_2"
				}
			},
			bg = "shade_2"
		},
		encoding = {
			padding_right = 1,
			icon = "",
		},
		lsp = {
			icon = {
				symbol = " ",
				fg = "#111111",
				bg = "shade_10"
			},
			padding_left = 1,
			border = {
				left = { style = "slanted", fg = "shade_10" },
				right = { style = "slanted", fg = "shade_2" },
			},
			bg = "shade_2"
		},
		filetype = {
			icon = {
				fg = "#111111",
				bg = "shade_10"
			},
			padding_left = 1,
			border = {
				left = { style = "slanted", fg = "shade_10" },
				right = { style = "slanted", fg = "shade_2" },
			},
			bg = "shade_2"
		},
		position = {
			format = "%l/%c",
			padding_left = 1,
			icon = {
				symbol = "",
				fg = "#111111",
				bg = "shade_10"
			},
			border = {
				left = { style = "slanted", fg = "shade_10" },
				right = { style = "slanted", fg = "shade_2" },
			},
			bg = "shade_2"
		}
	},
}
