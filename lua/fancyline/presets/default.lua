return {
  sections = {
    left = { "mode", "file", "git_branch", "git_diff" },
    center = {},
    right = { "lsp_progress", "diagnostics", "lsp", "position" },
  },
  components = {
    mode = {
      icon = "",
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
      style = "default",
    },
    file = {
      icon = "󰈚",
      style = "default",
    },
    git_branch = {
      icon = "",
      style = "default",
    },
    git_diff = {
      icon = "±",
      style = "default",
    },
    lsp_progress = {
      style = "default",
    },
    diagnostics = {
      icons = { error = "󰅜", warn = "󰀦", info = "󰀿", hint = "󰛿" },
      style = "default",
    },
    lsp = {
      icon = "⚙",
      style = "default",
    },
    position = {
      icon = "",
      format = "%p %%",
      style = "default",
    },
  },
}
