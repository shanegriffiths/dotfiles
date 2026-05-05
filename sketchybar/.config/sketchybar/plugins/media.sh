#!/bin/bash

# Now-playing item. Subscribed to the media_change event; $INFO carries
# JSON with state/title/artist/app from the system media controller.

if [ "$SENDER" != "media_change" ]; then
    exit 0
fi

STATE=$(echo "$INFO" | jq -r '.state // empty')
TITLE=$(echo "$INFO" | jq -r '.title // empty')
ARTIST=$(echo "$INFO" | jq -r '.artist // empty')

if [ "$STATE" = "playing" ] && [ -n "$TITLE" ]; then
    if [ -n "$ARTIST" ]; then
        LABEL="$TITLE — $ARTIST"
    else
        LABEL="$TITLE"
    fi
    sketchybar --set "$NAME" drawing=on label="$LABEL"
else
    sketchybar --set "$NAME" drawing=off
fi
