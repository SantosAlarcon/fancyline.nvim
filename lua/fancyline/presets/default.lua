---@type FancylineConfig
return {
	separator = "",
	sections = {
		left = { "mode", "file", "git_branch", "git_diff" },
		center = {},
		right = { "encoding", "errors", "warnings", "infos", "hints", "lsp", "project", "position" },
	},
	components = {
		mode = {
			padding_left = 1,
			icon = {
				symbol = "neovim",
				fg = "#111111",
				bg = "mode"
			},
			border = {
				left = {
					style = "round", fg = "mode"
				},
				right = {
					style = "round", fg = "mode"
				}
			},
			fg = "#111111",
			bg = "mode",
			bold = true
		},
		file = {
			padding_left = 1,
			icon = {
				-- fg = "#111111",
				bg = "shade_3"
			},
			border = {
				left = {
					style = "round",
					fg = "shade_3"
				},
				right = {
					style = "round",
					fg = "shade_3"
				}
			},
			bg = "shade_3"
		},
		git_branch = {
			icon = "",
			padding_left = 1
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
					style = "round",
					fg = "shade_9"
				},
				right = {
					style = "round",
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
					style = "round",
					fg = "shade_9"
				},
				right = {
					style = "round",
					fg = "shade_2"
				}
			},
			bg = "shade_2"
		},
		encoding = {
			icon = "",
			padding_right = 1
		},
		lsp = {
			padding_left = 1,
			icon = {
				symbol = "",
				fg = "#111111",
				bg = "shade_10"
			},
			border = {
				left = { style = "round", fg = "shade_10" },
				right = { style = "round", fg = "shade_2" },
			},
			bg = "shade_2"
		},
		filetype = {
			padding_left = 1,
			icon = {
				fg = "#111111",
				bg = "shade_10"
			},
			border = {
				left = { style = "round", fg = "shade_10" },
				right = { style = "round", fg = "shade_2" },
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
				left = { style = "round", fg = "shade_10" },
				right = { style = "round", fg = "shade_2" },
			},
			bg = "shade_2"
		}
	},
}
