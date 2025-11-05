#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

BUNDLE_ID="${1:-com.apple.finder}"
ws="$(aerospace list-workspaces --focused)"

# Ensure application has a window and is frontmost
if [ "$BUNDLE_ID" = "com.apple.finder" ]; then
  osascript <<OSA
tell application id "$BUNDLE_ID"
  if (count windows) = 0 then
    make new Finder window to (path to downloads folder)
  end if
  activate
end tell
OSA
else
  osascript <<OSA
tell application id "$BUNDLE_ID"
  activate
end tell
OSA
fi

# Give macOS/AeroSpace a beat if a new window was created
sleep 0.05

# Move the focused Finder window back to the saved workspace and return there
aerospace move-node-to-workspace "$ws"
aerospace workspace "$ws"
