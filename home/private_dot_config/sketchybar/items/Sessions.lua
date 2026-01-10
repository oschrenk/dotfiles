local sbar = require("sketchybar")

local Sessions = {}

-- @param icons Plugin specific icons
-- @param style Plugin specific colors
function Sessions.new(icons, style)
  local self = {}
  local question_session_id = nil -- Track which session has a question

  self.add = function(position)
    local cmd = "/opt/homebrew/bin/sessionizer sessions --json"

    -- support fixed amount of sessions
    for i = 1, 5, 1 do
      local session = sbar.add("item", {
        position = position,
        update_freq = 60,
        icon = icons.tmux,
      })

      local update = function()
        sbar.exec(cmd, function(sessions)
          local s = sessions[i]
          if s ~= nil then
            -- Determine the color based on state
            local color = style.inactive
            if s.id == question_session_id then
              -- Orange for question state
              if s.attached then
                color = 0xFFFF9500 -- Full orange for active session
              else
                color = 0xFFCC7700 -- Dimmer orange for inactive session
              end
            elseif s.attached then
              color = style.active
            end

            if s.attached or s.id == question_session_id then
              session:set({
                icon = {
                  string = icons.tmux,
                  color = color,
                },
                label = {
                  string = s.name,
                  color = color, -- Apply the same color to the label
                  drawing = s.attached, -- Only show label for attached sessions
                },
                drawing = true,
              })
            else
              session:set({
                icon = {
                  string = icons.tmux,
                  color = style.inactive,
                },
                label = {
                  drawing = false,
                },
                drawing = true,
              })
            end
          else
            session:set({ drawing = false })
          end
        end)
      end

      session:subscribe({ "mouse.clicked" }, function(_)
        sbar.exec("open -b com.mitchellh.ghostty")
      end)

      session:subscribe({
        "forced",
        "routine",
        "system_woke",
        "tmux_sessions_update",
        "ai_agent_waiting",
        "ai_agent_done",
      }, function(env)
        if env.SENDER == "ai_agent_waiting" and env.SESSION_ID then
          question_session_id = env.SESSION_ID
        elseif env.SENDER == "ai_agent_done" then
          question_session_id = nil
        end
        update()
      end)
    end
  end

  return self
end

return Sessions
