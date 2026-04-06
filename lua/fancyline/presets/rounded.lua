return {
  separator = " ",
  sections = {
    left = { "mode", "file", "git_branch", "git_diff" },
    center = {},
    right = { "lsp_progress", "diagnostics", "lsp", "position" },
  },
  components = {
    mode = {
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
        left = { style = "round", fg = "mode", bg = "shade_3" },
        right = { style = "round", fg = "mode", bg = "shade_3" },
      },
    },
    file = {
      icon = "󰈚",
      border = {
        left = { style = "round", fg = "#98c379", bg = "" },
        right = { style = "round", fg = "#98c379", bg = "" },
        -- left = { style = "round", fg = "#98c379", bg = "shade_3" },
        -- right = { style = "round", fg = "#98c379", bg = "shade_3" },
      },
    },
    git_branch = {
      icon = "",
      border = {
        left = { style = "round", fg = "#c678dd", bg = "shade_3" },
        right = { style = "round", fg = "#c678dd", bg = "shade_3" },
      },
    },
    git_diff = {
      border = {
        left = { style = "round", fg = "#e5c07b", bg = "shade_3" },
        right = { style = "round", fg = "#e5c07b", bg = "shade_3" },
      },
    },
    lsp_progress = {
      border = {
        left = { style = "round", fg = "#56b6c2", bg = "shade_3" },
        right = { style = "round", fg = "#56b6c2", bg = "shade_3" },
      },
    },
    diagnostics = {
      icons = { error = "󰅜", warn = "󰀦", info = "󰀿", hint = "󰛿" },
      border = {
        left = { style = "round", fg = "#e06c75", bg = "" },
        right = { style = "round", fg = "#e06c75", bg = "" },
      },
    },
    lsp = {
      icon = "⚙",
      border = {
        left = { style = "round", fg = "mode", bg = "" },
        right = { style = "round", fg = "mode", bg = "" },
      },
    },
    position = {
      icon = "󰗉",
      format = "%l:%c",
      border = {
        left = { style = "round", fg = "#abb2bf", bg = "" },
        right = { style = "round", fg = "#abb2bf", bg = "" },
      },
    },
  },
}
