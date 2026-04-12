# Uncomment to profile startup time:
# zmodload zsh/zprof

# ---------------------------------------------------------------------------
# PATH SETUP (must be first to ensure tools are available)
# ---------------------------------------------------------------------------

# Homebrew (Apple Silicon)
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------
# SSH SESSION DETECTION
# ---------------------------------------------------------------------------

# Detect if we're in an SSH session (lighter config to avoid input lag).
if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]]; then
  IS_SSH_SESSION=true
fi

# ---------------------------------------------------------------------------
# OH MY ZSH CONFIGURATION
# ---------------------------------------------------------------------------

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Disable Oh My Zsh's theme engine to use Starship.
ZSH_THEME=""

# Oh My Zsh plugins. Use a lighter set over SSH to prevent input lag.
if [[ -n "$IS_SSH_SESSION" ]]; then
  plugins=(
    git
    sudo
  )
else
  plugins=(
    git
    sudo
    command-not-found
    zsh-completions
    fzf-tab
    zsh-autosuggestions
    zsh-syntax-highlighting
  )
fi

# Load Oh My Zsh (interactive only — plugins are for terminal use).
if [[ $- == *i* ]]; then
  source $ZSH/oh-my-zsh.sh
fi

# ---------------------------------------------------------------------------
# COMPLETION TUNING
# ---------------------------------------------------------------------------

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always $realpath | head -200'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zcompcache"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# ---------------------------------------------------------------------------
# USER CONFIGURATION
# ---------------------------------------------------------------------------

# Set the default editor.
export EDITOR='nvim'

# Environment switching for local development (via direnv + pass)
# Usage: useenv [dev|prev|prod]
# Sources the matching .envrc file and allows direnv
useenv() {
  local env="${1:-dev}"
  local envfile

  case "$env" in
    dev|local) envfile=".envrc" ;;
    prev|preview) envfile=".envrc.preview" ;;
    prod|production) envfile=".envrc.production" ;;
    *)
      echo "Error: unknown environment '$env'"
      echo "Available: dev, prev, prod"
      return 1
      ;;
  esac

  if [[ ! -f "$envfile" ]]; then
    echo "Error: $envfile not found"
    return 1
  fi

  source "$envfile"
  direnv allow
  echo "✓ Now using: $env"
}

clearenv() {
  direnv deny 2>/dev/null
  unset STARSHIP_ENV_NAME
  echo "✓ Environment cleared"
}

# History settings: Increase size and set options for a better experience.
HISTFILE=$HOME/.zhistory
HISTSIZE=50000
SAVEHIST=50000
setopt share_history          # Share history between all sessions.
setopt hist_expire_dups_first # Delete older duplicates first.
setopt hist_ignore_dups       # Don't record commands that are duplicates of the previous one.
setopt hist_ignore_all_dups   # Remove older duplicate anywhere in history.
setopt hist_ignore_space      # Space-prefixed commands stay out of history.
setopt hist_find_no_dups      # No duplicates when searching history.
setopt hist_verify            # Don't execute history expansions immediately.
setopt hist_reduce_blanks     # Normalize whitespace in history entries.

# Auto-list directory contents on cd.
chpwd() {
  ls
}

# Shell options for navigation and safety.
setopt auto_cd              # Type directory name to cd into it.
setopt auto_pushd           # cd pushes old dir onto stack.
setopt pushd_ignore_dups
setopt pushd_silent
setopt extended_glob        # Enable # ~ ^ as glob operators.
setopt glob_dots            # Include dotfiles in globs.
setopt no_clobber           # Prevent > from overwriting files (use >| to force).

# Completion using arrow keys (based on history).
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Undo last command-line edit (Ctrl+Z).
bindkey '^z' undo

# Open current command line in $EDITOR (Ctrl+X then Ctrl+E).
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Copy current command line to clipboard (Ctrl+C).
copy-command() {
    echo -n $BUFFER | pbcopy
    zle -M "Copied to clipboard"
}
zle -N copy-command
bindkey '^Xc' copy-command

