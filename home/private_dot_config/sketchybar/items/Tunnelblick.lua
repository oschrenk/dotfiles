local sbar = require("sketchybar")

local Tunnelblick = {}

-- @param icons Plugin specific icons
-- @param tunnelblick Tunnelblick service
function Tunnelblick.new(icons, tunnelblick)
  local self = {}

  self.add = function(position)
    local item = sbar.add("item", {
      position = position,
      update_freq = 60,
      icon = icons.inactive,
      label = { drawing = false },
    })

    local update = function(isConnected)
      local icon = icons.inactive
      if isConnected then
        icon = {
          string = icons.active,
        }
      else
        icon = {
          string = icons.inactive,
        }
      end

      item:set({
        icon = icon,
      })
    end

    item:subscribe({ "forced", "routine", "system_woke" }, function(_)
      tunnelblick.isConnected(update)
    end)
  end

  return self
end

return Tunnelblick
