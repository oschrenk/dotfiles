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
function Calendar.new(icons, focus)
  local self = {}

  self.add = function(position)
    local calendar = sbar.add("item", {
      position = position,
      update_freq = 120,
      icon = icons.default,
    })

    local calUpdate = function()
      sbar.exec("/opt/homebrew/bin/plan next --reject-tag timeblock", function(json)
        local event = json[1]
        if event ~= nil then
          local legend = event.legend
          local icon = legend.icon
          local label = legend.description
          local suffix = ""
          if event.starts_in < 0 then
            suffix = ", " .. event.ends_in .. "m" .. " left"
          else
            suffix = " in " .. event.starts_in .. "m"
          end
          calendar:set({ icon = icon, label = label .. suffix })
        else
          calendar:set({ icon = icons.default })
        end
      end)
    end

    local update = function()
      sbar.exec("/opt/homebrew/bin/mission focus", function(raw)
        local result = raw:gsub("%s+", "")
        if result == focus.dnd or result == focus.sleep then
          calendar:set({ label = "sleeping" })
        else
          calUpdate()
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
