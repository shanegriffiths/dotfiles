#!/bin/bash

# Source the icon mapping ONCE at script start instead of on every event
source "$CONFIG_DIR/items/icon_map.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  # Get the icon from the font using the icon map
  APP_ICON=$(__icon_map "$INFO")
  
  # Set the app icon and label using the sketchybar-app-font
  sketchybar --set $NAME \
    icon="$APP_ICON" \
    label="$INFO"
fi
