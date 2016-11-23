------------------------
-- Settings
------------------------

-- Network
local wifiWatcher = nil
local workSSIDToken = "Vandebron"
local homeSSIDToken = "SitecomC4934C"
local lastSSID = hs.wifi.currentNetwork()
local homeLocation = "Home"
local workLocation = "Work"

-- Fast User Switching
-- `id -u` to find curent id
local personalUserId = "502"
local workUserId     = "505"

-- hotkey hyper
local hyper = {"ctrl", "alt", "shift", "cmd"}

-- disable animation
hs.window.animationDuration = 0

------------------------
-- Internal state
------------------------

local windowSizeCache = {}
local spotifyWasPlaying = false
local powerSource = hs.battery.powerSource()

------------------------
-- Window Managment
------------------------

function top_half_window()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = 0
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end

function bottom_half_window()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y + (max.h / 2)
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end

-- Toggle a window between its normal size, and being maximized
function toggle_window_maximized()
    local win = hs.window.focusedWindow()
    if windowSizeCache[win:id()] then
        win:setFrame(windowSizeCache[win:id()])
        windowSizeCache[win:id()] = nil
    else
        windowSizeCache[win:id()] = win:frame()
        win:maximize()
    end
end

-- Send Window Prev Monitor
function send_window_to_prev_monitor()
  if (#hs.screen.allScreens() > 1) then
    local win = hs.window.focusedWindow()
    local previousScreen = win:screen():previous()
    win:moveToScreen(previousScreen)
    hs.alert.show("Prev Monitor", 5)
  end
end

-- Send Window Next Monitor
function send_window_to_next_monitor()
  if (#hs.screen.allScreens() > 1) then
    local win = hs.window.focusedWindow()
    local nextScreen = win:screen():next()
    win:moveToScreen(nextScreen)
    hs.alert.show("Next Monitor", 5)
  end
end

hs.hotkey.bind(hyper, 'a', function() hs.window.focusedWindow():moveToUnit(hs.layout.left50) end)
hs.hotkey.bind(hyper, 'd', function() hs.window.focusedWindow():moveToUnit(hs.layout.right50) end)
hs.hotkey.bind(hyper, "w", top_half_window)
hs.hotkey.bind(hyper, "x", bottom_half_window)
hs.hotkey.bind(hyper, 's', toggle_window_maximized)
hs.hotkey.bind(hyper, 'f', function() hs.window.focusedWindow():toggleFullScreen() end)

hs.hotkey.bind(hyper, "p", send_window_to_prev_monitor)
hs.hotkey.bind(hyper, "n", send_window_to_next_monitor)

hs.hotkey.bind(hyper, "i", function() hs.hints.windowHints() end)

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
function closeNotifications()
  hs.alert.show("Closing notifications")
  hs.timer.doAfter(0.3, clearNotifications)
end
hs.hotkey.bind(hyper, "c", closeNotifications)

function cleanTrash()
  hs.sound.getByFile("/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/finder/empty trash.aif"):play()
  os.execute("/bin/rm -rf ~/.Trash/*")
end

hs.hotkey.bind(hyper, "t", cleanTrash)

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

function toggleUser()
  if (currentAccountId() == personalUserId ) then
    switchUser(workUserId, "work")
  else
    switchUser(personalUserId, "personal")
  end
end
hs.hotkey.bind(hyper, "u", toggleUser)

------------------------
-- Drives
------------------------

function unmountExternalDrives()
  print("unmount called")
  hs.alert.show("Unmounting Drives")
  -- escape single quotes like \'
  -- escape backslashes in sed with extra backslash
  os.execute("/usr/sbin/diskutil list | grep -i windows | sed \'s/.*\\(disk[0-9].*\\)/\\1/\' | uniq | xargs -I= /usr/sbin/diskutil unmount =")
end

function mountExternalDrives()
  print("mount called")
  hs.alert.show("Mounting Drives")
  -- escape single quotes like \'
  -- escape backslashes in sed with extra backslash
  os.execute("/usr/sbin/diskutil list | grep -i windows | sed \'s/.*\\(disk[0-9].*\\)/\\1/\' | uniq | xargs -I= /usr/sbin/diskutil mount =")
end

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

function enableWifi()
  hs.wifi.setPower(true)
  hs.alert.show("Enabled Wifi")
end

function disableWifi()
  hs.wifi.setPower(false)
  hs.alert.show("Disabled Wifi")
end

-- Toggle wifi
hs.hotkey.bind(hyper, "v", function()
  if (hs.wifi.interfaceDetails()["power"]) then
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
-- Audio settings
------------------------

function spotify_pause()
   hs.alert.show("Pausing Spotify")
   hs.spotify.pause()
end

function spotify_play()
   hs.alert.show("Playing Spotify")
   hs.spotify.play()
end

function mute()
  hs.audiodevice.defaultOutputDevice():setMuted(true)
  hs.alert.show("Mute")
end

hs.hotkey.bind(hyper, 'm', mute)

-- Per-device watcher to detect headphones in/out
function audiodevwatch(dev_uid, event_name, event_scope, event_element)
  print(string.format("dev_uid %s, event_name %s, event_scope %s, event_element %s", dev_uid, event_name, event_scope, event_element))
  dev = hs.audiodevice.findDeviceByUID(dev_uid)
  if event_name == 'jack' then
    if dev:jackConnected() then
      if spotifyWasPlaying then
        spotify_play()
      end
    else
      spotifyWasPlaying = hs.spotify.isPlaying()
      if spotifyWasPlaying then
        spotify_pause()
      end
    end
  end
end

hs.audiodevice.current()['device']:watcherCallback(audiodevwatch):watcherStart()

------------------------
-- Power settings
------------------------

function powerChanged()
  local current = hs.battery.powerSource()

  if (current ~= powerSource) then
    powerSource = current
    if (powerSource == "AC Power") then
      switchedToCharger()
    else
      switchedToBattery()
    end
  end
end

hs.battery.watcher.new(powerChanged):start()

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
  switchNetworkLocation(workLocation)
  mute()
end

function switchedToBattery()
  hs.alert.show("Battery")
  if (bluetoothEnabled()) then
     disableBluetooth()
   end
end

function switchedToCharger()
  hs.alert.show("Charging")
end

hs.caffeinate.watcher.new(function(event)
  if event == hs.caffeinate.watcher.systemWillSleep or event == hs.caffeinate.watcher.systemWillPowerOff  then
    print("sleeping")
    mute()
  end
  if event == hs.caffeinate.watcher.systemDidWake then
    print("waking up")
    mute()
  end
end):start()

------------------------
-- Reload
------------------------

function reload_config(files)
  hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config loaded")
