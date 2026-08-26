local _M = {}

-- Synchronously fetch current hostname
--
-- Not suited to be called regularly
function _M.getHostname()
  local f = assert(io.popen("/bin/hostname"))
  local hostname = f:read("*a") or ""
  f:close()
  hostname = string.gsub(hostname, "\n$", "")
  return hostname
end

-- Synchronously fetch current Wifi
--
-- Not suited to be called regularly
function _M.getWifi()
  local f = assert(io.popen("networksetup -getairportnetwork en0 | awk '{print $4}' | head -n 1"))
  local hostname = f:read("*a") or ""
  f:close()
  hostname = string.gsub(hostname, "\n$", "")
  return hostname
end

return _M
