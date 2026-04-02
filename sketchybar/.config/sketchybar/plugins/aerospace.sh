#!/usr/bin/env bash

# Aerospace workspace script for sketchybar
# Optimized with batched sketchybar calls

# Exit early if aerospace is not running
if ! pgrep -x "AeroSpace" > /dev/null 2>&1; then
    exit 0
fi

# Source icon_map ONCE at the start
source "$CONFIG_DIR/items/icon_map.sh"

WORKSPACE_ID="$1"

# Get apps running in this workspace
apps=$(aerospace list-windows --workspace "$WORKSPACE_ID" 2>/dev/null | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

# Build icon strip if apps exist
icon_strip=""
if [ -n "${apps}" ]; then
    while IFS= read -r app; do
        if [ -n "$app" ]; then
            icon=$(__icon_map "$app")
            icon_strip+="$icon "
        fi
    done <<<"${apps}"
fi

# Determine label drawing state
if [ -n "$icon_strip" ]; then
    label_drawing="on"
else
    label_drawing="off"
fi

# Determine if this is the focused workspace and build a single batched command
if [ "$WORKSPACE_ID" = "$FOCUSED_WORKSPACE" ]; then
    # Focused workspace - single batched update
    sketchybar --set "space.$WORKSPACE_ID" \
        background.drawing=on \
        background.color=0xffd13539 \
        background.border_width=0 \
        background.corner_radius=10 \
        background.height=28 \
        icon.drawing=on \
        icon="$WORKSPACE_ID" \
        icon.font="SF Pro:Medium:13.0" \
        icon.color=0xffffffff \
        icon.padding_left=12 \
        icon.padding_right=12 \
        label.drawing="$label_drawing" \
        label="$icon_strip" \
        label.font="sketchybar-app-font:Regular:13.0" \
        label.color=0xffffffff \
        label.padding_left=0 \
        label.padding_right=12
else
    # Unfocused workspace - single batched update
    sketchybar --set "space.$WORKSPACE_ID" \
        background.drawing=on \
        background.color=0x00000000 \
        background.border_width=2 \
        background.corner_radius=10 \
        background.height=28 \
        icon.drawing=on \
        icon="$WORKSPACE_ID" \
        icon.font="SF Pro:Medium:13.0" \
        icon.color=0xffffffff \
        icon.padding_left=12 \
        icon.padding_right=12 \
        label.drawing="$label_drawing" \
        label="$icon_strip" \
        label.font="sketchybar-app-font:Regular:13.0" \
        label.color=0xffffffff \
        label.padding_left=0 \
        label.padding_right=12
fi
