#!/bin/sh
# Wrapper for sesh picker — routes selection to sesh connect or resurrect restore
# Resurrect lines start with a date like "2026-04-10 16:45:00 │ ..."

selection="$1"
[ -z "$selection" ] && exit 0

dir="$HOME/.local/share/tmux/resurrect"

# Resurrect snapshot — identified by "YYYY-MM-DD HH:MM:SS │" pattern
case "$selection" in
[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\ *)
  date_part=$(echo "$selection" | awk '{print $1}' | tr -d '-')
  time_part=$(echo "$selection" | awk '{print $2}' | tr -d ':')
  fname="tmux_resurrect_${date_part}T${time_part}"
  target="$dir/${fname}.txt"
  if [ -f "$target" ]; then
    ln -sf "${fname}.txt" "$dir/last"
    tmux display "Snapshot ready — press prefix+Ctrl+r to restore"
  else
    tmux display "Snapshot not found: $fname"
  fi
  ;;
*)
  # Normal sesh selection
  sesh connect "$selection"
  ;;
esac
