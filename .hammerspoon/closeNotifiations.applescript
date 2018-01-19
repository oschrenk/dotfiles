my closeNotif()
on closeNotif()

    tell application "System Events"
        tell process "Notification Center"
            set theWindows to every window
            repeat with i from 1 to number of items in theWindows
                set this_item to item i of theWindows
                try
                    click button 1 of this_item
                on error
                    my closeNotif()
                end try
            end repeat
        end tell
    end tell
end closeNotif
