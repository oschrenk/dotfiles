#!/bin/sh

BUNDLE_ID="com.tinyspeck.slackmacgap"

BADGE=$(lsappinfo -all info -only StatusLabel "$BUNDLE_ID" | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')

ICON_COLOR=""0xffcad3f5""

# Could also be `•` instead of a count
if [[ -z "$BADGE"  || "$BADGE" == "•" ]]; then
  ICON_COLOR="0xff646466"
fi

sketchybar -m --set "$NAME" \
                    icon= \
                    icon.color="$ICON_COLOR" \
                    label.drawing="off" 
