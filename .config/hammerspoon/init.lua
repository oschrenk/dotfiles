------------------------
-- Settings
------------------------
-- base dirs
local HAMMERSPOON_DIR = os.getenv("HOME") .. "/.config/hammerspoon"
local SCRIPTS_DIR = HAMMERSPOON_DIR .. "/scripts"

-- disable animation
hs.window.animationDuration = 0

------------------------
-- Helpers
------------------------
function notify(message)
  hs.notify.new({
    title='Hammerspoon',
    informativeText=message,
  }):send()
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
require('notifications')
require('wifi')
require('window')

-- mounting/unmounting drives
-- require('drives')

-- fast user switching via script is crippled in Big Sur
-- see also https://apple.stackexchange.com/questions/409820/access-fast-user-switching-from-a-script-in-big-sur
-- require('userswitching')
-- hs.hotkey.bind(hyper, "u", toggleUser)

------------------------
-- Keyboard Bindings
------------------------
local hyper = {"ctrl", "alt", "shift", "cmd"}

hs.hotkey.bind(hyper, 'a', left50)
hs.hotkey.bind(hyper, 'd', right50)
hs.hotkey.bind(hyper, 's', toggle_window_maximized)
hs.hotkey.bind(hyper, 'x', toggle_full_screen)

hs.hotkey.bind(hyper, "q", send_window_to_prev_monitor)
hs.hotkey.bind(hyper, "e", send_window_to_next_monitor)

hs.hotkey.bind(hyper, "h", connectHeadphones)

hs.hotkey.bind(hyper, "c", closeNotifications)


hs.hotkey.bind(hyper, "b", toggleBluetooth)
hs.hotkey.bind(hyper, "v", toggleWifi)

hs.hotkey.bind(hyper, 'm', mute)

------------------------
-- Reload
------------------------
hs.pathwatcher.new(HAMMERSPOON_DIR, function(files) hs.reload() end):start()
notify("Config loaded")

