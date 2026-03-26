return {
  separator = " ",
  sections = {
    left = { "mode", "file", "git_branch", "git_diff" },
    center = {},
    right = { "lsp_progress", "diagnostics", "lsp", "position" },
  },
  components = {
    mode = {
      icon = "N",
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
        right = { style = "square", fg = "mode", bg = "shade_5" },
      },
    },
    file = {
      icon = "󰈚",
      border = {
        left = { style = "square", fg = "#98c379", bg = "shade_5" },
        right = { style = "square", fg = "#98c379", bg = "shade_5" },
      },
    },
    git_branch = {
      icon = "󰊢",
      border = {
        left = { style = "square", fg = "#c678dd", bg = "shade_5" },
        right = { style = "square", fg = "#c678dd", bg = "shade_5" },
      },
    },
    git_diff = {
      icon = "±",
      border = {
        left = { style = "square", fg = "#e5c07b", bg = "shade_5" },
        right = { style = "square", fg = "#e5c07b", bg = "shade_5" },
      },
    },
    lsp_progress = {
      border = {
        left = { style = "square", fg = "#56b6c2", bg = "shade_5" },
        right = { style = "square", fg = "#56b6c2", bg = "shade_5" },
      },
    },
    diagnostics = {
      icons = { error = "󰅜", warn = "󰀦", info = "󰀿", hint = "󰛿" },
      border = {
        left = { style = "square", fg = "#e06c75", bg = "shade_5" },
        right = { style = "square", fg = "#e06c75", bg = "shade_5" },
      },
    },
    lsp = {
      icon = "⚙",
      border = {
        left = { style = "square", fg = "mode", bg = "shade_5" },
        right = { style = "square", fg = "mode", bg = "shade_5" },
      },
    },
    position = {
      icon = "󰀹",
      format = "%p%%",
      border = {
        left = { style = "square", fg = "#abb2bf", bg = "shade_5" },
        right = { style = "square", fg = "#abb2bf", bg = "shade_5" },
      },
    },
  },
}
