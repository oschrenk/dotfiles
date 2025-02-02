local sbar = require("sketchybar")

local Tunnelblick = {}
function Tunnelblick.new()
  local self = {}

  self.isConnected = function(onComplete)
    local cmd =
      'osascript -e "tell application \\"/Applications/Tunnelblick.app\\"" -e "get state of configurations" -e "end tell"'
    sbar.exec(cmd, function(connnected_string)
      return onComplete(string.find(connnected_string, "CONNECTED"))
    end)
  end

  return self
end

return Tunnelblick
