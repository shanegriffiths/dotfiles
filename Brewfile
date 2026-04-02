# ~/.config/dotfiles/Brewfile
# Homebrew Bundle — Shane's Mac setup
# Captured from MacBook Pro running macOS Sequoia 15.x on 2026-03-20
#
# Usage:
#   brew bundle --file=~/.config/dotfiles/Brewfile --no-lock
#
# To check what would be installed without installing:
#   brew bundle check --file=~/.config/dotfiles/Brewfile --verbose
#
# To clean up formulae/casks not listed here:
#   brew bundle cleanup --file=~/.config/dotfiles/Brewfile --force
#
# Convention:
#   - Active entries will be installed automatically by bootstrap.sh
#   - Commented casks (# cask "...") are apps found on the source machine
#     that weren't originally managed by Homebrew. Uncomment any you want
#     Homebrew to manage on the new machine.
#   - Lines marked REVIEW need a decision before running on a new machine.
#
# Note: MAS (Mac App Store) entries require App Store sign-in first.
# bootstrap.sh handles this by prompting you to re-run brew bundle after
# signing in.

# ============================================================================
# Taps
# ============================================================================

tap "felixkratz/formulae"           # sketchybar, borders
tap "nikitabobko/tap"               # aerospace
tap "supabase/tap"                  # supabase cli
tap "shaunsingh/sfmono-nerd-font-ligaturized"

# REVIEW: experimental/less common taps — remove if not needed on new machine
tap "alexsjones/llmfit"             # llmfit — find models for your hardware
tap "arimxyer/tap"                  # models TUI
tap "gromgit/brewtils"              # taproom — interactive TUI for homebrew
tap "lihaoyun6/tap"
tap "rafaelswi/menubarusb"          # menubarusb
tap "updatest/tap", "https://github.com/updatest/tap.git"

# ============================================================================
# Terminal & Shell
# ============================================================================

brew "bat"                          # cat with syntax highlighting
brew "coreutils"                    # GNU core utilities
brew "eza"                          # modern ls replacement
brew "fd"                           # fast find alternative
brew "fzf"                          # fuzzy finder
brew "ripgrep"                      # fast grep (rg)
brew "starship"                     # cross-shell prompt
brew "tmux"                         # terminal multiplexer
brew "tree"                         # directory tree view
brew "zoxide"                       # smart cd (z)
brew "zsh-autocomplete"             # real-time type-ahead completion

# NOTE: zsh-autosuggestions and zsh-syntax-highlighting are managed by
# Oh My Zsh via git clones in ~/.oh-my-zsh/custom/plugins/ — not Homebrew.
# bootstrap.sh handles cloning these automatically.

# ============================================================================
# CLI Productivity
# ============================================================================

brew "btop"                         # resource monitor
brew "gh"                           # GitHub CLI
brew "glow"                         # render markdown in terminal
brew "jq"                           # JSON processor
brew "lazygit"                      # terminal UI for git
brew "mactop"                       # Apple Silicon monitor
brew "mas"                          # Mac App Store CLI
brew "pandoc"                       # document format converter
brew "sevenzip"                     # 7-Zip archiver
brew "tlrc"                         # tldr pages client (Rust)
brew "yazi"                         # terminal file manager
brew "yt-dlp"                       # audio/video downloader

# ============================================================================
# Editors
# ============================================================================

brew "neovim"                       # the one true editor

# ============================================================================
# Languages & Runtimes
# ============================================================================

brew "deno"                         # Deno runtime
brew "nvm"                          # Node version manager (provides nvm shell function)
brew "python@3.13"                  # Python 3.13
brew "uv"                           # fast Python package installer and resolver

# Not managed by Homebrew — installed by bootstrap.sh:
#   pnpm  — via corepack (ships with Node)
#   Bun   — via its own installer (curl -fsSL https://bun.sh/install)

# ============================================================================
# Databases
# ============================================================================

brew "neonctl"                      # Neon serverless Postgres CLI
brew "postgresql@17"                # PostgreSQL 17
brew "supabase/tap/supabase"        # Supabase CLI

