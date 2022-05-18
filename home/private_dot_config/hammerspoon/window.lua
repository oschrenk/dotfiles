------------------------
-- Window Managment
------------------------

-- Internal state
local windowSizeCache = {}

function center_window()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.w * (15 / 100)
  f.y = max.h * (5 / 100)
  f.w = max.w * (70 / 100)
  f.h = max.h * (90 / 100)
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

function left50()
  hs.window.focusedWindow():moveToUnit(hs.layout.left50)
end

function right50()
  hs.window.focusedWindow():moveToUnit(hs.layout.right50)
end

function toggle_full_screen()
  hs.window.focusedWindow():toggleFullScreen()
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

