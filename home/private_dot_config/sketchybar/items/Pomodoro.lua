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

  local drawBox = function(value, color, position)
    sbar.add("item", {
      position = position,
      label = {
        font = {
          family = "pomodoro",
          style = "Regular",
        },
        color = color,
        string = value,
      },
      icon = { drawing = false },
      background = {
        padding_left = 0,
        padding_right = 0,
      },
    })
  end

  self.add = function(position)
    drawBox("2", style.done, "q")
    drawBox("1", style.done, "q")
    local spacer = sbar.add("item", {
      position = position,
      width = 184,
      popup = {
        y_offset = -8,
        align = "center",
        blur_radius = 10,
      },
    })
    drawBox("2", style.active, "e")
    drawBox("2", style.inactive, "e")
    drawBox("1", style.inactive, "e")

    local clock = sbar.add("item", {
      position = "popup." .. spacer.name,
      width = 184,
      icon = {
        font = {
          family = "pomodoro",
          style = "Regular",
          size = 15.0,
        },
        string = "1",
      },
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
