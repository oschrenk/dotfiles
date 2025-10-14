local sbar = require("sketchybar")

local Sessions = {}

-- @param icons Plugin specific icons
-- @param style Plugin specific icons
function Sessions.new(icons, style)
  local self = {}

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
            if s.attached then
              session:set({
                icon = {
                  string = icons.tmux,
                  color = style.active,
                },
                label = {
                  string = s.name,
                  drawing = true,
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

      session:subscribe({ "forced", "routine", "system_woke", "tmux_sessions_update" }, function(_)
        update()
      end)
    end
  end

  return self
end

return Sessions
