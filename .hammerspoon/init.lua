require "pomodoro"

local wifiWatcher = nil
local workSSIDToken = "elmar"
local homeSSIDToken = "SitecomC4934C"
local lastSSID = hs.wifi.currentNetwork()

-- disable animation
hs.window.animationDuration = 0.3

-- hotkey hyper
local hyper = {"ctrl", "alt", "shift", "cmd"}

-- Half Left
hs.hotkey.bind(hyper, "a", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

-- Half Right
hs.hotkey.bind(hyper, "d", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

-- Half Up
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

-- Half Down
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

-- Maximize
hs.hotkey.bind(hyper, "s", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = 0
  f.y = 0
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end)

-- Full screen
hs.hotkey.bind(hyper, "f", function()
  local win = hs.window.focusedWindow()
  if win ~= nil then
    win:setFullScreen(not win:isFullScreen())
  end
end)

-- Send Window Prev Monitor
hs.hotkey.bind(hyper, "p", function()
  hs.alert.show("Prev Monitor")
  local win = hs.window.focusedWindow()
  local previousScreen = win:screen():previous()
  win:moveToScreen(previousScreen)
end)

-- Send Window Next Monitor
hs.hotkey.bind(hyper, "n", function()
  hs.alert.show("Next Monitor")
  local win = hs.window.focusedWindow()
  local nextScreen = win:screen():next()
  win:moveToScreen(nextScreen)
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

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()

-- Launch applications
hs.hotkey.bind(hyper, '1', function () hs.application.launchOrFocus("iTerm2") end)
hs.hotkey.bind(hyper, '2', function () hs.application.launchOrFocus("Google Chrome") end)

-- pomodoro key binding
hs.hotkey.bind(hyper, '9', function() pom_enable() end)
hs.hotkey.bind(hyper, '0', function() pom_disable() end)

-- RELOAD
function reload_config(files)
  wifiWatcher:stop()
  hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config reloaded")

