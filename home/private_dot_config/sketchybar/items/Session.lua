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

    session:subscribe({ "forced", "routine", "system_woke" }, function(_)
      session:set({ label = "some session" })
    end)
  end

  return self
end

return Session
