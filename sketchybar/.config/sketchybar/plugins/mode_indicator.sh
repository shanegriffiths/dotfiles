#!/bin/bash

# Show a badge for non-default aerospace modes.
# Triggered by aerospace's on-mode-changed callback with $MODE in env.

case "$MODE" in
    "laptop")
        sketchybar --set "$NAME" drawing=on \
                                 icon="" \
                                 label="LAPTOP" \
                                 background.drawing=on \
                                 background.color=0xff5e81ac
        ;;
    "service")
        sketchybar --set "$NAME" drawing=on \
                                 icon="" \
                                 label="SERVICE" \
                                 background.drawing=on \
                                 background.color=0xffd08770
        ;;
    *)
        sketchybar --set "$NAME" drawing=off
        ;;
esac
