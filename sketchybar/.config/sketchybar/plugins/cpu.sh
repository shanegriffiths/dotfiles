#!/bin/bash

# CPU% from `top` (user + system). The 2-sample run gives a stable read;
# the first sample is the boot baseline and is discarded.
CPU=$(top -l 2 -n 0 -s 1 | awk '/^CPU usage:/ {print $3 + $5}' | tail -1)

# Sketchybar graph values are normalised 0..1
NORMALISED=$(awk -v c="$CPU" 'BEGIN{printf "%.4f", c/100}')

sketchybar --push "$NAME" "$NORMALISED" \
           --set "$NAME" label="${CPU%.*}%"
