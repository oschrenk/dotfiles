local sbar = require("sketchybar")

-- Requirements
--  https://github.com/oschrenk/mission
--  brew tap oschrenk/made
--  brew install mission
--
--  To watch for changes and subscribe to events
--   brew services start mission
--  Then allow
--   "System Settings" > "Privacy & Security" > "Full Disk Access", allow mission
--   brew services restart mission
--  This is because we are watching iCloud and system files (for macOS Focus)
local Mission = {}

-- @param icons Plugin specific icons
-- @param focus Instance of Focus
function Mission.new(icons, focus)
	local self = {}

	-- @param position right|left
	self.add = function(position)
		local mission = sbar.add("item", {
			position = position,
			update_freq = 5,
			icon = {
				drawing = false,
			},
		})

		local onComplete = function(current_focus)
			local cmd = ""
			if current_focus == focus.work then
				cmd = "/opt/homebrew/bin/mission tasks --journal=work --show-done=false --show-cancelled=false"
			else
				cmd = "/opt/homebrew/bin/mission tasks --show-done=false --show-cancelled=false"
			end

			sbar.exec(cmd, function(task)
				mission:set({ label = task })
			end)
		end

		mission:subscribe({ "routine", "system_woke", "mission_task", "mission_focus" }, function(_)
			focus.handler(onComplete)
		end)
	end

	return self
end

return Mission
