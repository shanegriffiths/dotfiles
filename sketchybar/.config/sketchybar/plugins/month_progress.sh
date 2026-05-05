#!/bin/bash

CURRENT_DAY=$(date +%-d)
TOTAL_DAYS=$(date -v1d -v+1m -v-1d +%-d)

MONTH_PERCENT=$(( CURRENT_DAY * 100 / TOTAL_DAYS ))

MONTH=$(date +%b)

sketchybar --set $NAME label="$MONTH $MONTH_PERCENT%"
