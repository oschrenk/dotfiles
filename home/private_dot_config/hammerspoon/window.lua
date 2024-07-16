------------------------
-- Window Managment
------------------------
Windows = {}
Windows.new = function(notify)
	local self = {}

	-- Internal state
	self.windowSizeCache = {}
	self.windowSizeCacheLoop = {}

	self.centerWindow = function()
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
	self.toggleWindowMaximized = function()
		local win = hs.window.focusedWindow()
		if self.windowSizeCache[win:id()] then
			win:setFrame(self.windowSizeCache[win:id()])
			self.windowSizeCache[win:id()] = nil
		else
			self.windowSizeCache[win:id()] = win:frame()

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

	self.left50 = function()
		hs.window.focusedWindow():moveToUnit(hs.layout.left50)
	end

	self.loopLeft = function()
		local win = hs.window.focusedWindow()
		local entry = self.windowSizeCacheLoop[win:id()]
		if entry then
			local original_frame = entry["frame"]
			local percentage = entry["percentage"]
			if percentage == 50 then
				-- move to 70%
				hs.window.focusedWindow():moveToUnit(hs.layout.left70)
				local newState = { frame = original_frame, percentage = 70 }
				self.windowSizeCacheLoop[win:id()] = newState
			elseif percentage == 70 then
				-- move to original state, reset cache entry
				win:setFrame(original_frame)
				self.windowSizeCacheLoop[win:id()] = nil
			else
				-- move to 50% state
				local newState = { frame = original_frame, percentage = 50 }
				hs.window.focusedWindow():moveToUnit(hs.layout.left50)
				self.windowSizeCacheLoop[win:id()] = newState
			end
		else
			-- new windoww, start with 50%
			local newState = { frame = win:frame(), percentage = 50 }
			self.windowSizeCacheLoop[win:id()] = newState
			hs.window.focusedWindow():moveToUnit(hs.layout.left50)
		end
	end

	self.loopRight = function()
		local win = hs.window.focusedWindow()
		local entry = self.windowSizeCacheLoop[win:id()]
		if entry then
			local original_frame = entry["frame"]
			local percentage = entry["percentage"]
			if percentage == 50 then
				-- move to 30%
				hs.window.focusedWindow():moveToUnit(hs.layout.right30)
				local newState = { frame = original_frame, percentage = 30 }
				self.windowSizeCacheLoop[win:id()] = newState
			elseif percentage == 30 then
				-- move to original state, reset cache entry
				win:setFrame(original_frame)
				self.windowSizeCacheLoop[win:id()] = nil
			else
				-- move to 50% state
				local newState = { frame = original_frame, percentage = 50 }
				hs.window.focusedWindow():moveToUnit(hs.layout.right50)
				self.windowSizeCacheLoop[win:id()] = newState
			end
		else
			-- new windoww, start with 50%
			local newState = { frame = win:frame(), percentage = 50 }
			self.windowSizeCacheLoop[win:id()] = newState
			hs.window.focusedWindow():moveToUnit(hs.layout.right50)
		end
	end

	self.right50 = function()
		hs.window.focusedWindow():moveToUnit(hs.layout.right50)
	end

	self.toggleFullScreen = function()
		hs.window.focusedWindow():toggleFullScreen()
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

	return self
end
