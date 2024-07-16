------------------------
-- NetworkLocation
------------------------
NetworkLocation = {}
NetworkLocation.new = function(notify)
	local self = {}

	self.current = function()
		local file = assert(io.popen("/usr/sbin/networksetup -getcurrentlocation", "r"))
		local output = file:read("*all")
		file:close()

		return output:gsub("%s+", "")
	end

	-- this function relies on a sudoers.d entry like
	-- %Local  ALL=NOPASSWD: /usr/sbin/networksetup -switchtolocation "name"
	self.switchNetworkLocation = function(name)
		local location = self.current()
		if location ~= name then
			notify("Switching location to " .. name)
			os.execute('sudo /usr/sbin/networksetup -switchtolocation "' .. name .. '"')
		end
	end

	return self
end
