require("utils.Strings")
local sbar = require("sketchybar")

local MenuItem = {}

-- Requirements:
-- 1. Have Icon in Menu Bar
-- 2. Give screen recording permission to sketchybar
--
-- Re 1) Open Control Center > Menu Bar only > Show Weather in menubar
-- Re 2) Using a menubar alias requires sketchybar to have screen recording permission
-- Which means that a permanent indicator is shown
-- This can be mitigiated by installing
-- `brew install yellowdot`
-- It can technically also be removed but requires SIP removal
--
-- @param style color palette
-- @param table with name, cmd, update_freq, padding_right
function MenuItem.new(style, item)
  local self = {}

  self.add = function(position)
    local weather = sbar.add("alias", item.name, {
      position = position,
      update_freq = item.update_freq,
      alias = {
        color = style.palette.white,
      },
      icon = { drawing = false },
      label = { drawing = false },
      background = {
        padding_right = item.padding_right,
      },
    })
    if item.cmd ~= nil then
      weather:subscribe("mouse.clicked", function(_)
        sbar.exec(item.cmd)
      end)
    end
  end

  return self
end

return MenuItem
