# Theming

A single coordinated look across the terminal stack: **Ghostty, Starship, yazi,
eza, fzf, navi, atuin, bat, delta, tmux, nvim, herdr, and Claude Code**. Two
palettes — high-contrast GitHub light and Catppuccin Mocha — with a **red
accent** throughout, switching automatically with macOS appearance.

## How it works

Ghostty is the source of truth. Its two custom palettes define every ANSI slot,
and Ghostty swaps them automatically when macOS flips light/dark:

```
theme = light:GitHub Light HC Red,dark:Catppuccin Mocha Custom
```

Almost everything is configured with **ANSI colour *names*** (`red`, `cyan`, …) or
ANSI indices (`1`) rather than hex. Those emit indexed ANSI escapes, which the
terminal renders from its *active* palette — so when Ghostty switches, the prompt,
file manager, `ls`, fzf, navi, atuin, herdr, and tmux all follow for free. No
per-tool light/dark logic.

A few tools can't ride the cascade and fork on appearance themselves instead:
- **`defaults read -g AppleInterfaceStyle`** (macOS's own appearance flag) —
  Starship's branch pill (needs raw RGB for the pill *background*), tmux's
  `session-list.sh` (needs several distinct per-mode colours), bat and delta's
  shared theme fork in `zsh/.zshrc` (neither auto-detects reliably through a
  pipe), and the Claude Code launcher. Each only forks once per render/launch.
- **`vim.o.background`** — nvim asks the *terminal* directly (an OSC 11
  background query, answered asynchronously after startup), not macOS. See
  the nvim entry under Per-tool.

### One red (almost)

The **terminal red is now a single adaptive source**: everything that references
ANSI `red` resolves to `#a0111f` in light / `#f38ba8` in dark. That covers
Starship, yazi, eza, both fzf configs, navi (via fzf), the tmux accent, floax,
the tmux session list, and herdr's `ui.accent`.

The **one exception is GUI chrome** — JankyBorders window borders (driven from
`aerospace.toml`) and sketchybar — which are drawn by macOS, not a terminal, so
there's no ANSI palette to follow. They use a fixed `#c4262b` (a middle red that
reads in both modes). That's the only red you'd ever edit by hand.

## The palette (Ghostty)

`ghostty/.config/ghostty/config`:
- `theme = light:GitHub Light HC Red,dark:Catppuccin Mocha Custom` — auto-switch
- `minimum-contrast = 2` — robustness floor: rewrites any text colour below this
  contrast ratio against its background, in every app. `2` keeps our own
  palettes visually intact but rescues dark-first third-party tools (grey-on-white)
  in light mode. Ghostty's own default is `1` (no floor); this was raised from an
  earlier `1.2`, which only barely covered the near-black/near-white outer bounds.
- `unfocused-split-opacity = 1` — don't dim inactive splits
- `font-thicken = false`, `window-theme = auto`

`ghostty/.config/ghostty/themes/` (custom, hand-edited copies of Ghostty's own
bundled themes — see "Reset playbook" for exactly what was changed and how to
revert):

| | GitHub Light HC Red | Catppuccin Mocha Custom |
|---|---|---|
| background | `#ffffff` | `#262626` |
| foreground | `#0e1116` | `#cdd6f4` |
| red (ANSI 1) | `#a0111f` | `#f38ba8` |
| cursor | `#a0111f` | `#f38ba8` |

These two files are what every ANSI-aware tool resolves against. Change a slot
here and the whole terminal stack follows.

## Dark mode, explained

Dark mode needs almost no separate configuration, because it rides the same
"resolve against the live Ghostty palette" mechanism as light mode — just
pointed at Ghostty's other slot, `Catppuccin Mocha Custom`.

**The only genuinely hand-tuned part is the Ghostty theme file itself**, and the
delta from Ghostty's own bundled `Catppuccin Mocha` is exactly two values:

