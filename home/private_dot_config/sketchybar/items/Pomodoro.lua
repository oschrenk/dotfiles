local sbar = require("sketchybar")

local Pomodoro = {}

-- @param pomodoro Pomodoro service
-- @param style Plugin specific icons
--
-- We support a maximum of 10 pomodoros per day
-- That way this widget can be done statically, assuming
-- a fixed number of elements instead of dynamically resizing
function Pomodoro.new(pomodoro, style)
  local self = {}

  self.clock = nil
  self.done = {}
  self.left = {}

  local createCounter = function(initialValue, color, position)
    return sbar.add("item", {
      position = position,
      label = {
        font = {
          family = "pomodoro",
          style = "Regular",
        },
        color = color,
        string = initialValue,
      },
      icon = { drawing = false },
      background = {
        padding_left = 0,
        padding_right = 0,
      },
    })
  end

  local createMap = function(count)
    local m = {}
    local c = math.floor(count / 2)
    for i = 1, c do
      m[i] = "2"
    end
    if count % 2 == 1 then
      m[c + 1] = "1"
    end

    return m
  end

  local callback = function(state)
    if state == nil then
      self.left[1]:set({ label = { color = style.inactive } })
    else
      for i, v in ipairs(createMap(state.done)) do
        self.done[i]:set({ label = { string = v } })
      end

      for i, v in ipairs(createMap(state.left)) do
        self.left[i]:set({ label = { string = v } })
      end

      if state.time ~= "00:00" then
        self.left[1]:set({ label = { color = style.active } })
      else
        self.left[1]:set({ label = { color = style.inactive } })
      end
      self.clock:set({ label = { string = state.time } })
    end
  end

  self.add = function(position)
    for i = 1, 5 do
      self.done[i] = createCounter(" ", style.done, "q")
    end

    local spacer = sbar.add("item", {
      position = position,
      width = 184,
      popup = {
        y_offset = -8,
        align = "center",
        blur_radius = 10,
      },
      update_freq = 30,
    })

    for i = 1, 5 do
      self.left[i] = createCounter(" ", style.inactive, "e")
    end

    self.clock = sbar.add("item", {
      position = "popup." .. spacer.name,
      width = 120,
      icon = {
        drawing = false,
      },
      label = {
        font = {
          size = 20.0,
        },
        width = 120,
        align = "center",
        string = "00:00",
        y_offset = -5,
      },
      background = {
        height = 44,
        corner_radius = 12,
      },
    })

    spacer:subscribe({ "routine", "forced", "pomodoro" }, function(env)
      print(env.pomodoro_event)
      pomodoro.status(callback)
    end)

    spacer:subscribe("mouse.entered", function(_)
      pomodoro.status(callback)
      spacer:set({ popup = { drawing = true } })
    end)
    self.clock:subscribe("mouse.exited", function(_)
      spacer:set({ popup = { drawing = false } })
    end)
  end

  return self
end

return Pomodoro
