local sbar = require("sketchybar")

local Wttr = {}

function Wttr.new()
  local self = {}

  -- https://github.com/chubin/wttr.in/blob/master/lib/constants.py#L3C1-L52C2
  local wwoCode = {
    ["113"] = "Sunny",
    ["116"] = "PartlyCloudy",
    ["119"] = "Cloudy",
    ["122"] = "VeryCloudy",
    ["143"] = "Fog",
    ["176"] = "LightShowers",
    ["179"] = "LightSleetShowers",
    ["182"] = "LightSleet",
    ["185"] = "LightSleet",
    ["200"] = "ThunderyShowers",
    ["227"] = "LightSnow",
    ["230"] = "HeavySnow",
    ["248"] = "Fog",
    ["260"] = "Fog",
    ["263"] = "LightShowers",
    ["266"] = "LightRain",
    ["281"] = "LightSleet",
    ["284"] = "LightSleet",
    ["293"] = "LightRain",
    ["296"] = "LightRain",
    ["299"] = "HeavyShowers",
    ["302"] = "HeavyRain",
    ["305"] = "HeavyShowers",
    ["308"] = "HeavyRain",
    ["311"] = "LightSleet",
    ["314"] = "LightSleet",
    ["317"] = "LightSleet",
    ["320"] = "LightSnow",
    ["323"] = "LightSnowShowers",
    ["326"] = "LightSnowShowers",
    ["329"] = "HeavySnow",
    ["332"] = "HeavySnow",
    ["335"] = "HeavySnowShowers",
    ["338"] = "HeavySnow",
    ["350"] = "LightSleet",
    ["353"] = "LightShowers",
    ["356"] = "HeavyShowers",
    ["359"] = "HeavyRain",
    ["362"] = "LightSleetShowers",
    ["365"] = "LightSleetShowers",
    ["368"] = "LightSnowShowers",
    ["371"] = "HeavySnowShowers",
    ["374"] = "LightSleetShowers",
    ["377"] = "LightSleet",
    ["386"] = "ThunderyShowers",
    ["389"] = "ThunderyHeavyRain",
    ["392"] = "ThunderySnowShowers",
    ["395"] = "HeavySnowShowers",
  }

  self.codeToName = function(code)
    return wwoCode[code]
  end

  self.codeToIdentifier = function(code)
    local name = wwoCode[code]
    local raw = name:gsub("%u", function(c)
      return "." .. c:lower()
    end)
    local clean = raw:sub(2)

    return clean
  end

  -- request as json
  -- while bigger, it has the convenience of being translated to a lua table
  -- j1 = full json
  -- j2 = "light weight" json without hourly data
  local FormatString <const> = "j2"

  self.fetch = function(location, callback)
    local cmd = string.format("curl -s 'https://wttr.in/%s?m&format=%s'", location, FormatString)

    sbar.exec(cmd, function(wttr_json)
      if wttr_json ~= nil then
        local current_condition = wttr_json.current_condition[1]
        local code = current_condition.weatherCode
        local label = current_condition.temp_C .. "°C"
        local id = self.codeToIdentifier(code)

        callback({ label = label, id = id })
      else
        callback(nil)
      end
    end)
  end

  return self
end

return Wttr
