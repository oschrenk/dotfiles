local sbar = require("sketchybar")

local Windows = {}

-- @param icons Plugin specific icons
-- @param style Plugin specific icons
function Windows.new(icons, style)
  local self = {}

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
            if w.active_clients > 0 then
              if w.active then
                window:set({
                  icon = {
                    color = style.active,
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

      window:subscribe(
        { "forced", "routine", "system_woke", "tmux_sessions_update", "tmux_windows_update" },
        function(_)
          update()
        end
      )
    end
  end

  return self
end

return Windows
