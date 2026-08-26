local sbar = require("sketchybar")

local Spacer = {}

-- @param width Width of spacer
function Spacer.new(width)
  local self = {}

  self.add = function(position)
    sbar.add("item", {
      position = position,
      width = width,
      label = { drawing = false },
      icon = { drawing = false },
    })
  end

  return self
end

return Spacer
