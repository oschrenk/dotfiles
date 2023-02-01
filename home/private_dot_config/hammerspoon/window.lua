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

        -- to workaround AXEnhancedUserInterface bug:
        -- 1. disable AXEnhancedUserInterface
        -- 2. do the thing
        -- 3. re-enable AXEnhancedUserInterface
        -- see also https://github.com/Hammerspoon/hammerspoon/issues/3224#issuecomment-1294359070
        local axApp = hs.axuielement.applicationElement(win:application())
        local wasEnhanced = axApp.AXEnhancedUserInterface
        if wasEnhanced then
          axApp.AXEnhancedUserInterface = false
        end
        win:maximize()
        if wasEnhanced then
          axApp.AXEnhancedUserInterface = true
        end
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

