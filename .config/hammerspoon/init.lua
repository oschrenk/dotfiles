------------------------
-- Settings
------------------------
-- base dirs
local HAMMERSPOON_DIR = os.getenv("HOME") .. "/.config/hammerspoon"
local SCRIPTS_DIR = HAMMERSPOON_DIR .. "/scripts"

-- Fast User Switching
-- `id -u` to find curent id
local personalUserId = "501"
local workUserId     = "504"

-- hotkey hyper
local hyper = {"ctrl", "alt", "shift", "cmd"}

-- disable animation
hs.window.animationDuration = 0

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

-- Close notifications
function clearNotifications()
  ok, result = hs.osascript.applescriptFromFile(SCRIPTS_DIR .. "/closeNotifiations.applescript")
end

function closeNotifications()
  print("Closing notifications")
  hs.timer.doAfter(0.3, clearNotifications)
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
-- Audio settings
------------------------

function mute()
  hs.audiodevice.defaultOutputDevice():setMuted(true)
  notify("Mute")
end

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

function connectHeadphones()
  if (not bluetoothEnabled()) then
    enableBluetooth()
  end
  ok, result = hs.osascript.applescriptFromFile(SCRIPTS_DIR .. "/connectHeadphones.applescript")
end


require('bluetooth')
require('network')
require('wifi')
require('window')

------------------------
-- Keyboard Bindings
------------------------

hs.hotkey.bind(hyper, 'a', left50)
hs.hotkey.bind(hyper, 'd', right50)
hs.hotkey.bind(hyper, "x", center_window)
hs.hotkey.bind(hyper, 's', toggle_window_maximized)
hs.hotkey.bind(hyper, 'f', toggle_full_screen)

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

hs.pathwatcher.new(HAMMERSPOON_DIR, reload_config):start()
notify("Config loaded")

