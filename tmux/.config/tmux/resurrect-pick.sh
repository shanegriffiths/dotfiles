#!/bin/sh
# Resurrect snapshot picker — browse and restore any saved tmux session snapshot
# Shows: date/time, session count, window count, session names
# Only shows snapshots where the state actually changed (deduped by signature)
#
# Usage:
#   resurrect-pick.sh list    — output lines for fzf
#   resurrect-pick.sh select  — receive a picked line on stdin, update 'last' symlink

dir="$HOME/.local/share/tmux/resurrect"

# Convert "2026-04-10 16:45:00" back to "tmux_resurrect_20260410T164500"
line_to_fname() {
  date_part=$(echo "$1" | awk '{print $1}' | tr -d '-')
  time_part=$(echo "$1" | awk '{print $2}' | tr -d ':')
  echo "tmux_resurrect_${date_part}T${time_part}"
}

case "${1:-list}" in
list)
  prev_sig=""
  find "$dir" -name 'tmux_resurrect_*.txt' -type f | sort -r | while read -r f; do
    fname=$(basename "$f" .txt)
    ts=$(echo "$fname" | sed 's/tmux_resurrect_//' | sed 's/T/ /')
    date_part=$(echo "$ts" | cut -c1-4)-$(echo "$ts" | cut -c5-6)-$(echo "$ts" | cut -c7-8)
    time_part=$(echo "$ts" | cut -d' ' -f2 | sed 's/\(..\)\(..\)\(..\)/\1:\2:\3/')

    sessions=$(grep "^pane" "$f" | awk -F'\t' '{print $2}' | grep -v '^scratch$' | sort -u)
    session_count=$(echo "$sessions" | grep -c .)
    session_names=$(echo "$sessions" | paste -sd ',' - | sed 's/,/, /g')
    window_count=$(grep "^window" "$f" | grep -v 'scratch' | wc -l | tr -d ' ')

    # Signature: session count + window count + session names
    sig="${session_count}|${window_count}|${session_names}"

    # Skip if identical to previous snapshot
    if [ "$sig" = "$prev_sig" ]; then
      continue
    fi
    prev_sig="$sig"

    printf "%s %s │ %s sessions │ %s windows │ %s\n" \
      "$date_part" "$time_part" "$session_count" "$window_count" "$session_names"
  done
  ;;
select)
  read -r line
  fname=$(line_to_fname "$line")
  target="$dir/${fname}.txt"
  if [ -f "$target" ]; then
    ln -sf "${fname}.txt" "$dir/last"
    echo "✓ Ready to restore: $fname"
    echo "  Press prefix+Ctrl+r to restore now"
  else
    echo "✗ File not found: $target"
  fi
  ;;
esac
