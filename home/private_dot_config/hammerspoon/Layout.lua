Layout = {}
Layout.new = function(notify)
	local self = {}

	-- @param percentX x coordinates of top left corner, in relative terms to screen - between 0 and 1
	-- @param percentY x coordinates of top left corner, in relative terms to screen - between 0 and 1
	-- @param percentW width of windows in relative terms to screen - between 0 and 1
	-- @param percentW height of windows in relative terms to screen - between 0 and 1
	-- @param yOffset y offset in absolute terms that is "cut off" from the top
	self.moveWithYOffset = function(percentX, percentY, percentW, percentH, yOffset)
		local win = hs.window.focusedWindow()

		-- move into position
		local rect = hs.geometry.rect(percentX, percentY, percentW, percentH)
		win:moveToUnit(rect)

		-- only apply offset for non-notch screens
		if win:screen():name() ~= "Built-in Retina Display" then
			local f = win:frame()
			local topLeft = hs.geometry.point(f.x, f.y + yOffset)
			win:setTopLeft(topLeft)
		end
	end

	self.left50 = function()
		hs.window.focusedWindow():moveToUnit(hs.layout.left50)
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
