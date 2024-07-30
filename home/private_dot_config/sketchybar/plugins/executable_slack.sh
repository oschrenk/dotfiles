#!/bin/sh

❯ osascript -e 'id of app "Slack"'

BUNDLE_ID="com.tinyspeck.slackmacgap"

BADGE=$(lsappinfo -all info -only StatusLabel "$BUNDLE_ID" | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')


# draw by default
DRAWING="on"

# Could also be `•` instead of a count
if [[ -z "$BADGE"  || "$BADGE" == "•" ]]; then
  DRAWING="off"
fi

sketchybar -m --set "$NAME" \
                    icon= \
                    label.drawing="off" \
                    drawing="$DRAWING"
