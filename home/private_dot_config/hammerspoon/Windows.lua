------------------------
-- Window Managment
------------------------
require("WindowsLayout")

-- disable animation
hs.window.animationDuration = 0

Windows = {}
Windows.new = function(notify)
	local self = {}

	local layout = WindowsLayout.new(notify)

	-- Internal state
	self.windowSizeCache = {}

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
			layout.moveWithYOffset(0, 100, 0, 100, 33)
			if wasEnhanced then
				axApp.AXEnhancedUserInterface = true
			end
		end
	end

	self.left50 = function()
		layout.moveWithYOffset(0, 50, 0, 100, 33)
	end

	self.right50 = function()
		layout.moveWithYOffset(50, 50, 0, 100, 33)
	end

	self.toggleFullScreen = function()
		layout.toggleFullScreen()
	end

	self.sendWindowToPrevMonitor = function()
		layout.sendWindowToPrevMonitor()
	end

	self.sendWindowToNextMonitor = function()
		layout.sendWindowToNextMonitor()
	end

	return self
end
