#!/usr/bin/env fish

# Original script at
# https://github.com/cristianoliveira/dotfiles/blob/84ce7de3daac09efe6871e80e54210f21a266c13/bin/osx-win-move

set POSITION $argv[1]

# Default to center if no position provided
if test -z "$POSITION"
    set POSITION center
end

# Validate position if provided
set allowed_positions topleft topright center bottomleft bottomright bottomcenter
if not contains $POSITION $allowed_positions
    echo "Usage: $argv[0] [topleft|topright|center|bottomleft|bottomright|bottomcenter]"
    echo "Invalid position: $POSITION"
    exit 1
end

osascript -e "
on run
    set positionName to \"$POSITION\"
    set allowedPositions to {\"topleft\", \"topright\", \"center\", \"bottomleft\", \"bottomright\", \"bottomcenter\"}

    if allowedPositions does not contain positionName then
        display dialog \"Invalid position: \" & positionName
        return
    end if

    -- Get frontmost app
    tell application \"System Events\"
        set frontApp to name of first application process whose frontmost is true
        tell application process frontApp
            if (count of windows) = 0 then return
            set win to front window
            set {winW, winH} to size of win
        end tell
    end tell

    -- Get screen dimensions
    tell application \"Finder\"
        set {screenX, screenY, screenW, screenH} to bounds of window of desktop
    end tell

    -- Account for menu bar and dock
    set sketchyBar to 32
    set menuBarHeight to sketchyBar
    set dockHeight to 0

    -- Calculate target position
    if positionName is \"topleft\" then
        set newPos to {0, menuBarHeight}
    else if positionName is \"topright\" then
        set newPos to {screenW - winW, menuBarHeight}
    else if positionName is \"center\" then
        set newPos to {(screenW - winW) / 2, (screenH - winH - dockHeight) / 2}
    else if positionName is \"bottomleft\" then
        set newPos to {0, screenH - winH - dockHeight}
    else if positionName is \"bottomright\" then
        set newPos to {screenW - winW, screenH - winH - dockHeight}
    else if positionName is \"bottomcenter\" then
        set newPos to {(screenW - winW) / 2, screenH - winH - dockHeight}
    else
        display dialog \"Invalid position: \" & positionName
        return
    end if

    -- Move the frontmost window
    tell application \"System Events\"
        tell application process frontApp
            set position of front window to newPos
        end tell
    end tell
end run
"
