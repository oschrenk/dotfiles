local sbar = require("sketchybar")

local Focus = {}
function Focus.new()
	local self = {}

	self.dnd = "com.apple.donotdisturb.mode.default"
	self.sleep = "com.apple.sleep.sleep-mode"
	self.work = "com.apple.focus.work"
	self.personal = "com.apple.focus.personal-time"

	self.handler = function(onComplete)
		sbar.exec("/opt/homebrew/bin/mission focus", function(focus)
			onComplete(focus)
		end)
	end

	return self
end

return Focus
