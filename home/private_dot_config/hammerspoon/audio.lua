------------------------
-- Audio settings
------------------------
Audio = {}
Audio.new = function(notify)
	local self = {}

	self.mute = function()
		hs.audiodevice.defaultOutputDevice():setMuted(true)
		notify("Mute")
	end

	return self
end
