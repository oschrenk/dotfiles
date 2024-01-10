#!/bin/sh

status=$(cat ~/Library/DoNotDisturb/DB/Assertions.json | jq -r 'try .data[].storeAssertionRecords[].assertionDetails.assertionDetailsModeIdentifier')

case "$status" in
  com.apple.donotdisturb.mode.default)
    sketchybar -m --set focus icon.color=0xFFFFFFFF icon=d
    ;;
  com.apple.sleep.sleep-mode)
    sketchybar -m --set focus icon.color=0xFFFFFFFF icon=s
    ;;
  com.apple.focus.personal-time)
    sketchybar -m --set focus icon.color=0xFFFFFFFF icon=p
    ;;
  com.apple.focus.work)
    sketchybar -m --set focus icon.color=0xFFFFFFFF icon=w
    ;;
  *)
    sketchybar -m --set focus icon.color=0xFF999999 icon=y
    ;;
esac
