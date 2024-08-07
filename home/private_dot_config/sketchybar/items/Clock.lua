local sbar = require("sketchybar")

local Clock = {}

-- @param icons Plugin specific icons
function Clock.new(icons)
  local self = {}

  self.add = function(position)
    local clock = sbar.add("item", {
      position = position,
      update_freq = 30,
      icon = icons.clock,
      label = {
        align = "right",
      },
    })

    clock:subscribe({ "forced", "routine", "power_source_change", "system_woke" }, function(_)
      clock:set({ label = os.date("%a %d %b %H:%M") })
    end)
  end

  return self
end

return Clock
