#!/bin/sh
# Cycle to the next/previous session in the SAME order shown in the status bar.
# Bar order = `tmux list-sessions` (alphabetical by name) minus the floax `scratch`
# session, matching session-list.sh exactly. Wraps around at the ends.
# Usage: sessions-cycle.sh next|prev

dir="${1:-next}"
current=$(tmux display-message -p '#S')

# Same source + same exclusion as the status bar (session-list.sh).
sessions=$(tmux list-sessions -F '#{session_name}' | grep -vx 'scratch')
[ -z "$sessions" ] && exit 0

target=$(printf '%s\n' "$sessions" | awk -v cur="$current" -v dir="$dir" '
  { names[NR] = $0 }
  END {
    n = NR
    if (n == 0) exit
    idx = 0
    for (i = 1; i <= n; i++) if (names[i] == cur) idx = i
    if (idx == 0) { print names[1]; exit }       # current hidden (e.g. scratch) -> first
    if (dir == "prev") t = (idx == 1 ? n : idx - 1)
    else               t = (idx == n ? 1 : idx + 1)
    print names[t]
  }
')

[ -n "$target" ] && tmux switch-client -t "$target"
