#!/usr/bin/env bash
# Run the sessionizer picker in a floating Ghostty window.
# The shell in the window execs `sessionizer search`, so the window closes
# itself once the pick opens or focuses the session's window, or on Esc.
set -o errexit
set -o nounset
set -o pipefail

AEROSPACE_BIN='/etc/profiles/per-user/oliver/bin/aerospace'
TITLE='sessionizer'

# Typed into the login shell rather than set as `command`: Ghostty turns on
# wait-after-command for any scripted `command`, which keeps the window open.
osascript - "$TITLE" >/dev/null <<'OSA'
on run argv
  tell application "Ghostty"
    activate
    set cfg to new surface configuration
    set initial input of cfg to "exec /etc/profiles/per-user/oliver/bin/sessionizer search" & linefeed
    new window with configuration cfg with title (item 1 of argv)
  end tell
end run
OSA

# AeroSpace reads the title before Ghostty sets it, so an on-window-detected
# title rule never matches. Float the window by id once the title shows up.
id=''
for _ in 1 2 3 4 5 6 7 8 9 10; do
  id="$($AEROSPACE_BIN list-windows --all --format '%{window-id}|%{app-bundle-id}|%{window-title}' |
    awk -F'|' -v t="$TITLE" '$2 == "com.mitchellh.ghostty" && $3 == t { print $1; exit }')"
  [ -n "$id" ] && break
  sleep 0.05
done
[ -n "$id" ] || exit 1
$AEROSPACE_BIN layout --window-id "$id" floating

# A new Ghostty window takes the size of the last one, which is a full tile.
# Shrink it to a third of the screen it is on, centered.
osascript -l JavaScript - "$TITLE" >/dev/null <<'JXA'
function run(argv) {
  ObjC.import('AppKit');
  const f = $.NSScreen.mainScreen.visibleFrame;
  const primary = $.NSScreen.screens.objectAtIndex(0).frame;
  const w = Math.round(f.size.width / 3);
  const h = Math.round(f.size.height / 3);
  // AppKit counts y up from the bottom of the primary screen, System Events down from its top
  const top = primary.size.height - (f.origin.y + f.size.height);
  const win = Application('System Events').processes.byName('ghostty').windows.byName(argv[0]);
  win.size = [w, h];
  win.position = [Math.round(f.origin.x + (f.size.width - w) / 2), Math.round(top + (f.size.height - h) / 2)];
}
JXA
