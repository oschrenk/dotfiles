local tz = require("tz")

local sbar = require("sketchybar")

local Clock = {}

-- @param icons Plugin specific icons
function Clock.new(icons)
  local self = {}
  local clocks = {}
  local fmt <const> = "%a %d %b %H:%M"
  local GT <const> = "guatemala"
  local VN <const> = "vietnam"

  local updateClocks = function()
    local now = os.time()

    clocks[GT]:set({ label = tz.date(fmt, now, "America/Guatemala") })
    clocks[VN]:set({ label = tz.date(fmt, now, "Asia/Ho_Chi_Minh") })
  end

  self.add = function(position)
    local clock = sbar.add("item", {
      position = position,
      update_freq = 30,
      icon = icons.clock,
      background = {
        padding_left = 5,
        -- avoid being under macOS's screen/audio recording bubble
        -- or YellowDot app's bubble
        -- since the clock is the most right, add some padding right
        padding_right = 2,
      },
    })

    clock:subscribe("mouse.entered", function(_)
      updateClocks()
      clock:set({ popup = { drawing = true } })
    end)
    clock:subscribe("mouse.exited", function(_)
      clock:set({ popup = { drawing = false } })
    end)

    clocks[GT] = sbar.add("item", {
      icon = icons.guatemala,
      position = "popup." .. clock.name,
    })

    clocks[VN] = sbar.add("item", {
      icon = icons.vietnam,
      position = "popup." .. clock.name,
    })

    clock:subscribe({ "forced", "routine", "system_woke" }, function(_)
      clock:set({ label = os.date("%a %d %b %H:%M") })
    end)
  end

  return self
end

return Clock
