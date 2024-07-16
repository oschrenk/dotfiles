------------------------
-- Bluetooth
------------------------
-- relies on https://github.com/toy/blueutil
-- installable via `brew install blueutil`
--
Bluetooth = {}
Bluetooth.new = function(notify)
	local self = {}
	local binary = "/opt/homebrew/bin/blueutil"

	self.enable = function()
		print("Hello?")
		notify("Enabling Bluetooth")
		os.execute(string.format("%s -p 1", binary))
	end

	self.disable = function()
		print("Hello2?")

		notify("Disabling Bluetooth")
		os.execute(string.format("%s -p 0", binary))
	end

	self.isEnabled = function()
		local file = assert(io.popen(string.format("%s -p", binary), "r"))
		local output = file:read("*all")
		file:close()

		return output:gsub("%s+", "") == "1"
	end

	self.toggle = function()
		if self.isEnabled() then
			self.disable()
		else
			self.enable()
		end
	end

	return self
end
