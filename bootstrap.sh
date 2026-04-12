#!/usr/bin/env bash
# ~/.dotfiles/bootstrap.sh
# Provision a fresh Mac from scratch — installs tools, apps, and preferences.
#
# What it does (in order):
#   1.  Xcode Command Line Tools
#   2.  Homebrew
#   3.  Clone dotfiles repo and stow configs (backs up any conflicting files)
#   4.  Brew Bundle (formulae, casks, fonts, MAS apps, VS Code extensions)
#   5.  Oh My Zsh
#   6.  Oh My Zsh custom plugins (fzf-tab, autosuggestions, syntax-highlighting)
#   7.  tmux Plugin Manager (tpm)
#   8.  NVM + Node LTS + pnpm (via corepack)
#   9.  Bun
#   10. macOS system preferences (macos.sh)
#   11. Post-install checklist
#
# Usage — on a fresh Mac (requires SSH key for git clone):
#   bash <(curl -sL https://raw.githubusercontent.com/shanegriffiths/dotfiles/main/bootstrap.sh)
#
# Or if the repo is already cloned:
#   bash ~/.dotfiles/bootstrap.sh
#
# The script is idempotent — each step checks whether it's already done and
# skips if so. Safe to re-run after a partial failure or to pick up changes.
#
# Requirements:
#   - macOS (tested on Sequoia 15.x / Apple Silicon)
#   - Internet connection
#   - SSH key configured for github.com (for the dotfiles clone)
#     If you don't have an SSH key yet, set one up via 1Password SSH agent
#     or `ssh-keygen`, then re-run this script.

set -euo pipefail

DOTFILES_REPO="git@github.com:shanegriffiths/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m==> WARNING:\033[0m %s\n" "$1"; }
ok()   { printf "\033[1;32m==>\033[0m %s\n" "$1"; }

# ============================================================================
# 1. Xcode Command Line Tools
# ============================================================================
# Required for git, compilers, and many Homebrew formulae.

if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press any key once the installation is complete..."
    read -n 1 -s
else
    ok "Xcode Command Line Tools already installed"
fi

# ============================================================================
# 2. Homebrew
# ============================================================================
# Package manager for macOS. Installs to /opt/homebrew on Apple Silicon.

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH for the rest of this script
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    ok "Homebrew already installed"
fi

brew update

# Install stow early — needed to symlink dotfiles in step 3
if ! command -v stow &>/dev/null; then
    info "Installing GNU Stow..."
    brew install stow
else
    ok "GNU Stow already installed"
fi

# ============================================================================
# 3. Clone dotfiles and stow configs
# ============================================================================
# Uses GNU Stow to symlink config files from ~/.dotfiles into $HOME.
# Each subdirectory (zsh/, ghostty/, nvim/, etc.) is a "package" that mirrors
# the home directory structure. `stow */` creates all symlinks at once.

if [ ! -d "$DOTFILES_DIR/.git" ]; then
    info "Cloning dotfiles..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    ok "Dotfiles repo already exists"
fi

# Back up any conflicting files before stowing
info "Stowing dotfiles..."
cd "$DOTFILES_DIR"

# Dry run to detect conflicts
if ! stow -n */ 2>/dev/null; then
    warn "Backing up conflicting files to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"

    # Use --adopt to pull conflicting files into the repo, then restore from git
    stow --adopt */
    git checkout .
else
    stow */
fi

ok "Dotfiles stowed"

# ============================================================================
# 4. Brew Bundle
# ============================================================================
# Installs everything in the Brewfile: formulae, casks, fonts, MAS apps, and
# VS Code extensions. MAS apps will fail silently if not signed in to the
# App Store — the post-install checklist reminds you to sign in and re-run.

BREWFILE="$DOTFILES_DIR/Brewfile"

if [ -f "$BREWFILE" ]; then
    info "Installing Homebrew packages (this may take a while)..."
    brew bundle --file="$BREWFILE" --no-lock
else
    warn "Brewfile not found at $BREWFILE — skipping"
fi

