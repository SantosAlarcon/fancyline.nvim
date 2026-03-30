return {
  sections = {
    left = { "mode" },
    center = { "file" },
    right = { "position" },
  },
  components = {
    mode = {
      icon = "",
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
      style = "none",
    },
    git_branch = {
      icon = "",
      style = "none",
    },
    git_diff = {
      icon = "",
      style = "none",
    },
    file = {
      icon = "",
      use_devicon = false,
      style = "none",
    },
    diagnostics = {
      icon = "",
      style = "none",
    },
    lsp = {
      icon = "",
      style = "none",
    },
    filetype = {
      icon = "",
      style = "none",
    },
    position = {
      icon = "",
      format = "Ln %l, Col %c",
      style = "none",
    },
  },
}
