local sbar = require("sketchybar")

local Pomodoro = {}

-- requires currently https://github.com/open-pomodoro/openpomodoro-cli
-- to investigate requirements
function Pomodoro.new()
  local self = {}

  self.status = function(callback)
    sbar.exec('/Users/oliver/Frameworks/go/bin/pomodoro status -f "%r %c/%g"', function(raw)
      -- clean up multiline output
      raw = raw:gsub("%s+", "")
      if raw == "" or raw == nil then
        callback(nil)
      else
        local minutes, seconds, done, goal = string.match(raw, "(%d+):(%d+) (%d+)/(%d+)")

        local state = {
          state = "unknown",
          time = string.format("%02d:%02d", minutes, seconds),
          done = done,
          left = goal - done,
          goal = goal,
        }

        callback(state)
      end
    end)
  end

  return self
end

return Pomodoro
