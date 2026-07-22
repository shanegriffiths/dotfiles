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

## Task 4 — spot-audit of the ANSI-clean tools

macOS confirmed in light mode for this entire audit (`defaults read -g AppleInterfaceStyle` → unset/Light). Method note: Ghostty is the live terminal, but this session runs inside tmux (session `skillsight`); rendered-output checks used a scratch tmux window created for the check and killed immediately after (`tmux new-window` → `send-keys`/`capture-pane -e` → `tmux kill-window`), never touching Shane's existing windows/panes. One quirk: `tmux send-keys` only reaches a shell's key-table/zle bindings reliably when sent as a **named key** (`C-r`) or a **literal byte** (`-l $'\x12'`) to a pane that has fully finished shell init — chained prefix sequences (`C-a` then `C-n`) did **not** dispatch through tmux's prefix table when injected this way (the client-side key-table state isn't tracked for a non-attached scripted pane), so navi's `prefix Ctrl+N` binding was verified by running its underlying command (`navi --print`) directly instead.

### starship — PASS
`starship prompt` rendered in `~/.dotfiles` (a git repo):
```
%{^[[90m%}…%{^[[31m%} .dotfiles %{^[[0m%}…%{^[[38;2;208;215;222m%}…%{^[[48;2;208;215;222;38;2;36;41;47m%} … main %{^[[0m%}…%{^[[96m%}…%{^[[0m%}
```
- Directory: `ESC[31m` — ANSI red. ✓
- Branch pill: raw RGB `208;215;222` (cap) / `48;2;208;215;222;38;2;36;41;47` (body) — matches the config's light-mode branch (`cd`/`gd` != Dark path), a legible light-silver chip with dark text. ✓
- git_status: `96m` (bright cyan, untracked count) — legible on white. ✓

### yazi — PASS
Live-rendered via a scratch tmux window (`yazi` launched, pane captured, `q` + window killed):
- Folder names/icons: `38;5;1` (ANSI red) throughout the listing and the `~/.dotfiles` breadcrumb at top. ✓
- `border_style`/`[spot].border` use a hardcoded `#262626` (not ANSI) — confirmed legible: contrast **15.1:1** against white. Not mode-forked, but it's dark-grey-on-white in both directions of contrast so it isn't a light-mode regression (it would only be a *dark*-mode concern if it ever matches the dark bg, which is out of this task's scope).
- No dark surfaces: selected-row highlight uses reverse-video (`7m`) against the terminal's own colours, not a hardcoded dark fill.

### eza + completion — PASS
```
$ zsh -ic 'echo $EZA_COLORS'
EZA_COLORS=di=1;31
```
`zsh/.zshrc:66`: `zstyle ':completion:*' list-colors "${(s.:.)${LS_COLORS/di=1;36/di=1;31}}"` — swaps completion-menu directory colour from cyan to red, same `1;31` as `EZA_COLORS`.
Rendered proof (`ls -la /tmp`, eza aliased): directory entries show `ESC[1;31m` around the name. ✓
(Aside, not a theming issue: `eza`/`ls` with no path argument returned 0 output in this sandboxed shell unless `COLUMNS` was set explicitly or a path was passed — an environment quirk of this harness, not a dotfiles config bug; confirmed by testing `eza -la .` and `eza -la /tmp` which both worked normally.)

### fzf (both configs) — PASS
- `zsh/.zshrc:196`: `FZF_DEFAULT_OPTS="--height 50% --layout=default --border --color=hl:1,hl+:1,bg:-1,preview-bg:-1"`
- `tmux/.config/tmux/tmux.conf:116` (sesh picker): `--color 'hl:1,bg:-1,preview-bg:-1'`
Both use ANSI index 1 (red) for the match highlight and `-1` (inherit) for bg/preview-bg — identical pattern, config-level confirmed identical to THEME.md.
Rendered proof came via the navi test below (same `fzf` binary, same `$FZF_DEFAULT_OPTS`): typing a query produced `ESC[31m` around every matched substring, on the terminal's inherited (white) background — no `48;...` full-screen fill anywhere. Direct interactive capture of the zshrc `Ctrl+T` widget was attempted but proved unreliable to script (an orphaned `fzf` process was left behind by one attempt — a scripted-pane artifact of the tmux/pty test harness, not related to Shane's real usage; it was identified as not belonging to any live pane via `tmux list-panes -a` and killed). Given the identical `$FZF_DEFAULT_OPTS`/binary is proven live via navi, this is not treated as a gap — see checkpoint list.

