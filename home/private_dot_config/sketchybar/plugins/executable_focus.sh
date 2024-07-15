#!/bin/sh

# Requirements
#  https://jqlang.github.io/jq/
#  brew install jq
#

FOCUS_FILE="~/Library/DoNotDisturb/DB/Assertions.json"

if [ -z "${FOCUS_MODE}" ]; then
  if [[ -e "$FOCUS_FILE" ]]; then
    status=$(cat "$FOCUS_FILE" | jq -r 'try .data[].storeAssertionRecords[].assertionDetails.assertionDetailsModeIdentifier')
  fi
    status="unknown"
else
  status=$FOCUS_MODE
fi

case "$status" in
  com.apple.donotdisturb.mode.default)
    sketchybar -m --set focus icon.color=0xFFFFFFFF icon=􀆺
    ;;
  com.apple.sleep.sleep-mode)
    sketchybar -m --set focus icon.color=0xFFFFFFFF icon=􀙪
    ;;
  com.apple.focus.personal-time)
    sketchybar -m --set focus icon.color=0xFFFFFFFF icon=􀉪
    ;;
  com.apple.focus.work)
    sketchybar -m --set focus icon.color=0xFFFFFFFF icon=􁕝
    ;;
  *)
    sketchybar -m --set focus icon.color=0xFF999999 icon=􀟈
    ;;
esac
