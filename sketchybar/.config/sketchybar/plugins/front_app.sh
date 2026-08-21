#!/bin/bash

# Source the icon mapping ONCE at script start instead of on every event
source "$CONFIG_DIR/items/icon_map.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  # Get the icon from the font using the icon map
  APP_ICON=$(__icon_map "$INFO")

  # Font is re-applied on every event via a two-step flip: sketchybar only
  # re-resolves a font when the string CHANGES, so if the bar started before
  # macOS registered user fonts at login, the item would otherwise keep the
  # fallback font forever and render ligatures like ":claude:" as raw text.
  sketchybar --set $NAME icon.font="SF Pro:Medium:11.0"
  sketchybar --set $NAME \
    icon.font="sketchybar-app-font:Regular:11.0" \
    icon="$APP_ICON" \
    label="$INFO"
fi
