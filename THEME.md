# Theming

A single coordinated look across the terminal stack: **Ghostty, Starship, yazi,
eza, fzf, tmux, and Claude Code**. Two palettes — high-contrast GitHub light and
Catppuccin Mocha — with a **red accent** throughout, switching automatically with
macOS appearance.

## How it works

Ghostty is the source of truth. Its two custom palettes define every ANSI slot,
and Ghostty swaps them automatically when macOS flips light/dark:

```
theme = light:GitHub Light HC Red,dark:Catppuccin Mocha Custom
```

Almost everything is configured with **ANSI colour *names*** (`red`, `cyan`, …) or
ANSI indices (`1`) rather than hex. Those emit indexed ANSI escapes, which the
terminal renders from its *active* palette — so when Ghostty switches, the prompt,
file manager, `ls`, fzf, and tmux all follow for free. No per-tool light/dark logic.

A few tools detect macOS appearance themselves (`defaults read -g
AppleInterfaceStyle`) because they can't ride the ANSI cascade: Starship's branch
pill (needs raw RGB for the pill *background*), tmux's `session-list.sh` (needs
several distinct per-mode colours), and the Claude Code launcher. Each only forks
once per render/launch.

### One red (almost)

The **terminal red is now a single adaptive source**: everything that references
ANSI `red` resolves to `#a0111f` in light / `#f38ba8` in dark. That covers
Starship, yazi, eza, both fzf configs, the tmux accent, floax, and the tmux
session list.

The **one exception is GUI chrome** — JankyBorders window borders (driven from
`aerospace.toml`) and sketchybar — which are drawn by macOS, not a terminal, so
there's no ANSI palette to follow. They use a fixed `#c4262b` (a middle red that
reads in both modes). That's the only red you'd ever edit by hand.

## The palette (Ghostty)

`ghostty/.config/ghostty/config`:
- `theme = light:GitHub Light HC Red,dark:Catppuccin Mocha Custom` — auto-switch
- `minimum-contrast = 1.2` — floor so no colour renders near-invisible (both modes)
- `unfocused-split-opacity = 1` — don't dim inactive splits
- `font-thicken = false`, `window-theme = auto`

`ghostty/.config/ghostty/themes/` (custom, hand-edited):

| | GitHub Light HC Red | Catppuccin Mocha Custom |
|---|---|---|
| background | `#ffffff` | `#262626` |
| foreground | `#0e1116` | `#cdd6f4` |
| red (ANSI 1) | `#a0111f` | `#f38ba8` |
| cursor | `#a0111f` | `#f38ba8` |

These two files are what every ANSI-aware tool resolves against. Change a slot
here and the whole terminal stack follows.

## Per-tool

### Starship — `starship/.config/starship.toml`
- Dropped the hardcoded Catppuccin palette; **all colours are ANSI names** so the
  prompt tracks the live Ghostty palette.
- `[directory]` → `red`; OS icon → `bright-black`; git_status keeps semantic
  colours (staged green, modified yellow, etc.).
- `[custom.git_branch_pill]` — a self-contained per-mode pill. Detects appearance
  via `AppleInterfaceStyle` and emits raw ANSI (RGB) for the pill caps/body, so it
  can colour the *background* (a neutral grey chip — deliberately not red, so the
  red elsewhere pops). Glyphs are octal UTF-8 escapes. The per-prompt `defaults
  read` is intentional: it's the price of a precise per-mode chip, and only runs
  inside git repos.

### yazi — `yazi/.config/yazi/theme.toml`
- Overrides the `catppuccin-latte` (light) / `catppuccin-mocha` (dark) flavors
  using **ANSI names**, so folders track the palette (red in both modes).
- Folder *names* red: `[filetype].rules` restated with ANSI names (that section
  replaces wholesale rather than merging). Folder *icons* red:
  `[icon].prepend_conds` (named dirs like `.git`/`Documents` keep their flavor
  icons). cwd breadcrumb → red.
- **Gotcha:** the flavor files in `flavors/*.yazi/` are `ya pkg`-managed and
  read-only — overrides live in `theme.toml` so they survive upgrades.

### eza / `ls` / completion — `zsh/.zshrc`
- `export EZA_COLORS="di=1;31"` — red directories in `ls` (an eza wrapper).
- Tab-completion menu: `zstyle … list-colors` swaps `di=1;36`→`di=1;31`.

