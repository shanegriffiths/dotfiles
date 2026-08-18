# My Dotfiles

GNU Stow-managed dotfiles with bootstrap automation for macOS. One repo, two
machine types: the core MacBook, and profiles on the Mac mini agent-server.

## Machines

| Machine | Script | Profiles | Notes |
|---------|--------|----------|-------|
| MacBook (core) | `bootstrap.sh` | shane | Full rebuild: GUI apps, fonts, macOS defaults, window management |
| Mac mini (agent-server) | `bootstrap-server.sh` | `kitvoss` (Hermes/Kit), `forge` (cloud dev agent), `jess` (planned) | Headless shell setup per profile |

**Landlord model (agent-server):** `/opt/homebrew` is shared machine-wide but
owned by `kitvoss` alone. Other profiles consume installed tools; they cannot
install or upgrade — deliberate, so autonomous agents can never break the
toolbox Kit's runtime depends on. `bootstrap-server.sh` detects a non-landlord
profile and skips all brew steps gracefully.

Operational routines (weekly/monthly maintenance, update procedures, known
landmines) live in the Obsidian vault: **Technical Notes → Mac Mini Operations
Handbook**.

## Quick Start

Core Mac rebuild (requires an SSH key for github.com):

```bash
bash <(curl -sL https://raw.githubusercontent.com/shanegriffiths/dotfiles/main/bootstrap.sh)
```

New agent-server profile (public https clone — no key needed):

```bash
bash <(curl -sL https://raw.githubusercontent.com/shanegriffiths/dotfiles/main/bootstrap-server.sh)
```

Both are idempotent — safe to re-run after a partial failure. Conflicting
files are backed up to `~/.dotfiles-backup/<timestamp>/` before being replaced.

## What's Included

### Configs tracked by this repo (Stow packages)

| Package | Tool | Config location | Machines |
|---------|------|-----------------|----------|
| `zsh` | Zsh, Oh My Zsh, aliases, PATH | `~/.zshrc`, `~/.zshenv` | all |
| `git` | Git, delta pager, global ignores | `~/.gitconfig`, `~/.gitignore_global` | all |
| `starship` | Starship prompt (+ minimal SSH variant) | `~/.config/starship.toml` | all |
| `ghostty` | Ghostty terminal + custom themes | `~/.config/ghostty/` | all |
| `nvim` | Neovim (kickstart.nvim base, lazy.nvim) | `~/.config/nvim/` | all |
| `atuin` | Shell history | `~/.config/atuin/` | all |
| `yazi` | Terminal file manager | `~/.config/yazi/` | all |
| `navi` | CLI cheatsheets | `~/.local/share/navi/` | all |
| `direnv` | Per-directory environments | `~/.direnvrc` | all |
| `claude` | Claude Code custom themes | `~/.claude/themes/` | all |
| `herdr` | Herdr agent multiplexer | `~/.config/herdr/` | all |
| `bin` | Personal scripts | `~/bin/` | laptop |
| `launchd` | Personal LaunchAgents | `~/Library/LaunchAgents/` | laptop |
| `gnupg` | GPG agent | `~/.gnupg/gpg-agent.conf` | laptop |
| `aerospace` | AeroSpace tiling window manager | `~/.config/aerospace/` | laptop |
| `sketchybar` | Custom macOS menu bar | `~/.config/sketchybar/` | laptop |
| `tmux` | tmux + status scripts | `~/.config/tmux/` | **server only** — retired on the laptop 2026-08-17 (Herdr replaced it); kept for kitvoss phone-SSH (mosh) sessions |

The whole terminal stack shares one coordinated light/dark theme with a red
accent, switching automatically with macOS appearance — see [THEME.md](THEME.md)
for how that works.

### Tools installed by bootstrap (laptop)

| Category | What gets installed |
|----------|---------------------|
| Terminal & Shell | bat, coreutils, eza, fd, fzf, ripgrep, starship, tree, zoxide |
| CLI Productivity | btop, gh, glow, jq, lazygit, mas, pandoc, yazi, yt-dlp |
| Editors | Neovim |
| Languages & Runtimes | Node LTS (fnm), pnpm (corepack), Deno, Bun, Python 3.13 (uv) |
| Databases | PostgreSQL 17, Supabase CLI |
| Media | ffmpeg, ImageMagick, ocrmypdf, resvg, typst |
| Window Management | AeroSpace, sketchybar |
| GUI Apps | Active Homebrew casks + Mac App Store apps (see Brewfile) |
| Fonts | Hack, JetBrains Mono, SF Mono (all Nerd Font patched), Geist, SF Pro |
| VS Code Extensions | 75+ extensions (themes, linters, language support) |

