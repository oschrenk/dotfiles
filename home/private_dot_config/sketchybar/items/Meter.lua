local sbar = require("sketchybar")

local Meter = {}

-- @param meter Meter service
function Meter.new(meter)
  local self = {}
  self.day = nil

  local callback = function(json)
    self.day:set({
      label = { string = (json.five_hour.utilization or 0) .. "%" },
    })

    self.week:set({
      label = { string = (json.seven_day.utilization or 0) .. "%" },
    })
  end

  self.add = function(position, width)
    local itemWidth = width and (width / 2) or nil

    self.day = sbar.add("item", {
      position = position,
      width = itemWidth,
      icon = { string = "􀐯", y_offset = 1, width = 26 },
      label = { string = "0%" },
    })

    self.week = sbar.add("item", {
      position = position,
      width = itemWidth,
      icon = { string = "􀉉", y_offset = 1, width = 26 },
      label = { string = "0%" },
    })

    self.day:subscribe(
      { "routine", "forced", "system_woke", "tmux_sessions_update", "ai_agent_done", "ai_agent_waiting" },
      function(_)
        meter.usage(callback)
      end
    )
  end

  return self
end

return Meter
