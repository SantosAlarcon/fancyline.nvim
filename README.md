# Fancyline

A beautiful, fast, and highly configurable Neovim statusline with icons and decorative borders.

## Features

- **8 Components**: mode, git branch/diff, file, diagnostics, LSP, filetype, cursor
- **20 Built-in Themes**: tokyonight, catppuccin, dracula, nord, kanagawa, rose_pine, onedark, oxocarbon, github, gruvbox, nightfox, everforest, sonokai, cyberdream, vscode, material, solarized_osaka, nordic, moonfly, andromeda
- **Theme Variants**: Auto-detects dark/light variants (night, moon, mocha, etc.)
- **Custom Borders**: Fully customizable borders with separate styles and colors for left/right sides
- **Multi-Color Git States**: Each git state (added, modified, untracked) has its own color
- **Git Without Gitsigns**: Works with plain git commands when gitsigns isn't available
- **Fast**: Throttled refresh, no unnecessary re-renders
- **Configurable**: Every icon, text, and style is customizable
- **Extensions**: Telescope and Oil.nvim support

## Requirements

- Neovim 0.10+
- (Optional) [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) for file icons
- (Optional) [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) for git integration

## Installation

### lazy.nvim

```lua
{
  "your-name/fancyline",
  lazy = false,
  priority = 1000,
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- optional
  },
}
```

### packer.nvim

```lua
use {
  "your-name/fancyline",
  requires = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("fancyline").setup()
  end
}
```

## Quick Start

```lua
require("fancyline").setup()
```

## Configuration

```lua
require("fancyline").setup({
  -- Sections: left, center, right
  sections = {
    left = { "mode", "git_branch", "git_diff" },
    center = { "file" },
    right = { "diagnostics", "lsp", "filetype", "cursor" },
  },

  -- Component configuration
  components = {
    mode = {
      icon = "neovim",
      text = { n = "NORMAL", i = "INSERT", v = "VISUAL" },
    },
    git_branch = {
      icon = "",
    },
    git_diff = {},  -- Shows +added, ~changed, ?untracked with colors
    file = {
      use_devicon = true,
      empty_name = "[No Name]",
    },
    diagnostics = {
      icons = {
        error = "󰅎",
        warn = "󰋎",
        info = "󰟢",
        hint = "󰌶",
      },
    },
    lsp = {
      icon = { symbol = "⚙" },
    },
    filetype = {},
    cursor = {
      format = "Ln %l, Col %c",
    },
  },

  -- Separator between sections
  separator = " │ ",

  -- Theme: "auto" or specific theme
  theme = "auto",

  -- Extensions
  extensions = {
    telescope = true,
    oil = true,
  },

  -- Performance
  refresh = {
    enabled = true,
    interval = 16,
  },
})
```

## Custom Borders

Each component supports fully customizable borders with separate styles and colors for left and right sides.

### Border Structure

```lua
components = {
  component_name = {
    -- Text colors
    fg = "#ffffff",    -- text foreground color
    bg = "#1e1e2e",    -- text background color

    -- Icon colors
    icon = {
      symbol = "󰟢",
      fg = "#000000",
      bg = "#aaaaff",
    },

    -- Border configuration
    border = {
      -- Left border
      left = {
        style = "round",    -- border style
        fg = "#61afef",    -- foreground color
        bg = "#1e1e2e",    -- background color
      },
      -- Right border
      right = {
        style = "round",    -- border style
        fg = "#61afef",    -- foreground color
        bg = "#1e1e2e",    -- background color
      },
      -- Gap between icon and text
      content_gap = " ",
    },

    -- Legacy style (used when no border config)
    style = "round",
  }
}
```

### Available Border Styles

| Style | Left Char | Right Char |
|-------|-----------|------------|
| `round` |  |  |
| `square` | 󰝤 | 󰝤 |
| `slanted` |  |  |
| `arrow` |  |  |
| `none` | (empty) | (empty) |

