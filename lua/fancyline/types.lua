---@diagnostic disable:undefined-doc-name

---@class FancylineSections
---@field left? string[] Components for the left section
---@field center? string[] Components for the center section
---@field right? string[] Components for the right section

---@class FancylineIconState
---@field fg? string Foreground color
---@field bg? string Background color

---@class FancylineIconConfig
---@field symbol? string Icon character (e.g., "N", "󰈔", "neovim", "vim")
---@field fg? string Foreground color (hex or theme reference)
---@field bg? string Background color (hex or theme reference)
---@field states? table<string, FancylineIconState> Per-state icon colors

---@class FancylineBorderSide
---@field style? string Border style: "round", "square", "slanted", "arrow", "none", "tagged"
---@field fg? string Foreground color (hex, "mode", or "shade_X")
---@field bg? string Background color (hex, "mode", or "shade_X")

---@class FancylineBorder
---@field left? FancylineBorderSide Left border configuration
---@field right? FancylineBorderSide Right border configuration
---@field content_gap? string Gap between icon and text (default: " ")

---@class FancylineComponentBase
---@field icon? string|FancylineIconConfig Icon symbol or configuration
---@field style? string Border style: "round", "square", "slanted", "arrow", "tagged", "none" (default: varies by component)
---@field fg? string Foreground color override (hex or theme color reference)
---@field bg? string Background color override (hex or theme color reference)
---@field bold? boolean Enable bold text only (not icon or border) (default: false)
---@field border? FancylineBorder Custom border per side

---@class FancylineModeText
---@field [key: string] string Mode display text

---@class FancylineModeComponent: FancylineComponentBase
---@field text? FancylineModeText Mode key to display text mapping (e.g., { n = "NORMAL", i = "INSERT" })
---@field colors? table<string, string> Per-mode color overrides: { n = "#FF0000", i = "#00FF00" }

---@class FancylineFileComponent: FancylineComponentBase
---@field use_devicon? boolean Use file type icons (default: true)
---@field empty_name? string Text for unnamed buffers (default: "[Empty]")
---@field icons? table<string, string> State icons: { modified = "●", readonly = "󰌾" }

---@class FancylineDiagnosticsComponent: FancylineComponentBase
---@field icon? string Main icon (e.g., "󰅴")
---@field icons? table<string, string> Per-severity icons: { error = "", warn = "", info = "", hint = "💡" }

---@class FancylinePositionComponent: FancylineComponentBase
---@field format? string Format string with placeholders: %l (line), %c (col), %L (total lines), %p (percent), %P (percent+%)
---Default: "Ln %l, Col %c"

---@class FancylineFiletypeComponent: FancylineComponentBase
---@field icon? string|FancylineIconConfig Custom icon (uses auto-detection if not specified)
---@field lowercase? boolean Display filetype in lowercase
---@field uppercase? boolean Display filetype in uppercase
---@field titlecase? boolean Display filetype in title case
---@field show_text? boolean Show filetype text (default: true)

---@class FancylineSearchStatsComponent: FancylineComponentBase
---@field format? string Format string with %d placeholders for current/total (default: "%d/%d")

---@class FancylineLspClientsComponent: FancylineComponentBase
---@field max_clients? number Maximum number of clients to display (default: 3)
---@field show_version? boolean Show LSP server version (default: true)

---@class FancylineIndentComponent: FancylineComponentBase
---@field icon? string Icon prefix (default: "󰌒")
---@field spaces_text? string Custom label for spaces (e.g., "Spaces")
---@field tabs_text? string Custom label for tabs (e.g., "Tabs")

---@class FancylineGitSignsComponent: FancylineComponentBase
---@field icons? table<string, string> Per-hunk icons: { added = "│", changed = "▎", deleted = "┌" }

---@class FancylineBranchStatusComponent: FancylineComponentBase
---@field icons? table<string, string> Icons: { ahead = "↑", behind = "↓" }

---@class FancylineCwdComponent: FancylineComponentBase
---@field max_length? number Maximum path depth to show

---@class FancylineCommitMsgComponent: FancylineComponentBase
---@field max_length? number Maximum message length (truncates with "…")

---@class FancylineDapStateIcons
---@field running? string
---@field stopped? string
---@field breakpoint? string
---@field exception? string

---@class FancylineDapComponent: FancylineComponentBase
---@field icons? FancylineDapStateIcons Per-state icons

---@class FancylineChecktimeIcon
---@field symbol? string Icon character
---@field fg? string Foreground color
---@field bg? string Background color

---@class FancylineChecktimeComponent: FancylineComponentBase
---@field icon? string|FancylineChecktimeIcon Icon for the component

---@class FancylineSpellIcon
---@field symbol? string Spell indicator text
---@field fg? string Foreground color
---@field bg? string Background color

---@class FancylineSpellComponent: FancylineComponentBase
---@field icon? string|FancylineSpellIcon Icon configuration

---@class FancylineMacroRecordingIcon
---@field symbol? string Icon character (default: "●")
---@field fg? string Foreground color
---@field bg? string Background color

---@class FancylineMacroRecordingComponent: FancylineComponentBase
---@field icon? string|FancylineMacroRecordingIcon Icon configuration

---@class FancylineReloadIcon
---@field symbol? string Icon text (default: "RELOAD")
---@field fg? string Foreground color
---@field bg? string Background color

---@class FancylineReloadComponent: FancylineComponentBase
---@field icon? string|FancylineReloadIcon Icon configuration

---@class FancylineTreesitterComponent: FancylineComponentBase
---@field icon? string|FancylineIconConfig Icon prefix (default: "TS")

