#!/bin/sh

BUNDLE_ID="com.tinyspeck.slackmacgap"
ICON_COLOR_ACTIVE="0xffcad3f5" 
ICON_COLOR_INACTIVE="0xff484848"

BADGE=$(lsappinfo -all info -only StatusLabel "$BUNDLE_ID" | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')

ICON_COLOR="$ICON_COLOR_ACTIVE"

# Could also be `•` instead of a count
if [[ -z "$BADGE"  || "$BADGE" == "•" ]]; then
  ICON_COLOR="$ICON_COLOR_INACTIVE"
fi

sketchybar -m --set "$NAME" \
                    icon="" \
                    icon.color="$ICON_COLOR" \
                    icon.align=center \
                    icon.width=25 \
                    icon.padding_left=-2 \
                    icon.padding_right=-8 \
                    label.drawing="off" 
