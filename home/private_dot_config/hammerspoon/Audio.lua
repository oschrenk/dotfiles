------------------------
-- Audio settings
------------------------
Audio = {}
Audio.new = function(notify, bluetooth, scripts_dir)
	local self = {}

	self.toggleMute = function()
		if hs.audiodevice.defaultOutputDevice():outputMuted() then
			hs.audiodevice.defaultOutputDevice():setMuted(false)
		else
			hs.audiodevice.defaultOutputDevice():setMuted(true)
		end
		notify("Toggle Mute")
	end

	self.mute = function()
		hs.audiodevice.defaultOutputDevice():setMuted(true)
		notify("Mute")
	end

	self.connectHeadphones = function()
		if not bluetooth.isEnabled() then
			bluetooth.enable()
		end
		_, _ = hs.osascript.applescriptFromFile(scripts_dir .. "/connectHeadphones.applescript")
	end

	return self
end
