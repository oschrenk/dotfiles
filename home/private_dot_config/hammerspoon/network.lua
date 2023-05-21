------------------------
-- Network location
------------------------
local wifiWatcher = nil
local work_SSID_pool = {  }
local home_SSID_pool = { 'Citadel' }
local lastSSID = hs.wifi.currentNetwork()

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        -- print("comparing: val:"..(val or "nil").." value:"..(value or "nil"))
        -- We grab the first index of our sub-table instead
        if value == val then
          return true
        end
    end

    return false
end


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
    return (not has_value(ssid_pool, old_ssid)) and has_value(ssid_pool, new_ssid)
  end

  return false
end

function enteredHome(ssid)
  notify("Connected to home wifi" .. ' "' ..ssid .. '"')
end

function enteredWork(ssid)
  notify("Connected to work wifi" .. ' "' ..ssid .. '"')
end

function enteredUntrusted(ssid)
  notify("Connected to untrusted wifi" .. ' "' ..ssid .. '"')
end

function wifiListener(watcher, message, interface)
  if message == "SSIDChange" then
    newSSID = hs.wifi.currentNetwork()

    print("ssidChangedCallback: old:"..(lastSSID or "nil").." new:"..(newSSID or "nil"))
    if (newSSID ~= nil) then
      if (enteredNetwork(lastSSID, newSSID, work_SSID_pool)) then
        enteredWork(newSSID)
      elseif (enteredNetwork(lastSSID, newSSID, home_SSID_pool)) then
        enteredHome(newSSID)
      else
        enteredUntrusted(newSSID)
      end
    end

    lastSSID = newSSID
  end
end

