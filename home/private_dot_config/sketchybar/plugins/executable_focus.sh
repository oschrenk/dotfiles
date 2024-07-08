#!/bin/sh

if [ -z "${FOCUS_MODE}" ]; then
  status=$(cat ~/Library/DoNotDisturb/DB/Assertions.json | jq -r 'try .data[].storeAssertionRecords[].assertionDetails.assertionDetailsModeIdentifier')
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
