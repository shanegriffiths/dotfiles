# Light Mode Robustness — Design

**Date:** 2026-07-22
**Status:** Draft for review

## Goal

Light mode across the terminal stack feels first-party: one design system
(GitHub Light High Contrast + the red accent), no visible remnants of other
palettes, readable out of the box even in brand-new dark-first tools.
Documentation (THEME.md) matches reality, dark mode is explained rather than
changed, and there is a written reset playbook for every layer.

**Non-goals:** changing dark mode's look (stock Catppuccin Mocha + neutral
`#262626` background + red cursor — it stays); replacing the Catppuccin tmux
plugin (kept as the status-bar engine); GUI chrome redesign (JankyBorders /
sketchybar keep their fixed `#c4262b`).

## Architecture (reaffirmed, not changed)

The existing THEME.md architecture is correct and stays:

1. **Ghostty is the single source of truth** — two custom palette files,
   auto-switched by macOS appearance.
2. **Everything that can ride the ANSI cascade does** — colours are ANSI
   names/indices so tools follow the palette for free.
3. **Per-mode surfaces that can't be ANSI live in exactly one place per tool**
   — for tmux that is `theme-light.conf` / `theme-dark.conf`.

What this project adds: a stronger terminal-level safety net, completion of
the GitHub Light takeover of the tmux chrome, a verified audit of every tool,
and documentation that matches.

## Workstreams

### 1. Ghostty safety net

- `minimum-contrast`: `1.2` → `2.0` in `ghostty/.config/ghostty/config`,
  comment updated to explain it is the robustness floor for dark-first tools.
- **Verify:** both modes look unchanged in day-to-day use (Starship prompt,
  yazi, fzf, Claude Code, tmux chrome); the Herdr washed-out-text case becomes
  readable.
- **Rollback:** single line.

### 2. tmux light chrome — finish the GitHub Light takeover (Approach A)

Keep Catppuccin as the engine in both modes. In light mode, `theme-light.conf`
becomes the complete, single override surface:

- **Audit first:** with the server in light mode, dump `show-options -g`,
  `show-window-options -g`, and grep the Catppuccin plugin for every static
  hex or `@thm_*` reference the chrome renders. Classify each: latte remnant
  (replace), GitHub-correct already (keep), content passthrough (ignore).
- **Replace latte values with a GitHub Light mapping**, e.g.:

  | Variable / option | Now (latte) | Becomes (GitHub Light) |
  |---|---|---|
  | `@thm_crust` (pill caps) | `#dce0e8` | `#d0d7de` border grey |
  | `@thm_fg` (pill text) | `#4c4f69` | `#0e1116` |
  | `@thm_overlay_2` | `#7c7f93` | `#66707b` |
  | `@thm_surface_0/_1` (inactive pills) | `#ccd0da` / `#bcc0cc` | `#f6f8fa` / `#eaeef2` scale |
  | `message-style` fg | latte teal `#179299` | `#0e1116` (or accent red for prefix state) |

  Exact hexes tuned visually during implementation; the rule is: greys from
  the GitHub Light scale, accent = ANSI red, nothing latte-tinted survives.
- **Already fixed this session (fold into the audit + docs):** pane borders →
  ANSI red both modes (`tmux.conf` red-accent section); copy-mode selection →
  white-on-black in `theme-light.conf`.
- **Escape hatch (Approach B):** if a baked value cannot be overridden cleanly
  after TPM load, evict Catppuccin from light mode and hand-write the light
  status line. This is a documented decision point, not the default — B costs
  a parallel status-line implementation that will drift.
- **Verify:** light-mode screenshot review of every chrome element (status
  rows, window pills, message prompt, popups, floax, borders, copy-mode,
  search matches); `prefix r` reload; cold server restart
  (`tmux kill-server`) to catch cold-start paint issues.

### 3. Full-stack light-mode audit

Launch each tool in light mode and check: text readable, accent is red, no
dark-first or latte remnants. Fix via ANSI names where possible; per-mode fork
only when unavoidable; every finding lands in THEME.md.

| Tool | Status per THEME.md | Audit action |
|---|---|---|
| Starship, yazi, eza/completion, fzf (both), sesh picker | ANSI-clean | Spot-verify only |
| Claude Code themes (`studio-brio*.json`) | Hand-set backgrounds | Verify light surfaces + diffs |
| nvim | **Not in THEME.md** | Full check: theme, light/dark switching |
| atuin | **Not in THEME.md** | Full check (has own TUI colours) |
| navi | **Not in THEME.md** | Full check |
| git pager / diff colours (`.gitconfig`) | **Not in THEME.md** | Full check |
| zsh syntax-highlighting / other zshrc colours | Partial | Sweep `.zshrc` for hex/colour codes |
| sketchybar, aerospace/JankyBorders | GUI, fixed `#c4262b` | Confirm + document only |
| session-list.sh, resurrect/sesh preview scripts | Per-mode forks | Spot-verify light branch |

### 4. Herdr diagnosis

Config is already correct (`theme = "terminal"`), so the washed-out light
rendering is a mapping problem, not a config omission.

- **Hypothesis:** Herdr paints body text with ANSI white/bright-white
  (7/15), which GitHub Light HC deliberately maps to greys
  (`#66707b`/`#88929d`) — dark-first assumption baked into its "terminal"
  theme.
- **Method:** `herdr --default-config` for theme keys; research its docs/repo
  (tool is new); test whether fg mapping is overridable per-slot in
  `config.toml`.
- **Outcomes, in order of preference:** config override in our
  `herdr/config.toml` → documented workaround → upstream issue drafted (filed
  only with Shane's go-ahead).
- **Acceptance:** Claude Code running inside Herdr in light mode is readable.
  (The 2.0 contrast floor already guarantees a minimum; the goal is
  first-party, not merely legible.)

### 5. THEME.md rewrite

- Sync to reality: today's fixes, contrast 2.0, tmux mapping table, audit
  results for the newly-covered tools (nvim, atuin, navi, git).
- **New section — Dark mode, explained:** stock Catppuccin Mocha everywhere;
  the only deltas are Ghostty background `#1e1e2e` → `#262626`, cursor →
  mocha red, plus the shared red-accent overrides. Three lines of delta from
  stock, listed explicitly.
- **New section — Reset playbook:** per layer (Ghostty light, Ghostty dark,
  tmux chrome, each audited tool): what is stock, what is custom (exact
  file + lines), how to reset that layer to stock, and how to rebase the
  whole stack onto a different palette (generalises the existing "Changing
  the accent" section).
- **New section — Adding a new tool** (the Herdr lesson): prefer the tool's
  terminal/ANSI theme mode; the light-mode checklist to run before trusting
  it; where to record it.

## Risks & error handling

- **Catppuccin cold-start** paints dark on first server start (existing,
  documented gotcha; `prefix r` fixes). Unchanged by this work; re-verified.
- **Contrast 2.0 recolours something loved** — verified visually in both
  modes before committing; one-line rollback.
- **Catppuccin `-og` locks / baked statics** — follow the existing force-set
  pattern (post-TPM `set -g`); escape hatch is Approach B.
- **Stow symlinks + zsh `noclobber`** — all edits to real files under
  `~/.dotfiles`; use `>|` if shell redirection is ever needed.

## Testing

Config work — acceptance is visual and behavioural, not automated:

1. Both modes toggled via macOS appearance; `prefix r`; cold tmux restart.
2. Per-tool light-mode checklist (section 3) passes.
3. Herdr + Claude Code smoke test in light mode.
4. Screenshot before/after pair for the tmux chrome and Herdr.
5. Dark mode confirmed pixel-identical for chrome we didn't touch.
