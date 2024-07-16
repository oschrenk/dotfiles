------------------------
-- WiFi
------------------------
Wifi = {}
Wifi.new = function(notify)
	local self = {}

	self.enable = function()
		hs.wifi.setPower(true)
		notify("Enabled Wifi")
	end

	self.disable = function()
		hs.wifi.setPower(false)
		notify("Disabled Wifi")
	end

	self.toggle = function()
		if hs.wifi.interfaceDetails()["power"] then
			self.disableWifi()
		else
			self.enableWifi()
		end
	end
	return self
end
