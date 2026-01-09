local sbar = require("sketchybar")

local Windows = {}

-- @param icons Plugin specific icons
-- @param style Plugin specific icons
function Windows.new(icons, style)
  local self = {}
  local question_window_id = nil -- Track which window has a question

  self.add = function(position)
    local cmd = "/opt/homebrew/bin/sessionizer windows --json"

    -- support fixed amount of windows
    for i = 1, 5, 1 do
      local window = sbar.add("item", {
        position = position,
        update_freq = 60,
        icon = icons.dot,
      })

      local update = function()
        sbar.exec(cmd, function(windows)
          local w = windows[i]
          if w ~= nil then
            -- Determine the color based on state
            local color = style.inactive
            if w.id == question_window_id then
              color = 0xFFFF9500 -- Orange for question state
            elseif w.active then
              color = style.active
            end

            if w.active_clients > 0 or w.id == question_window_id then
              window:set({
                icon = {
                  string = icons.dot,
                  color = color,
                },
                label = {
                  drawing = false,
                },
                drawing = true,
              })
            else
              window:set({
                icon = {
                  string = icons.dot,
                  color = style.inactive,
                },
                label = {
                  drawing = false,
                },
                drawing = true,
              })
            end
          else
            window:set({ drawing = false })
          end
        end)
      end

      window:subscribe({
        "forced",
        "routine",
        "system_woke",
        "tmux_sessions_update",
        "tmux_windows_update",
        "ai_agent_waiting",
        "ai_agent_done",
      }, function(env)
        if env.SENDER == "ai_agent_waiting" and env.WINDOW_ID then
          question_window_id = env.WINDOW_ID
        elseif env.SENDER == "ai_agent_done" then
          question_window_id = nil
        end
        update()
      end)
    end
  end

  return self
end

return Windows
