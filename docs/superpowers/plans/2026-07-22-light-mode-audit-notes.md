# Light-mode audit notes — 2026-07-22

Working notes accumulated during the light-mode robustness work.
Consumed by the THEME.md rewrite task, then this file can be deleted.

## ghostty
- minimum-contrast 1.2 → 2.0 (robustness floor; one-line rollback).

## tmux (before)

```
@thm_bg "#eff1f5"
@thm_blue red
@thm_crust "#dce0e8"
@thm_fg "#4c4f69"
@thm_flamingo "#dd7878"
@thm_green "#40a02b"
@thm_lavender "#7287fd"
@thm_mantle "#e6e9ef"
@thm_maroon "#e64553"
@thm_mauve red
@thm_overlay_0 "#9ca0b0"
@thm_overlay_1 "#8c8fa1"
@thm_overlay_2 "#7c7f93"
@thm_peach "#fe640b"
@thm_pink "#ea76cb"
@thm_red "#d20f39"
@thm_rosewater "#dc8a78"
@thm_sapphire "#209fb5"
@thm_sky "#04a5e5"
@thm_subtext_0 "#5c5f77"
@thm_subtext_1 "#6c6f85"
@thm_surface_0 "#ccd0da"
@thm_surface_1 "#bcc0cc"
@thm_surface_2 "#acb0be"
@thm_teal "#179299"
@thm_yellow "#df8e1d"
message-style "fg=#179299,bg=#ffffff,fill=#ffffff,align=centre"
```

## tmux

GitHub Light HC takeover complete. Mapping table (variables rendered in light-mode chrome):

| Variable | Latte (was) | GitHub Light (now) | Role |
|----------|-------------|-------------------|------|
| @thm_crust | `#dce0e8` (pale grey) | `#ffffff` (white) | text on coloured pills (number, current-window) |
| @thm_fg | `#4c4f69` (dark grey) | `#0e1116` (black) | window-name text |
| @thm_overlay_2 | `#7c7f93` (medium grey) | `#66707b` (GitHub grey) | number-pill background |
| @thm_overlay_0 | `#9ca0b0` (light grey) | `#d0d7de` (GitHub silver) | right-click menu selected-item bg |
| @thm_surface_0 | `#ccd0da` (light lavender) | `#eaeef2` (GitHub light) | inactive window-name chip bg |
| @thm_surface_1 | `#bcc0cc` (lavender) | `#d0d7de` (GitHub silver) | current window-name chip bg |
| @thm_yellow | `#df8e1d` (catppuccin) | `#9a6700` (GitHub dark-yellow) | zoom badge in status-left |

Additional chrome overrides (new or updated):

- **message-style**: `fg=#179299` → `fg=#0e1116` (teal text → black text on white bar)
- **message-command-style**: `fg=#179299` → `fg=#0e1116` (teal text → black text on white bar)
- **mode-style**: already set to white-on-black `fg=#ffffff,bg=#0e1116,bold` (copy-mode selection)
- **copy-mode-match-style**: newly set to `bg=#fff8c5,fg=#0e1116` (pale-yellow wash for matches)
- **copy-mode-current-match-style**: newly set to `bg=#a0111f,fg=#ffffff` (red for current match, mirrors Ghostty)
- **copy-mode-mark-style**: newly set to `bg=#a0111f,fg=#ffffff` (red for mark)
- **pane-border-style**: set in tmux.conf to `fg=red` (both modes; was latte lavender #7287fd)
- **pane-active-border-style**: set in tmux.conf to `fg=red` (both modes; was latte lavender #7287fd)
- **popup-style**: already set to `bg=#ffffff,fg=#0e1116` (light surface)
- **popup-border-style**: already set to `fg=#d0d7de,bg=#ffffff` (GitHub silver border)
- **status-style**: already set to `bg=#ffffff,fg=#0e1116` (white bar with black text)
- **@floax-text-color**: already set to `#0e1116` (black text for floax floating pane)
- **@bar_bg**: already set to `#ffffff` (white for extra status rows)

No latte value renders in light mode. @catppuccin_status_* module variables (battery, gitmux) still contain latte hexes (#7287fd, #179299) but are NOT rendered — status-right is overridden to white space.

## bat

bat 0.25+ auto-detects terminal background, but fails when content is piped (exact scenario for fzf previews). Falls back to dark theme, rendering light-mode previews with dark syntax colours on white backgrounds. Exported `BAT_THEME` at shell init to lock the theme per macOS appearance.

**Themes chosen:**
- Light: `GitHub` (light syntax colours, white-friendly contrast)
- Dark: `Monokai Extended` (bat's previous default dark rendering; unchanged to preserve dark-mode UX)

**Implementation:**
Inserted theme fork in `~/.dotfiles/zsh/.zshrc` after `EZA_COLORS` block, using same `defaults read -g AppleInterfaceStyle` pattern as Claude Code launcher.

**Verification (light mode):**
```bash
$ zsh -ic 'echo $BAT_THEME; echo "{\"a\": 1}" | bat --color=always -pl json'
GitHub
[38;2;51;51;51m{[0m[38;2;24;54;145m"[0m[38;2;24;54;145ma[0m[38;2;24;54;145m"[0m[38;2;51;51;51m:[0m[38;2;51;51;51m [0m[38;2;0;134;179m1[0m[38;2;51;51;51m}[0m
```

Rendering shows light theme colors (RGB 51,51,51 for dark text; 24,54,145 for JSON keys; 0,134,179 for numbers). fzf file previews now display with light syntax colours on light terminal background.
