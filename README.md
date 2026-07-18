# My Dotfiles

GNU Stow-managed dotfiles with bootstrap automation for macOS. One script to go
from a fresh Mac to a fully configured development environment.

## Quick Start

On a fresh Mac (requires an SSH key for github.com):

```bash
bash <(curl -sL https://raw.githubusercontent.com/shanegriffiths/dotfiles/main/bootstrap.sh)
```

Or if the repo is already cloned:

```bash
bash ~/.dotfiles/bootstrap.sh
```

The script is idempotent — safe to re-run after a partial failure or to pick up
changes. Any existing config files that would conflict are backed up to
`~/.dotfiles-backup/<timestamp>/` before being replaced.

There's also a headless variant for provisioning a server (CLI-only stow
packages, `Brewfile.server`, no GUI apps):

```bash
bash ~/.dotfiles/bootstrap-server.sh
```

## What's Included

### Configs tracked by this repo (Stow packages)

| Package | Tool | Config location |
|---------|------|-----------------|
| `zsh` | Zsh, Oh My Zsh, aliases, PATH | `~/.zshrc`, `~/.zshenv` |
| `git` | Git, delta pager, global ignores | `~/.gitconfig`, `~/.gitignore_global` |
| `starship` | Starship prompt (+ minimal SSH variant) | `~/.config/starship.toml` |
| `ghostty` | Ghostty terminal + custom themes | `~/.config/ghostty/` |
| `tmux` | tmux, status-bar and session scripts | `~/.config/tmux/` |
| `nvim` | Neovim (kickstart.nvim base, lazy.nvim) | `~/.config/nvim/` |
| `aerospace` | AeroSpace tiling window manager | `~/.config/aerospace/` |
| `sketchybar` | Custom macOS menu bar | `~/.config/sketchybar/` |
| `yazi` | Terminal file manager | `~/.config/yazi/` |
| `atuin` | Shell history | `~/.config/atuin/` |
| `sesh` | tmux session manager | `~/.config/sesh/` |
| `navi` | CLI cheatsheets | `~/.local/share/navi/` |
| `direnv` | Per-directory environments | `~/.direnvrc` |
| `gnupg` | GPG agent | `~/.gnupg/gpg-agent.conf` |
| `claude` | Claude Code custom themes | `~/.claude/themes/` |

The whole terminal stack shares one coordinated light/dark theme with a red
accent, switching automatically with macOS appearance — see [THEME.md](THEME.md)
for how that works.

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
| GUI Apps | 18 active Homebrew casks + 46 Mac App Store apps (see Brewfile) |
| Fonts | Hack, JetBrains Mono, SF Mono (all Nerd Font patched), Geist, SF Pro |
| VS Code Extensions | 75+ extensions (themes, linters, language support) |

### Apps available but commented out

The Brewfile contains ~50 additional cask entries that are commented out. These
are apps found on the source machine that weren't originally managed by
Homebrew. Review and uncomment the ones you want:

```bash
# Open the Brewfile and uncomment what you need
vim ~/.dotfiles/Brewfile

# Then install
brew bundle --file=~/.dotfiles/Brewfile
```

## Managing Dotfiles

Configs are symlinked into `$HOME` with
[GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a
Stow "package" that mirrors the home directory structure; `stow */` from
`~/.dotfiles` links everything at once.

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

## File Structure

```
~/.dotfiles/
├── bootstrap.sh            # Full Mac provisioning script
├── bootstrap-server.sh     # Headless server variant
├── Brewfile                # Homebrew packages, casks, MAS apps, VS Code extensions
├── Brewfile.server         # Server subset (CLI tools only)
├── macos.sh                # macOS system preferences (Dock, Finder, keyboard, etc.)
├── THEME.md                # How the coordinated light/dark theming works
├── aerospace/              # Stow package: AeroSpace window manager
├── atuin/                  #   ... shell history
├── claude/                 #   ... Claude Code themes
├── direnv/                 #   ... per-directory environments
├── ghostty/                #   ... Ghostty terminal + themes
├── git/                    #   ... git config + global ignores
├── gnupg/                  #   ... GPG agent
├── navi/                   #   ... CLI cheatsheets
├── nvim/                   #   ... Neovim
├── sesh/                   #   ... tmux session manager
├── sketchybar/             #   ... menu bar
├── starship/               #   ... prompt
├── tmux/                   #   ... tmux + scripts
├── yazi/                   #   ... file manager
└── zsh/                    #   ... shell
```

## Bootstrap Steps

`bootstrap.sh` runs these steps in order. Each step is skipped if already
complete:

| Step | What | Notes |
|------|------|-------|
| 1 | Xcode Command Line Tools | Required for git and compilers |
| 2 | Homebrew | Package manager, installs to `/opt/homebrew` |
| 3 | Clone + stow dotfiles | Symlinks configs into `$HOME`, backs up conflicts |
| 4 | Brew Bundle | Installs everything in the Brewfile |
| 5 | Oh My Zsh | Zsh framework (`RUNZSH=no` to stay in script) |
| 6 | Zsh plugins | fzf-tab, autosuggestions, syntax-highlighting, completions |
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

Tested on macOS Sequoia 15.x. Run standalone with `bash ~/.dotfiles/macos.sh`.

## Manual Install Apps

These aren't available via Homebrew or the Mac App Store — download and install
manually:

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
- [ ] Sign in to **Mac App Store**, then re-run `brew bundle --file=~/.dotfiles/Brewfile`
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
