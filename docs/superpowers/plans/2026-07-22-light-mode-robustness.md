# Light Mode Robustness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make light mode first-party across the terminal stack — GitHub Light HC + red accent everywhere, readable-by-default for new tools, with THEME.md rewritten to match reality and include a reset playbook.

**Architecture:** Ghostty stays the single source of truth (ANSI cascade); `minimum-contrast 2.0` becomes the robustness floor; Catppuccin remains the tmux status engine but every `@thm_*` value it renders in light mode is force-set to a GitHub Light colour in `theme-light.conf`; per-tool light/dark forks only where the ANSI cascade can't reach (bat, Claude Code launcher — existing pattern).

**Tech Stack:** Ghostty, tmux 3.7 + Catppuccin/TPM, zsh, bat 0.26, nvim (catppuccin/nvim), Herdr 0.7.4, GNU Stow dotfiles.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-22-light-mode-robustness-design.md`
- **Dark mode's look must not change** (exception: already-applied red pane borders). Any dark-mode diff = bug.
- Edit real files under `~/.dotfiles/...`, never the `~/.config` symlinks.
- All colour choices: GitHub Light scale for surfaces/greys, ANSI `red` (or `#a0111f` where a literal is unavoidable) for accent. No latte values may render in light mode.
- zsh has `noclobber`: use `>|` for shell overwrites.
- Every commit ends with:
  `Claude-Session: https://claude.ai/code/session_01682qqcEjBhgUyfJ12XotLn`
- Audit findings accumulate in `~/.dotfiles/docs/superpowers/plans/2026-07-22-light-mode-audit-notes.md` (created in Task 1, consumed by Task 7).
- Verification is visual+behavioural: after each task's own checks, ask Shane to confirm the screen looks right before committing.

---

### Task 1: Ghostty contrast floor 1.2 → 2.0

**Files:**
- Modify: `~/.dotfiles/ghostty/.config/ghostty/config` (the `minimum-contrast` line)
- Create: `~/.dotfiles/docs/superpowers/plans/2026-07-22-light-mode-audit-notes.md`

**Interfaces:**
- Produces: audit-notes file (markdown, one `## <tool>` section per finding) that Tasks 2–6 append to and Task 7 reads.

- [ ] **Step 1: Edit the config**

Change:

```
# Floor on text-vs-background contrast so no color renders near-invisible (both modes)
minimum-contrast = 1.2
```

to:

```
# Robustness floor: rewrites any text colour below this contrast ratio against
# its background, in every app. 2.0 keeps our palettes visually intact but
# rescues dark-first tools (grey-on-white) in light mode. See THEME.md.
minimum-contrast = 2
```

- [ ] **Step 2: Verify the value parses**

Run: `ghostty +show-config | grep minimum-contrast`
Expected: `minimum-contrast = 2`

- [ ] **Step 3: Create the audit-notes file**

```markdown
# Light-mode audit notes — 2026-07-22

Working notes accumulated during the light-mode robustness work.
Consumed by the THEME.md rewrite task, then this file can be deleted.

## ghostty
- minimum-contrast 1.2 → 2.0 (robustness floor; one-line rollback).
```

- [ ] **Step 4: Ask Shane to reload Ghostty (Cmd+Shift+,) and confirm** both modes still look right in normal use (prompt, ls, fzf). Flag: colours that shift here were below 2.0 contrast — note any complaints in audit notes rather than reverting immediately.

- [ ] **Step 5: Commit**

```bash
cd ~/.dotfiles && git add ghostty/.config/ghostty/config docs/superpowers/plans/2026-07-22-light-mode-audit-notes.md && git commit -m "ghostty: raise minimum-contrast floor to 2.0

Rescues dark-first TUIs (grey-on-white) in light mode without visibly
shifting either palette in normal use.

Claude-Session: https://claude.ai/code/session_01682qqcEjBhgUyfJ12XotLn"
```

---

### Task 2: tmux light chrome — finish the GitHub Light takeover

**Files:**
- Modify: `~/.dotfiles/tmux/.config/tmux/theme-light.conf` (full rewrite, content below)
- Modify (already changed this session, commits here): `~/.dotfiles/tmux/.config/tmux/tmux.conf` (red borders block, lines 213–220)