# REVIEW: do you still need PostgreSQL 14 on the new machine?
brew "postgresql@14"

# ============================================================================
# Media & Document Processing
# ============================================================================

brew "ffmpeg"                       # audio/video Swiss army knife
brew "imagemagick-full"             # image manipulation (all delegates)
brew "ocrmypdf"                     # add OCR text layer to scanned PDFs
brew "poppler"                      # PDF rendering library
brew "resvg"                        # SVG rendering
brew "typst"                        # modern markup-based typesetting

# ============================================================================
# Window Management & Status Bar
# ============================================================================

brew "felixkratz/formulae/borders"      # window borders
brew "felixkratz/formulae/sketchybar"   # custom macOS menu bar

# ============================================================================
# Misc / Experimental
# ============================================================================

# REVIEW: keep these on the new machine?
brew "llmfit"                       # find what AI models run on your hardware
brew "arimxyer/tap/models"          # AI model browser TUI
brew "gromgit/brewtils/taproom"     # interactive Homebrew TUI

# ============================================================================
# Casks — GUI Apps (already managed by Homebrew)
# ============================================================================
# These are already installed via Homebrew on the source machine and will
# be installed automatically by brew bundle.

cask "1password-cli"                # 1Password CLI (op command)
cask "nikitabobko/tap/aerospace"    # i3-like tiling window manager
cask "alt-tab"                      # Windows-like alt-tab switcher
cask "basictex"                     # minimal TeX distribution
cask "bezel"                        # iOS screen mirroring/recording
cask "flashspace"                   # workspace/space management
cask "jordanbaird-ice"              # menu bar manager (hide icons)
cask "localcan"                     # local dev with public URLs and .local domains
cask "markedit"                     # markdown editor
cask "rafaelswi/menubarusb/menubarusb"  # USB device menu bar monitor
cask "microsoft-teams"              # Microsoft Teams
cask "reminders-menubar"            # Apple Reminders in the menu bar
cask "sf-symbols"                   # Apple SF Symbols browser
cask "stats"                        # system monitor in menu bar
cask "updatest/tap/updatest@beta"   # app updater
cask "warp"                         # Warp terminal

# ============================================================================
# Casks — Apps to review for Homebrew management
# ============================================================================
# These apps are installed on the source machine but weren't managed by
# Homebrew. All have valid casks. Uncomment the ones you want Homebrew to
# install and keep updated on the new machine.
#
# Tip: after uncommenting, run:
#   brew bundle --file=~/.config/dotfiles/Brewfile --no-lock

# --- Core apps ---
# cask "1password"                  # 1Password password manager
# cask "obsidian"                   # Obsidian knowledge base
# cask "raycast"                    # Raycast launcher (replaces Spotlight)

# --- Browsers ---
# cask "brave-browser"              # Brave Browser
# cask "firefox"                    # Firefox
# cask "google-chrome"              # Google Chrome

# --- Communication ---
# cask "beeper"                     # Beeper unified messaging
# cask "discord"                    # Discord
# cask "legcord"                    # Legcord (lightweight Discord client)
# cask "mimestream"                 # Mimestream native Gmail client
# cask "signal"                     # Signal private messenger
# cask "whatsapp"                   # WhatsApp
# cask "zoom"                       # Zoom

# --- Development ---
# cask "cursor"                     # Cursor AI editor
# cask "visual-studio-code"         # VS Code
# cask "github"                     # GitHub Desktop
# cask "orbstack"                   # OrbStack (Docker/Linux on Mac)
# cask "postman"                    # Postman API client
# cask "tableplus"                  # TablePlus database GUI
# cask "tower"                      # Tower Git client
# cask "yaak"                       # Yaak API client
# cask "repo-prompt"                # Repo Prompt (codebase → LLM context)
# cask "codex"                      # OpenAI Codex CLI

# --- AI ---
# cask "chatgpt"                    # ChatGPT desktop app
# cask "claude"                     # Claude desktop app
# cask "macwhisper"                 # MacWhisper local transcription

