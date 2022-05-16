------------------------
-- WiFi
------------------------

function enableWifi()
  hs.wifi.setPower(true)
  notify("Enabled Wifi")
end

function disableWifi()
  hs.wifi.setPower(false)
  notify("Disabled Wifi")
end

function toggleWifi()
  if (hs.wifi.interfaceDetails()["power"]) then
    disableWifi()
  else
    enableWifi()
  end
end
