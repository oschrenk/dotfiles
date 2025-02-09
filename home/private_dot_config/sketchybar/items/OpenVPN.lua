local sbar = require("sketchybar")

local OpenVPN = {}

-- @param icons Plugin specific icons
-- @param ifconfig  service
function OpenVPN.new(icons, ifconfig)
  local self = {}

  self.add = function(position)
    local item = sbar.add("item", {
      position = position,
      update_freq = 30,
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
      ifconfig.isConnected(update)
    end)
  end

  return self
end

return OpenVPN
