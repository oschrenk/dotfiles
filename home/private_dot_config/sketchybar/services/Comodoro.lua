local sbar = require("sketchybar")
local time = require("utils.Time")

local Comodoro = {}

local STATE_PAUSED = "paused"
local STATE_RUNNING = "running"
local STATE_STOPPED = "stopped"

-- requires currently https://github.com/pimalaya/comodoro
-- to investigate requirements
function Comodoro.new()
  local self = {}

  -- find first  duration from config matching current cycle
  local function get_max_cycle_duration(json)
    for _, cycle in ipairs(json.config.cycles) do
      if cycle.name == json.cycle.name then
        return cycle.duration
      end
    end
    return nil
  end

  -- percentage of current/max (returns value between 0 and 1)
  local function calculate_percentage(current, max)
    if max == nil or max == 0 then
      return 0
    end
    return current / max
  end

  self.status = function(callback)
    sbar.exec("/Users/oliver/.local/share/cargo/bin/comodoro get --json", function(json)
      if json.state == STATE_STOPPED then
        local firstCycleDuration = json.config.cycles[1].duration
        local state = {
          state = json.state,
          time = time.format_seconds(firstCycleDuration),
          percentage = 0,
        }
        callback(state)
      else
        local max = get_max_cycle_duration(json)
        local current = json.cycle.duration

        local state = {
          state = json.state,
          time = time.format_seconds(current),
          percentage = calculate_percentage(current, max),
        }

        callback(state)
      end
    end)
  end

  self.toggle = function()
    sbar.exec("/Users/oliver/.local/share/cargo/bin/comodoro get --json", function(json)
      if json.state == STATE_STOPPED then
        sbar.exec("/Users/oliver/.local/share/cargo/bin/comodoro start")
      elseif json.state == STATE_PAUSED then
        sbar.exec("/Users/oliver/.local/share/cargo/bin/comodoro resume")
      elseif json.state == STATE_RUNNING then
        sbar.exec("/Users/oliver/.local/share/cargo/bin/comodoro pause")
      end
      sbar.trigger("comodoro_hook")
    end)
  end

  self.start = function()
    sbar.exec("/Users/oliver/.local/share/cargo/bin/comodoro start")
    sbar.trigger("comodoro_hook")
  end

  self.stop = function()
    sbar.exec("/Users/oliver/.local/share/cargo/bin/comodoro stop")
    sbar.trigger("comodoro_hook")
  end

  return self
end

return Comodoro
