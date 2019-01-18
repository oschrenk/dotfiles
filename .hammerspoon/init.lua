------------------------
-- Settings
------------------------

-- Network
local wifiWatcher = nil
local work_SSID_pool = { 'reedelsevier', 'RELX_Guest' }
local home_SSID_pool = { 'Citadel' }
local lastSSID = hs.wifi.currentNetwork()
local homeLocation = 'Home'
local workLocation = 'Work'

-- Fast User Switching
-- `id -u` to find curent id
local personalUserId = "501"
local workUserId     = "504"

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
-- Helper functions
------------------------

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        print("comparing: val:"..(val or "nil").." value:"..(value or "nil"))
        -- We grab the first index of our sub-table instead
        if value == val then
          return true
        end
    end

    return false
end

------------------------
-- Notifications
------------------------

-- Set Hammerspoon notifications to Alert in the Notification Center pane of
-- System Preferencese, so that they have a "Close" button
function notify(message)
  hs.notify.new({
    title='Hammerspoon',
    informativeText=message,
    -- hide the action button, show only "Close"
    hasActionButton=false
  }):send()
end

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

function brokenScreenResize()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = 460
  f.y = 0
  f.w = max.w - 460
  f.h = max.h - 60
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
    notify("Prev Monitor", 5)
  end
end

