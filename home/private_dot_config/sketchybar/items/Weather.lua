require("utils.Strings")
local Wttr = require("utils.Wttr")

local sbar = require("sketchybar")

local Weather = {}

-- @param icons Plugin specific icons
function Weather.new(icons)
  local self = {}

  local Location <const> = "Haarlem,NL"

  -- request as json
  -- while bigger, it has the convenience of being translated to a lua table
  -- j1 = full json
  -- j2 = "light weight" json without hourly data
  local FormatString <const> = "j2"

  local isValidResponse = function(wttr_json)
    if wttr_json == nil then
      return false
    end
    return true
  end

  self.add = function(position)
    local weather = sbar.add("item", {
      position = position,
      update_freq = 3600,
      icon = icons.unknown,
      label = { drawing = false },
    })

    local update = function()
      local cmd = string.format("curl -s 'https://wttr.in/%s?m&format=%s'", Location, FormatString)

      sbar.exec(cmd, function(wttr_json)
        if isValidResponse(wttr_json) then
          local current_condition = wttr_json.current_condition[1]
          local code = current_condition.weatherCode
          local label = current_condition.temp_C .. "°C"
          local id = Wttr.codeToIdentifier(code)
          local icon = icons[id]

          weather:set({
            icon = icon,
            label = {
              string = label,
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

    weather:subscribe({ "forced", "routine", "system_woke" }, function(_)
      update()
    end)
  end

  return self
end

return Weather
