local Wttr = {}

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

Wttr.codeToName = function(code)
  return wwoCode[code]
end

Wttr.codeToIdentifier = function(code)
  local name = wwoCode[code]
  local raw = name:gsub("%u", function(c)
    return "." .. c:lower()
  end)
  local clean = raw:sub(2)

  return clean
end

function Wttr.new()
  local self = {}
  return self
end

return Wttr
