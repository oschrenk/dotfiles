require("utils.Strings")
local sbar = require("sketchybar")

local WeatherWttr = {}

-- @param icons Plugin specific icons
-- @param wttr wttr instance
function WeatherWttr.new(icons, wttr)
  local self = {}

  local Location <const> = "Haarlem,NL"

  self.add = function(position)
    local weather = sbar.add("item", {
      position = position,
      update_freq = 3600,
      icon = icons.unknown,
      label = { drawing = false },
    })

    local update = function()
      wttr.fetch(Location, function(data)
        if data ~= nil then
          weather:set({
            icon = icons[data.id],
            label = {
              string = data.label,
              drawing = true,
            },
          })
        else
          weather:set({
            icon = icons.unknown,
            label = {
              drawing = false,
            },
          })
        end
      end)
    end
    wttr.fetch(Location, update)

    weather:subscribe({ "forced", "routine", "system_woke" }, function(_)
      update()
    end)
  end

  return self
end

return WeatherWttr
