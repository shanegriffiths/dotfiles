#!/usr/bin/env bash

# Dynamic border colors based on window floating state.
# Called from aerospace on-focus-changed and the layout-toggle binding —
# cache short-circuits no-op invocations to keep the focus-change path cheap.

ACTIVE_TILED="0xFFC4262B"      # Red for tiled windows
ACTIVE_FLOATING="0xFFFFFFFF"   # White for floating windows
INACTIVE="0xff494d64"          # Grey for all inactive

WIDTH="8.0"
STYLE="round"
HIDPI="on"
BLACKLIST="Sleeve"

CACHE_FILE="/tmp/.borders-layout"

layout=$(aerospace list-windows --focused --format '%{window-parent-container-layout}' 2>/dev/null)
[ -z "$layout" ] && layout="tiles"

if [ -f "$CACHE_FILE" ] && [ "$layout" = "$(cat "$CACHE_FILE")" ]; then
    exit 0
fi

if [ "$layout" = "floating" ]; then
    borders active_color="$ACTIVE_FLOATING" inactive_color="$INACTIVE" \
            width="$WIDTH" style="$STYLE" hidpi="$HIDPI" blacklist="$BLACKLIST"
else
    borders active_color="$ACTIVE_TILED" inactive_color="$INACTIVE" \
            width="$WIDTH" style="$STYLE" hidpi="$HIDPI" blacklist="$BLACKLIST"
fi

echo "$layout" > "$CACHE_FILE"
