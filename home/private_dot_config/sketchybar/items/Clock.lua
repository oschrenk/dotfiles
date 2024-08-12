local tz = require("tz")

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
    })

    clock:subscribe("mouse.entered", function(_)
      clock:set({ popup = { drawing = true } })
    end)
    clock:subscribe("mouse.exited", function(_)
      clock:set({ popup = { drawing = false } })
    end)

    local guatemala = sbar.add("item", {
      icon = icons.guatemala,
      position = "popup." .. clock.name,
    })
    guatemala:subscribe({ "forced", "routine" }, function(_)
      local time = tz.date("%a %d %b %H:%M", os.time(), "America/Guatemala")
      guatemala:set({ label = time })
    end)

    local vietnam = sbar.add("item", {
      position = "popup." .. clock.name,
      icon = icons.vietnam,
      label = "Vietnam",
    })
    vietnam:subscribe({ "forced", "routine" }, function(_)
      local time = tz.date("%a %d %b %H:%M", os.time(), "Asia/Ho_Chi_Minh")
      vietnam:set({ label = time })
    end)

    clock:subscribe({ "forced", "routine", "system_woke" }, function(_)
      clock:set({ label = os.date("%a %d %b %H:%M") })
    end)
  end

  return self
end

return Clock
