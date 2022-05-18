------------------------
-- Bluetooth
------------------------
-- relies on https://github.com/toy/blueutil
-- installable via `brew install blueutil`

function enableBluetooth()
  notify("Enabling Bluetooth")
  os.execute("/usr/local/bin/blueutil -p 1")
end

function disableBluetooth()
  notify("Disabling Bluetooth")
  os.execute("/usr/local/bin/blueutil -p 0")
end

function bluetoothEnabled()
  local file = assert(io.popen('/usr/local/bin/blueutil -p', 'r'))
  local output = file:read('*all')
  file:close()

  return output:gsub("%s+", "") == "1"
end

function toggleBluetooth()
  if (bluetoothEnabled()) then
    disableBluetooth()
  else
    enableBluetooth()
  end
end

