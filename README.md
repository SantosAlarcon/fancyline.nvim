# Fancyline

A beautiful, fast, and highly configurable Neovim statusline written in Lua.

[![Neovim](https://img.shields.io/badge/Neovim-0.10+-57A143?style=flat-square&logo=neovim)](https://neovim.io)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

> [!TIP]
> Works out of the box with sensible defaults. Customize every component when you need it.

## Table of contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
  - [Presets](#presets)
  - [Themes](#themes)
  - [Sections](#sections)
  - [Components](#components)
  - [Custom Borders](#custom-borders)
  - [Dynamic Colors](#dynamic-colors)
- [Components Reference](#components-reference)
- [API](#api)
- [Project Structure](#project-structure)
- [Testing](#testing)

## Features

- **33 Components** - Mode, git info, file, diagnostics, LSP, position, and more
- **20 Built-in Themes** - Auto-detects your colorscheme (tokyonight, catppuccin, dracula, nord, github, material with 5 variants, and more)
- **11 Presets** - From minimal to full-featured, with styled border variants
- **Custom Borders** - Fully customizable with separate styles and colors for each side
- **Icon Providers** - Supports mini.icons, nvim-web-devicons, or fallback icons
- **Theme Variants** - Automatic dark/light variant detection
- **Performance** - Throttled refresh, no unnecessary re-renders

## Requirements

- Neovim 0.10+
- Optional: [mini.icons](https://github.com/echasnovski/mini.nvim) (recommended)
- Optional: [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
- Optional: [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)

## Installation

### lazy.nvim

```lua
{
  "SantosAlarcon/fancyline.nvim",
  lazy = false,
  priority = 1000,
  dependencies = {
    "echasnovski/mini.nvim",  -- recommended
    "nvim-tree/nvim-web-devicons",  -- fallback
  },
}
```

## Quick Start

```lua
require("fancyline").setup()
```

## Configuration

### Presets

```lua
require("fancyline").setup({
  preset = "default",  -- or "minimal", "standard", "full", "git-focused", "vscode", "slim"
})
```

Available presets:

| Preset | Description |
|--------|-------------|
| `default` | NvChad-style with mode, git, file, diagnostics, LSP |
| `minimal` | Ultra-compact: mode, file, position |
| `standard` | Balanced: mode, git, file, lsp, filetype |
| `full` | Everything enabled |
| `git-focused` | Git-centric with diagnostics |
| `vscode` | VS Code-style layout |
| `slim` | Minimal with git |
| `rounded` | With rounded borders |
| `angular` | With square borders |
| `diagonal` | With slanted borders |
| `arrows` | With arrow borders |

### Themes

Themes auto-detect from your colorscheme:

```lua
require("fancyline").setup({
  theme = "auto",  -- detects from vim.g.colors_name
})
```

Force a specific theme and variant:

```lua
require("fancyline").setup({
  theme = { name = "github", variant = "light" },
})
```

### Sections

```lua
require("fancyline").setup({
  sections = {
    left = { "mode", "file", "git_branch" },
    center = { "git_diff" },
    right = { "diagnostics", "lsp", "filetype" },
  },
})
```

### Components

Each component is optional and fully configurable:

```lua
require("fancyline").setup({
  components = {
    mode = {
      icon = "N",
      text = { n = "NORMAL", i = "INSERT", v = "VISUAL" },
    },
    git_branch = { icon = "main" },
    file = { use_devicon = true },
    diagnostics = { icons = { error = "!", warn = "~", info = "i", hint = "?" } },
    lsp = { icon = " LSP" },
    filetype = {},
    position = { format = "Ln %l, Col %c" },
  },
})
```

### Custom Borders

Every component supports custom borders:

```lua
require("fancyline").setup({
  components = {
    mode = {
      border = {
        left = { style = "round", fg = "mode", bg = "shade_3" },
        right = { style = "round", fg = "mode", bg = "shade_3" },
      },
    },
  },
})
```

Available border styles: `round`, `square`, `slanted`, `arrow`, `none`, `tagged`

Use `"mode"` to dynamically use the current mode color, or `"shade_X"` for theme-based backgrounds (shade_1 to shade_10).

### Dynamic Colors

Colors can reference theme values:

- `"mode"` - Current Vim mode color
- `"shade_X"` - Theme shade (1-10, dark to light)

## Components Reference

| Component | Description |
|-----------|-------------|
| `mode` | Vim mode indicator |
| `file` | Current file name |
| `git_branch` | Git branch name |
| `git_signs` | Git hunks and untracked files |
| `git_diff` | Git diff summary (+added, ~changed, ?untracked) |
| `branch_status` | Branch status (ahead/behind) |
| `commit_msg` | Current commit message |
| `errors` | LSP errors count |
| `warnings` | LSP warnings count |
| `infos` | LSP info count |
| `hints` | LSP hints count |
| `diagnostics` | Combined diagnostics |
| `lsp` | Active LSP servers |
| `lsp_progress` | LSP progress messages |
| `lsp_clients` | LSP clients with versions |
| `dap` | DAP debugger status |
| `treesitter` | Treesitter language |
| `encoding` | File encoding |
| `fileformat` | File format (LF/CRLF) |
| `filesize` | File size |
| `indent` | Indentation settings |
| `position` | Cursor position |
| `bufnr` | Buffer number |
| `tabnr` | Tab number |
| `cwd` | Current working directory |
| `project` | Project name |
| `quickfix` | Quickfix list count |
| `filetype` | File type with icon |
| `checktime` | File check time/reload status |
| `macro_recording` | Macro recording indicator |
| `search_stats` | Search statistics |
| `spell` | Spell check indicator |
| `reload` | File reload indicator |

## API

```lua
require("fancyline").setup(opts)    -- Configure
require("fancyline").render()       -- Get statusline string
require("fancyline").enable()       -- Enable
require("fancyline").disable()       -- Disable
require("fancyline").refresh()      -- Force refresh
require("fancyline").reload()       -- Reload highlights
require("fancyline").get_config()   -- Get current config
```

## Project Structure

```
lua/fancyline/
├── init.lua            -- Entry point
├── config.lua          -- Default config
├── statusline.lua      -- Statusline renderer
├── themes/
│   ├── init.lua        -- Theme loader & auto-detection
│   └── themes/         -- 20 theme definitions
├── presets/
│   ├── init.lua        -- Preset loader
│   ├── default.lua     -- NvChad-style
│   ├── minimal.lua     -- Ultra-compact
│   ├── vscode.lua      -- VS Code-style
│   ├── rounded.lua     -- With rounded borders
│   ├── angular.lua     -- With square borders
│   ├── diagonal.lua    -- With slanted borders
│   └── arrows.lua      -- With arrow borders
├── components/         -- 33 components
├── extensions/         -- Telescope & Oil support
├── renderer/
│   ├── init.lua        -- Component renderer
│   └── border.lua      -- Border rendering
└── utils/             -- Git, LSP, diagnostics utilities
```

## Testing

Tests use plenary.nvim:

```bash
nvim --headless -c 'PlenaryBustedDirectory tests/ { recursive = true }'
```
