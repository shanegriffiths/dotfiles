#!/bin/sh
# Renders tmux session list for status bar
# Current session: pink bold, others: muted
# Colors: pink=#f5c2e7, red=#f38ba8, overlay_0=#6c7086
current="$1"
prefix="$2"
if [ "$prefix" = "1" ]; then
  active_fg="#f38ba8"
else
  active_fg="#f5c2e7"
fi
muted="#6c7086"
sep="#6c7086"
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
