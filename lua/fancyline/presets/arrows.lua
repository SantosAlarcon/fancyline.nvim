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
        left = { style = "arrow", fg = "mode", bg = "shade_9" },
        right = { style = "arrow", fg = "mode", bg = "shade_9" },
      },
    },
    file = {
      icon = "󰈚",
      border = {
        left = { style = "arrow", fg = "#98c379", bg = "shade_9" },
        right = { style = "arrow", fg = "#98c379", bg = "shade_9" },
      },
    },
    git_branch = {
      icon = "󰊢",
      border = {
        left = { style = "arrow", fg = "#c678dd", bg = "shade_9" },
        right = { style = "arrow", fg = "#c678dd", bg = "shade_9" },
      },
    },
    git_diff = {
      icon = "±",
      border = {
        left = { style = "arrow", fg = "#e5c07b", bg = "shade_9" },
        right = { style = "arrow", fg = "#e5c07b", bg = "shade_9" },
      },
    },
    lsp_progress = {
      border = {
        left = { style = "arrow", fg = "#56b6c2", bg = "shade_9" },
        right = { style = "arrow", fg = "#56b6c2", bg = "shade_9" },
      },
    },
    diagnostics = {
      icons = { error = "󰅜", warn = "󰀦", info = "󰀿", hint = "󰛿" },
      border = {
        left = { style = "arrow", fg = "#e06c75", bg = "shade_9" },
        right = { style = "arrow", fg = "#e06c75", bg = "shade_9" },
      },
    },
    lsp = {
      icon = "⚙",
      border = {
        left = { style = "arrow", fg = "mode", bg = "shade_9" },
        right = { style = "arrow", fg = "mode", bg = "shade_9" },
      },
    },
    position = {
      icon = "󰀹",
      format = "%p%%",
      border = {
        left = { style = "arrow", fg = "#abb2bf", bg = "shade_9" },
        right = { style = "arrow", fg = "#abb2bf", bg = "shade_9" },
      },
    },
  },
}
