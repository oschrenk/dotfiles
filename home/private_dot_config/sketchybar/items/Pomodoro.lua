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

  local drawBox = function(color, position)
    sbar.add("item", {
      position = position,
      icon = {
        drawing = false,
      },
      background = {
        color = color,
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
  end

  self.add = function(position)
    drawBox(style.inactive, "q")
    drawBox(style.inactive, "q")
    drawBox(style.inactive, "q")
    local spacer = sbar.add("item", {
      position = position,
      width = 184,
      popup = {
        y_offset = -8,
        align = "center",
        blur_radius = 10,
      },
    })
    drawBox(style.inactive, "e")
    drawBox(style.inactive, "e")
    drawBox(style.inactive, "e")

    local clock = sbar.add("item", {
      position = "popup." .. spacer.name,
      width = 184,
      icon = { drawing = icons.default },
      label = {
        width = 184,
        align = "center",
        string = format(self.tick),
      },
      background = {
        height = 40,
        corner_radius = 8,
      },
    })

    clock:subscribe({ "routine" }, function()
      if self.running == true then
        self.tick = self.tick + 1
        clock:set({ label = { string = format(self.tick) } })
      end
    end)

    spacer:subscribe("mouse.entered", function(_)
      spacer:set({ popup = { drawing = true } })
    end)
    spacer:subscribe("mouse.exited", function(_)
      spacer:set({ popup = { drawing = false } })
    end)
  end

  return self
end

return Pomodoro