### Color Inheritance

- If `fg` or `bg` is not specified, it defaults to the theme's color
- Colors can be any valid Neovim color (hex, rgb, named colors)
- Use `"mode"` to dynamically use the current Vim mode color

### Dynamic Color: "mode"

You can use `"mode"` as a color value to dynamically use the current Vim mode color from the theme. This works in any color field:

```lua
components = {
  mode = {
    fg = "mode",              -- text uses mode color
    icon = { fg = "mode" },   -- icon uses mode color
    border = {
      left = { fg = "mode" }, -- border uses mode color
      right = { fg = "mode" }
    }
  },
  file = {
    icon = { fg = "mode" },   -- icon uses mode color
  },
  cursor = {
    fg = "mode",             -- text uses mode color
  }
}
```

Works in: `fg`, `bg`, `icon.fg`, `icon.bg`, `border.left.fg`, `border.left.bg`, `border.right.fg`, `border.right.bg`, etc.

### Visual Example

```lua
cursor = {
  fg = "#ffffff",
  bg = "#7777ff",
  icon = {
    symbol = "󰗉",
    fg = "#000000",
    bg = "#aaaaff",
  },
  border = {
    left = {
      style = "round",
      fg = "#aaaaff",
      bg = "#aaaaff",
    },
    right = {
      style = "round",
      fg = "#6666ff",
      bg = "#6666ff",
    }
  }
}
```

Renders as:
```
┌─────────┐
│  fg/bg  │  1:1
└─────────┘
  left     right
```

### All Components Support Borders

All 8 components support the same border configuration:

- `mode` - Vim mode indicator
- `git_branch` - Git branch name
- `git_diff` - Git diff summary
- `file` - Current file
- `diagnostics` - LSP diagnostics
- `lsp` - Active LSP servers
- `filetype` - File type
- `cursor` - Cursor position

## Themes

Fancyline includes 20 themes that automatically match your colorscheme:

| Theme | Colorschemes |
|-------|--------------|
| tokyonight | tokyonight-night, tokyonight-day, tokyonight-moon, etc |
| catppuccin | catppuccin-mocha, catppuccin-latte, etc |
| dracula | dracula, dracula-pro |
| nord | nord, nord-nvim |
| kanagawa | kanagawa-wave, kanagawa-dragon, kanagawa-lotus |
| rose_pine | rose-pine, rose-pine-moon, rose-pine-dawn |
| onedark | onedark, onedarkpro |
| oxocarbon | oxocarbon |
| github | github-dark, github-light |
| gruvbox | gruvbox, gruvbox-material |
| nightfox | nightfox, nordfox, dayfox, carbonfox, etc |
| everforest | everforest, everforest-nvim |
| sonokai | sonokai |
| cyberdream | cyberdream |
| vscode | vscode, vscode-dark |
| material | material |
| solarized_osaka | solarized-osaka |
| nordic | nordic |
| moonfly | moonfly, vim-moonfly |
| andromeda | andromeda |

### Manual Theme Selection

```lua
require("fancyline").setup({
  theme = "tokyonight",
})
```

## Mode Colors

The mode component changes color based on the current Vim mode.

### Override Mode Colors

```lua
require("fancyline").setup({
  components = {
    mode = {
      colors = {
        n = "#FF6B6B",  -- Red for Normal mode
        i = "#4ECDC4",  -- Teal for Insert mode
      }
    }
  }
})
```

### Mode Component as Function

For full control, define the mode component as a function:

```lua
require("fancyline").setup({
  components = {
    mode = function(mode_name)
      local configs = {
        n = {
          text = "NORMAL",
          icon = { symbol = "N", fg = "#ffffff", bg = "#61afef" },
          style = "round",
        },
        i = {
          text = "INSERT",
          icon = { symbol = "I", fg = "#ffffff", bg = "#98c379" },
          style = "round",
        },
      }
      return configs[mode_name] or { text = mode_name }
    end
  }
})
```

