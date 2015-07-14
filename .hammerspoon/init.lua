------------------------
-- Settings
------------------------

-- Wifi Watcher
local wifiWatcher = nil
local workSSIDToken = "elmar"
local homeSSIDToken = "SitecomC4934C"
local lastSSID = hs.wifi.currentNetwork()

-- Defines for window maximize toggler
local frameCache = {}

-- disable animation
hs.window.animationDuration = 0

-- hotkey hyper
local hyper = {"ctrl", "alt", "shift", "cmd"}

------------------------
-- Launcher
------------------------

-- Launch applications
hs.hotkey.bind(hyper, '1', function () hs.application.launchOrFocus("iTerm2") end)
hs.hotkey.bind(hyper, '2', function () hs.application.launchOrFocus("Google Chrome") end)

------------------------
-- Window Managment
------------------------

-- Half Windows
hs.hotkey.bind(hyper, 'a', function() hs.window.focusedWindow():moveToUnit(hs.layout.left50) end)
hs.hotkey.bind(hyper, 'd', function() hs.window.focusedWindow():moveToUnit(hs.layout.right50) end)
hs.hotkey.bind(hyper, "w", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = 0
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)
hs.hotkey.bind(hyper, "x", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y + (max.h / 2)
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

-- Toggle a window between its normal size, and being maximized
function toggle_window_maximized()
    local win = hs.window.focusedWindow()
    if frameCache[win:id()] then
        win:setFrame(frameCache[win:id()])
        frameCache[win:id()] = nil
    else
        frameCache[win:id()] = win:frame()
        win:maximize()
    end
end

-- Maximize
hs.hotkey.bind(hyper, 's', toggle_window_maximized)

-- Full screen
hs.hotkey.bind(hyper, 'f', function() hs.window.focusedWindow():toggleFullScreen() end)

-- Send Window Prev Monitor
hs.hotkey.bind(hyper, "p", function()
  if (#hs.screen.allScreens() > 1) then
    local win = hs.window.focusedWindow()
    local previousScreen = win:screen():previous()
    win:moveToScreen(previousScreen)
    hs.alert.show("Prev Monitor", 5)
  end
end)

-- Send Window Next Monitor
hs.hotkey.bind(hyper, "n", function()
  if (#hs.screen.allScreens() > 1) then
    local win = hs.window.focusedWindow()
    local nextScreen = win:screen():next()
    win:moveToScreen(nextScreen)
    hs.alert.show("Next Monitor", 5)
  end
end)

-- Show window hints
hs.hotkey.bind(hyper, "i", function() hs.hints.windowHints() end)

-- Focus Windows
hs.hotkey.bind(hyper, 'k', function() hs.window.focusedWindow():focusWindowNorth() end)
hs.hotkey.bind(hyper, 'j', function() hs.window.focusedWindow():focusWindowSouth() end)
hs.hotkey.bind(hyper, 'l', function() hs.window.focusedWindow():focusWindowEast() end)
hs.hotkey.bind(hyper, 'h', function() hs.window.focusedWindow():focusWindowWest() end)


-- Close notifications
script = [[
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
end closeNotif ]]
function clearNotifications()
  ok, result = hs.applescript(script)
end
hs.hotkey.bind(hyper, "c", function()
  hs.alert.show("Closing notifications")
  hs.timer.doAfter(1, clearNotifications)
end)


-- Clean trash
hs.hotkey.bind(hyper, "t", function()
    os.execute("/bin/rm -rf ~/.Trash/*")
end)

------------------------
-- Bluetooth
------------------------

-- Toggle bluetooth
hs.hotkey.bind(hyper, "b", function()
  local file = assert(io.popen('/usr/local/bin/blueutil power', 'r'))
  local output = file:read('*all')
  file:close()
  state = output:gsub("%s+", "") == "1"

  if (state) then
    hs.alert.show("Disabling Bluetooth")
    os.execute("/usr/local/bin/blueutil power 0")
  else
    hs.alert.show("Enabling Bluetooth")
    os.execute("/usr/local/bin/blueutil power 1")
  end
end)

------------------------
-- WiFi
------------------------

-- Toggle wifi
hs.hotkey.bind(hyper, "v", function()
  local file = assert(io.popen('/usr/sbin/networksetup -getairportpower en0 | cut -d ":" -f2', 'r'))
  local output = file:read('*all')
  file:close()
  active = output:gsub("%s+", "") == "On"

  if (active) then
    hs.alert.show("Disabling Wifi")
    os.execute("/usr/sbin/networksetup -setairportpower en0 off")
  else
    hs.alert.show("Enabling Wifi")
    os.execute("/usr/sbin/networksetup -setairportpower en0 on")
  end
end)

function enteredNetwork(old_ssid, new_ssid, token)
  -- activated wifi
  if (old_ssid == nil and new_ssid ~= nil) then
    return string.find (string.lower(new_ssid), string.lower(token))
  end

  -- disabled wifi
  if (old_ssid ~= nil and new_ssid == nil) then
    return false
  end

  -- significantly change wifi
  -- checking if we more than changed network suffix within the company
  if (old_ssid ~= nil and new_ssid ~= nil) then
    return (not string.find(string.lower(old_ssid), string.lower(token)) and
                string.find(string.lower(new_ssid), string.lower(token)))
  end

  return false
end

-- not used for now
function ssidChangedCallback()
    newSSID = hs.wifi.currentNetwork()

    if (newSSID ~= nil) then
      if (enteredNetwork(lastSSID, newSSID, workSSIDToken)) then
        hs.alert.show("Arrived at work ")
        os.execute("/usr/local/bin/blueutil power 1")
      end

      if (enteredNetwork(old_ssid, new_ssid, homeSSIDToken)) then
        hs.alert.show("Arrived at home ")
        os.execute("/usr/local/bin/blueutil power 0")
      end
    end

    lastSSID = newSSID
end

------------------------
-- Reload
------------------------

function reload_config(files)
  hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config loaded")
