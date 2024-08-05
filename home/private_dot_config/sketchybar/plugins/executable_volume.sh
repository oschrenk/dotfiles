#!/bin/sh

if [[ "$SENDER" = "mouse.clicked" ]]; then
  open "x-apple.systempreferences:com.apple.preference.sound"
fi

# sf-symbols:speaker.wave.3
ICON_SPEAKER_WAVE_3="􀊨"
# sf-symbols:speaker.wave.2
ICON_SPEAKER_WAVE_2="􀊦"
# sf-symbols:speaker.wave.1
ICON_SPEAKER_WAVE_1="􀊤"
# sf-symbols:speaker
ICON_SPEAKER="􀊠"

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.
#

if [ "$SENDER" = "volume_change" ]; then
  VOLUME=$INFO

  case $VOLUME in
    [6-9][0-9]|100) ICON="$ICON_SPEAKER_WAVE_3"
    ;;
    [3-5][0-9]) ICON="$ICON_SPEAKER_WAVE_2"
    ;;
    [1-9]|[1-2][0-9]) ICON="$ICON_SPEAKER_WAVE_1"
    ;;
    *) ICON="$ICON_SPEAKER"
  esac

  sketchybar --set "$NAME" \
               icon="$ICON" \
               label.drawing="off" 
fi
