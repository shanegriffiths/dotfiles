export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export EDITOR='nvim'
export VISUAL='nvim'

# Homebrew on PATH for non-interactive shells. `ssh host cmd` sources only
# .zshenv, so without this mosh/Moshi can't find mosh-server, tmux or herdr.
case ":$PATH:" in
  *":/opt/homebrew/bin:"*) ;;
  *) export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH" ;;
esac
