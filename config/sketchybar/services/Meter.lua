local sbar = require("sketchybar")

local Meter = {}

function Meter.new()
  local self = {}

  self.usage = function(callback)
    local today = os.date("%Y%m%d")
    local cmd = "~/.config/meter/session.sh " .. today
    sbar.exec(cmd, function(json)
      callback(json)
    end)
  end

  return self
end

return Meter
