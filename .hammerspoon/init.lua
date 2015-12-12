------------------------
-- Settings
------------------------

-- Network
local wifiInterface = "en0"
local wifiWatcher = nil
local workSSIDToken = "elmar"
local homeSSIDToken = "SitecomC4934C"
local lastSSID = hs.wifi.currentNetwork()
local homeLocation = "Home"
local workLocation = "Work"

-- Fast User Switching
-- `id -u` to find curent id
local personalUserId = "502"
local workUserId     = "503"

-- hotkey hyper
local hyper = {"ctrl", "alt", "shift", "cmd"}

------------------------
-- Internal state
------------------------

-- Defines for window maximize toggler
local frameCache = {}

-- disable animation
hs.window.animationDuration = 0

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
  hs.timer.doAfter(0.3, clearNotifications)
end)

-- Clean trash
hs.hotkey.bind(hyper, "t", function()
    os.execute("/bin/rm -rf ~/.Trash/*")
end)

------------------------
-- Fast user switching
------------------------

function currentAccountId()
  local file = assert(io.popen('/usr/bin/id -u', 'r'))
  local output = file:read('*all')
  file:close()

  return output:gsub("%s+", ""):gsub("%s+$", "")
end

function switchUser(id, name)
  hs.alert.show("Switch to " .. name)
  os.execute('/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -switchToUserID ' .. id)
end

hs.hotkey.bind(hyper, "u", function()
  if (currentAccountId() == personalUserId ) then
    switchUser(workUserId, "work")
  else
    switchUser(personalUserId, "personal")
  end
end)

------------------------
-- Bluetooth
------------------------
-- relies on https://github.com/toy/blueutil
-- installable via `brew install blueutil`

function enableBluetooth()
  hs.alert.show("Enabling Bluetooth")
  os.execute("/usr/local/bin/blueutil power 1")
end

function disableBluetooth()
  hs.alert.show("Disabling Bluetooth")
  os.execute("/usr/local/bin/blueutil power 0")
end

function bluetoothEnabled()
  local file = assert(io.popen('/usr/local/bin/blueutil power', 'r'))
  local output = file:read('*all')
  file:close()

  return output:gsub("%s+", "") == "1"
end

hs.hotkey.bind(hyper, "b", function()
  if (bluetoothEnabled()) then
    disableBluetooth()
  else
    enableBluetooth()
  end
end)

------------------------
-- WiFi
------------------------

function wifiEnabled()
  local file = assert(io.popen('/usr/sbin/networksetup -getairportpower ' .. wifiInterface, 'r'))
  local output = file:read('*all')
  file:close()

  return string.match(output, ":%s(%a+)") == "On"
end

function enableWifi()
  os.execute("/usr/sbin/networksetup -setairportpower " .. wifiInterface .. " on")
  hs.alert.show("Enabled Wifi")
end

function disableWifi()
  hs.alert.show("Disabled Wifi")
  os.execute("/usr/sbin/networksetup -setairportpower " .. wifiInterface .. " off")
end

-- Toggle wifi
hs.hotkey.bind(hyper, "v", function()
  if (wifiEnabled()) then
    disableWifi()
  else
    enableWifi()
  end
end)

------------------------
-- Network location
------------------------

function currentNetworkLocation()
  local file = assert(io.popen('/usr/sbin/networksetup -getcurrentlocation', 'r'))
  local output = file:read('*all')
  file:close()

  return output:gsub("%s+", "")
end

-- this function relies on a sudoers.d entry like
-- %Local  ALL=NOPASSWD: /usr/sbin/networksetup -switchtolocation "name"
function switchNetworkLocation(name)
  local location = currentNetworkLocation()
  if (location ~= name) then
    hs.alert.show("Switching location to " .. name)
    os.execute("sudo /usr/sbin/networksetup -switchtolocation \"" .. name .. "\"")
  end
end

------------------------
-- Watch network changes
------------------------

function enteredNetwork(old_ssid, new_ssid, token)
  if (old_ssid == nil and new_ssid ~= nil) then
    return string.find (string.lower(new_ssid), string.lower(token))
  end

  if (old_ssid ~= nil and new_ssid == nil) then
    return false
  end

  -- significantly change wifi
  -- checking if we more than changed network within environment
  if (old_ssid ~= nil and new_ssid ~= nil) then
    hs.alert.show("Changed Wifi")
    return (not (string.find(string.lower(old_ssid), string.lower(token)) and
                string.find(string.lower(new_ssid), string.lower(token))))
  end

  return false
end

function ssidChangedCallback()
    newSSID = hs.wifi.currentNetwork()

    print("ssidChangedCallback: old:"..(lastSSID or "nil").." new:"..(newSSID or "nil"))
    if (newSSID ~= nil) then
      if (enteredNetwork(lastSSID, newSSID, workSSIDToken)) then
        enteredWork()
      end

      if (enteredNetwork(lastSSID, newSSID, homeSSIDToken)) then
        enteredHome()
      end
    end

    lastSSID = newSSID
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()

------------------------
-- Environment settings
------------------------

function enteredHome()
  if (bluetoothEnabled()) then
    disableBluetooth()
  end

  switchNetworkLocation(homeLocation)
end

function enteredWork()
  if (not bluetoothEnabled()) then
    enableBluetooth()
  end
  switchNetworkLocation(workLocation)
end

------------------------
-- Reload
------------------------

function reload_config(files)
  hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config loaded")
