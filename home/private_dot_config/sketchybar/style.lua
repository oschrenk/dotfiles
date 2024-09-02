local black = 0xff000000
local white = 0xffcad3f5
local grey = 0xff484848

return {
  background = {
    color = black,
    corner_radius = 5,
  },
  bar = {
    margin = 0,
    color = black,
    -- notch heights:
    -- Mac 14.9
    --   1024x 665          : 22
    --   1147x 745          : 24
    --   1352x 878          : 29
    --   1512x 982 (default): 32
    --   1800x1169          : 38
    height = 32,
    sticky = true,
    padding_left = 16,
    padding_right = 16,
    notch_width = 188,
    font_smoothing = true,
    shadow = false,
    topmost = "window",
    -- main, all, <positive_integer list>
    display = "all",
  },
  icon = {
    font = {
      -- brew install oschrenk/casks/font-sf-mono-nerd-font
      family = "SFMono Nerd Font",
      style = "Medium",
      size = 15.0,
    },
    color = white,
    width = 30,
    align = "center",
    padding_left = 2,
    padding_right = 2,
    y_offset = 0,
  },
  label = {
    font = {
      -- brew install font-sf-pro
      family = "SF Pro",
      style = "Regular",
      size = 14.0,
    },
    color = white,
    padding_left = 3,
    padding_right = 3,
    y_offset = 0,
  },
  sessions = {
    active = white,
    inactive = grey,
  },
  windows = {
    active = white,
    inactive = grey,
  },
  workspaces = {
    active = white,
    inactive = grey,
  },
}
