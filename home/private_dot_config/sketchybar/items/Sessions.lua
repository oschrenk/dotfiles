local sbar = require("sketchybar")

local Session = {}

-- @param icons Plugin specific icons
function Session.new(icons)
  local self = {}

  self.add = function(position)
    local session = sbar.add("item", {
      position = position,
      update_freq = 60,
      icon = icons.tmux,
    })

    local update = function()
      local cmd = '/opt/homebrew/bin/sessionizer sessions --json | jq -r ".[] | select(.attached==true) | .name"'

      sbar.exec(cmd, function(name)
        session:set({ label = name })
      end)
    end

    session:subscribe({ "forced", "routine", "system_woke" }, function(_)
      update()
    end)
  end

  return self
end

return Session
