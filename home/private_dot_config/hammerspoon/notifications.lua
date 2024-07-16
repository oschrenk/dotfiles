------------------------
-- Notifications
------------------------
Notifications = {}
Notifications.new = function(scripts_dir)
	local self = {}

	self.notify = function(message)
		hs.notify
			.new({
				title = "Hammerspoon",
				informativeText = message,
			})
			:send()
	end

	-- Clear notifications immediately
	self.clearNotifications = function()
		hs.osascript.applescriptFromFile(scripts_dir .. "/closeNotifiations.applescript")
	end

	-- Close notifications with small delay
	self.closeNotifications = function()
		print("Closing notifications")
		hs.timer.doAfter(0.3, self.clearNotifications)
	end

	return self
end
