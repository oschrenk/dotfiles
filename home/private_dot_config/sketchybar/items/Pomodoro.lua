local sbar = require("sketchybar")

local Pomodoro = {}

-- @param icons Plugin specific icons
-- @param style Plugin specific icons
function Pomodoro.new(icons, style)
  local self = {}

  local secondsPerTick = 1
  local secondsMax = 25 * 60

  self.running = false
  self.tick = 0

  local format = function(tick)
    local secondsGone = tick * secondsPerTick
    local totalSecondsLeft = secondsMax - secondsGone
    local minutesLeft = math.floor(totalSecondsLeft / 60)
    local secondsLeft = totalSecondsLeft % 60

    return string.format("%02d:%02d", minutesLeft, secondsLeft)
  end

  self.add = function(position)
    local icon = sbar.add("item", {
      position = position,
      label = { drawing = false },
      icon = icons.default,
    })
    local clock = sbar.add("item", {
      position = position,
      icon = { drawing = false },
      label = {
        string = format(self.tick),
        padding_left = 0,
        padding_right = 3,
      },
      update_freq = secondsPerTick,
    })
    sbar.add("item", {
      position = position,
      icon = {
        drawing = false,
      },
      background = {
        color = style.inactive,
        corner_radius = 8,
        height = 14,
        padding_left = 3,
        padding_right = 3,
      },
      label = {
        padding_left = 4,
        padding_right = 4,
        font = {
          size = 12.0,
        },
      },
    })

    sbar.add("item", {
      position = position,
      icon = {
        drawing = false,
      },
      background = {
        color = style.inactive,
        corner_radius = 8,
        height = 14,
        padding_left = 3,
        padding_right = 3,
      },
      label = {
        padding_left = 4,
        padding_right = 4,
        font = {
          size = 12.0,
        },
      },
    })

    clock:subscribe("mouse.clicked", function(_)
      if self.running ~= true then
        self.running = true
        clock:set({ update_freq = secondsPerTick })
      else
        self.running = false
        clock:set({ update_freq = 0 })
      end
    end)

    clock:subscribe({ "routine" }, function()
      if self.running == true then
        self.tick = self.tick + 1
        clock:set({ label = { string = format(self.tick) } })
      end
    end)
  end

  return self
end

return Pomodoro
