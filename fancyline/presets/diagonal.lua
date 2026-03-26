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
        left = { style = "slanted", fg = "mode", bg = "shade_7" },
        right = { style = "slanted", fg = "mode", bg = "shade_7" },
      },
    },
    file = {
      icon = "󰈚",
      border = {
        left = { style = "slanted", fg = "#98c379", bg = "shade_7" },
        right = { style = "slanted", fg = "#98c379", bg = "shade_7" },
      },
    },
    git_branch = {
      icon = "󰊢",
      border = {
        left = { style = "slanted", fg = "#c678dd", bg = "shade_7" },
        right = { style = "slanted", fg = "#c678dd", bg = "shade_7" },
      },
    },
    git_diff = {
      icon = "±",
      border = {
        left = { style = "slanted", fg = "#e5c07b", bg = "shade_7" },
        right = { style = "slanted", fg = "#e5c07b", bg = "shade_7" },
      },
    },
    lsp_progress = {
      border = {
        left = { style = "slanted", fg = "#56b6c2", bg = "shade_7" },
        right = { style = "slanted", fg = "#56b6c2", bg = "shade_7" },
      },
    },
    diagnostics = {
      icons = { error = "󰅜", warn = "󰀦", info = "󰀿", hint = "󰛿" },
      border = {
        left = { style = "slanted", fg = "#e06c75", bg = "shade_7" },
        right = { style = "slanted", fg = "#e06c75", bg = "shade_7" },
      },
    },
    lsp = {
      icon = "⚙",
      border = {
        left = { style = "slanted", fg = "mode", bg = "shade_7" },
        right = { style = "slanted", fg = "mode", bg = "shade_7" },
      },
    },
    position = {
      icon = "󰀹",
      format = "%p%%",
      border = {
        left = { style = "slanted", fg = "#abb2bf", bg = "shade_7" },
        right = { style = "slanted", fg = "#abb2bf", bg = "shade_7" },
      },
    },
  },
}
