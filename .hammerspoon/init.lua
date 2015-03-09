require "pomodoor"

-- disable animation
hs.window.animationDuration = 0

----- HELPER FUNCTIONS -----
local half = function(n) return n / 2 end
local zero = function(n) return 0     end
local full = function(n) return n     end
local centerX = function(s, f) return s.w/2 - f.w / 2 + s.x end
local centerY = function(s, f) return s.h/2 - f.h/2 + s.y end

local currentWindow = function()
  return hs.window.focusedWindow()
end

local newFrame = function(containerSizes, transformations)
  return { x = transformations.x(containerSizes.width),
           w = transformations.w(containerSizes.width),
           y = transformations.y(containerSizes.height),
           h = transformations.h(containerSizes.height),
         }
end

local windowTopLeft    = function(containerSizes) return newFrame(containerSizes, {x=zero, y=zero, w=half, h=half}) end
local windowTopRight   = function(containerSizes) return newFrame(containerSizes, {x=half, y=zero, w=half, h=half}) end
local windowBotLeft    = function(containerSizes) return newFrame(containerSizes, {x=zero, y=half, w=half, h=half}) end
local windowBotRight   = function(containerSizes) return newFrame(containerSizes, {x=half, y=half, w=half, h=half}) end
local windowFullScreen = function(containerSizes) return newFrame(containerSizes, {x=zero, y=zero, w=full, h=full}) end
local windowLeft       = function(containerSizes) return newFrame(containerSizes, {x=zero, y=zero, w=half, h=full}) end
local windowRight      = function(containerSizes) return newFrame(containerSizes, {x=half, y=zero, w=half, h=full}) end
local windowTop        = function(containerSizes) return newFrame(containerSizes, {x=zero, y=zero, w=full, h=half}) end
local windowBot        = function(containerSizes) return newFrame(containerSizes, {x=zero, y=half, w=full, h=half}) end

local updateWindow = function(getWindow, frameFor)
  return function()
    local window      = getWindow()
    local screenFrame = window:screen():frame()
    local sizes       = {width=(screenFrame.x + screenFrame.w), height=(screenFrame.y + screenFrame.h)}
    local newFrame    = frameFor(sizes)
    window:setFrame(newFrame)
  end
end

-- hotkey hyper
local mash       = {"ctrl", "alt", "shift", "cmd"}

--------------------------------------------------------------------------------

-- window hints
hs.hints.style = "vimperator"
hs.hotkey.bind(mash, '.', hs.hints.windowHints)

-- Launch applications
hs.hotkey.bind(mash, '1', function () hs.application.launchOrFocus("iTerm2") end)
hs.hotkey.bind(mash, '2', function () hs.application.launchOrFocus("Google Chrome") end)

-- move windows
hs.hotkey.bind(mash, "h", updateWindow(currentWindow, windowLeft))
hs.hotkey.bind(mash, "l", updateWindow(currentWindow, windowRight))
hs.hotkey.bind(mash, "k", updateWindow(currentWindow, windowTop))
hs.hotkey.bind(mash, "j", updateWindow(currentWindow, windowBot))

-- pomodoro key binding
hs.hotkey.bind(mash, '9', function() pom_enable() end)
hs.hotkey.bind(mash, '0', function() pom_disable() end)

-- RELOAD
function reload_config(files)
    hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config reloaded")