# --- Design & Media ---
# cask "figma"                      # Figma design tool
# cask "iina"                       # IINA media player
# cask "imageoptim"                 # ImageOptim image compressor
# cask "pixelsnap"                  # PixelSnap 2 screen measuring
# cask "rightfont"                  # RightFont font manager
# cask "iconjar"                    # IconJar icon organiser
# cask "screen-studio"              # Screen Studio screen recorder
# cask "clop"                       # Clop image/video optimizer
# cask "downie"                     # Downie video downloader

# --- Productivity & Utilities ---
# cask "antinote"                   # Antinote floating notes
# cask "blip"                       # Blip
# cask "bloom"                      # Bloom focus timer
# cask "displaybuddy"               # DisplayBuddy external monitor control
# cask "ghostty"                    # Ghostty terminal emulator
# cask "google-drive"               # Google Drive file sync
# cask "kaleidoscope"               # Kaleidoscope diff/merge tool
# cask "linear-linear"              # Linear project management
# cask "loopback"                   # Loopback virtual audio routing
# cask "netnewswire"                # NetNewsWire RSS reader
# cask "nordvpn"                    # NordVPN
# cask "numi"                       # Numi natural language calculator
# cask "onyx"                       # OnyX system maintenance utility
# cask "pdf-expert"                 # PDF Expert editor
# cask "pearcleaner"                # Pearcleaner app uninstaller
# cask "powerphotos"                # PowerPhotos photo library manager
# cask "synology-drive"             # Synology Drive client

# ============================================================================
# Casks — Fonts
# ============================================================================

cask "font-hack-nerd-font"
cask "font-jetbrains-mono-nerd-font"
cask "font-sf-mono-nerd-font-ligaturized"
cask "font-sf-pro"
cask "font-symbols-only-nerd-font"

# ============================================================================
# Mac App Store
# ============================================================================
# Requires App Store sign-in. If running bootstrap.sh on a fresh Mac, these
# will be skipped on the first pass. Sign in to the App Store, then re-run:
#   brew bundle --file=~/.config/dotfiles/Brewfile --no-lock

mas "1Password for Safari", id: 1569813296
mas "Actions For Obsidian", id: 1659667937
mas "Anybox", id: 1593408455
mas "Better Rename", id: 6738119141
mas "BrowserSwitch", id: 1545802199
mas "Capture", id: 6458535284
mas "CCCCorners", id: 6754601983
mas "Compressor", id: 424390742
mas "CotEditor", id: 1024640650
mas "DaisyDisk", id: 411643860
mas "Dato", id: 1470584107
mas "Days", id: 1551509202
mas "Declutr", id: 6747143693
mas "Developer", id: 640199958
mas "Drafts", id: 1435957248
mas "Dropover", id: 1355679052
mas "Final Cut Pro", id: 424389933
mas "Folder Peek", id: 1615988943
mas "Gapplin", id: 768053424
mas "Gestimer", id: 6447125648
mas "Gifski", id: 1351639930
mas "GoodLinks", id: 1474335294
mas "Hyperduck", id: 6444667067
mas "iA Writer", id: 775737590
mas "Image2Icon", id: 992115977
mas "Just Press Record", id: 1033342465
mas "Keka", id: 470158793
mas "MediaInfo", id: 510620098
mas "Menu Drop", id: 6754022187
mas "MetaImage", id: 1397099749
mas "MetaVideo", id: 6443710350
mas "Mini Stopwatch", id: 6739762059
mas "Numbers", id: 409203825
mas "OneTab", id: 1540160809
mas "Photomator", id: 1444636541
mas "Pixelmator Pro", id: 1289583905
mas "Presentify", id: 1507246666
mas "Pure Paste", id: 1611378436
mas "rcmd", id: 1596283165
mas "Reeder", id: 6475002485
mas "RocketSim", id: 1504940162
mas "Save to Raindrop.io", id: 1549370672
mas "Shareful", id: 1522267256
mas "Stretch It", id: 6670762193
mas "Tim", id: 1449619230
mas "Xcode", id: 497799835
mas "Zone Bar", id: 6755328989

