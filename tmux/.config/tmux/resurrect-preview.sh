#!/bin/sh
# Preview script for resurrect-pick fzf picker
# Receives the full fzf line, extracts date/time, shows session/window summary

dir="$HOME/.local/share/tmux/resurrect"

# Convert "2026-04-10 16:45:00" back to "tmux_resurrect_20260410T164500"
date_part=$(echo "$1" | awk '{print $1}' | tr -d '-')
time_part=$(echo "$1" | awk '{print $2}' | tr -d ':')
fname="tmux_resurrect_${date_part}T${time_part}"
file="$dir/${fname}.txt"

[ ! -f "$file" ] && exit 0

grep "^window" "$file" | grep -v 'scratch' | awk -F'\t' '{
  gsub(/:/, "", $4)
  printf "  %s │ %s\n", $2, $4
}'
