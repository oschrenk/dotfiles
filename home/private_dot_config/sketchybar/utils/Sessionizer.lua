local sbar = require("sketchybar")

local Sessionizer = {}
function Sessionizer.new()
  local self = {}

  self.sessions = function(onComplete)
    local cmd = "/opt/homebrew/bin/sessionizer sessions --json"
    sbar.exec(cmd, function(sessions)
      onComplete(sessions)
    end)
  end

  self.currentSession = function(onComplete)
    local cmd = "/opt/homebrew/bin/sessionizer sessions --json"
    sbar.exec(cmd, function(sessions)
      local session = nil
      for _, v in pairs(sessions) do
        if v.attached then
          session = v
        end
      end
      onComplete(session)
    end)
  end

  return self
end

return Sessionizer
