---@type FancylineConfig
return {
	separator = " ",
	sections = {
		left = { "mode", "file", "git_branch", "git_diff", "errors", "warnings", "infos", "hints" },
		center = {},
		right = { "lsp", "encoding", "fileformat", "indent", "position", "filetype" },
	},
	components = {
		mode = {
			icon = "",
			style = "none",
			border = {
				left = {
					style = "none"
				},
				right = {
					style = "none"
				}
			},
			padding_right = 1,
		},
		file = {
			icon = "󰈚",
			padding_left = 1,
			padding_right = 1,
			style = "none",
		},
		git_branch = {
			icon = "󰊢",
			style = "none",
			padding_left = 1,
		},
		errors = {
			icon = "",
			style = "none",
		},
		warnings = {
			icon = "",
			style = "none",
		},
		infos = {
			icon = "",
			style = "none",
		},
		hints = {
			icon = "",
			style = "none",
		},
		encoding = {
			icon = "",
			style = "none",
			padding_left = 1,
		},
		indent = {
			icon = "󰌒",
			padding_left = 1,
			padding_right = 1,
			style = "none",
		},
		lsp = {
			style = "none",
			padding_left = 1
		},
		position = {
			icon = "󰀹",
			padding_left = 1,
			padding_right = 1,
			format = "Ln %l, Col %c",
			style = "none",
		},
		filetype = {
			padding_left = 1,
			icon = nil,
			show_icon = true,
			show_text = true,
			style = "none",
		},
	},
}
