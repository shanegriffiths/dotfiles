#!/bin/sh
# Unified preview for sesh picker — handles both sesh items and resurrect snapshots

# Resurrect snapshot — starts with "YYYY-MM-DD HH:MM:SS"
case "$1" in
[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\ *)
  exec "$HOME/.config/tmux/resurrect-preview.sh" "$1"
  ;;
*)
  exec sesh preview "$1"
  ;;
esac