## Icon Configuration

Each component supports icon configuration with colors and states:

```lua
icon = {
  symbol = "󰈔",      -- The icon character
  fg = "#98C379",     -- Foreground color (optional)
  bg = "#282C34",      -- Background color (optional)
  states = {           -- Colors per state (optional)
    normal = { fg = "#98C379" },
    modified = { fg = "#E5C07B" },
    error = { fg = "#E06C75", bg = "#282C34" },
  }
}
```

### Component States

| Component | States | Detection |
|-----------|--------|-----------|
| `git_branch` | `clean`, `modified` | Based on git status |
| `git_diff` | `added`, `changed`, `untracked` | Based on git status (works with or without gitsigns) |
| `file` | `normal`, `modified`, `readonly` | Based on buffer flags |
| `diagnostics` | `error`, `warn`, `info`, `hint` | Based on highest severity |

## Component Formatting

### Cursor Format Placeholders

| Placeholder | Description |
|-------------|-------------|
| `%l` | Current line number |
| `%c` | Current column number |
| `%L` | Total number of lines |
| `%p` | Percentage through file |
| `%P` | Percentage with `%` symbol |

### File Component

| Option | Description |
|--------|-------------|
| `use_devicon` | Use nvim-web-devicons for file type icons (default: true) |
| `empty_name` | Text shown for unnamed buffers (default: "[Empty]") |

## API

### `require("fancyline").setup(opts)`

Configure Fancyline with options.

### `require("fancyline").render()`

Returns the current statusline string.

### `require("fancyline").enable()`

Enable Fancyline statusline.

### `require("fancyline").disable()`

Disable Fancyline and restore default statusline.

### `require("fancyline").refresh()`

Force refresh the statusline.

### `require("fancyline").get_config()`

Get the current configuration.

### `require("fancyline").reload()`

Reload highlights and refresh.

## Visual Preview

```
╭─ 󰅐 INSERT ─╮ │  main │ +16 ~1 │ ╭─ 󰈔 config.lua ─╮ │ ⚙ lua_ls, tsserver │ lua │ Ln 42, Col 15
```

Git diff shows individual states with colors:
- `+16` (added, green)
- `~1` (changed, yellow)
- `?3` (untracked, orange)

## Testing

Tests use plenary.nvim's testing framework.

```bash
# Run all tests
nvim --headless -c 'PlenaryBustedDirectory tests/ { recursive = true }'

# Run specific test file
nvim --headless -c 'PlenaryBustedFile tests/fancyline/components/mode_spec.lua'
```

## Project Structure

```
lua/fancyline/
├── init.lua              -- Main entry point
├── config.lua            -- Default configuration
├── statusline.lua        -- Statusline renderer
├── themes/
│   ├── init.lua          -- Theme loader
│   └── themes/           -- Theme definitions
├── extensions/
│   ├── init.lua          -- Extension loader
│   ├── telescope.lua      -- Telescope extension
│   └── oil.lua           -- Oil.nvim extension
├── utils/
│   ├── throttle.lua      -- Throttling utility
│   ├── git.lua           -- Git utilities
│   ├── diagnostics.lua    -- Diagnostics utilities
│   ├── devicons.lua      -- Devicons utilities
│   └── lsp.lua           -- LSP utilities
├── components/
│   ├── mode.lua          -- Vim mode display
│   ├── git_branch.lua    -- Git branch display
│   ├── git_diff.lua      -- Git diff display
│   ├── file.lua          -- File info display
│   ├── diagnostics.lua    -- Diagnostics display
│   ├── lsp.lua           -- Active LSP servers display
│   ├── filetype.lua      -- Filetype display
│   └── cursor.lua        -- Cursor position display
└── renderer/
    ├── init.lua          -- Main renderer
    └── border.lua        -- Border rendering with custom styles/colors
```

## Contributing

Contributions welcome! Please see the tests for examples of how to test components.

## License

MIT