npm globals (installed per-Node, not tracked here): neonctl, repomix, vercel,
wrangler, defuddle, agent-browser, and friends — re-install with `npm i -g`.

### Apps available but commented out

The Brewfile contains additional cask entries that are commented out. Review
and uncomment the ones you want:

```bash
# Open the Brewfile and uncomment what you need
vim ~/.dotfiles/Brewfile

# Then install
brew bundle --file=~/.dotfiles/Brewfile
```

## Managing Dotfiles

Configs are symlinked into `$HOME` with
[GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a
Stow "package" that mirrors the home directory structure. Each bootstrap
script stows an explicit package list for its machine type — never `stow */`
(that's how server-only packages would leak onto the laptop).

The `dot` alias (defined in `.zshrc`) runs git against the repo from anywhere:

```bash
alias dot='git -C $HOME/.dotfiles'
```

Common operations:

```bash
# Check what's changed
dot status

# Track a new config file: move it into the matching package, then stow
mv ~/.config/foo/config ~/.dotfiles/foo/.config/foo/config
cd ~/.dotfiles && stow foo

# Commit changes
dot add -A
dot commit -m "Add foo config"

# Push to remote
dot push
```

> **Editing note:** the `~/.config/...` paths are symlinks into `~/.dotfiles`.
> Edit the real file under `~/.dotfiles` — some tools refuse to write through
> symlinks.

> **Multi-machine note:** changes pushed here reach agent-server profiles on
> their next `git -C ~/.dotfiles pull`. Anything machine-specific in shared
> files must be guarded (`command -v tool >/dev/null && ...`) — see the fnm
> init in `.zshrc` for the pattern.

## File Structure

```
~/.dotfiles/
├── bootstrap.sh            # Core Mac (laptop) provisioning script
├── bootstrap-server.sh     # Agent-server profile variant (landlord-aware)
├── Brewfile                # Laptop: formulae, casks, MAS apps, VS Code extensions
├── Brewfile.server         # Server subset (CLI tools only, landlord installs)
├── macos.sh                # macOS system preferences (Dock, Finder, keyboard, etc.)
├── THEME.md                # How the coordinated light/dark theming works
├── aerospace/              # Stow package: AeroSpace window manager (laptop)
├── atuin/                  #   ... shell history
├── bin/                    #   ... personal scripts (laptop)
├── claude/                 #   ... Claude Code themes
├── direnv/                 #   ... per-directory environments
├── ghostty/                #   ... Ghostty terminal + themes
├── git/                    #   ... git config + global ignores
├── gnupg/                  #   ... GPG agent (laptop)
├── herdr/                  #   ... Herdr agent multiplexer
├── launchd/                #   ... personal LaunchAgents (laptop)
├── navi/                   #   ... CLI cheatsheets
├── nvim/                   #   ... Neovim
├── sketchybar/             #   ... menu bar (laptop)
├── starship/               #   ... prompt
├── tmux/                   #   ... tmux + scripts (server only)
├── yazi/                   #   ... file manager
└── zsh/                    #   ... shell
```

## Bootstrap Steps (laptop)

`bootstrap.sh` runs these steps in order. Each step is skipped if already
complete:

| Step | What | Notes |
|------|------|-------|
| 1 | Xcode Command Line Tools | Required for git and compilers |
| 2 | Homebrew | Package manager, installs to `/opt/homebrew` |
| 3 | Clone + stow dotfiles | Explicit laptop package list, backs up conflicts |
| 4 | Brew Bundle | Installs everything in the Brewfile |
| 5 | Oh My Zsh | Zsh framework (`RUNZSH=no` to stay in script) |
| 6 | Zsh plugins | fzf-tab, autosuggestions, syntax-highlighting, completions |
| 7 | Node + pnpm | LTS via fnm, pnpm via corepack |
| 8 | Bun | Installed via its own script |
| 9 | macOS defaults | Runs `macos.sh` (Dock, Finder, keyboard, etc.) |
| 10 | Checklist | Prints remaining manual steps |

`bootstrap-server.sh` is the same skeleton minus GUI concerns, plus the
landlord check: on a profile that can't write to `/opt/homebrew` it skips
every brew step and only stows configs + installs Oh My Zsh and plugins.
Per-user CLIs (Claude Code) install via their own installers afterwards.

## macOS Defaults

`macos.sh` configures system preferences to match Shane's setup. Key settings:

- **Keyboard**: fast key repeat (2/15) — essential for nvim. Disables press-and-hold, auto-correct, smart quotes
- **Dock**: auto-hide with zero delay, static-only (shows running apps only), no recents, 45px icons
- **Finder**: column view, show hidden files, path bar, status bar, folders on top, search current folder
- **Trackpad**: tap to click, light sensitivity, momentum scrolling
- **Hot corners**: top-left = App Windows (cmd), bottom-left = Mission Control (cmd), bottom-right = Desktop (cmd)
- **Screenshots**: PNG format, no shadow
- **Safari**: Develop menu, Do Not Track, full URL in address bar
- **Mission Control**: don't rearrange Spaces by recent use

Tested on macOS Sequoia 15.x. Run standalone with `bash ~/.dotfiles/macos.sh`.

## Manual Install Apps

Not available via Homebrew or the Mac App Store — download and install
manually. *(List pruned 2026-08-18: Rize and Synology Image Assistant removed
after uninstall; a fuller review of this list is pending.)*

| App | Source | Category |
|-----|--------|----------|
| 1Setter | 1Password utility | Utility |
| Affinity (Designer, Photo, Publisher) | affinity.serif.com | Design |
| Blackmagic Cam | blackmagicdesign.com | Video |
| Cavalry | cavalry.scenegroup.co | Motion graphics |
| CleanShot X | cleanshot.com | Screenshots |
| DitherBoy | ditherboy.com | Design |
| Eagle | eagle.cool | Asset management |
| Focusrite Control 2 | focusrite.com | Audio hardware |
| Insta360 Link Controller | insta360.com | Camera hardware |
| Logitech Options+ | logitech.com | Peripheral drivers |
| Markdown Preview | — | Markdown viewer (system `.md` handler, `mdp` alias) |
| Mockuuups Studio | mockuuups.studio | Design mockups |
| Port Menu | — | Network utility |
| RODE Central | rode.com | Audio hardware |
| Sleeve | replay.software/sleeve | Music widget |
| Supercharge | supercharge.app | Utility |
| Supercut | — | Video editing |
| TinkerTool | bresink.com/osx/TinkerTool | System utility |
| Topaz Gigapixel | topazlabs.com | AI upscaling |
| Umbra | — | Dark mode utility |
| Wispr Flow | wispr.com | Voice dictation |
| XPPen drivers | xppen.com | Tablet drivers |

## Post-Install Checklist

After running `bootstrap.sh`:

- [ ] Sign in to **1Password** and enable Safari extension
- [ ] Sign in to **iCloud** and enable services
- [ ] Sign in to **Mac App Store**, then re-run `brew bundle --file=~/.dotfiles/Brewfile`
- [ ] Import **Raycast** settings from backup/sync
- [ ] Set up **SSH keys** (or restore from 1Password SSH agent)
- [ ] Open **Ghostty** — config loads from `~/.config/ghostty/`
- [ ] Open **neovim** — plugins auto-install on first launch
- [ ] Review commented casks in `Brewfile` — uncomment and re-run brew bundle
- [ ] Install **manual apps** from the table above
- [ ] **Restart** your Mac for all settings to take effect

After running `bootstrap-server.sh` on a new agent-server profile:

- [ ] Install Claude Code: `curl -fsSL https://claude.ai/install.sh | bash`
- [ ] Sign in: `claude`, `codex login`, `gh auth login`
- [ ] Add the laptop's SSH key to `~/.ssh/authorized_keys` (or `ssh-copy-id`)
- [ ] Add a `Host` entry in the laptop's `~/.ssh/config`

## Updating

To capture new Homebrew packages after installing them:

```bash
brew bundle dump --file=~/.dotfiles/Brewfile --describe --force
```

To track changes:

```bash
dot add Brewfile
dot commit -m "Update Brewfile"
dot push
```

To re-apply macOS defaults after changing `macos.sh`:

```bash
bash ~/.dotfiles/macos.sh
```

## License

[MIT](LICENSE)
