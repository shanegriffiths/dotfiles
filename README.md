# Shane's Dotfiles

Bare git repo dotfiles with bootstrap automation for macOS. One script to go from a fresh Mac to a fully configured development environment.

## Quick Start

On a fresh Mac (requires SSH key for github.com):

```bash
bash <(curl -sL https://raw.githubusercontent.com/shanegriffiths/dotfiles/main/.config/dotfiles/bootstrap.sh)
```

Or if the repo is already cloned:

```bash
bash ~/.config/dotfiles/bootstrap.sh
```

The script is idempotent — safe to re-run after a partial failure or to pick up changes.

## What's Included

### Configs tracked by the dotfiles repo

| Category | Tools | Config location |
|----------|-------|-----------------|
| Shell | zsh, Oh My Zsh, starship prompt | `~/.zshrc`, `~/.config/starship.toml` |
| Terminal | Ghostty, tmux | `~/.config/ghostty/`, `~/.tmux.conf` |
| Editor | Neovim | `~/.config/nvim/` |
| Window Management | AeroSpace (tiling), borders | `~/.config/aerospace/`, `~/.config/borders/` |
| Status Bar | sketchybar | `~/.config/sketchybar/` |
| File Manager | yazi | `~/.config/yazi/` |

### Tools installed by bootstrap

| Category | What gets installed |
|----------|---------------------|
| Terminal & Shell | bat, coreutils, eza, fd, fzf, ripgrep, starship, tmux, tree, zoxide |
| CLI Productivity | btop, gh, glow, jq, lazygit, mactop, mas, pandoc, tlrc, yazi, yt-dlp |
| Editors | Neovim |
| Languages & Runtimes | Node LTS (nvm), pnpm (corepack), Deno, Bun, Python 3.13 (uv) |
| Databases | PostgreSQL 17, Supabase CLI, Neon CLI |
| Media | ffmpeg, ImageMagick, ocrmypdf, resvg, typst |
| Window Management | AeroSpace, borders, sketchybar |
| GUI Apps | 15 active Homebrew casks + 47 Mac App Store apps (see Brewfile) |
| Fonts | Hack, JetBrains Mono, SF Mono (all Nerd Font patched), SF Pro |
| VS Code Extensions | 80+ extensions (themes, linters, language support) |

### Apps available but commented out

The Brewfile contains ~50 additional cask entries that are commented out. These are apps found on the source machine that weren't originally managed by Homebrew. Review and uncomment the ones you want:

```bash
# Open the Brewfile and uncomment what you need
vim ~/.config/dotfiles/Brewfile

# Then install
brew bundle --file=~/.config/dotfiles/Brewfile --no-lock
```

## Managing Dotfiles

The bare repo uses a `dot` alias (defined in `.zshrc`):

```bash
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

Common operations:

```bash
# Check what's changed
dot status

# Track a new config file
dot add ~/.config/ghostty/config

# Commit changes
dot commit -m "Update ghostty config"

# Push to remote
dot push

# See what's tracked
dot ls-files

# Diff changes
dot diff
```

> **Why a bare repo?** It avoids nesting a `.git` directory in `$HOME`, which would make every subdirectory look like a git repo. The bare repo at `~/.dotfiles` stores git data, while `$HOME` is the work tree. `status.showUntrackedFiles no` keeps `dot status` clean.

## File Structure

```
~/.config/
├── dotfiles/               # Bootstrap toolkit (this directory)
│   ├── Brewfile            # Homebrew packages, casks, MAS apps, VS Code extensions
│   ├── bootstrap.sh        # Full Mac provisioning script
│   ├── macos.sh            # macOS system preferences (Dock, Finder, keyboard, etc.)
│   └── README.md           # This file
├── aerospace/              # AeroSpace tiling window manager
├── borders/                # Window border styling
├── ghostty/                # Ghostty terminal emulator
├── nvim/                   # Neovim config (lazy.nvim)
├── sketchybar/             # Custom menu bar
├── starship.toml           # Cross-shell prompt theme
└── yazi/                   # Terminal file manager
~/.zshrc                    # Zsh config (Oh My Zsh, aliases, PATH, plugins)
~/.tmux.conf                # tmux config
~/.dotfiles/                # Bare git repo (data only, not a working directory)
```

## Bootstrap Steps

`bootstrap.sh` runs these steps in order. Each step is skipped if already complete:

| Step | What | Notes |
|------|------|-------|
| 1 | Xcode Command Line Tools | Required for git and compilers |
| 2 | Homebrew | Package manager, installs to `/opt/homebrew` |
| 3 | Clone dotfiles | Bare repo to `~/.dotfiles`, backs up conflicts |
| 4 | Brew Bundle | Installs everything in the Brewfile |
| 5 | Oh My Zsh | Zsh framework (`RUNZSH=no` to stay in script) |
| 6 | Zsh plugins | fzf-tab, autosuggestions, syntax-highlighting |
| 7 | tpm | tmux plugin manager — press `prefix + I` after |
| 8 | Node + pnpm | LTS via nvm, pnpm via corepack |
| 9 | Bun | Installed via its own script |
| 10 | macOS defaults | Runs `macos.sh` (Dock, Finder, keyboard, etc.) |
| 11 | Checklist | Prints remaining manual steps |

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

Tested on macOS Sequoia 15.x. Run standalone with `bash ~/.config/dotfiles/macos.sh`.

## Manual Install Apps

These aren't available via Homebrew or the Mac App Store — download and install manually:

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
| Mockuuups Studio | mockuuups.studio | Design mockups |
| Port Menu | — | Network utility |
| Rize | rize.io | Time tracking |
| RODE Central | rode.com | Audio hardware |
| Sleeve | replay.software/sleeve | Music widget |
| Supercharge | supercharge.app | Utility |
| Supercut | — | Video editing |
| Synology Image Assistant | synology.com | NAS utility |
| TinkerTool | bresink.com/osx/TinkerTool | System utility |
| Topaz Gigapixel | topazlabs.com | AI upscaling |
| Umbra | — | Dark mode utility |
| Wispr Flow | wispr.com | Voice dictation |
| XPPen drivers | xppen.com | Tablet drivers |

## Post-Install Checklist

After running `bootstrap.sh`:

- [ ] Sign in to **1Password** and enable Safari extension
- [ ] Sign in to **iCloud** and enable services
- [ ] Sign in to **Mac App Store**, then re-run `brew bundle --file=~/.config/dotfiles/Brewfile --no-lock`
- [ ] Import **Raycast** settings from backup/sync
- [ ] Set up **SSH keys** (or restore from 1Password SSH agent)
- [ ] Open **Ghostty** — config loads from `~/.config/ghostty/`
- [ ] Open **neovim** — plugins auto-install on first launch
- [ ] In **tmux**, press `prefix + I` to install tpm plugins
- [ ] Review commented casks in `Brewfile` — uncomment and re-run brew bundle
- [ ] Install **manual apps** from the table above
- [ ] **Restart** your Mac for all settings to take effect

## Updating

To capture new Homebrew packages after installing them:

```bash
brew bundle dump --file=~/.config/dotfiles/Brewfile --describe --force
```

To track changes:

```bash
dot add ~/.config/dotfiles/Brewfile
dot commit -m "Update Brewfile"
dot push
```

To re-apply macOS defaults after changing `macos.sh`:

```bash
bash ~/.config/dotfiles/macos.sh
```
