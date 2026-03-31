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
			border = {
				left = {
					style = "round", fg = "mode"
				},
				right = {
					style = "round", fg = "shade_4"
				}
			},
			fg = "mode",
			bg = "shade_4",
			bold = true
		},
		file = {
			icon = {
				fg = "#111111",
				bg = "shade_9"
			},
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
		cwd = {
			icon = {
				symbol = " ",
				fg = "#111111",
				bg = "shade_9"
			},
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
		},
		lsp = {
			icon = {
				symbol = " ",
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
