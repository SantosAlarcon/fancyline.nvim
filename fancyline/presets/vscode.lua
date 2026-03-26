return {
  separator = " ",
  sections = {
    left = { "file", "git_branch", "git_diff", "errors", "warnings", "infos", "hints" },
    center = {},
    right = { "lsp", "encoding", "indent", "position", "filetype" },
  },
  components = {
    mode = {
      icon = "N",
      style = "none",
    },
    file = {
      icon = "󰈚",
      style = "none",
    },
    git_branch = {
      icon = "󰊢",
      style = "none",
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
    },
    indent = {
      icon = "󰌒",
      style = "none",
    },
	lsp = {
		style = "none"
	},
    position = {
      icon = "󰀹",
      format = "Ln %l, Col %c",
      style = "none",
    },
    filetype = {
      icon = nil,
      show_icon = true,
      show_text = true,
      style = "none",
    },
  },
}
