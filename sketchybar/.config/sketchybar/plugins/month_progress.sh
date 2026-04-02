#!/bin/bash

# Get current day and total days in month
CURRENT_DAY=$(date +%d | sed 's/^0*//')
TOTAL_DAYS=$(date +%d -d "$(date +%Y-%m-01) +1 month -1 day" 2>/dev/null || date -v1d -v+1m -v-1d +%d)

# Calculate percentage
MONTH_PERCENT=$(echo "scale=0; ($CURRENT_DAY * 100) / $TOTAL_DAYS" | bc)

# Get month name
MONTH=$(date +%b)

sketchybar --set $NAME label="$MONTH $MONTH_PERCENT%"
