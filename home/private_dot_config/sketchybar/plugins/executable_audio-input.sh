#!/bin/sh

# Requirements
#   brew install switchaudio-osx jq
INPUT=$(SwitchAudioSource -c -t input -f json | jq -r .name)

# NO MICROPHONE as fallback
ICON="󱦉"

if [[ "${INPUT}" == *"AirPods Pro"* ]]; then
  ICON="󰍬"
fi

if [[ "${INPUT}" == *"MacBook Pro"* ]]; then
  ICON="󰍬"
fi

if [[ "${INPUT}" == *"OlschPhone Pro"* ]]; then
  ICON="󰍬"
fi

if [[ "${INPUT}" == *"WH-1000XM4"* ]]; then
  ICON="󰍬"
fi

sketchybar --set "$NAME" \
             icon="$ICON" \
             label.drawing="off"