# Clear screen, keep buffer (Ctrl+X then l).
clear-keep-buffer() {
    zle clear-screen
}
zle -N clear-keep-buffer
bindkey '^Xl' clear-keep-buffer

# ---------------------------------------------------------------------------
# Fzf
# ---------------------------------------------------------------------------

# Set up fzf key bindings and fuzzy completion (interactive only, not SSH).
if [[ $- == *i* && -z "$IS_SSH_SESSION" ]]; then
  eval "$(fzf --zsh)"
fi

# Set up atuin shell history (Ctrl+R for history search)
export ATUIN_NOBIND=true
if [[ -z "$IS_SSH_SESSION" ]]; then
  eval "$(atuin init zsh)"
  bindkey '^r' atuin-search
fi

# Set up navi cheatsheet widget (Ctrl+G)
if [[ -z "$IS_SSH_SESSION" ]]; then
  eval "$(navi widget zsh)"
fi

# -- Use fd instead of fzf --

export FZF_DEFAULT_OPTS="--height 50% --layout=default --border --color=hl:#2dd4bf,bg:#262626,preview-bg:#262626"
export FZF_TMUX_OPTS="-p90%,70%"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ---------------------------------------------------------------------------
# TOOL INITIALIZATION
# ---------------------------------------------------------------------------

# Eza Aliases (a modern replacement for ls)
function ls() {
  eza --color=always --icons=always --grid --group-directories-first --width=$(( COLUMNS / 3 )) "$@"
}

# Suffix Aliases — type a filename to open it with the right tool
alias -s md='open -a MarkEdit'
alias -s pdf='open -a "PDF Expert"'
alias -s svg='open -a Gapplin'
alias -s {png,jpg,jpeg,gif,webp}='open -a Preview'
alias -s {mov,mp4,mkv,avi}='open -a IINA'
alias -s {js,ts,jsx,tsx,go,py,sh,zsh}="$EDITOR"
alias -s {yaml,yml,toml}='bat -l yaml'
alias -s json='bat -l json'
alias -s csv='csvlens'
alias -s html='open'
alias -s log='bat -l log'

# Global Aliases — expand anywhere in a command
alias -g C='| pbcopy'

# Activate Zoxide (a smarter cd command) — only in interactive shells
# to avoid "command not found: __zoxide_z" in non-interactive contexts.
if [[ $- == *i* ]]; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ---------------------------------------------------------------------------
# QUALITY OF LIFE ALIASES
# ---------------------------------------------------------------------------

alias ..='cd ..'
alias ...='cd ../..'
alias zshrc='${EDITOR} ~/.zshrc'
alias reload='source ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'
# Directory stack (pairs with auto_pushd)
alias d='dirs -v | head -10'
# Dotfiles management (GNU Stow)
alias dot='git -C $HOME/.dotfiles'
alias o.='open -a Bloom .'

# ---------------------------------------------------------------------------
# LOCAL OVERRIDES (secrets, machine-specific config)
# ---------------------------------------------------------------------------

[[ -f ~/.zsh_local ]] && source ~/.zsh_local

# ---------------------------------------------------------------------------
# PROMPT INITIALIZATION (MUST BE LAST)
# ---------------------------------------------------------------------------

# System info on new shell (disabled — run `fastfetch` manually when needed)
# fastfetch

# Direnv — auto-load .envrc per-directory (must be before starship)
export DIRENV_LOG_FORMAT=""
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# Load Starship - a fast, cross-shell prompt (interactive only).
# Use a minimal config over SSH to avoid prompt lag.
if [[ $- == *i* ]]; then
  if [[ -n "$IS_SSH_SESSION" ]]; then
    export STARSHIP_CONFIG="$HOME/.config/starship-ssh.toml"
  fi
  eval "$(starship init zsh)"
fi

# bun completions
[ -s "/Users/shane/.bun/_bun" ] && source "/Users/shane/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Uncomment (along with top of file) to profile startup time:
# zprof
export PATH="/usr/local/texlive/2025basic/bin/universal-darwin:$PATH"
export PATH="/opt/homebrew/opt/imagemagick-full/bin:$PATH"
