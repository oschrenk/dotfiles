------------------------
-- Notifications
------------------------

-- Close notifications
function clearNotifications()
  ok, result = hs.osascript.applescriptFromFile(SCRIPTS_DIR .. "/closeNotifiations.applescript")
end

function closeNotifications()
  print("Closing notifications")
  hs.timer.doAfter(0.3, clearNotifications)
end
