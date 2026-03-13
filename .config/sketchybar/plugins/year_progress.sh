#!/bin/bash

# Get day of year and total days in year
DAY_OF_YEAR=$(date +%j | sed 's/^0*//')
YEAR=$(date +%Y)

# Check if leap year
if [ $((YEAR % 4)) -eq 0 ] && { [ $((YEAR % 100)) -ne 0 ] || [ $((YEAR % 400)) -eq 0 ]; }; then
    TOTAL_DAYS=366
else
    TOTAL_DAYS=365
fi

# Calculate percentage
YEAR_PERCENT=$(echo "scale=0; ($DAY_OF_YEAR * 100) / $TOTAL_DAYS" | bc)

sketchybar --set $NAME label="Year $YEAR_PERCENT%"