# ============================================================================
# VS Code Extensions
# ============================================================================
# These are restored by `brew bundle` when VS Code is installed.
# Cursor shares VS Code's extension system and will pick these up too.

vscode "aaron-bond.better-comments"
vscode "adpyke.codesnap"
vscode "akamud.vscode-theme-onedark"
vscode "akamud.vscode-theme-onelight"
vscode "alefragnani.bookmarks"
vscode "alexdo.catppuccin-noir"
vscode "anthropic.claude-code"
vscode "anysphere.remote-containers"
vscode "astro-build.astro-vscode"
vscode "augment.vscode-augment"
vscode "austenc.tailwind-docs"
vscode "bierner.markdown-mermaid"
vscode "biomejs.biome"
vscode "bradlc.vscode-tailwindcss"
vscode "castrogusttavo.symbols"
vscode "catppuccin.catppuccin-vsc"
vscode "catppuccin.catppuccin-vsc-icons"
vscode "christian-kohler.path-intellisense"
vscode "csstools.postcss"
vscode "databricks.neon-local-connect"
vscode "davidanson.vscode-markdownlint"
vscode "dbaeumer.vscode-eslint"
vscode "dotjoshjohnson.xml"
vscode "eamodio.gitlens"
vscode "esbenp.prettier-vscode"
vscode "fabian-hiller.pace-theme"
vscode "figma.figma-vscode-extension"
vscode "formulahendry.auto-rename-tag"
vscode "formulahendry.code-runner"
vscode "fosshaas.fontsize-shortcuts"
vscode "github.copilot"
vscode "github.github-vscode-theme"
vscode "github.vscode-github-actions"
vscode "gruntfuggly.todo-tree"
vscode "iyulab.copy-text-selected-files"
vscode "johnpapa.vscode-peacock"
vscode "kisstkondoros.vscode-gutter-preview"
vscode "l13rary.l13-diff"
vscode "l13rary.l13-projects"
vscode "liviuschera.noctis"
vscode "marxism.ai-token-count"
vscode "mechatroner.rainbow-csv"
vscode "mikestead.dotenv"
vscode "mintlify.document"
vscode "monokai.theme-monokai-pro-vscode"
vscode "ms-playwright.playwright"
vscode "ms-vsliveshare.vsliveshare"
vscode "naumovs.color-highlight"
vscode "nichabosh.minimalist-dark"
vscode "nuxt.mdc"
vscode "openai.chatgpt"
vscode "otovo-oss.htmx-tags"
vscode "pmndrs.pmndrs"
vscode "pmneo.tsimporter"
vscode "postman.postman-for-vscode"
vscode "prisma.prisma"
vscode "pushqrdx.inline-html"
vscode "quicktype.quicktype"
vscode "raillyhugo.one-hunter"
vscode "redhat.vscode-yaml"
vscode "ritwickdey.liveserver"
vscode "rvest.vs-code-prettier-eslint"
vscode "shd101wyy.markdown-preview-enhanced"
vscode "stagewise.stagewise-vscode-extension"
vscode "streetsidesoftware.code-spell-checker"
vscode "styled-components.vscode-styled-components"
vscode "supabase.postgrestools"
vscode "tailwindlabs.tailwindcss-vscode-theme"
vscode "tamasfe.even-better-toml"
vscode "tomoki1207.pdf"
vscode "tomoyukim.vscode-mermaid-editor"
vscode "unifiedjs.vscode-mdx"
vscode "usernamehw.errorlens"
vscode "vincaslt.highlight-matching-tag"
vscode "vunguyentuan.vscode-postcss"
vscode "vxplain.vxplain"
vscode "wakatime.vscode-wakatime"
vscode "wallabyjs.quokka-vscode"
vscode "wayou.vscode-todo-highlight"
vscode "webpro.vscode-knip"
vscode "wix.vscode-import-cost"
vscode "yoavbls.pretty-ts-errors"
vscode "zhuangtongfa.material-theme"
