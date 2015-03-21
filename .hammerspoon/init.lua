require "pomodoro"

-- disable animation
hs.window.animationDuration = 0

-- hotkey hyper

local hyper = {"ctrl", "alt", "shift", "cmd"}

-- Send Window Left
hs.hotkey.bind(hyper, "h", function()
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

-- Send Window Right
hs.hotkey.bind(hyper, "l", function()
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

-- Send Window Up
hs.hotkey.bind(hyper, "k", function()
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

-- Send Window Down
hs.hotkey.bind(hyper, "j", function()
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

-- Maximize window
hs.hotkey.bind(hyper, "i", function()
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
hs.hotkey.bind(hyper, "y", function()
  hs.alert.show("Prev Monitor")
  local win = hs.window.focusedWindow()
  local previousScreen = win:screen():previous()
  win:moveToScreen(previousScreen)
end)

-- Send Window Next Monitor
hs.hotkey.bind(hyper, "o", function()
  hs.alert.show("Next Monitor")
  local win = hs.window.focusedWindow()
  local nextScreen = win:screen():next()
  win:moveToScreen(nextScreen)
end)

-- Launch applications
hs.hotkey.bind(hyper, '1', function () hs.application.launchOrFocus("iTerm2") end)
hs.hotkey.bind(hyper, '2', function () hs.application.launchOrFocus("Google Chrome") end)

-- pomodoro key binding
hs.hotkey.bind(hyper, '9', function() pom_enable() end)
hs.hotkey.bind(hyper, '0', function() pom_disable() end)

-- RELOAD
function reload_config(files)
    hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config reloaded")

