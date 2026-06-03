local sbar = require("sketchybar")

local Sessions = {}

-- @param icons Plugin specific icons
-- @param style Plugin specific colors
-- @param sessionizer Instance of Sessionizer service
function Sessions.new(icons, style, sessionizer)
  local self = {}
  local question_session_id = nil -- Track which session has a question

  self.add = function(position)
    local cmd = "/opt/homebrew/bin/sessionizer sessions --json"
    local attached = {}

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
            attached[i] = s.attached
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

            session:set({
              icon = {
                string = icons.tmux,
                color = color,
              },
              label = {
                string = s.name,
                color = color,
                width = s.attached and "dynamic" or 0,
                drawing = true,
              },
              drawing = true,
            })
          else
            attached[i] = false
            session:set({ drawing = false })
          end
        end)
      end

      session:subscribe({ "mouse.clicked" }, function(_)
        sbar.exec("/opt/homebrew/bin/sessionizer sessions --json", function(sessions)
          local s = sessions[i]
          if s ~= nil then
            sessionizer.open(s.name)
          end
        end)
      end)

      session:subscribe("mouse.entered", function(_)
        session:set({ label = { width = "dynamic" } })
      end)

      session:subscribe("mouse.exited", function(_)
        if not attached[i] then
          session:set({ label = { width = 0 } })
        end
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
