local sbar = require("sketchybar")

local Battery = {}
function Battery.new(icons)
  local self = {}

  self.add = function(position)
    local battery = sbar.add("item", {
      position = position,
      label = { drawing = false },
      update_freq = 120,
    })

    battery:subscribe("mouse.clicked", function(_)
      sbar.exec("open 'x-apple.systempreferences:com.apple.preference.battery'")
    end)

    battery:subscribe({ "power_source_change", "system_woke" }, function()
      sbar.exec("pmset -g batt", function(batt_info)
        local icon = "!"

        if string.find(batt_info, "AC Power") then
          icon = icons.charging
        else
          local found, _, charge = batt_info:find("(%d+)%%")
          if found then
            charge = tonumber(charge)
          end

          if found and charge > 80 then
            icon = icons._100
          elseif found and charge > 60 then
            icon = icons._75
          elseif found and charge > 40 then
            icon = icons._50
          elseif found and charge > 20 then
            icon = icons._25
          else
            icon = icons._0
          end
        end

        battery:set({ icon = icon })
      end)
    end)
  end

  return self
end

return Battery
