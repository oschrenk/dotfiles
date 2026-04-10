function close-incognito --description "Close all incognito windows in Arc"
    osascript -e 'tell application "Arc" to close (every window whose mode is "incognito")'
end
