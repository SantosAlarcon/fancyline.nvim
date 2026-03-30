return {
	separator = " ",
	sections = {
		left = { "mode", "file", "git_branch", "git_diff" },
		center = {},
		right = { "encoding", "errors", "warnings", "infos", "hints", "lsp", "position" },
	},
	components = {
		mode = {
			icon = {
				symbol = "vim",
				fg = "#111111",
				bg = "mode"
			},
			border = {
				left = {
					style = "round", fg = "mode"
				},
				right = {
					style = "round", fg = "shade_9"
				}

			},
			fg = "mode",
			bg = "shade_9"
		},
		encoding = {
			icon = ""
		},
		lsp = {
			icon = {
				symbol = "",
				fg = "#111111",
				bg = "shade_5"
			},
			border = {
				left = {style = "round", fg = "shade_5"},
				right = {style = "round", fg = "shade_7"},
			}
		},
		position = {
			icon = {
				symbol = "",
				fg = "#111111",
				bg = "shade_5"
			},
border = {
				left = {style = "round", fg = "shade_5"},
				right = {style = "round", fg = "shade_7"},
			}

		}
	},
}
