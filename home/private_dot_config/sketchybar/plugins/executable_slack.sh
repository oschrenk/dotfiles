#!/bin/sh

❯ osascript -e 'id of app "Slack"'

BUNDLE_ID="com.tinyspeck.slackmacgap"

BADGE=$(lsappinfo -all info -only StatusLabel "$BUNDLE_ID" | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')


# Could also be `•`
if [[ -z "$BADGE"  || "$BADGE" == "•" ]]; then
  sketchybar -m --set "$NAME" icon= \
                          label="0" \
                          drawing=on
else
  sketchybar -m --set "$NAME" icon= \
                          label="$BADGE" \
                          drawing=on
fi