### fzf — `zsh/.zshrc` and `tmux/.config/tmux/tmux.conf`
- Both configs use `--color=hl:1,…` (ANSI index 1 = palette red, adaptive) with
  `bg:-1`/`preview-bg:-1` to inherit the terminal background.
- Two places: `FZF_DEFAULT_OPTS` in `.zshrc`, and the sesh-picker invocation in
  `tmux.conf`.

### tmux — `tmux/.config/tmux/`
- `tmux.conf` — the catppuccin status-bar plugin flips mocha↔latte by
  `AppleInterfaceStyle`. After TPM loads, `set -g @thm_blue "red"` repaints the
  path accent to ANSI red in **both** modes (the status format references
  `#{@thm_blue}` live). floax border → `red`. Re-applied on `prefix r`.
- `theme-light.conf` / `theme-dark.conf` — sourced after the plugin (per mode).
  These only set the surfaces that *can't* be ANSI: status bar `#ffffff`/dark text
  (light), and popup backgrounds (`#ffffff` light, `#262626` dark — catppuccin
  otherwise leaves popups on its bluish base).
- `session-list.sh` — detects appearance per-redraw; `active_prefix` is ANSI `red`
  (adaptive), other colours are per-mode hex.
- **Gotcha:** tmux can't reliably read appearance at launch, so the first paint may
  be dark until you hit `prefix r`.

### Claude Code — `~/.claude/` *(outside this repo)*
- Two custom themes in `~/.claude/themes/`: `studio-brio.json` (base `light-ansi`)
  and `studio-brio-dark.json` (base `dark-ansi`). Both use `ansi:red` /
  `ansi:redBright` for the accent (so red follows the palette) plus a per-mode
  `userMessageBackground` (neutral grey in dark, faint warm tint in light).
- **Backgrounds are explicit hex, not ANSI.** The `-ansi` bases ride the palette
  for *foreground/accent* colours (which is the point — adaptive red), but they
  flatten anything that's meant to be a subtle RGB *background* blend, because ANSI
  has 16 fixed slots and no notion of "tint the surface 8%". So every background key
  is set by hand, per mode:
  - **Diffs:** `diffAdded` / `diffRemoved` (line wash) + `diffAddedWord` /
    `diffRemovedWord` (intra-line highlight) — Mocha-toned greens/reds in dark,
    canonical GitHub-light diff colours in light. (Left at the `-ansi` default,
    added/removed lines get no wash and a diff reads as one block of dim grey.)
  - **Surfaces:** `userMessageBackground`(+`Hover`), `messageActionsBackground`,
    `bashMessageBackgroundColor` (`!` entries), `memoryBackgroundColor` (`#`
    entries), `selectionBg` — neutral greys in dark, faint warm/neutral tints in
    light.
  - **Rule of thumb:** any *foreground* colour → leave it (ANSI cascade handles it);
    any *background* colour → set it explicitly in both theme files.
- **Auto-switch:** Claude Code has no built-in light/dark follow, so the `claude`
  shell function in `.zshrc` picks the matching theme by `AppleInterfaceStyle` at
  launch and layers it with `claude --settings '{"theme":"…"}'` — settings.json is
  never rewritten. `settings.json` still lists `custom:studio-brio` as the fallback
  for launches that bypass the wrapper.
- **Gotchas:** appearance is decided at launch (switch macOS mid-session → relaunch
  to follow). Inline-code/backtick colour isn't themeable (follows the base = ANSI
  blue). Theme files hot-reload; adding/activating one needs `/theme` or a restart.

## Editing these files

The `~/.config/...` paths are GNU Stow symlinks into `~/.dotfiles/...`. **Edit the
real file under `~/.dotfiles`** — some tools refuse to write through symlinks.

`zsh` has `noclobber` set; use `>|` (not `>`) when overwriting a file via the shell.

## Changing the accent

1. Edit palette slot **1 (red)** in both Ghostty theme files
   (`ghostty/.config/ghostty/themes/`). Everything using ANSI red follows
   automatically: Starship, yazi, eza, completion, both fzf configs, the tmux
   accent/floax/session-list, and the Claude Code themes.
2. **GUI window borders don't follow** — update `#c4262b` by hand in:
   - `sketchybar/.config/sketchybar/plugins/borders.sh` (`ACTIVE_TILED`)
   - `aerospace/.config/aerospace/aerospace.toml` (`borders active_color`)
3. Starship's branch pill uses RGB literals in `[custom.git_branch_pill]` (it's a
   neutral grey chip, not red — only touch it if you want the chip recoloured).
