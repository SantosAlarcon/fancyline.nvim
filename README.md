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
- [FAQ](#faq)
- [Testing](#testing)

## Features

- **33 Components** - Mode, git info, file, diagnostics, LSP, position, and more
- **20 Built-in Themes** - Auto-detects your colorscheme (tokyonight, catppuccin, dracula, nord, github, material with 5 variants, and more)
- **9 Presets** - Layout presets + styled border variants
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
    "echasnovski/mini.nvim",       -- recommended
    "nvim-tree/nvim-web-devicons", -- fallback
  },
}
```

## Quick Start

```lua
require("fancyline").setup()
```

## Commands

| Command | Description |
|---------|-------------|
| `:FancyLine enable` | Enable the statusline |
| `:FancyLine disable` | Disable the statusline |
| `:FancyLine toggle` | Toggle enable/disable |
| `:FancyLine refresh` | Force refresh the statusline |
| `:FancyLine reload` | Reload highlights (useful after colorscheme change) |
| `:FancyLine theme <name>` | Change theme dynamically |
| `:FancyLine preset <name>` | Change preset dynamically |
| `:FancyLine config` | Show current configuration |

Tab autocompletion works for theme and preset names.

## Configuration

### Presets

```lua
require("fancyline").setup({
  preset = "default",  -- or "vscode", "slim"
})
```

**Layout Presets:**

| Preset | Description |
|--------|-------------|
| `default` | NvChad-style: mode, git, file, diagnostics, LSP |
| `vscode` | VS Code-style layout |
| `slim` | Minimal with text-only components |

**Border Presets:**

| Preset | Description |
|--------|-------------|
| `rounded` | Rounded borders |
| `angular` | Square borders |
| `diagonal` | Slanted borders |
| `arrows` | Arrow borders |
| `pill` | Rounded borders on both sides |
| `brick` | Rectangle borders on both sides |

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
      icon = "",
      text = { n = "NORMAL", i = "INSERT", v = "VISUAL" },
    },
    git_branch = { icon = "" },
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

### Text Styling

Add bold text to any component:

```lua
require("fancyline").setup({
  components = {
    mode = {
      icon = "neovim",
      bold = true,  -- Bold text only (not icon or border)
    }
  }
})
```

Note: Bold styling only applies to the text content, not the icon or border.

## Components Reference

### Git
| Component | Description |
|------------|-------------|
| `git_branch` | Git branch name |
| `git_signs` | Git hunks and untracked files |
| `git_diff` | Git diff summary (+added, ~changed, ?untracked) |
| `branch_status` | Branch status (ahead/behind) |
| `commit_msg` | Current commit message |

### LSP / Diagnostics
| Component | Description |
|------------|-------------|
| `errors` | LSP errors count |
| `warnings` | LSP warnings count |
| `infos` | LSP info count |
| `hints` | LSP hints count |
| `diagnostics` | Combined diagnostics |
| `lsp` | Active LSP servers |
| `lsp_progress` | LSP progress messages |
| `lsp_clients` | LSP clients with versions |

### File
| Component | Description |
|-----------|-------------|
| `file` | Current file name |
| `filetype` | File type with icon |
| `encoding` | File encoding |
| `fileformat` | File format (LF/CRLF) |
| `filesize` | File size |
| `indent` | Indentation settings |
| `checktime` | File check time/reload status |
| `reload` | File reload indicator |

### UI / Status
| Component | Description |
|-----------|-------------|
| `mode` | Vim mode indicator |
| `position` | Cursor position (Ln, Col) |
| `bufnr` | Buffer number |
| `tabnr` | Tab number |
| `cwd` | Current working directory |
| `project` | Project name |
| `quickfix` | Quickfix list count |
| `macro_recording` | Macro recording indicator |
| `search_stats` | Search statistics |
| `spell` | Spell check indicator |

### Extra
| Component | Description |
|-----------|-------------|
| `dap` | DAP debugger status |
| `treesitter` | Treesitter language |

## API

```lua
require("fancyline").setup(opts)      -- Configure
require("fancyline").render()        -- Get statusline string
require("fancyline").enable()        -- Enable
require("fancyline").disable()       -- Disable
require("fancyline").toggle()        -- Toggle enable/disable
require("fancyline").refresh(force)  -- Force refresh (bypass rate limiter if true)
require("fancyline").reload()        -- Reload highlights
require("fancyline").get_config()    -- Get current config
require("fancyline").set_preset(name) -- Change preset dynamically
```

## FAQ

### Why is fancyline slow on Windows?

Windows Defender scans every `git` process spawn, causing delays. Fix:

**Option 1: Add Neovim to Windows Defender Exclusions (Recommended)**
1. Open Windows Security
2. Go to Virus & threat protection > Manage settings
3. Under Exclusions, click "Add an exclusion"
4. Select "Executable" and add `nvim.exe`

**Option 2: Use Git Bash Shell**
```lua
vim.o.shell = vim.fn.executable("bash") == 1 and "bash.exe" or vim.o.shell
```

**Option 3: Use WSL**
Running Neovim on Windows Subsystem for Linux bypasses these issues entirely.

### How do I change themes at runtime?

```vim
:FancyLine theme tokyonight
```

Use tab completion to see available themes.

### How do I create a custom preset?

```lua
require("fancyline").setup({
  preset = "default",  -- start from a preset
  sections = {
    left = { "mode", "file", "git_branch", "git_diff" },
    center = {},
    right = { "diagnostics", "lsp", "filetype", "position" },
  },
  components = {
    mode = { icon = " 󰊤 ", bold = true },
    git_branch = { icon = "  " },
    -- ... customize any component
  },
})
```

### How do I add icons?

FancyLine auto-detects [mini.icons](https://github.com/echasnovski/mini.nvim) or [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons). Just install one of them - no extra config needed.

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
│   ├── vscode.lua      -- VS Code-style
│   ├── slim.lua        -- Minimal
│   ├── rounded.lua     -- Rounded borders
│   ├── angular.lua     -- Square borders
│   ├── diagonal.lua    -- Slanted borders
│   ├── arrows.lua      -- Arrow borders
│   ├── pill.lua        -- Pill borders
│   └── brick.lua       -- Brick borders
├── components/         -- 33 components
├── extensions/         -- Telescope & Oil support
├── renderer/
│   ├── init.lua        -- Component renderer
│   └── border.lua      -- Border rendering
└── utils/              -- Git, LSP, diagnostics utilities
```

## Testing

Tests use plenary.nvim:

```bash
nvim --headless -c 'PlenaryBustedDirectory tests/ { recursive = true }'
```
