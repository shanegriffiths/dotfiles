#!/bin/bash

DAY_OF_YEAR=$(date +%-j)
YEAR=$(date +%Y)

if [ $((YEAR % 4)) -eq 0 ] && { [ $((YEAR % 100)) -ne 0 ] || [ $((YEAR % 400)) -eq 0 ]; }; then
    TOTAL_DAYS=366
else
    TOTAL_DAYS=365
fi

YEAR_PERCENT=$(( DAY_OF_YEAR * 100 / TOTAL_DAYS ))

sketchybar --set $NAME label="Year $YEAR_PERCENT%"