| | stock `Catppuccin Mocha` | `Catppuccin Mocha Custom` | why |
|---|---|---|---|
| `background` | `#1e1e2e` | `#262626` | matches the custom "black" surface already used by tmux's popups/status bar and nvim's `color_overrides.mocha.base` — not Catppuccin's blue-leaning base |
| `cursor-color` | `#f5e0dc` (rosewater) | `#f38ba8` (mocha's own "red") | matches the shared ANSI-red accent, same idea as the light theme's cursor override |

Every other slot — every `palette = N=…` line, `foreground`, `cursor-text`,
`selection-*` — is identical to Ghostty's stock file. No light/latte hex
anywhere in it.

**The shared red-accent overrides do their job automatically in dark mode too**,
because they live in mode-agnostic files, not the per-mode ones:
- `tmux/.config/tmux/tmux.conf:203` (`@thm_blue "red"`), `:211` (`@thm_mauve
  "red"`), `:219-220` (pane border styles), `:107` (`@floax-border-color
  'red'`) — all unconditional, so dark mode gets ANSI red resolving to Mocha's
  `#f38ba8` for free.
- Starship, yazi, eza, both fzf configs, herdr's `ui.accent` — plain ANSI names,
  no mode branch was ever written for them.

**tmux's dark-only file, `theme-dark.conf`, isn't a colour delta — it's a
race-condition guard.** The catppuccin/tmux plugin sets its `@thm_*` window-list
variables with `set -og` (only-if-unset) at plugin load; if TPM's cold start
ever samples `AppleInterfaceStyle` before the shell settles, the flavor can
resolve to latte and get **locked** there for the life of the tmux server — no
later `prefix r` can dislodge it. `theme-dark.conf` force-re-asserts the correct
mocha hex values (plus status/message-bar surfaces) so `prefix r` always
recovers. The one place it adds an actual new colour: popup background is
forced to `#262626` (catppuccin's own default otherwise leaves popups on its
bluish `#1e1e2e` base) — matching the custom Ghostty background already chosen
above, not a new palette choice.

**Claude Code's dark theme** (`studio-brio-dark.json`, base `dark-ansi`) is the
dark half of the same file pair documented under Per-tool → Claude Code:
`ansi:red` accent plus hand-set background hexes tuned for the mocha palette.
Nothing new here either.

Everything else — nvim's default `catppuccin` colorscheme when `background !=
'light'`, herdr's `terminal` theme, atuin, navi, bat's `Monokai Extended` — is
each tool's own untouched plugin/theme default, no dark-specific work of ours
involved.

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

### navi — no dedicated config
- No `~/.config/navi/config.yaml` exists, so navi uses its bundled default
  `fzf` finder unmodified — which means it inherits `$FZF_DEFAULT_OPTS`
  (`zsh/.zshrc:196`) exactly like every other fzf caller: ANSI red (`hl:1`) on
  an inherited, unfilled background. Nothing to configure; it rides the fzf
  section above for free.

### atuin — `atuin/.config/atuin/config.toml`
- `[theme]` is fully commented out — no override. Every colour atuin emits
  (header/footer text, tab labels, history rows, selected row) is a plain ANSI
  index (0–15), so it's already fully adaptive off Ghostty's live palette —
  architecturally identical to Starship/yazi/eza: fully ANSI-clean, no
  per-mode fork needed.
- **Watch:** the "Search" tab label uses ANSI **bright-white** (index 15),
  which on `GitHub Light HC Red` is `#88929d` — 3.16:1 against white,
  borderline (passes WCAG only for large/bold text). It's the same
  "index-15-is-the-faint-one" trait of this palette that broke herdr's
  `overlay1` (see Herdr, below). Left alone here — atuin exposes no token to
  remap it, and the label is short and bold — but it's the lightest-contrast
  surviving element in the whole stack.

### bat — `zsh/.zshrc`
- bat 0.25+ auto-detects the terminal background itself, but detection fails
  when its output is piped — exactly what fzf's file preview does
  (`show_file_or_dir_preview`, `zsh/.zshrc:214`) — and falls back to a **dark**
  theme, so light-mode previews rendered dark syntax colours on a white
  background.
- Fixed by exporting `BAT_THEME` explicitly at shell init (`zsh/.zshrc:247-252`),
  the same `AppleInterfaceStyle` fork already used by the Claude Code launcher:
  light → `GitHub`, dark → `Monokai Extended` (bat's previous default,
  unchanged, to preserve the existing dark-mode look).
- **Gotcha:** this is a hard pin, not detection. If bat's own background
  auto-detect is ever fixed for piped output, this override would need
  revisiting so it doesn't fight a now-correct default.
- **Gotcha:** the fork only runs at shell init, so an already-open shell keeps
  whatever `BAT_THEME` it started with until a new shell starts — the same
  "read once, not live" class as tmux's first-paint gotcha, below.

### git / delta — `git/.gitconfig`, `zsh/.zshrc`
- delta does **not** auto-detect the way an earlier version of this doc
  claimed. `--detect-dark-light auto` (delta's real detection flag) only flips
  the diff *decoration* mode (line-background wash) — a separate mechanism
  from `syntax-theme`, which always stays pinned to whatever `[delta]
  syntax-theme` says, regardless of terminal background.
- `[delta] syntax-theme = "Catppuccin Mocha"` (`git/.gitconfig:13`) is
  dark-only, permanently. In light mode this rendered a dark "card" behind
  every diff line (Mocha's pastel foreground on a near-black background wash)
  — measured contrast as low as 1.3:1, well under WCAG's 4.5:1 minimum.
- Fixed the same way as bat: a `[delta "github-light"]` feature block
  (`git/.gitconfig:18-20`, `light = true` + `syntax-theme = GitHub`) activated
  per-appearance by exporting `DELTA_FEATURES="+github-light"` in the light
  branch of the same fork bat uses (`zsh/.zshrc:253-255`). Dark mode
  explicitly `unset`s `DELTA_FEATURES` (`zsh/.zshrc:249-250`), so delta falls
  through to the base `[delta]` config (pinned Mocha, unchanged) — the
  explicit unset matters because a tmux server started in light mode can
  otherwise leak `+github-light` into a pane that later flips to dark.
- **Gotcha:** `syntax-theme` and `--detect-dark-light` are independent knobs —
  setting one does not cover the other.
- **Gotcha:** already-open shells keep the old `DELTA_FEATURES` until a new
  shell starts, for the same "read once, not live" reason as bat's gotcha
  above and tmux's first-paint gotcha, below.

### tmux — `tmux/.config/tmux/`
- `tmux.conf` — catppuccin/tmux flips mocha↔latte by `AppleInterfaceStyle`
  (`@catppuccin_flavor`, :163-165). After TPM loads, `@thm_blue`/`@thm_mauve`
  are repainted to ANSI `red` (:203, :211) so the path accent and current-window
  pill track the live Ghostty palette in **both** modes. `pane-active-border-style`
  / `pane-border-style` are set to `fg=red` directly (:219-220) — **all pane
  borders are red in both modes** (previously latte lavender `#7287fd` leaked
  through in light mode). floax border → `red` (:107). Re-applied on `prefix r`.
- `theme-light.conf` is now the **complete** light-mode chrome — every surface
  catppuccin's `latte` flavor can't cover with an ANSI name gets a literal
  GitHub Light value:
  - **Window-list `@thm_*` force-set** (defeats catppuccin's `set -og`
    only-if-unset lock so these actually take effect):

    | Variable | Catppuccin latte (was) | GitHub Light (now) | Role |
    |---|---|---|---|
    | `@thm_crust` | `#dce0e8` | `#ffffff` | text on coloured pills (number, current-window) |
    | `@thm_fg` | `#4c4f69` | `#0e1116` | window-name text |
    | `@thm_overlay_2` | `#7c7f93` | `#66707b` | number-pill background |
    | `@thm_overlay_0` | `#9ca0b0` | `#d0d7de` | right-click menu selected-item background |
    | `@thm_surface_0` | `#ccd0da` | `#eaeef2` | inactive window-name chip background |
    | `@thm_surface_1` | `#bcc0cc` | `#d0d7de` | current window-name chip background |
    | `@thm_yellow` | `#df8e1d` | `#9a6700` | zoom badge in status-left |

  - **Direct surface overrides:** status bar (`bg=#ffffff,fg=#0e1116`), popups
    (`bg=#ffffff,fg=#0e1116`, silver border `#d0d7de`), messages/command-prompt
    (`fg=#0e1116` on the white bar — was teal `#179299`), copy-mode selection
    (white-on-black, mirrors Ghostty's own `selection-*`), copy-mode search
    (pale-yellow wash for matches, red for the current match/mark — mirrors
    the Ghostty cursor red), `@bar_bg` / `@floax-text-color` for the extra
    status rows and the floating pane.
  - **No latte value renders in light mode.** The plugin's own
    `@catppuccin_status_*` module variables still *contain* latte hexes
    (`#7287fd`, `#179299`), but they're dead here — status-right is
    overridden to blank space, so nothing reads them.
- `theme-dark.conf` — mirrors the above for dark, but is mostly a
  race-condition guard rather than a colour change (see "Dark mode,
  explained").
- `session-list.sh` — detects appearance per-redraw; `active_prefix` is ANSI
  `red` (adaptive), other colours are per-mode hex.
- **Gotcha:** tmux can't reliably read appearance at launch, so the first paint
  may be dark until you hit `prefix r`.

### nvim — `nvim/.config/nvim/init.lua`
- Two colorscheme plugins, picked by `vim.o.background` rather than
  catppuccin's own `flavour = 'auto'` (which only knows mocha/latte — no
  GitHub theme option):
  - `projekt0n/github-nvim-theme` (`:805-809`, `github_light_high_contrast`
    variant) for light.
  - `catppuccin/nvim` (`:811-846`) for dark — `flavour = 'auto'` is still set
    for its own internal bookkeeping, but `color_overrides.mocha.base =
    '#262626'` (`:823-827`) matches the custom Ghostty/tmux "black" surface.
- `pick_colorscheme()` (`:833-839`) runs once at setup and again on an
  `OptionSet` autocmd for `background` (`:841-844`) — `background` arrives
  asynchronously from the terminal's OSC 11 reply *after* nvim finishes
  starting, so the autocmd (not the synchronous initial call) is what catches
  the real value in normal use.
- **Gotcha:** `:help OptionSet` — "Not triggered on startup." A headless
  `nvim --headless "+set background=light" ...` invocation (scripted testing
  only, not real usage) never fires the autocmd, and falls through to
  catppuccin's own built-in "`background` changed → reload colorscheme" hook,
  which then self-picks `catppuccin-latte` instead of
  `github_light_high_contrast`. Confirmed this does **not** happen in a real
  attached terminal — OSC 11 arrives after startup finishes, so the autocmd
  fires and picks correctly. It's a startup-timing artefact of batching
  `-c`/`+cmd` flags in a headless test harness, not a real-usage bug.

### herdr — `herdr/.config/herdr/config.toml`
- **Split base themes per appearance** (`:27-30`): `auto_switch = true` with
  `dark_name = "terminal"` / `light_name = "catppuccin-latte"`. Dark mode
  rides the host ANSI palette (the same "ride Ghostty" approach as
  tmux/yazi/eza/fzf); light mode can't — the terminal theme's *surface*
  tokens are hardcoded dark-first (`surface_dim` = ANSI bright black, a dark
  slate `#4b535d` in GitHub Light HC, drawn as a dark bar behind the selected
  sidebar row), and GitHub Light HC has no pale ANSI slot at all, so no
  single adaptive override can fix a surface for both modes. Latte's neutral
  pale surfaces stand in until upstream fixes the terminal theme
  (filed: `github.com/ogulcancelik/herdr/issues/1731`).
- `text = "reset"` + `panel_bg = "reset"` (`:56-57`) pin body text and panel
  background to the real terminal colours in both modes, so the latte base
  only contributes surfaces, not ink. `ui.accent = "red"` (`:68`) for the
  shared accent.
- **Gotcha:** `[theme.custom]` values apply on top of *whichever* base
  `auto_switch` picked — every custom value must work on both backgrounds
  (named-ANSI or `reset` only; a hex would break one of the two modes).
- **Gotcha:** opening herdr's in-app theme settings writes the picked theme
  back into `config.toml` and force-writes `auto_switch = false` with it
  (`save_theme()`, `src/app/config_io.rs`) — silently disabling the split.
  If the dark selection bar returns, check that flag first. Theme changes
  belong in the config file, not the in-app picker. Related trap: with no
  detected terminal background, `auto_switch` assumes **dark**
  (`appearance.unwrap_or(Dark)`, `src/app/mod.rs`), so a client that never
  answered the OSC 11 query renders the dark base — reattach to fix.
- herdr 0.7.4 ships as a single closed-file Rust binary with no on-disk theme
  assets. The canonical `[theme.custom]` token list (16 keys — `accent,
  panel_bg, surface0, surface1, surface_dim, overlay0, overlay1, text,
  subtext0, mauve, green, yellow, red, blue, teal, peach`) came from
  `https://herdr.dev/docs/config-reference/`, cross-checked directly against
  herdr's own (AGPL-3.0, public) source at `github.com/ogulcancelik/herdr`.
- **The overlay1 fix (`:50`):** `overlay1 = "gray"`. herdr's built-in `terminal`
  palette (`src/app/state.rs::terminal()`) maps most secondary-text tokens to
  `Color::Gray` (ANSI 7), but singled out `overlay1` for `Color::White` (ANSI
  15) instead — the token behind the selected-workspace-number badge in the
  collapsed sidebar rail and the body text of the settings/help/onboarding/
  release-notes overlays. `GitHub Light HC Red` deliberately makes ANSI 15
  (`#88929d`) fainter than ANSI 7 (`#66707b`) — matching GitHub's own
  high-contrast "placeholder text" grey, which inverts the usual "bright white
  is brighter" assumption. Result: `overlay1` rendered at 3.16:1 (fails WCAG
  AA) while its sibling tokens sat at 5.04:1. Re-pointing it at the same ANSI
  index its siblings already use is a one-line, **named-colour (not hex)**
  fix, so it keeps tracking Ghostty's live palette automatically in both
  appearances (5.04:1 light / 6.80:1 dark — still comfortably AA, no dark-mode
  loss).
- **What it wasn't:** the working hypothesis going in was that herdr's *body
  text* was hardcoded to ANSI white. That was wrong — `text` was already
  `Color::Reset` (correctly adaptive) before this fix touched anything; the
  actual defect was the one outlier secondary token, not the foreground.
- **Residual, not config-fixable:** herdr hardcodes `Modifier::DIM` onto
  `overlay0` at several sidebar call sites (`src/ui/sidebar.rs`). SGR "faint"
  is conventionally an intensity/blend reduction toward the background, which
  can push an already-AA-passing colour below Ghostty's own
  `minimum-contrast` floor with no `theme.custom` token able to prevent it —
  style modifiers aren't configurable, only colours are. **Filed upstream** as
  `github.com/ogulcancelik/herdr/issues/1729` (observed-behaviour bug report,
  per their contribution policy); a built-and-tested 3-file patch waits on
  the `shanegriffiths/herdr` fork branch `fix/terminal-theme-dim-contrast`
  should a maintainer approve the PR path (first attempt, PR #1727, was
  auto-closed by their new-contributor policy bot — process, not rejection).
- See "Adding a new tool (the Herdr lesson)" below for the general checklist
  this produced.

### Claude Code — `claude/.claude/themes/`
- Two custom themes in `~/.claude/themes/` (stowed from the `claude` package):
  `studio-brio.json` (base `light-ansi`)
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

## Reset playbook

Every layer below has a stock/default state it can be reset to, and an exact
place the custom delta lives. "Stock base" is what you'd get by deleting the
custom delta entirely; none of this is aspirational — every cell is a real
file you can go read.

| Layer | Stock base | Custom delta (file:lines) | To reset |
|---|---|---|---|
| Ghostty light theme | Ghostty-bundled `GitHub Light High Contrast` (`/Applications/Ghostty.app/Contents/Resources/ghostty/themes/GitHub Light High Contrast`) | `ghostty/.config/ghostty/themes/GitHub Light HC Red:1` (header comment), `:20-21` (`cursor-color`, `cursor-text`) | `cp "/Applications/Ghostty.app/Contents/Resources/ghostty/themes/GitHub Light High Contrast" "ghostty/.config/ghostty/themes/GitHub Light HC Red"` |
| Ghostty dark theme | Ghostty-bundled `Catppuccin Mocha` (`/Applications/Ghostty.app/Contents/Resources/ghostty/themes/Catppuccin Mocha`) | `ghostty/.config/ghostty/themes/Catppuccin Mocha Custom:17` (`background`), `:19` (`cursor-color`) | `cp "/Applications/Ghostty.app/Contents/Resources/ghostty/themes/Catppuccin Mocha" "ghostty/.config/ghostty/themes/Catppuccin Mocha Custom"` |
| Ghostty contrast floor | `minimum-contrast = 1` (Ghostty's own default — confirmed via `ghostty +show-config --default`) | `ghostty/.config/ghostty/config:16-19` | delete those 4 lines (comment + `minimum-contrast = 2`) |
| tmux chrome | catppuccin/tmux plugin defaults (mocha/latte via `@catppuccin_flavor`, no forced surfaces) | `tmux/.config/tmux/theme-light.conf` (whole file), `theme-dark.conf` (whole file), `tmux.conf:199-220` (red-accent + border block), `:239-241` (the if-shell that sources the two `theme-*.conf` files) | delete both `theme-*.conf` files, remove the sourcing if-shell (`:239-241`) and the red-accent block (`:199-220`); `prefix r` to reload |
| bat | bat's own background auto-detect (broken when output is piped) | `zsh/.zshrc:243-256` (the `AppleInterfaceStyle` fork wrapping `BAT_THEME`) | delete that block; `unset BAT_THEME` |
| delta | delta's `--detect-dark-light auto` (flips decoration only, never `syntax-theme`) | `git/.gitconfig:9-20` (`[delta]` + `[delta "github-light"]`), `zsh/.zshrc:249-250` (dark-branch `unset DELTA_FEATURES`), `zsh/.zshrc:253-255` (`DELTA_FEATURES` export) | delete the `[delta "github-light"]` block, the `unset DELTA_FEATURES` line, and the `DELTA_FEATURES` export line; `syntax-theme` stays whatever `[delta]` says, unconditionally |
| herdr | herdr's built-in `terminal` palette (`Palette::terminal()`, herdr 0.7.4 source) | `herdr/.config/herdr/config.toml:20-35` (`[theme.custom]`, `overlay1 = "gray"`) | delete the `[theme.custom]` block; `herdr server reload-config` |
| nvim | catppuccin's own `flavour = 'auto'` (mocha/latte only, no GitHub theme) | `nvim/.config/nvim/init.lua:805-809` (`github-theme` lazy spec), `:829-844` (`pick_colorscheme` + `OptionSet` autocmd) | delete the `github-theme` spec block; replace the `pick_colorscheme`/autocmd pair with the bare `vim.cmd.colorscheme 'catppuccin'` call it replaced |
| Claude Code themes | Claude Code's built-in themes (e.g. `light-ansi` / `dark-ansi`, or plain `light` / `dark`) | `claude/.claude/themes/studio-brio.json`, `studio-brio-dark.json` (whole files); `~/.claude/settings.json` `"theme"` key (**not** stow-managed — a real file outside `~/.dotfiles`); `zsh/.zshrc:262-269` (the `claude` launcher function) | `rm ~/.claude/themes/studio-brio*.json`; edit `"theme"` in `~/.claude/settings.json` back to a built-in name; delete the `claude` function override in `.zshrc` |

### Rebasing onto a new palette

Generalises "changing the accent" from a single-slot swap into a full-palette
swap:

1. **Edit both Ghostty theme files first** — not just palette slot 1, every
   `palette = 0..15` line plus `background`/`foreground`/`cursor-*` — in
   `GitHub Light HC Red` and `Catppuccin Mocha Custom`. Everything that rides
   the ANSI cascade follows automatically: Starship, yazi, eza, completion,
   both fzf configs, navi, atuin, the tmux accent/floax/session-list, herdr,
   and nvim's dark-mode fallback.
2. **Then the short list of files that hold literal hex and don't ride the
   cascade:**
   - `tmux/.config/tmux/theme-light.conf` — the GitHub-Light surface hexes
     (`@thm_overlay_2`, `@thm_surface_0`/`@thm_surface_1`, `@thm_overlay_0`,
     `@thm_yellow`, and the `mode-style`/`copy-mode-*`/`message-*`/`popup-*`
     literals) were hand-picked to match the *current* light palette and need
     re-picking for a new one.
   - GUI chrome's fixed `#c4262b` —
     `sketchybar/.config/sketchybar/plugins/borders.sh:7` and
     `aerospace/.config/aerospace/aerospace.toml:6`.
   - Claude Code themes' backgrounds — `diffAdded`/`diffRemoved` (+`Word`),
     `userMessageBackground` (+`Hover`), `messageActionsBackground`,
     `bashMessageBackgroundColor`, `memoryBackgroundColor`, `selectionBg` in
     both `studio-brio.json` and `studio-brio-dark.json` — hand-tuned RGB
     blends, not ANSI references.
3. Starship's branch pill RGB literals in `[custom.git_branch_pill]` — only if
   the new palette's neutral-grey chip should change tone too.

## Adding a new tool (the Herdr lesson)

Herdr looked done after one config line (`theme = "terminal"`) — and mostly
was. What it revealed is that "the tool has an ANSI/terminal theme mode" is
necessary, not sufficient. The checklist this produced:

1. **Prefer the tool's terminal/ANSI theme mode** over anything that ships its
   own fixed palette — that's what buys the free light/dark follow described
   in "How it works".
2. **Light-mode smoke test *before* trusting it.** Don't assume "terminal
   mode" means every token is actually ANSI-clean — look at body text,
   selection/highlight colour, and borders against a real white background.
3. **If something's washed out, suspect an ANSI-white (index 15) token before
   anything else** — several palettes (this one included, see atuin's watch
   item and herdr's `overlay1` above) deliberately make "bright white" the
   *faintest* grey, not the brightest, which breaks tools that assume
   otherwise. Read the tool's actual source/palette definition rather than
   guessing which token is wrong — herdr's first hypothesis (body/foreground
   text) was wrong; the real defect was one secondary token pinned to the
   wrong ANSI index. Fix by overriding that specific token (named colour, not
   hex, so it keeps tracking the live palette) or, if the tool has no such
   token, forking per-mode like bat/delta do.
4. **Record it here** — add a Per-tool entry (mechanism, the fix if any, and
   any residual/config-unfixable gotcha) so the next tool audit starts from
   evidence, not memory.