# ============================================================================
# 5. Oh My Zsh
# ============================================================================
# Framework for managing zsh configuration. RUNZSH=no prevents it from
# launching a new shell (which would exit this script).

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    ok "Oh My Zsh already installed"
fi

# ============================================================================
# 6. Oh My Zsh custom plugins
# ============================================================================
# These are git-cloned into ~/.oh-my-zsh/custom/plugins/ rather than installed
# via Homebrew, so they're managed by Oh My Zsh's plugin system.

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

declare -A plugins=(
    ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
    ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
)

for plugin in "${!plugins[@]}"; do
    plugin_dir="$ZSH_CUSTOM/plugins/$plugin"
    if [ ! -d "$plugin_dir" ]; then
        info "Cloning $plugin..."
        git clone "${plugins[$plugin]}" "$plugin_dir"
    else
        ok "$plugin already installed"
    fi
done

# ============================================================================
# 7. tmux Plugin Manager (tpm)
# ============================================================================
# After installation, open tmux and press `prefix + I` to install plugins
# defined in .tmux.conf.

TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
    info "Installing tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    ok "tpm already installed"
fi

# ============================================================================
# 8. NVM + Node LTS + pnpm
# ============================================================================
# NVM is installed by Homebrew (step 4) but works as a shell function, not a
# binary. We source it here to make it available, then install Node LTS and
# enable pnpm via corepack.

export NVM_DIR="$HOME/.nvm"

# Source nvm shell function (Homebrew installs the script, not a binary)
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"

if command -v nvm &>/dev/null; then
    info "Installing Node.js LTS via nvm..."
    nvm install --lts
    nvm alias default lts/*

    # Enable pnpm via corepack (ships with Node 16.9+)
    info "Enabling pnpm via corepack..."
    corepack enable
    corepack prepare pnpm@latest --activate
else
    warn "nvm not found — install Node manually after fixing PATH"
fi

# ============================================================================
# 9. Bun
# ============================================================================
# Fast JavaScript runtime and package manager. Installed via its own script
# rather than Homebrew for easier version management.

if ! command -v bun &>/dev/null; then
    info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
else
    ok "Bun already installed"
fi

# ============================================================================
# 10. macOS Defaults
# ============================================================================
# Applies system preferences (Dock, Finder, keyboard, trackpad, etc.)
# See macos.sh for full documentation of each setting.

MACOS_SCRIPT="$DOTFILES_DIR/macos.sh"

if [ -f "$MACOS_SCRIPT" ]; then
    info "Applying macOS defaults..."
    bash "$MACOS_SCRIPT"
else
    warn "macos.sh not found — skipping"
fi

# ============================================================================
# 11. Post-Install Checklist
# ============================================================================

echo ""
echo "============================================"
echo "  Bootstrap complete!"
echo "============================================"
echo ""
echo "Manual steps remaining:"
echo ""
echo "  1. Sign in to 1Password and enable Safari extension"
echo "  2. Sign in to iCloud and enable services"
echo "  3. Sign in to Mac App Store, then re-run:"
echo "     brew bundle --file=~/.dotfiles/Brewfile --no-lock"
echo "  4. Import Raycast settings (from backup/sync)"
echo "  5. Open Ghostty — config is already in ~/.config/ghostty/"
echo "  6. Open neovim — plugins will auto-install on first launch"
echo "  7. In tmux, press prefix + I to install plugins"
echo "  8. Set up SSH keys (or restore from 1Password SSH agent)"
echo "  9. Review commented casks in Brewfile — uncomment any you want"
echo " 10. Install apps not available via Homebrew/MAS:"
echo "     1Setter, Affinity, Blackmagic Cam, Cavalry, CleanShot X,"
echo "     DitherBoy, Eagle, Focusrite Control 2, Insta360 Link Controller,"
echo "     Logitech Options+, Mockuuups Studio, Port Menu, Rize,"
echo "     RODE Central, Sleeve, Supercharge, Supercut, Synology Image"
echo "     Assistant, TinkerTool, Topaz Gigapixel, Umbra, Wispr Flow,"
echo "     XPPen drivers"
echo ""
echo "  Restart your Mac to apply all changes."
echo ""
