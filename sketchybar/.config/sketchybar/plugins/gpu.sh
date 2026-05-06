#!/bin/bash

# Apple Silicon exposes GPU utilization via the AGXAccelerator IORegistry node.
# "Device Utilization %" is the overall GPU busy percentage; sudoless.
GPU_PCT=$(ioreg -r -d 1 -c AGXAccelerator | sed -n 's/.*"Device Utilization %"=\([0-9]*\).*/\1/p' | head -1)
GPU_PCT=${GPU_PCT:-0}

NORMALISED=$(awk -v g="$GPU_PCT" 'BEGIN{printf "%.4f", g/100}')

sketchybar --push "$NAME" "$NORMALISED" \
           --set "$NAME" label="GPU ${GPU_PCT}%"
