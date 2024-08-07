local sbar = require("sketchybar")

local Weather = {}

-- @param icons Plugin specific icons
function Weather.new(icons)
  local self = {}

  self.add = function(position)
    local weather = sbar.add("item", {
      position = position,
      update_freq = 3600,
      icon = icons.unknown,
    })

    weather:subscribe({ "forced", "routine", "system_woke" }, function(_)
      weather:set({ label = "weather" })
    end)
  end

  return self
end

return Weather
