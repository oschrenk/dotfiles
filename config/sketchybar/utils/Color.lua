local color = {}

-- Extract RGB components from ARGB hex value
local function extract_rgb(argb)
  local r = math.floor(argb / 0x10000) % 0x100
  local g = math.floor(argb / 0x100) % 0x100
  local b = argb % 0x100
  return r, g, b
end

-- Linearly interpolate between two values
local function lerp(a, b, t)
  return a + (b - a) * t
end

-- Interpolate between two colors
local function interpolate_colors(color1, color2, t)
  local r1, g1, b1 = extract_rgb(color1)
  local r2, g2, b2 = extract_rgb(color2)

  local r = math.floor(lerp(r1, r2, t))
  local g = math.floor(lerp(g1, g2, t))
  local b = math.floor(lerp(b1, b2, t))

  return 0xff000000 + r * 0x10000 + g * 0x100 + b
end

-- Map a percentage (0-1) to a red-yellow-green spectrum
-- Returns color in ARGB format (0xff000000 = black, 0xffffffff = white)
color.progress_to_spectrum = function(percentage)
  local red = 0xffe85841
  local yellow = 0xfff1bf4f
  local green = 0xffb9bb46

  -- Clamp to 0-1
  percentage = math.max(0, math.min(1, percentage))

  if percentage <= 0.5 then
    -- Interpolate between red and yellow (0 to 0.5)
    local t = percentage / 0.5
    return interpolate_colors(red, yellow, t)
  else
    -- Interpolate between yellow and green (0.5 to 1)
    local t = (percentage - 0.5) / 0.5
    return interpolate_colors(yellow, green, t)
  end
end

return color