---@class FancylineLspProgressComponent: FancylineComponentBase
---@field style? string Border style (default: "default")

---@class FancylineLspComponent: FancylineComponentBase
---@field icon? string|FancylineIconConfig Icon (default: "⚙")

---@class FancylineEncodingComponent: FancylineComponentBase
---@field icon? string Icon prefix (default: "󰈔")

---@class FancylineFileformatComponent: FancylineComponentBase

---@class FancylineFilesizeComponent: FancylineComponentBase

---@class FancylineBufnrComponent: FancylineComponentBase

---@class FancylineTabnrComponent: FancylineComponentBase

---@class FancylineQuickfixComponent: FancylineComponentBase

---@class FancylineProjectComponent: FancylineComponentBase

---@class FancylineGitBranchComponent: FancylineComponentBase

---@class FancylineGitDiffComponent: FancylineComponentBase

---@class FancylineErrorsComponent: FancylineComponentBase
---@field icon? string Error icon (default: "󰅜")

---@class FancylineWarningsComponent: FancylineComponentBase
---@field icon? string Warning icon (default: "󰀦")

---@class FancylineInfosComponent: FancylineComponentBase
---@field icon? string Info icon (default: "󰀿")

---@class FancylineHintsComponent: FancylineComponentBase
---@field icon? string Hint icon (default: "󰛿")

---@class FancylineComponents
---@field mode? FancylineModeComponent
---@field file? FancylineFileComponent
---@field git_branch? FancylineGitBranchComponent
---@field git_diff? FancylineGitDiffComponent
---@field git_signs? FancylineGitSignsComponent
---@field diagnostics? FancylineDiagnosticsComponent
---@field errors? FancylineErrorsComponent
---@field warnings? FancylineWarningsComponent
---@field infos? FancylineInfosComponent
---@field hints? FancylineHintsComponent
---@field lsp? FancylineLspComponent
---@field lsp_progress? FancylineLspProgressComponent
---@field lsp_clients? FancylineLspClientsComponent
---@field filetype? FancylineFiletypeComponent
---@field encoding? FancylineEncodingComponent
---@field fileformat? FancylineFileformatComponent
---@field filesize? FancylineFilesizeComponent
---@field indent? FancylineIndentComponent
---@field treesitter? FancylineTreesitterComponent
---@field position? FancylinePositionComponent
---@field bufnr? FancylineBufnrComponent
---@field tabnr? FancylineTabnrComponent
---@field cwd? FancylineCwdComponent
---@field project? FancylineProjectComponent
---@field quickfix? FancylineQuickfixComponent
---@field checktime? FancylineChecktimeComponent
---@field macro_recording? FancylineMacroRecordingComponent
---@field search_stats? FancylineSearchStatsComponent
---@field spell? FancylineSpellComponent
---@field reload? FancylineReloadComponent
---@field branch_status? FancylineBranchStatusComponent
---@field commit_msg? FancylineCommitMsgComponent
---@field dap? FancylineDapComponent

---@class FancylineStyleDefinition
---@field left string Left border character
---@field right string Right border character
---@field icon_gap string Gap between icon and text

---@class FancylineStyles
---@field round? FancylineStyleDefinition
---@field square? FancylineStyleDefinition
---@field slanted? FancylineStyleDefinition
---@field arrow? FancylineStyleDefinition
---@field none? FancylineStyleDefinition
---@field tagged? FancylineStyleDefinition

---@class FancylineRefresh
---@field enabled? boolean Enable periodic refresh (default: true)
---@field interval? number Refresh interval in milliseconds (default: 16)

---@class FancylineTheme
---@field name? string Theme name: "tokyonight", "catppuccin", "dracula", "nord", "github", "kanagawa", "rose_pine", "nordfox", "onedark", "oxocarbon", "nightfox", "everforest", "sonokai", "cyberdream", "vscode", "material", "solarized_osaka", "nordic", "moonfly", "gruvbox", "andromeda"
---@field variant? string Theme variant (e.g., "night", "storm", "moon", "day" for tokyonight; "deep_ocean", "oceanic", "palenight", "darker", "lighter" for material)
---@field foreground? string Default text color for statusline

---@class FancylineExtensions
---@field telescope? boolean Enable Telescope statusline extension
---@field oil? boolean Enable Oil.nvim statusline extension

---@class FancylineConfig
---@field preset? string Preset name: "default", "minimal", "standard", "full", "git-focused", "vscode", "slim", "rounded", "angular", "diagonal", "arrows", "pill", "brick"
---@field sections? FancylineSections Statusline sections layout
---@field components? FancylineComponents Per-component configuration
---@field style? FancylineStyles Border style definitions (extends defaults)
---@field separator? string Separator between sections (default: " │ ")
---@field refresh? FancylineRefresh Periodic refresh settings
---@field theme? string|FancylineTheme Theme selection ("auto", theme name string, or table)
---@field extensions? FancylineExtensions Extension settings

---@class FancylineContext
---@field bufnr number Buffer number
---@field winid number Window ID

---@class FancylineComponentResult
---@field text? string Display text
---@field icon? FancylineIconConfig Icon configuration
---@field style? string Border style
---@field highlight? string Highlight group name
---@field fg? string Foreground color
---@field bg? string Background color
---@field bold? boolean Bold styling for text content only
---@field state? string Component state for dynamic coloring
---@field border? FancylineBorder Custom border configuration

---@class FancylineProvider
---@field provider fun(opts: table|nil, ctx: FancylineContext): FancylineComponentResult|FancylineComponentResult[]|nil
