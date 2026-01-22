local color = require("utils.Color")
local sbar = require("sketchybar")

local Comodoro = {}

local COLOR_WHITE = 0xffe8dcb7

-- @param comodoro Comodoro service
-- @param style Plugin specific icons
--
-- We support a maximum of 10 pomodoros per day
-- That way this widget can be done statically, assuming
-- a fixed number of elements instead of dynamically resizing
function Comodoro.new(comodoro, style)
  local self = {}

  self.clock = nil

  local callback = function(state)
    if state == nil then
    else
      local iconColor
      if state.state == "stopped" then
        iconColor = COLOR_WHITE
      else
        iconColor = color.progress_to_spectrum(state.percentage)
      end
      self.clock:set({
        label = { string = state.time },
        icon = { color = iconColor },
      })
    end
  end

  self.add = function(position, width)
    self.clock = sbar.add("item", {
      position = "center",
      width = width,
      update_freq = 1,
      icon = {
        string = "􀧷",
        y_offset = 1,
        padding_right = -10,
      },
      label = {
        align = "center",
        string = "00:00",
      },
    })

    self.clock:subscribe({ "routine", "forced", "comodoro_hook" }, function(env)
      comodoro.status(callback)
    end)

    self.clock:subscribe("mouse.clicked", function(env)
      if env.BUTTON == "right" then
        comodoro.stop()
      elseif env.MODIFIER == "cmd" then
        comodoro.start()
      else
        comodoro.toggle()
      end
    end)
  end

  return self
end

return Comodoro
