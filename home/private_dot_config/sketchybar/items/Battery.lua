-- Battery indicator using BatteryMono.ttf (per-percent glyphs).
--
-- Glyph map:
--   U+F000 + pct  →  battery at exact charge level (pct = 0..100)
--   U+F065        →  100% battery with charging bolt

local sbar = require("sketchybar")

local FONT_FAMILY = "BatteryMono"
local FONT_STYLE = "Regular"
local FONT_SIZE = 24.0

local function pct_to_glyph(pct)
  pct = math.max(0, math.min(101, math.floor(pct)))
  return utf8.char(0xF000 + pct)
end

local CHARGING_GLYPH = pct_to_glyph(101) -- U+F065

local Battery = {}

function Battery.new()
  local self = {}

  self.add = function(position)
    local battery = sbar.add("item", {
      position = position,
      label = {
        drawing = false,
      },
      icon = {
        font = { family = FONT_FAMILY, style = FONT_STYLE, size = FONT_SIZE },
        color = 0xffe8dcb7, -- palette.white
        string = pct_to_glyph(0),
      },
      update_freq = 120,
    })

    battery:subscribe("mouse.clicked", function(_)
      sbar.exec("open 'x-apple.systempreferences:com.apple.preference.battery'")
    end)

    battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
      sbar.exec("pmset -g batt", function(batt_info)
        local charging = string.find(batt_info, "AC Power") ~= nil
        local _, _, charge_str = batt_info:find("(%d+)%%")
        local pct = charge_str and tonumber(charge_str) or 0

        local glyph = charging and CHARGING_GLYPH or pct_to_glyph(pct)

        battery:set({ icon = { string = glyph } })
      end)
    end)
  end

  return self
end

return Battery
