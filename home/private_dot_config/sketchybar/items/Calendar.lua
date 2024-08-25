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

		local update = function()
			sbar.exec("/opt/homebrew/bin/plan next --ignore-tag timeblock --ignore-all-day-events", function(json)
				local event = json[1]
				if event ~= nil then
					local icon = event.title.icon
					local label = event.title.label
					local suffix = ""

					if event["schedule"]["start"]["in"] < 0 then
						suffix = ", " .. event["schedule"]["end"]["in"] .. "m" .. " left"
					else
						suffix = " in " .. event["schedule"]["start"]["in"] .. "m"
					end
					calendar:set({
						icon = {
							string = icon,
							drawing = true,
						},
						label = {
							string = label .. suffix,
							drawing = true,
						},
						drawing = true,
					})

					local url = ""
					for type, u in pairs(event["services"]) do
						if type == "ical" then
							url = u
						end
					end
					calendar:subscribe("mouse.clicked", function(_)
						sbar.exec("open '" .. url .. "'")
					end)
				else
					calendar:set({
						icon = {
							string = icons.default,
							drawing = true,
						},
						label = {
							drawing = false,
						},
						drawing = true,
					})
				end
			end)
		end

		local onComplete = function(current_focus)
			if current_focus == focus.dnd or current_focus == focus.sleep then
				calendar:set({ drawing = false })
			else
				update()
			end
		end

		calendar:subscribe({ "forced", "routine", "system_woke", "mission_focus" }, function(_)
			focus.handler(onComplete)
		end)
	end

	return self
end

return Calendar
