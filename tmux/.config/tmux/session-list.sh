#!/bin/sh
# Renders tmux session list for status bar.
# Colours follow macOS appearance (light/dark) so the bar matches the terminal.
# Current session: bold accent, others: muted. Turns red when prefix is active.
current="$1"
prefix="$2"

active_prefix="red"         # ANSI red — follows the Ghostty palette (both modes)
if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then
  active_norm="#f5c2e7"     # pink   (current session)
  muted="#6c7086"           # catppuccin overlay_0
  sep="#6c7086"
else
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
  # Wrap each name in a user range so it's clickable in the status bar.
  # The range string IS the session name; the MouseDown1Status handler in
  # tmux.conf reads #{mouse_status_range} and switches to it. (Session names
  # can't contain ':' or '.', so they never collide with the built-in
  # window/pane/left/right/session range keywords.)
  if [ "$s" = "$current" ]; then
    printf '#[range=user|%s,fg=%s,bold]%s %s#[norange]' "$s" "$active_fg" "$icon" "$s"
  else
    printf '#[range=user|%s,fg=%s,none]%s %s#[norange]' "$s" "$muted" "$icon" "$s"
  fi
done
