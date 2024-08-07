local sbar = require("sketchybar")

-- Requirements
--   brew install ical-buddy
--   brew install coreutils
--   brew install oschrenk/made/mission
--
-- To watch for changes and subscribe to events
--   brew services start mission
--
-- Then allow
--   "System Settings" > "Privacy & Security" > "Full Disk Access", allow mission
--   brew services restart mission
-- This is because we are watching iCloud and system files (for macOS Focus)

-- this script only work until midnight of a given day
-- beyond that date and time calculation might be wrong
local Calendar = {}
function Calendar.new(icons)
  local focus_dnd <const> = "com.apple.donotdisturb.mode.default"
  local focus_sleep <const> = "com.apple.sleep.sleep-mode"

  local self = {}

  self.add = function(position)
    local calendar = sbar.add("item", {
      position = position,
      update_freq = 120,
      icon = icons.default,
    })

    local update = function()
      sbar.exec("/opt/homebrew/bin/mission focus", function(raw)
        local result = raw:gsub("%s+", "")
        if result == focus_dnd or result == focus_sleep then
          calendar:set({ label = result })
        end
      end)
    end

    calendar:subscribe({ "forced", "routine", "system_woke", "mission_focus" }, function(_)
      update()
    end)
  end

  return self
end

return Calendar