**Interfaces:**
- Consumes: nothing.
- Produces: the final `theme-light.conf`; audit-notes `## tmux` section listing every replaced value (Task 7 turns this into THEME.md's mapping table).

- [ ] **Step 1: Record the "before" state for regression comparison**

Run (light mode): `tmux show-options -g | grep -E "^@thm_|^message-style|^mode-style|^copy-mode|^pane-border|^pane-active" `
Expected: latte values (`@thm_crust "#dce0e8"`, `@thm_fg "#4c4f69"`, message fg `#179299`, etc.). Paste output into audit notes under `## tmux (before)`.

- [ ] **Step 2: Rewrite theme-light.conf**

Replace the entire file with:

```tmux
# Light-mode overrides for tmux — sourced only when macOS appearance is Light
# (see the appearance block at the bottom of tmux.conf). Dark mode uses the
# defaults in tmux.conf untouched. Re-applied on `prefix r`.
#
# DESIGN RULE (THEME.md): light mode is GitHub Light HC + the red accent.
# Catppuccin stays as the status-line ENGINE (formats reference #{@thm_*}
# live), but every @thm_* value the chrome renders is force-set here to a
# GitHub Light colour — no latte value may survive to the screen.

# GitHub-light status surface with dark text (mirrors Ghostty "GitHub Light HC Red")
set -g status-style "bg=#ffffff,fg=#0e1116"
set -g status-right "#[bg=#ffffff] "
# Extra status rows (spacer + sessions) follow this; white in light mode so the
# whole bar flips together (the default in tmux.conf is the dark #262626).
set -g @bar_bg "#ffffff"

# Floating pane (floax) text dark-on-light so it stays readable
set -g @floax-text-color "#0e1116"

# Overlay popups (sesh picker, fzf, display-popup): light surface.
# Overrides catppuccin, which otherwise leaves popup-style on its base colour.
set -g popup-style "bg=#ffffff,fg=#0e1116"
set -g popup-border-style "fg=#d0d7de,bg=#ffffff"

# Copy-mode / mouse-drag selection: catppuccin bakes mode-style with mocha
# surface0 (bg=#313244) and no fg — dark text on dark grey in light mode.
# Force white-on-black, mirroring Ghostty's own selection colours in
# "GitHub Light HC Red" (selection-background #0e1116 / foreground #ffffff),
# so tmux selections and native Shift-drag selections look identical.
set -g mode-style "fg=#ffffff,bg=#0e1116,bold"

# Copy-mode search: tmux defaults (bg=cyan / bg=magenta, fg=black) resolve to
# dark-on-dark on this palette. GitHub-style pale-yellow wash for matches;
# accent red for the current match and the mark.
set -g copy-mode-match-style "bg=#fff8c5,fg=#0e1116"
set -g copy-mode-current-match-style "bg=#a0111f,fg=#ffffff"
set -g copy-mode-mark-style "bg=#a0111f,fg=#ffffff"

# Message / command prompt: dark text on the white bar (was latte teal).
# tmux 3.7 overlays messages on the status line; "fill" clears the full width.
set -g message-style "fg=#0e1116,bg=#ffffff,fill=#ffffff,align=centre"
set -g message-command-style "fg=#0e1116,bg=#ffffff,fill=#ffffff,align=centre"

# Window-list palette — GitHub Light force-set over catppuccin latte (set -g
# defeats the plugin's only-if-unset -og lock; the formats in tmux.conf
# reference these live). Mapping:
#   @thm_crust     white text on coloured pills (number pill, red current pill)
#   @thm_fg        window-name text
#   @thm_overlay_2 number-pill grey
#   @thm_surface_0 inactive window-name chip
#   @thm_surface_1 current window-name chip
#   @thm_overlay_0 right-click menu selected-item bg
#   @thm_yellow    zoom badge in status-left
set -g @thm_crust "#ffffff"
set -g @thm_fg "#0e1116"
set -g @thm_overlay_2 "#66707b"
set -g @thm_surface_0 "#eaeef2"
set -g @thm_surface_1 "#d0d7de"
set -g @thm_overlay_0 "#d0d7de"
set -g @thm_yellow "#9a6700"
```

- [ ] **Step 3: Reload and verify options**

Run: `tmux source-file ~/.config/tmux/tmux.conf && tmux show-options -g | grep -E "^@thm_(crust|fg|overlay_2|overlay_0|surface_0|surface_1|yellow)|^message-style|^copy-mode-match"`
Expected: every value matches Step 2's file — no `#dce0e8`, `#4c4f69`, `#7c7f93`, `#ccd0da`, `#bcc0cc`, or `#179299` anywhere.

- [ ] **Step 4: Latte-leak scan**

Run: `tmux show-options -g | grep -iE "style|colou?r" | grep -vE "^@catppuccin_(status_|[a-z_]*(icon|text))" | grep -E "#(dce0e8|e6e9ef|eff1f5|ccd0da|bcc0cc|4c4f69|7c7f93|8c8fa1|179299|7287fd|313244)"`
Expected: no output for options that actually render (the window pills, message, borders, mode, popups, status rows). `@catppuccin_status_*` module formats may still contain latte hexes — they are NOT rendered (status-right is overridden); note this fact in audit notes.

- [ ] **Step 5: Visual check with Shane**

Window pills (inactive grey chips, current red pill + `#d0d7de` name chip), message prompt (`prefix r` shows "Config reloaded" in dark text), copy-mode selection (white on black), copy-mode search (`prefix v`, `/`, search a word: pale yellow matches, red current match), right-click menu, sesh popup, floax. Ask Shane to confirm.

- [ ] **Step 6: Cold-start check**

Run: `tmux kill-server` then reattach from Ghostty. Expected (documented gotcha, unchanged): first paint may be mocha until `prefix r`. Confirm `prefix r` lands the GitHub Light chrome.

- [ ] **Step 7: Append the after-state to audit notes** (`## tmux` — the mapping table: variable → old latte → new GitHub value, plus the borders/mode-style/search fixes and the "status modules unused" note).

- [ ] **Step 8: Commit** (includes this session's earlier tmux.conf border changes)

```bash
cd ~/.dotfiles && git add tmux/.config/tmux/tmux.conf tmux/.config/tmux/theme-light.conf docs/superpowers/plans/2026-07-22-light-mode-audit-notes.md && git commit -m "tmux: finish GitHub Light takeover of light-mode chrome

- pane borders: ANSI red both modes (replaces baked latte/mocha lavender)
- copy-mode selection: white-on-black, mirrors Ghostty selection
- copy-mode search: GitHub yellow wash + red current match (light)
- window pills, menu, zoom badge, message prompt: GitHub Light greys
  force-set over every latte @thm_* the chrome renders

No latte value renders in light mode; dark mode chrome unchanged.

Claude-Session: https://claude.ai/code/session_01682qqcEjBhgUyfJ12XotLn"
```

---

### Task 3: bat — explicit light/dark themes (fzf previews)

**Files:**
- Modify: `~/.dotfiles/zsh/.zshrc` (near the existing eza/fzf colour block, after line 241's `EZA_COLORS`)

**Interfaces:**
- Consumes: nothing.
- Produces: `BAT_THEME` exported per-appearance at shell init; audit-notes `## bat` section.

- [ ] **Step 1: Confirm the failure**

Run: `bat --list-themes | head -30` (note exact names, expect `GitHub` and a Monokai dark variant), then `echo test | bat --color=always -pl txt | head -2` piped in a light-mode shell.
Expected: piped output uses a dark theme (detection can't query through a pipe) — that's the fzf-preview bug.

- [ ] **Step 2: Add the per-appearance export to .zshrc**

Insert after the `EZA_COLORS` block:

```zsh
# bat: pick the syntax theme at shell init. bat 0.25+ auto-detects the
# terminal background, but detection fails when piped (exactly what fzf
# previews do) and falls back dark — so light-mode previews rendered dark.
# Same per-launch appearance fork as the Claude Code launcher (THEME.md).
if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then
  export BAT_THEME="Monokai Extended"
else
  export BAT_THEME="GitHub"
fi
```

(If Step 1 shows different exact theme names, use those; the dark theme should match bat's previous default rendering so dark mode does not change.)

- [ ] **Step 3: Verify**

Run in a NEW light-mode shell: `echo '{"a": 1}' | bat --color=always -pl json` and trigger an fzf file preview (`Ctrl+T`, highlight a source file).
Expected: light GitHub syntax colours on the white background. Repeat conceptually for dark (or ask Shane to check after next appearance flip).

- [ ] **Step 4: Append findings to audit notes; commit**

```bash
cd ~/.dotfiles && git add zsh/.zshrc docs/superpowers/plans/2026-07-22-light-mode-audit-notes.md && git commit -m "zsh: pin BAT_THEME per macOS appearance

bat's background auto-detection fails when piped (fzf previews), falling
back to a dark theme on a white terminal.

Claude-Session: https://claude.ai/code/session_01682qqcEjBhgUyfJ12XotLn"
```

---

### Task 4: Spot-audit the ANSI-clean tools (starship, yazi, eza, fzf, sesh, navi, atuin)

**Files:**
- Modify: none expected. Any fix beyond a trivial ANSI-name swap → STOP, report to Shane, do not improvise.

**Interfaces:**
- Consumes: Task 1 (contrast floor active).
- Produces: audit-notes `## <tool>` section per tool: PASS, or finding + fix applied/proposed.

- [ ] **Step 1: Starship** — in a light-mode git repo shell, confirm: directory red, branch-pill chip legible, git_status colours readable. Expected: PASS (ANSI-clean per THEME.md).
- [ ] **Step 2: yazi** — open in light mode: folders red, breadcrumb red, no dark surfaces. Expected: PASS.
- [ ] **Step 3: eza + completion** — `ls`, then tab-complete a path: directories red both places. Expected: PASS.
- [ ] **Step 4: fzf both configs** — `Ctrl+T` (zshrc) and `prefix t` (sesh picker): bg inherits white, highlight red, preview readable (bat fix from Task 3). Expected: PASS.
- [ ] **Step 5: navi** — `prefix Ctrl+N`: readable list, red highlight (rides FZF_DEFAULT_OPTS). Expected: PASS.
- [ ] **Step 6: atuin** — `Ctrl+R` in light mode: results, selected row, and help footer all legible. Atuin config has no `[theme]` set (default theme). If broken: the fix is `theme.name = "default"` alternatives or a custom TOML theme — report options to Shane first.
- [ ] **Step 7: session-list.sh + resurrect/sesh preview scripts** — confirm the light branch colours render (session row readable, active session red).
- [ ] **Step 8: git/delta** — `cd ~/.dotfiles && git log -p -1 | head -40` in a light-mode shell: delta renders light diff colours (config already auto-detects, delta ≥ 0.18). Expected: PASS.
- [ ] **Step 9: GUI chrome (sketchybar / JankyBorders)** — eyeball only: window borders + bar accent still the fixed `#c4262b`, unaffected by this work. Expected: PASS, document-only.
- [ ] **Step 10: Record PASS/findings per tool in audit notes; commit notes**

```bash
cd ~/.dotfiles && git add docs/superpowers/plans/2026-07-22-light-mode-audit-notes.md && git commit -m "docs: light-mode audit notes for ANSI-clean tools

Claude-Session: https://claude.ai/code/session_01682qqcEjBhgUyfJ12XotLn"
```

---

### Task 4b: delta — GitHub-light feature fork (from Task 4's FINDING; Shane chose DELTA_FEATURES)

**Files:**
- Modify: `~/.dotfiles/git/.gitconfig` (the `[delta]` block)
- Modify: `~/.dotfiles/zsh/.zshrc` (the BAT_THEME block added in Task 3)

**Interfaces:**
- Consumes: Task 3's BAT_THEME conditional (extended, not duplicated).
- Produces: audit-notes `## delta (fix)` section; dark mode diffs pixel-identical.

- [ ] **Step 1: Fix the .gitconfig** — replace the wrong comment and add the feature block:

```gitconfig
[delta]
	# Dark mode: pinned Catppuccin Mocha. Light mode: the "github-light"
	# feature below, activated via DELTA_FEATURES exported per-appearance
	# in zsh/.zshrc (delta does NOT auto-detect through a pager pipe).
	syntax-theme = "Catppuccin Mocha"
	navigate = true
	side-by-side = true
[delta "github-light"]
	light = true
	syntax-theme = GitHub
```

(Keep any other existing `[delta]` keys unchanged.)

- [ ] **Step 2: Extend the zshrc appearance conditional** — inside Task 3's existing `if/else`, light branch only:

```zsh
  # delta (git pager): activate the GitHub-light feature block
  # ([delta "github-light"] in git/.gitconfig); dark keeps pinned Mocha.
  export DELTA_FEATURES="+github-light"
```

- [ ] **Step 3: Verify** — `zsh -ic 'echo $DELTA_FEATURES'` → `+github-light`; `zsh -ic 'cd ~/.dotfiles && git log -p -1 --color=always | head -40' | cat -v` → no dark background fills (`48;2;0;40;0` / `48;2;63;0;1` gone), light syntax colours. Confirm `delta --show-syntax-themes | grep GitHub` lists the theme. Dark path: unset var → unchanged Mocha (config untouched when DELTA_FEATURES absent).

- [ ] **Step 4: Append audit-notes `## delta (fix)` section; commit**

```bash
cd ~/.dotfiles && git add git/.gitconfig zsh/.zshrc docs/superpowers/plans/2026-07-22-light-mode-audit-notes.md && git commit -m "git/zsh: delta GitHub-light feature fork per appearance

delta never auto-detected (syntax-theme was pinned); light mode now
activates [delta \"github-light\"] via DELTA_FEATURES. Dark unchanged.

Claude-Session: https://claude.ai/code/session_01682qqcEjBhgUyfJ12XotLn"
```

---

### Task 5b: nvim — GitHub Light HC in light mode (Shane chose switch; dark stays Mocha)

**Files:**
- Modify: `~/.dotfiles/nvim/.config/nvim/init.lua` (catppuccin spec at ~line 805; add github-theme spec beside it)

**Interfaces:**
- Consumes: Shane's Task-5 decision (GitHub light).
- Produces: audit-notes `## nvim` section; light nvim = `github_light_high_contrast`, dark = catppuccin mocha (custom `#262626` base preserved).

- [ ] **Step 1: Add the plugin spec** next to the catppuccin spec (same lazy.nvim list):

```lua
  { -- GitHub Light theme (light mode only — dark stays Catppuccin Mocha)
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    priority = 1000,
  },
```

- [ ] **Step 2: Replace `vim.cmd.colorscheme 'catppuccin'`** (inside catppuccin's `config`) with background-driven selection:

```lua
      -- Pick by background: GitHub Light HC in light mode (matches the
      -- terminal stack — THEME.md), Catppuccin Mocha in dark. 'background'
      -- arrives asynchronously from the terminal's OSC 11 reply, so re-pick
      -- whenever it changes (also covers mid-session appearance flips).
      local function pick_colorscheme()
        if vim.o.background == 'light' then
          vim.cmd.colorscheme 'github_light_high_contrast'
        else
          vim.cmd.colorscheme 'catppuccin'
        end
      end
      pick_colorscheme()
      vim.api.nvim_create_autocmd('OptionSet', {
        pattern = 'background',
        callback = pick_colorscheme,
      })
```

- [ ] **Step 3: Install and verify headless** — `nvim --headless "+Lazy! sync" +qa`, then:
  - `nvim --headless "+set background=light" "+lua print(vim.g.colors_name)" +qa` → `github_light_high_contrast`
  - `nvim --headless "+lua print(vim.g.colors_name)" +qa` (default dark) → `catppuccin`
  Expected: no startup errors either way.

- [ ] **Step 4: Live check** — scratch tmux window (Task 4's method: `tmux new-window` → open nvim → `capture-pane -e` → `kill-window` on YOUR window only): background detection through tmux yields light rendering (white bg escape codes). If detection fails through tmux, record the symptom in audit notes and report — do not patch ad hoc.

- [ ] **Step 5: Append audit-notes `## nvim` section; commit**

```bash
cd ~/.dotfiles && git add nvim/.config/nvim/init.lua docs/superpowers/plans/2026-07-22-light-mode-audit-notes.md && git commit -m "nvim: GitHub Light HC in light mode, Mocha in dark

Last non-GitHub light surface in the stack (was catppuccin latte).
Background-driven pick with OptionSet re-pick for async OSC 11 detection.

Claude-Session: https://claude.ai/code/session_01682qqcEjBhgUyfJ12XotLn"
```

---

### Task 5: nvim — verify switching, decide latte question

**Files:**
- Modify: none in this task (decision may spawn a follow-up).

**Interfaces:**
- Consumes: nothing.
- Produces: audit-notes `## nvim` section + Shane's decision recorded.

- [ ] **Step 1: Verify auto-switching works** — open nvim inside tmux in light mode: catppuccin latte should render (light background). Run `:lua print(vim.o.background)` → expect `light`. If it renders dark: the OSC 11 background query is failing through tmux — record exact symptom in audit notes and report; do not patch ad hoc.
- [ ] **Step 2: Ask Shane the taste question** (AskUserQuestion): nvim light mode is Catppuccin *latte* — the only remaining non-GitHub light surface in the stack. Options: (a) keep latte (it's self-contained inside the editor, zero work), (b) switch light nvim to a GitHub theme (e.g. `projekt0n/github-nvim-theme`, `github_light_high_contrast`) for full-stack consistency — a new plugin + small config change. Record the decision in audit notes.
- [ ] **Step 3: If (b) chosen** — STOP and tell Shane this becomes a small follow-up task appended to this plan (plugin spec: add `projekt0n/github-nvim-theme`, set `vim.o.background`-conditional colorscheme; verify both modes). Do not implement inside this task's commit.
- [ ] **Step 4: Commit audit notes**

```bash
cd ~/.dotfiles && git add docs/superpowers/plans/2026-07-22-light-mode-audit-notes.md && git commit -m "docs: nvim light-mode audit + theme decision

Claude-Session: https://claude.ai/code/session_01682qqcEjBhgUyfJ12XotLn"
```

---

### Task 6: Herdr — diagnose and fix the washed-out light rendering

**Files:**
- Modify: `~/.dotfiles/herdr/.config/herdr/config.toml` (expected: `[theme.custom]` additions)
- Possibly create: upstream issue draft in audit notes (file only with Shane's explicit go-ahead)

**Interfaces:**
- Consumes: Task 1 (contrast floor — partial rescue already active; note the difference it made).
- Produces: audit-notes `## herdr` section; config fix.

- [ ] **Step 1: Re-screenshot the baseline** — Shane opens Herdr in light mode post-Task-1; compare against the 10:29 CleanShot. Expected: contrast floor already improved raw legibility. Record delta.
- [ ] **Step 2: Enumerate the theme tokens** — `herdr --default-config` shows `[theme.custom]` accepts per-token overrides (`panel_bg`, `accent`, `red`, `green`, …). Get the full token list: check `herdr config check --help` / repo docs online (tool is new — research the docs/GitHub for "theme tokens" or the themes source directory).
- [ ] **Step 3: Test the hypothesis** — the washed text is Herdr mapping default/body foreground to ANSI white/bright-white (deliberately grey `#66707b`/`#88929d` in GitHub Light HC). Try overriding the foreground token(s) found in Step 2, e.g.:

```toml
[theme.custom]
# Body/foreground token name per Step 2's docs — candidates: fg, text, foreground
fg = "reset"   # "reset" = terminal default fg (#0e1116 light / #cdd6f4 dark), stays adaptive
```

Reload (`herdr server reload-config` or `prefix+shift+r`). Prefer `"reset"`-style values over hex so the fix stays adaptive across modes; hex per-token only if reset is unsupported.

- [ ] **Step 4: Acceptance check** — Claude Code running inside Herdr, light mode: banner, body text, and sidebar chrome all first-party readable (dark text on white), accent red intact. Shane confirms side-by-side with plain tmux.
- [ ] **Step 5: If no token combination fixes it** — write the upstream issue draft in audit notes (title, repro: `theme = "terminal"` + GitHub Light HC palette, expected vs actual, the ANSI-white-as-body-text diagnosis, workaround). Ask Shane before filing anything.
- [ ] **Step 6: Commit**

```bash
cd ~/.dotfiles && git add herdr/.config/herdr/config.toml docs/superpowers/plans/2026-07-22-light-mode-audit-notes.md && git commit -m "herdr: fix light-mode foreground mapping

'terminal' theme mapped body text to ANSI white — deliberately grey in
GitHub Light HC — reading as washed-out on white.

Claude-Session: https://claude.ai/code/session_01682qqcEjBhgUyfJ12XotLn"
```

(Adjust the commit body to match what Step 3 actually found.)

---

### Task 7: THEME.md rewrite

**Files:**
- Modify: `~/.dotfiles/THEME.md`

**Interfaces:**
- Consumes: the complete audit-notes file (Tasks 1–6).

- [ ] **Step 1: Sync existing sections to reality** — update: Ghostty section (`minimum-contrast = 2`), tmux section (borders red both modes; theme-light.conf is now the *complete* light chrome including the GitHub-Light `@thm_*` mapping table from audit notes, mode/search styles), new bat paragraph under the zsh/eza area, Herdr subsection (the Task 6 outcome), nvim + atuin + navi + git/delta rows (first-time coverage; git/delta: "auto-detects, nothing to do").
- [ ] **Step 2: Add section "Dark mode, explained"** — content: dark mode is stock Catppuccin Mocha everywhere; the complete delta from stock is (1) Ghostty background `#1e1e2e` → `#262626`, (2) Ghostty cursor → mocha red `#f38ba8`, (3) the shared red-accent overrides (path, pills, borders — same lines that act in light mode); everything else is untouched plugin/theme defaults.
- [ ] **Step 3: Add section "Reset playbook"** — a table per layer: layer | stock base | custom delta (file:lines) | to reset (exact steps). Rows: Ghostty light theme file (delta = cursor block; reset = copy stock `GitHub Light High Contrast` back), Ghostty dark theme file (bg + cursor), ghostty config (minimum-contrast), tmux chrome (delete theme-light.conf overrides / red-accent block; `prefix r`), bat (remove BAT_THEME block), herdr (`[theme.custom]` block), nvim (per Task 5 decision), Claude Code themes (delete `~/.claude/themes/*.json` + settings fallback). End with "Rebasing onto a new palette" — generalise the existing "Changing the accent" steps: edit the two Ghostty palette files first, then the short list of hex-holding files (theme-light.conf surfaces, GUI `#c4262b`, Claude themes' backgrounds).
- [ ] **Step 4: Add section "Adding a new tool (the Herdr lesson)"** — checklist: (1) prefer the tool's terminal/ANSI theme mode; (2) light-mode smoke test BEFORE trusting it: body text, selection, borders on white; (3) if washed out, suspect ANSI-white body text — override fg token or per-mode fork; (4) record it in THEME.md's per-tool list.
- [ ] **Step 5: Self-check** — every claim in THEME.md must now be verifiable against a file; grep the doc for the old wrong claims (`1.2`, "only set the surfaces", latte hexes) → none remain.
- [ ] **Step 6: Delete the audit-notes file** (its content now lives in THEME.md) **and commit**

```bash
cd ~/.dotfiles && git add THEME.md && git rm docs/superpowers/plans/2026-07-22-light-mode-audit-notes.md && git commit -m "docs: rewrite THEME.md — light-mode takeover, dark-mode delta, reset playbook

Claude-Session: https://claude.ai/code/session_01682qqcEjBhgUyfJ12XotLn"
```

---

### Task 8: Final verification sweep

**Files:** none (verification only; fixes loop back to the owning task).

- [ ] **Step 1: Light-mode sweep** — Shane drives, one pass: tmux chrome (pills/message/copy-mode/search/borders), fzf + bat preview, starship, yazi, atuin, navi, nvim, Herdr with Claude Code inside, sesh picker. Everything readable, GitHub-Light-coherent, red accent.
- [ ] **Step 2: Dark-mode regression** — flip macOS appearance, relaunch shells, `prefix r`: dark mode identical to before this work (except red pane borders). Any other visible change = regression → fix in the owning task before closing.
- [ ] **Step 3: Cold-start** — `tmux kill-server`, reattach: known gotcha only (first paint dark until `prefix r`), nothing new.
- [ ] **Step 4: Screenshot the before/after pair** — Shane's two CleanShots from this morning vs. the same views now; store nothing in the repo, just confirm together.
- [ ] **Step 5: Confirm clean tree** — `cd ~/.dotfiles && git status --short` → empty. All work committed per-task.
