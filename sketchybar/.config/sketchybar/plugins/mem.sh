#!/bin/bash

# macOS treats inactive pages as available, so add them to free.
MEM_TOTAL=$(sysctl -n hw.memsize)
PAGE_SIZE=$(sysctl -n hw.pagesize)

read -r PAGES_FREE PAGES_INACTIVE < <(vm_stat | awk '
    /Pages free:/      {gsub(/\./,"",$3); free=$3}
    /Pages inactive:/  {gsub(/\./,"",$3); inactive=$3}
    END                {print free, inactive}
')

FREE_BYTES=$(( (PAGES_FREE + PAGES_INACTIVE) * PAGE_SIZE ))
USED_BYTES=$(( MEM_TOTAL - FREE_BYTES ))
USED_PCT=$(( USED_BYTES * 100 / MEM_TOTAL ))

NORMALISED=$(awk -v u="$USED_PCT" 'BEGIN{printf "%.4f", u/100}')

sketchybar --push "$NAME" "$NORMALISED" \
           --set "$NAME" label="MEM ${USED_PCT}%"
