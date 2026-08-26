local sbar = require("sketchybar")

local Claude = {}

function Claude.new()
  local self = {}

  self.usage = function(callback)
    local today = os.date("%Y%m%d")
    local cmd = "~/.config/ccusage/session.sh " .. today
    sbar.exec(cmd, function(json)
      callback(json)
    end)
  end

  return self
end

return Claude
