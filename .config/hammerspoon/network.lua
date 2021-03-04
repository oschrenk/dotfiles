------------------------
-- Network location
------------------------
local wifiWatcher = nil
local work_SSID_pool = {  }
local home_SSID_pool = { 'Citadel' }
local lastSSID = hs.wifi.currentNetwork()
local homeLocation = 'Home'
local workLocation = 'Work'

function currentNetworkLocation()
  local file = assert(io.popen('/usr/sbin/networksetup -getcurrentlocation', 'r'))
  local output = file:read('*all')
  file:close()

  return output:gsub("%s+", "")
end

-- this function relies on a sudoers.d entry like
-- %Local  ALL=NOPASSWD: /usr/sbin/networksetup -switchtolocation "name"
function switchNetworkLocation(name)
  local location = currentNetworkLocation()
  if (location ~= name) then
    notify("Switching location to " .. name)
    os.execute("sudo /usr/sbin/networksetup -switchtolocation \"" .. name .. "\"")
  end
end

------------------------
-- Watch network changes
------------------------

function enteredNetwork(old_ssid, new_ssid, ssid_pool)
  -- activated wifi
  if (old_ssid == nil and new_ssid ~= nil) then
    return has_value(ssid_pool,new_ssid)
  end

  -- deactivated wifi
  if (old_ssid ~= nil and new_ssid == nil) then
    return false
  end

  -- changed wifi
  -- checking if we more than changed network within environment
  if (old_ssid ~= nil and new_ssid ~= nil) then
    notify("Changed Wifi")
    return (not has_value(ssid_pool, old_ssid)) and has_value(ssid_pool, new_ssid)
  end

  return false
end

function ssidChangedCallback()
    newSSID = hs.wifi.currentNetwork()

    print("ssidChangedCallback: old:"..(lastSSID or "nil").." new:"..(newSSID or "nil"))
    if (newSSID ~= nil) then
      if (enteredNetwork(lastSSID, newSSID, work_SSID_pool)) then
        enteredWork()
      end

      if (enteredNetwork(lastSSID, newSSID, home_SSID_pool)) then
        enteredHome()
      end
    end

    lastSSID = newSSID
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()
