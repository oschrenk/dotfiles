require("utils.Strings")

local sbar = require("sketchybar")

local Weather = {}

-- @param icons Plugin specific icons
function Weather.new(icons)
  local self = {}

  local Location = "Haarlem,NL"

  -- see https://github.com/chubin/wttr.in/tree/master?tab=readme-ov-file#one-line-output
  -- %c is the weather as emoji
  -- %t is the temperature
  local FormatString = "+%c:+%t"

  self.add = function(position)
    local weather = sbar.add("item", {
      position = position,
      update_freq = 3600,
      icon = icons.unknown,
    })

    local update = function()
      local cmd = string.format("curl -s 'https://wttr.in/%s?m&format=%s'", Location, FormatString)

      sbar.exec(cmd, function(oneline)
        local resp = Split(oneline, ":")
        local icon = resp[1]:gsub("%s+", "")
        local label = resp[2]:gsub("%s+", "")

        weather:set({ icon = icon, label = label })
      end)
    end

    weather:subscribe({ "forced", "routine", "system_woke" }, function(_)
      update()
    end)
  end

  return self
end

return Weather
