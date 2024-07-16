------------------------
-- WiFi Watcher
------------------------
WifiWatcher = {}
WifiWatcher.new = function(workIds, homeIds, enteredHome, enteredWork, enteredUntrusted)
	local self = {}

	self.lastSSID = hs.wifi.currentNetwork()

	self.start = function()
		self.wifiWatcher = hs.wifi.watcher.new(self.wifiListener)
		self.wifiWatcher:watchingFor({ "SSIDChange" })
		self.wifiWatcher:start()
	end

	self.has_value = function(tab, val)
		for _, value in ipairs(tab) do
			-- grab first index of sub-table
			if value == val then
				return true
			end
		end

		return false
	end

	self.enteredNetwork = function(old_ssid, new_ssid, ssid_pool)
		-- activated wifi
		if old_ssid == nil and new_ssid ~= nil then
			return self.has_value(ssid_pool, new_ssid)
		end

		-- deactivated wifi
		if old_ssid ~= nil and new_ssid == nil then
			return false
		end

		-- changed wifi
		-- checking if we more than changed network within environment
		if old_ssid ~= nil and new_ssid ~= nil then
			return (not self.has_value(ssid_pool, old_ssid)) and self.has_value(ssid_pool, new_ssid)
		end

		return false
	end

	-- interface: (watcher, message, interface)
	self.wifiListener = function(_, message, _)
		if message == "SSIDChange" then
			local newSSID = hs.wifi.currentNetwork()

			print("ssidChangedCallback: old:" .. (self.lastSSID or "nil") .. " new:" .. (newSSID or "nil"))
			if newSSID ~= nil then
				if self.enteredNetwork(self.lastSSID, newSSID, workIds) then
					enteredWork(newSSID)
				elseif self.enteredNetwork(self.lastSSID, newSSID, homeIds) then
					enteredHome(newSSID)
				else
					enteredUntrusted(newSSID)
				end
			end

			self.lastSSID = newSSID
		end
	end

	return self
end
