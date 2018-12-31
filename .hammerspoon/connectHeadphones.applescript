my connectHeadphones()
on connectHeadphones()

  activate application "SystemUIServer"
  tell application "System Events"
    tell process "SystemUIServer"
    set btMenu to (menu bar item 1 of menu bar 1 where description is "bluetooth")
    tell btMenu
      click
      tell (menu item "MDR-1000X" of menu 1)
        click
        if exists menu item "Connect" of menu 1 then
	        click menu item "Connect" of menu 1
	        return "Connecting..."
        else
	        tell btMenu -- Close main BT drop down if Connect wasn't present
            click
          end tell
	        return "Connect menu was not found, are you already connected?"
        end if
      end tell
    end tell
    end tell
  end tell
end connectHeadphones
