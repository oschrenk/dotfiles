Appearance = {}
Appearance.new = function()
	local self = {}

	self.setDarkMode = function(mode)
		local setSystemModeAppleScriptString = [[tell application "System Events"]]
			.. "\n"
			.. [[tell appearance preferences]]
			.. "\n"
			.. [[set dark mode to ]]
			.. tostring(mode)
			.. "\n"
			.. [[end tell]]
			.. "\n"
			.. [[end tell]]
		hs.osascript.applescript(setSystemModeAppleScriptString)
	end

	self.enableDarkMode = function()
		self.setDarkMode(true)
	end

	self.disableDarkMode = function()
		self.setDarkMode(true)
	end

	self.toggleDarkMode = function()
		self.setDarkMode(not self.isDarkMode())
	end

	self.isDarkMode = function()
		if "Dark" == hs.host.interfaceStyle() then
			return true
		end
		return false
	end

	return self
end

return Appearance
