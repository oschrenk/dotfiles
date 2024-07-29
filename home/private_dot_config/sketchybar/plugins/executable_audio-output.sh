#!/bin/sh

# Requirements
#   brew install switchaudio-osx jq
OUTPUT=$(SwitchAudioSource -c -t output -f json | jq -r .name)

# NO SPEAKER as fallback
ICON=􀊢

if [[ "${OUTPUT}" == *"AirPods Pro"* ]]; then
  ICON="􀪷"
fi

if [[ "${OUTPUT}" == *"MacBook Pro Speakers"* ]]; then
  ICON="􀟛"
fi

if [[ "${OUTPUT}" == *"WH-1000XM4"* ]]; then
  ICON="􀑈"
fi

sketchybar --set "$NAME" \
             icon="$ICON" \
             label.drawing="off"
