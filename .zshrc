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
# OH MY ZSH CONFIGURATION
# ---------------------------------------------------------------------------

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Disable Oh My Zsh's theme engine to use Starship.
ZSH_THEME=""

# Oh My Zsh plugins. zsh-syntax-highlighting should be last.
plugins=(
  git
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Load Oh My Zsh (interactive only — plugins are for terminal use).
if [[ $- == *i* ]]; then
  source $ZSH/oh-my-zsh.sh
fi

# ---------------------------------------------------------------------------
# COMPLETION TUNING
# ---------------------------------------------------------------------------

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
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

# Environment switching for local development
# Usage: useenv [dev|prev|prod]
# Creates .env.local from .env.[env] and sets .current-env for status line
useenv() {
  local env="${1:-dev}"
  local envfile=".env.${env}"

  if [[ ! -f "$envfile" ]]; then
    echo "Error: $envfile not found"
    local available=$(ls -1 .env.* 2>/dev/null | grep -v '.env.local' | sed 's/.env.//' | tr '\n' ' ')
    [[ -n "$available" ]] && echo "Available: $available"
    return 1
  fi

  cp "$envfile" .env.local
  echo "$env" > .current-env
  echo "✓ Now using: $env"
}

clearenv() {
  rm -f .current-env
  echo "✓ Environment indicator cleared"
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

# ---------------------------------------------------------------------------
# Fzf
# ---------------------------------------------------------------------------

# Set up fzf key bindings and fuzzy completion (interactive only).
if [[ $- == *i* ]]; then
  eval "$(fzf --zsh)"
fi

# -- Use fd instead of fzf --

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
alias ls='eza --color=always --icons=always --grid --group-directories-first'

# Activate Zoxide (a smarter cd command) — only in interactive shells
# to avoid "command not found: __zoxide_z" in non-interactive contexts.
if [[ $- == *i* ]]; then
  eval "$(zoxide init zsh)"
  alias cd="z"
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
# Dotfiles management (bare git repo)
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# ---------------------------------------------------------------------------
# LOCAL OVERRIDES (secrets, machine-specific config)
# ---------------------------------------------------------------------------

[[ -f ~/.zsh_local ]] && source ~/.zsh_local

# ---------------------------------------------------------------------------
# PROMPT INITIALIZATION (MUST BE LAST)
# ---------------------------------------------------------------------------

# Load Starship - a fast, cross-shell prompt (interactive only).
if [[ $- == *i* ]]; then
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
