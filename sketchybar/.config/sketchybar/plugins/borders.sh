#!/usr/bin/env bash

# Dynamic border colors based on window floating state
# Called by aerospace on-focus-changed callback

# Colors
ACTIVE_TILED="0xFFC4262B"      # Red for tiled windows
ACTIVE_FLOATING="0xFFFFFFFF"   # White for floating windows
INACTIVE="0xff494d64"          # Grey for all inactive

# Get the layout of the focused window
layout=$(aerospace list-windows --focused --format '%{window-parent-container-layout}' 2>/dev/null)

if [ "$layout" = "floating" ]; then
    borders active_color="$ACTIVE_FLOATING" inactive_color="$INACTIVE" blacklist="Sleeve"
else
    borders active_color="$ACTIVE_TILED" inactive_color="$INACTIVE" blacklist="Sleeve"
fi
