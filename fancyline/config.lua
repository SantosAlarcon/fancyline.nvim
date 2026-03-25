return {
  sections = {
    left = { "mode", "git_branch", "git_diff" },
    center = { "file" },
    right = { "diagnostics", "lsp", "filetype", "cursor" },
  },

  components = {
    mode = {
      icon = "neovim",
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
      style = "round",
      colors = {},  -- Override colors per mode: { n = "#FF0000", i = "#00FF00" }
    },
    git_branch = { icon = "", style = "none" },
    git_diff = { icon = "±", style = "none" },
    file = { icon = "󰈔", use_devicon = true, style = "square" },
    diagnostics = {
      icon = "󰅴",
      icons = { error = "", warn = "", info = "", hint = "💡" },
      style = "none",
    },
    lsp = {
      icon = "⚙",
      style = "round",
    },
    filetype = { icon = "󰘴", style = "square" },
    cursor = { icon = "󰁕", format = "Ln %l, Col %c", style = "round" },
  },

  style = {
    square = { left = "󰝤", right = "󰝤", icon_gap = "  " },
    round = { left = "", right = "", icon_gap = "  " },
    slanted = { left = "", right = "", icon_gap = "  " },
    arrow = { left = "", right = "", icon_gap = "  " },
    none = { left = "", right = "", icon_gap = " " },
  },

  separator = " │ ",

  refresh = {
    enabled = true,
    interval = 16,
  },

  highlights = {
    mode = "FancylineMode",
    git_branch = "FancylineGitBranch",
    git_diff = "FancylineGitDiff",
    file = "FancylineFile",
    diagnostics = "FancylineDiagnostics",
    filetype = "FancylineFiletype",
    cursor = "FancylineCursor",
    separator = "FancylineSeparator",
  },

  theme = "auto",

  extensions = {
    telescope = true,
    oil = true,
  },
}
