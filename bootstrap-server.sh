#!/usr/bin/env bash
# ~/.dotfiles/bootstrap-server.sh
# Provision the Mac Mini (agent-server) — headless setup for OpenClaw,
# Claude Code, and background tasks.
#
# Usage (if repo is already cloned):
#   bash ~/.dotfiles/bootstrap-server.sh
#
# Or from a fresh machine (requires SSH key for git clone):
#   bash <(curl -sL https://raw.githubusercontent.com/shanegriffiths/dotfiles/main/bootstrap-server.sh)
#
# The script is idempotent — safe to re-run.

set -euo pipefail

DOTFILES_REPO="git@github.com:shanegriffiths/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# Stow packages to deploy on the server (no GUI packages)
STOW_PACKAGES=(zsh git nvim tmux starship direnv atuin sesh yazi ghostty)

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m==> WARNING:\033[0m %s\n" "$1"; }
ok()   { printf "\033[1;32m==>\033[0m %s\n" "$1"; }

# ============================================================================
# 1. Xcode Command Line Tools
# ============================================================================

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

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    ok "Homebrew already installed"
fi

brew update

# Install stow early — needed to symlink dotfiles
if ! command -v stow &>/dev/null; then
    info "Installing GNU Stow..."
    brew install stow
else
    ok "GNU Stow already installed"
fi

# ============================================================================
# 3. Clone dotfiles and stow server configs
# ============================================================================

if [ ! -d "$DOTFILES_DIR/.git" ]; then
    info "Cloning dotfiles..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    ok "Dotfiles repo already exists"
fi

info "Stowing dotfiles (server packages only)..."
cd "$DOTFILES_DIR"

# Dry run to detect conflicts
if ! stow -n "${STOW_PACKAGES[@]}" 2>/dev/null; then
    warn "Backing up conflicting files to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    stow --adopt "${STOW_PACKAGES[@]}"
    git checkout .
else
    stow "${STOW_PACKAGES[@]}"
fi

ok "Dotfiles stowed"

# ============================================================================
# 4. Brew Bundle (server Brewfile)
# ============================================================================

BREWFILE="$DOTFILES_DIR/Brewfile.server"

if [ -f "$BREWFILE" ]; then
    info "Installing Homebrew packages..."
    brew bundle --file="$BREWFILE" --no-upgrade
else
    warn "Brewfile.server not found at $BREWFILE — skipping"
fi

# ============================================================================
# 5. Oh My Zsh
# ============================================================================

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    ok "Oh My Zsh already installed"
fi

# ============================================================================
# 6. Oh My Zsh custom plugins
# ============================================================================

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_plugin() {
    local name="$1" url="$2"
    local plugin_dir="$ZSH_CUSTOM/plugins/$name"
    if [ ! -d "$plugin_dir" ]; then
        info "Cloning $name..."
        git clone "$url" "$plugin_dir"
    else
        ok "$name already installed"
    fi
}

clone_plugin fzf-tab https://github.com/Aloxaf/fzf-tab
clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
clone_plugin zsh-completions https://github.com/zsh-users/zsh-completions

# ============================================================================
# 7. tmux Plugin Manager (tpm)
# ============================================================================

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

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"

if command -v nvm &>/dev/null; then
    info "Installing Node.js LTS via nvm..."
    nvm install --lts
    nvm alias default lts/*

    info "Enabling pnpm via corepack..."
    corepack enable
    corepack prepare pnpm@latest --activate
else
    warn "nvm not found — install Node manually after fixing PATH"
fi

# ============================================================================
# 9. Done
# ============================================================================

echo ""
echo "============================================"
echo "  Server bootstrap complete!"
echo "============================================"
echo ""
echo "Manual steps remaining:"
echo ""
echo "  1. Open neovim — plugins will auto-install on first launch"
echo "  2. In tmux, press prefix + I to install plugins"
echo "  3. Run 'source ~/.zshrc' or start a new shell"
echo "  4. Set up Claude Code: claude login"
echo ""
