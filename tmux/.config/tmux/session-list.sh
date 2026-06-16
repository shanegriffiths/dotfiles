#!/bin/sh
# Renders tmux session list for status bar.
# Colours follow macOS appearance (light/dark) so the bar matches the terminal.
# Current session: bold accent, others: muted. Turns red when prefix is active.
current="$1"
prefix="$2"

if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then
  active_prefix="#f38ba8"   # red    (prefix held)
  active_norm="#f5c2e7"     # pink   (current session)
  muted="#6c7086"           # catppuccin overlay_0
  sep="#6c7086"
else
  active_prefix="#c4262b"   # red    (prefix held)
  active_norm="#0e1116"     # near-black (current session, matches Ghostty fg)
  muted="#6e7781"           # GitHub muted grey
  sep="#d0d7de"             # GitHub border grey
fi

if [ "$prefix" = "1" ]; then
  active_fg="$active_prefix"
else
  active_fg="$active_norm"
fi

icon=$(printf '\xee\xaf\x88')
first=1
tmux list-sessions -F '#{session_name}' | while read -r s; do
  [ "$s" = "scratch" ] && continue
  if [ "$first" != "1" ]; then
    printf '#[fg=%s,none] │ ' "$sep"
  fi
  first=0
  if [ "$s" = "$current" ]; then
    printf '#[fg=%s,bold]%s %s' "$active_fg" "$icon" "$s"
  else
    printf '#[fg=%s,none]%s %s' "$muted" "$icon" "$s"
  fi
done
