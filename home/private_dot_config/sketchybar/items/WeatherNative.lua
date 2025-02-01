require("utils.Strings")
local sbar = require("sketchybar")

local WeatherWttr = {}

-- Using a menubar alias requires sketchybar to have screen recording permission
-- Which means that a permanent indicator is shown
-- This can be mitigiated by installing
-- `brew install yellowdot`
-- It can technically also be removed but requires SIP removal
-- @param style color palette
function WeatherWttr.new(style)
  local self = {}

  self.add = function(position)
    local weather = sbar.add("alias", "WeatherMenu,Item-0", {
      position = position,
      update_freq = 900,
      alias = {
        color = style.palette.white,
      },
      icon = { drawing = false },
      label = { drawing = false },
      background = {
        padding_right = -8,
      },
    })

    weather:subscribe("mouse.clicked", function(_)
      sbar.exec("open -a 'Weather'")
    end)
  end

  return self
end

return WeatherWttr
