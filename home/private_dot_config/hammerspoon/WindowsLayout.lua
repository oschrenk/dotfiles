WindowsLayout = {}
WindowsLayout.new = function(notify)
	local self = {}

	self.moveWithYOffset = function(percentX, percentW, percentY, percentH, yOffset)
		local win = hs.window.focusedWindow()
		local f = win:frame()
		local screen = win:screen()
		local max = screen:frame()
		local screenName = screen:name()

		local newX = max.w * (percentX / 100)
		local newW = max.w * (percentW / 100)

		local newY = max.h * (percentY / 100)
		local newH = max.h * (percentH / 100)

		-- don-t apply offset for built-in display
		if screenName ~= "Built-in Retina Display" then
			newY = newY + yOffset
			newH = newH - yOffset
		end

		f.x = newX
		f.w = newW
		f.y = newY
		f.h = newH

		win:setFrame(f)
	end

	self.left50 = function()
		hs.window.focusedWindow():moveToUnit(hs.layout.right50)
	end

	self.right50 = function()
		hs.window.focusedWindow():moveToUnit(hs.layout.right50)
	end

	-- Send Window Prev Monitor
	self.sendWindowToPrevMonitor = function()
		if #hs.screen.allScreens() > 1 then
			local win = hs.window.focusedWindow()
			local previousScreen = win:screen():previous()
			win:moveToScreen(previousScreen)
			notify("Prev Monitor", 5)
		end
	end

	-- Send Window Next Monitor
	self.sendWindowToNextMonitor = function()
		if #hs.screen.allScreens() > 1 then
			local win = hs.window.focusedWindow()
			local nextScreen = win:screen():next()
			win:moveToScreen(nextScreen)
			notify("Next Monitor", 5)
		end
	end

	self.toggleFullScreen = function()
		hs.window.focusedWindow():toggleFullScreen()
	end

	return self
end