### navi — PASS
Ran `navi --print` in a scratch tmux window, typed `git` as a query, captured pane:
```
…[48;5;236m▌[39m [31mgit[96m…   (repeated across ~44 matching rows)
```
- Matched substring "git" renders `ESC[31m` (ANSI red) — confirms `hl:1` from `$FZF_DEFAULT_OPTS` is honoured (no `navi/config.yaml` exists, so navi uses its default `fzf` finder, unmodified).
- List background inherits the terminal (no full-screen `48;...` fill); selected-row marker `▌` uses `38;5;161` (pink-red) on a small `48;5;236` (dark-grey) highlight strip — a normal inverted-highlight-bar pattern (fzf's own default `bg+`, not overridden), legible and self-contained, not a "dark surface" bug.
- Border/prompt/count chrome uses muted blue-grey (`38;5;59`) and blue (`38;5;110`) — legible on white.

### atuin — PASS (see checkpoint)
Confirmed `atuin/.config/atuin/config.toml` has `[theme]` fully commented out — no theme override, matching the brief's premise. `[tmux].enabled = true` is set (popup mode), but the live capture (see method note above) rendered atuin's UI **inline** in the scratch pane rather than as a tmux popup — worth Shane double-checking in a real popup context (checkpoint list).
Rendered capture of `Ctrl+R` (`atuin-search` bound via `zsh/.zshrc:183`):
- Header/help footer text uses ANSI **bright-black** (`38;5;8`) → Ghostty light palette index 8 = `#4b535d`, contrast **7.8:1** on white. ✓
- Active "Search" tab label uses ANSI **bright-white** (`38;5;15`) → Ghostty light palette index 15 = `#88929d`, contrast **3.16:1** on white — passes WCAG for large/bold text, borderline for anything smaller. This is the single lightest-contrast element rendered; flagged for Shane's eyeball.
- History rows: duration coloured green/red by speed (ANSI 2/1, ordinary "fast vs slow" semantics, both legible), timestamps blue (ANSI 4), selected row bold ANSI red (`1m` `38;5;1`). All ride the live Ghostty palette (ANSI 0–15 indices only — no raw RGB anywhere in atuin's own output), so this is architecturally identical to Starship/yazi/eza: fully ANSI-clean, ergo automatically light-mode-safe. No `[theme]` override needed.

### session-list.sh + resurrect/sesh preview scripts — PASS
`tmux/.config/tmux/session-list.sh` called live (`~/.config/tmux/session-list.sh "skillsight" "0"`) against the real running session list:
```
#[range=user|skillsight,fg=#0e1116,bold]…skillsight#[norange]#[fg=#d0d7de,none] … 
```
- Current session: `fg=#0e1116` (matches Ghostty light `foreground`), other sessions: `fg=#6e7781` (muted grey), separators: `fg=#d0d7de` (GitHub silver) — exactly the light branch in the script.
- Prefix-active state verified by calling with `"1"`: current-session colour switches to `fg=red,bold`. ✓
`sesh-preview.sh`, `resurrect-pick.sh`, `resurrect-preview.sh` — read in full: none emit ANSI colour codes at all (plain text only); all colouring comes from the fzf `--color` options at the call site (already verified above), so there is no separate light/dark logic needed and none to audit.

### git / delta — FINDING (not fixed; STOP-and-report per brief)
**Expected PASS per brief ("config already auto-detects, delta ≥ 0.18"); actual result contradicts that.**

`git/.gitconfig`:
```
[core]
	pager = delta
[delta]
	# dark/light auto-detected from the terminal background (delta >= 0.18)
	syntax-theme = "Catppuccin Mocha"
	navigate = true
	side-by-side = true
	line-numbers = true
	hyperlinks = true
```
`syntax-theme` is pinned to a single, dark-only theme. Two problems compound:
1. Delta's real terminal-background auto-detection (`--detect-dark-light`, default `auto`) is a *separate* flag from `syntax-theme` and isn't overridden here — but even when it fires, it only flips the `--light`/`--dark` decoration mode; it does **not** change `syntax-theme`, which stays pinned to Catppuccin Mocha regardless.
2. `syntax-theme = "Catppuccin Mocha"` alone determines delta's code-token colours (pastel lavender/pink/teal/green, tuned for a dark background) independent of the `--light`/`--dark` flag.

**Live proof (real tmux/Ghostty pane, light mode, not a piping artefact):**
```
$ git log -p -1 --color=never | delta --paging=never
```
→ added lines get background `48;2;0;40;0` (near-black dark green), removed lines `48;2;63;0;1` (near-black dark red/maroon), word-level emphasis `48;2;0;96;0` / `48;2;144;16;17` — a dark "card" sitting inside an all-white terminal, on every single diff. Confirmed both via direct piping and via a genuine tmux pane capture (same result both ways) — this is not a test-harness artefact.

**Tried to reproduce the "textbook fix" and it makes things worse, not better:**
```
$ git log -p -1 --color=never | delta --light   # forces the decoration mode, theme still pinned
```
→ plus-line background flips to a pale `48;2;208;255;208`, but the syntax-highlighted text is still Catppuccin Mocha's pastel foreground colours (e.g. `205;214;244`, `243;139;168`) — measured contrast against that pale background: **1.3:1 to 2.1:1** (genuinely illegible; WCAG minimum is 4.5:1). So simply adding a light/dark fork to the existing config is **not** a trivial fix — the syntax-theme itself has to change too, or highlighting has to be dropped, per mode.

**Confirmed via `--syntax-theme=none --light`:** decorations render correctly (pale green/red backgrounds, default terminal foreground for code, ANSI-coloured line-number/hunk-header chrome) — proving the fix is tractable, just not a one-line change.

**Per the brief's STOP-and-report rule, not implemented. Options for Shane to choose from:**
1. **Simplest:** drop `syntax-theme` entirely (rely on delta's default/no highlighting) and add `detect-dark-light = auto` (or `--light`/`--dark` via a wrapper) — loses Catppuccin Mocha code-token colouring in dark mode too.
2. **Match bat's precedent (Task 3):** replace `core.pager = delta` with a tiny wrapper script that forks on `defaults read -g AppleInterfaceStyle` (same pattern as `BAT_THEME`/Starship's branch pill) and execs `delta --light --syntax-theme="GitHub"` vs `delta --dark --syntax-theme="Catppuccin Mocha"`. Keeps the nicer dark-mode theme; costs one new script file + one gitconfig line change.
3. **Cheapest one-line change (but changes dark mode too):** set `syntax-theme = "GitHub"` unconditionally, matching bat's light choice — sacrifices the deliberately-chosen dark-mode Catppuccin Mocha rendering.

Recommend option 2 to Shane (mirrors the already-established bat/starship/tmux/Claude-launcher per-mode-fork pattern in THEME.md), but this is his call.

### GUI chrome (sketchybar / JankyBorders) — PASS, document-only
```
sketchybar/.config/sketchybar/plugins/borders.sh:7:  ACTIVE_TILED="0xFFC4262B"
aerospace/.config/aerospace/aerospace.toml:6:  'exec-and-forget borders active_color=0xFFC4262B …'
```
Both still hardcode `0xFFC4262B` (`#c4262b`), matching THEME.md exactly — unaffected by this work, as expected (drawn by macOS, not the terminal palette). No config drift found. Visual confirmation is Shane's eyeball item only (see checkpoint).

## checkpoint — Shane must eyeball

Everything below is config-verified and/or rendered-in-a-scratch-pane, but only a real look at the actual apps (in a live Ghostty window, not a scripted capture) can close it out:

1. **atuin `Ctrl+R`** — confirm it actually opens as a **tmux popup** (per `[tmux].enabled = true` in `atuin/.config/atuin/config.toml`) rather than inline, and that the popup's "Search" tab label (the lightest-contrast element found, `#88929d` on white, 3.16:1) reads comfortably at your normal font size.
2. **git/delta — the FINDING above.** Run `git log -p` or `git diff` on something with real changes, directly in Ghostty (not piped), and confirm what you actually see: a dark green/red "card" behind every diff line (what the automated tests captured), or something else. Either way it needs one of the three fix options above — your call on which.
3. **fzf `Ctrl+T`** (zshrc widget) — full-screen interactive check; scripted capture of this one specific path was unreliable (see method note above), though the identical config/binary was proven live via navi.
4. **yazi** — a live look, since the rendered capture only proves the ANSI codes were emitted correctly, not the actual terminal glyph/box-drawing rendering (nerd-font glyphs, icon legibility).
5. **sesh picker** (`prefix t`) and **navi** (`prefix Ctrl+N`) — the *tmux-bound* entry points specifically (this audit verified the underlying fzf/navi invocations directly, not the prefix key-chord launch path, since tmux prefix-chord dispatch couldn't be scripted reliably — see method note above).
6. **GUI chrome** (sketchybar bar + JankyBorders window border) — config confirms `#c4262b` is untouched; a glance confirms it still reads correctly against both light desktop wallpaper and light-mode window chrome.

## delta (fix)

**Implementation:** Option 2 (feature-fork pattern, matching bat/starship per-mode precedent).

`git/.gitconfig`: replaced the false "auto-detected" comment with clarification that `syntax-theme = "Catppuccin Mocha"` is pinned for dark mode only. Added a `[delta "github-light"]` feature block with `light = true` and `syntax-theme = GitHub`.

`zsh/.zshrc`: extended the BAT_THEME appearance conditional to export `DELTA_FEATURES="+github-light"` in the light branch. Dark mode leaves `DELTA_FEATURES` unset, so delta uses the base `[delta]` config (pinned Mocha, no feature overlay).

**Verification (light mode):**
- `zsh -ic 'echo $DELTA_FEATURES'` → `+github-light` ✓
- `delta --show-syntax-themes | grep GitHub` → lists `GitHub` theme ✓
- `git log -p` renders with light syntax colours (no dark background fills `48;2;0;40;0` / `48;2;63;0;1`), added lines green, removed lines red ✓
- Dark mode test deferred (not in dark mode during audit); dark branch produces no `DELTA_FEATURES` export, ergo config stays pinned to Mocha ✓ (confirmed by code inspection)

## nvim

Task 5b (follow-up to Task 5's GitHub-light decision). Last non-GitHub-light surface in the whole terminal stack (`init.lua` catppuccin spec, ~line 805) — was pinned to Latte for light mode. Now background-driven: GitHub Light HC in light mode, Catppuccin Mocha in dark (custom `#262626` base untouched).

**Implementation:** Added `projekt0n/github-nvim-theme` (`name = 'github-theme'`, `priority = 1000`) as its own lazy spec next to catppuccin's. Replaced catppuccin config's trailing `vim.cmd.colorscheme 'catppuccin'` with a `pick_colorscheme()` function keyed off `vim.o.background`, called once at setup and re-run on an `OptionSet` autocmd for `background` (per brief, verbatim).

**Step 3 — headless install + verification:**
- `nvim --headless "+Lazy! sync" +qa` → ran to completion, exit code 0, no errors. Output is a very long per-plugin fetch/status/checkout/log dump (the "UI issues headless" the brief anticipated — Lazy's floating-window UI renders as a linear log in `--headless`, not an error). `github-theme` lines confirm clean fetch/checkout (`Finished task fetch in 364ms`, `Finished task checkout in 0ms`, no error lines anywhere in the log).
- Confirmed `github_light_high_contrast` exists before relying on it: `ls ~/.local/share/nvim/lazy/github-theme/colors/` lists it alongside 10 other github-theme variants. Not blocked.
- `nvim --headless "+set background=light" "+lua print(vim.g.colors_name)" +qa` → **`catppuccin-latte`**, not the expected `github_light_high_contrast`.
- `nvim --headless "+lua print(vim.g.colors_name)" +qa` (default/dark) → `catppuccin-mocha` — matches expectation (catppuccin always reports its flavour-qualified name, not bare `catppuccin`).

**Root cause of the light-mode headless mismatch (diagnosed, not patched — brief says exact code only):**
1. `:help OptionSet` states plainly: "Not triggered on startup." All of Step 3's `+cmd`/`-c` flags execute during nvim's startup phase, so our `OptionSet` autocmd on `background` never fires in this exact headless invocation — confirmed directly: an ad-hoc debug autocmd (writing to a file, to rule out stdout buffering) never fired for `background`, `number`, or `*` when set via `+set`/`+lua vim.cmd('set ...')`/`+lua vim.o.x = ...` in the same command batch, for any option, not just `background`.
2. Independent of our autocmd, Nvim has a separate **hardcoded** behaviour (`:help 'background'`): "When a color scheme is loaded (`g:colors_name` is set) changing `'background'` will cause the color scheme to be reloaded." Catppuccin's `flavour = 'auto'` leans on exactly this hook — its `colors/catppuccin-mocha.lua` reload recomputes the flavour from the *current* `vim.o.background` whenever background changes, independent of any autocmd. So `+set background=light` triggers Nvim's built-in reload of `catppuccin-mocha` → catppuccin's own auto-logic sees `background=light` and self-switches to `catppuccin-latte` — and since our `OptionSet` callback never runs in this startup-batch scenario, nothing overrides it back to `github_light_high_contrast`.
3. Confirmed the pick logic itself is correct in isolation: `nvim --headless --cmd "set background=light" "+lua print(vim.g.colors_name)" +qa` (background set via `--cmd`, i.e. *before* init.lua/plugins load, not via a startup `-c`) → `github_light_high_contrast`, correctly, on the very first `pick_colorscheme()` call.

**Step 4 — live tmux check (the check that actually matters for real usage):**
- First attempt used a scratch window in tmux session `lifeOS` (not the attached one) — nvim never auto-detected background (stayed `BG=dark COLORS=catppuccin-mocha` after 6s). Root cause: `tmux list-clients` showed the only attached client (`/dev/ttys001`, `xterm-ghostty`) is on session `shanegriffiths`; `lifeOS` had no live terminal to answer the OSC 11 background query. Cleaned up (`:qa!` then `tmux kill-window -t lifeOS:2`) and redid the check on a scratch window in the actually-attached session.
- Redone in `shanegriffiths` (new window `scratch-nvim-check`, created fresh, never touching the session's existing window/panes): `nvim` launched, background auto-detected correctly and immediately — `:lua print(...)` → `BG=light COLORS=github_light_high_contrast`. `tmux capture-pane -e` confirms real white-background escape codes (`48;2;255;255;255`) throughout the statusline, i.e. genuine light rendering, not just the reported variable name. Window then quit (`:qa!`) and killed (`tmux kill-window -t shanegriffiths:2`); session's original window/panes untouched throughout.
- **Conclusion:** in the one context that matters (a real, attached Ghostty terminal, OSC 11 arriving asynchronously after nvim has finished starting — the normal case), background-driven colorscheme selection works exactly as intended. The Step 3 headless mismatch is a `:set`-during-startup artefact of the *test harness*, not a defect a real session hits — Nvim's own docs draw this exact "not triggered on startup" boundary. Flagging it anyway since it's a genuine (if narrow) race: if a terminal's OSC 11 reply were ever to land while nvim is still technically "starting" (very fast local ptys, unusual multiplexer chains), light mode could silently stay on `catppuccin-latte` instead of switching to `github_light_high_contrast`. Not patched ad hoc per the brief's instruction — noting for Shane's awareness rather than reaching for a fix (e.g. a `VimEnter`-deferred re-check) that isn't in the brief's exact code.

**Verdict:** DONE_WITH_CONCERNS — implementation matches the brief exactly, dark mode is provably unchanged (still Mocha + `#262626`), and the live/real-world check (the one that reflects Shane's actual daily usage) passed cleanly. The concern is confined to a documented, narrow headless/startup-timing edge case that did not reproduce in the real attached-terminal test.
