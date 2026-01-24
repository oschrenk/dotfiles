#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

AEROSSPACE_BIN='/opt/homebrew/bin/aerospace'

BUNDLE_ID="${1:-com.apple.finder}"
ws="$($AEROSSPACE_BIN list-workspaces --focused)"

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
$AEROSSPACE_BIN move-node-to-workspace "$ws"
$AEROSSPACE_BIN workspace "$ws"
