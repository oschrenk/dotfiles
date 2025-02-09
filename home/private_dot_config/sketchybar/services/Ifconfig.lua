local sbar = require("sketchybar")

local Ifconfig = {}
function Ifconfig.new()
  local self = {}

  self.isConnected = function(onComplete)
    local cmd = "ifconfig utun4 | grep UP"
    sbar.exec(cmd, function(connnected_string)
      return onComplete(string.find(connnected_string, "UP"))
    end)
  end

  return self
end

return Ifconfig
