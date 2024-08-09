local tz = require("tz")

local sbar = require("sketchybar")

local Clock = {}

-- @param icons Plugin specific icons
function Clock.new(icons)
  local self = {}

  local popup_toggle = "sketchybar --set $NAME popup.drawing=toggle"

  self.add = function(position)
    local clock = sbar.add("item", {
      position = position,
      click_script = popup_toggle,
      update_freq = 30,
      icon = icons.clock,
    })

    local guatemala = sbar.add("item", {
      icon = icons.guatemala,
      position = "popup." .. clock.name,
    })
    guatemala:subscribe({ "forced", "routine" }, function(_)
      local time = tz.date("%a %d %b %H:%M", os.time(), "America/Guatemala")
      guatemala:set({ label = time })
    end)
    guatemala:subscribe("mouse.clicked", function(_)
      guatemala:set({ popup = { drawing = false } })
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
    vietnam:subscribe("mouse.clicked", function(_)
      vietnam:set({ popup = { drawing = false } })
    end)

    clock:subscribe({ "forced", "routine", "system_woke" }, function(_)
      clock:set({ label = os.date("%a %d %b %H:%M") })
    end)
  end

  return self
end

return Clock