-- Send Window Next Monitor
function send_window_to_next_monitor()
  if (#hs.screen.allScreens() > 1) then
    local win = hs.window.focusedWindow()
    local nextScreen = win:screen():next()
    win:moveToScreen(nextScreen)
    notify("Next Monitor", 5)
  end
end

-- Close notifications
function clearNotifications()
  ok, result = hs.osascript.applescriptFromFile(os.getenv ("HOME") .. "/.hammerspoon/closeNotifiations.applescript")
end

function closeNotifications()
  print("Closing notifications")
  hs.timer.doAfter(0.3, clearNotifications)
end

function cleanTrash()
  hs.sound.getByFile("/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/finder/empty trash.aif"):play()
  os.execute("/bin/rm -rf ~/.Trash/*")
end

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
  notify("Switch to " .. name)
  os.execute('/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -switchToUserID ' .. id)
end

function toggleUser()
  if (currentAccountId() == personalUserId ) then
    switchUser(workUserId, "work")
  else
    switchUser(personalUserId, "personal")
  end
end

------------------------
-- Drives
------------------------

function unmountExternalDrives()
  print("unmount called")
  notify("Unmounting Drives")
  -- escape single quotes like \'
  -- escape backslashes in sed with extra backslash
  os.execute("/usr/sbin/diskutil list | grep -i windows | sed \'s/.*\\(disk[0-9].*\\)/\\1/\' | uniq | xargs -I= /usr/sbin/diskutil unmount =")
end

function mountExternalDrives()
  print("mount called")
  notify("Mounting Drives")
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
  notify("Enabling Bluetooth")
  os.execute("/usr/local/bin/blueutil -p 1")
end

function disableBluetooth()
  notify("Disabling Bluetooth")
  os.execute("/usr/local/bin/blueutil -p 0")
end

function bluetoothEnabled()
  local file = assert(io.popen('/usr/local/bin/blueutil -p', 'r'))
  local output = file:read('*all')
  file:close()

  return output:gsub("%s+", "") == "1"
end

function toggleBluetooth()
  if (bluetoothEnabled()) then
    disableBluetooth()
  else
    enableBluetooth()
  end
end

function connectHeadphones()
  if (not bluetoothEnabled()) then
    enableBluetooth()
  end
  ok, result = hs.osascript.applescriptFromFile(os.getenv ("HOME") .. "/.hammerspoon/connectHeadphones.applescript")
end

------------------------
-- WiFi
------------------------

function enableWifi()
  hs.wifi.setPower(true)
  notify("Enabled Wifi")
end

function disableWifi()
  hs.wifi.setPower(false)
  notify("Disabled Wifi")
end

function toggleWifi()
  if (hs.wifi.interfaceDetails()["power"]) then
    disableWifi()
  else
    enableWifi()
  end
end


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
    notify("Switching location to " .. name)
    os.execute("sudo /usr/sbin/networksetup -switchtolocation \"" .. name .. "\"")
  end
end

------------------------
-- Watch network changes
------------------------

function enteredNetwork(old_ssid, new_ssid, ssid_pool)
  -- activated wifi
  if (old_ssid == nil and new_ssid ~= nil) then
    return has_value(ssid_pool,new_ssid)
  end

  -- deactivated wifi
  if (old_ssid ~= nil and new_ssid == nil) then
    return false
  end

  -- changed wifi
  -- checking if we more than changed network within environment
  if (old_ssid ~= nil and new_ssid ~= nil) then
    notify("Changed Wifi")
    return (not has_value(ssid_pool, old_ssid)) and has_value(ssid_pool, new_ssid)
  end

  return false
end

function ssidChangedCallback()
    newSSID = hs.wifi.currentNetwork()

    print("ssidChangedCallback: old:"..(lastSSID or "nil").." new:"..(newSSID or "nil"))
    if (newSSID ~= nil) then
      if (enteredNetwork(lastSSID, newSSID, work_SSID_pool)) then
        enteredWork()
      end

      if (enteredNetwork(lastSSID, newSSID, home_SSID_pool)) then
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
   notify("Pausing Spotify")
   hs.spotify.pause()
end

function spotify_play()
   notify("Playing Spotify")
   hs.spotify.play()
end

function mute()
  hs.audiodevice.defaultOutputDevice():setMuted(true)
  notify("Mute")
end


-- Per-device watcher to detect headphones in/out
function audiodevwatch(dev_uid, event_name, event_scope, event_element)
  print(string.format("dev_uid %s, event_name %s, event_scope %s, event_element %s", dev_uid, event_name, event_scope, event_element))
  if event_name == 'jack' then
    dev = hs.audiodevice.findDeviceByUID(dev_uid)
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
  switchNetworkLocation(homeLocation)
end

function enteredWork()
  switchNetworkLocation(workLocation)
  mute()
end

function switchedToBattery()
  notify("Battery")
end

function switchedToCharger()
  notify("Charging")
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
-- Concentration
------------------------

local afplayTask = nil
local afplayWasPlaying = false

function taskStopped(code, stdout, stderr)
  print("code: "..code)
  print("stdout: "..stdout)
  print("stderr: "..stderr)
  notify("Stopped afplay")
  afplayTask = nil
  afplayWasPlaying = false
end

function start()
  print("Starting afplay")
  task = hs.task.new("/usr/bin/afplay", taskStopped, {"Concentration.mp3"})
  task:setWorkingDirectory("/Users/Shared/Music")
  task:start()
  afplayTask = task
  notify("Started afplay")
end

function play()
  if (afplayTask) then
    if (afplayWasPlaying) then
      resume()
    else
      pause()
    end
  else
   start()
  end
end

function resume()
  print("Resume afplay")
  notify("Resume afplay")
  afplayTask:resume()
  afplayWasPlaying = false
end

function pause()
  print("Pause afplay")
  notify("Pause afplay")
  afplayTask:pause()
  afplayWasPlaying = true
end

function stop()
  hs.print("Stop afplay")
  notify("Stop afplay")
  afplayTask:interrupt()
end

------------------------
-- Keyboard Bindings
------------------------

hs.hotkey.bind(hyper, 'a', function() hs.window.focusedWindow():moveToUnit(hs.layout.left50) end)
hs.hotkey.bind(hyper, 'd', function() hs.window.focusedWindow():moveToUnit(hs.layout.right50) end)
hs.hotkey.bind(hyper, "w", top_half_window)
hs.hotkey.bind(hyper, "x", brokenScreenResize)
hs.hotkey.bind(hyper, 's', toggle_window_maximized)
hs.hotkey.bind(hyper, 'f', function() hs.window.focusedWindow():toggleFullScreen() end)

hs.hotkey.bind(hyper, "q", send_window_to_prev_monitor)
hs.hotkey.bind(hyper, "e", send_window_to_next_monitor)

hs.hotkey.bind(hyper, "h", connectHeadphones)

hs.hotkey.bind(hyper, "c", closeNotifications)

hs.hotkey.bind(hyper, "u", toggleUser)

hs.hotkey.bind(hyper, "b", toggleBluetooth)
hs.hotkey.bind(hyper, "v", toggleWifi)

hs.hotkey.bind(hyper, 'm', mute)

------------------------
-- Reload
------------------------

function reload_config(files)
  hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
notify("Config loaded")
