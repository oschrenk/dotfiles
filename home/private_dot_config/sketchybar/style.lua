local palette = {
  black = 0xff000000,
  blue = 0xff8aa499,
  green = 0xffb9bb46,
  grey = 0xff484848,
  red = 0xffe85841,
  white = 0xffe8dcb7,
  yellow = 0xfff1bf4f,
}

return {
  palette = palette,
  bar = {
    margin = 0,
    color = palette.black,
    -- notch heights:
    -- Macbook 14 (M1)
    --   1024x 665          : 22
    --   1147x 745          : 24
    --   1352x 878          : 29
    --   1512x 982 (default): 32
    --   1800x1169          : 38
    -- Macbook 16 (M2)
    --   1168x 756          : 22
    --   1312x 848          : 24
    --   1497x 976          : 28
    --   1728x1117 (default): 32
    --   2056x1329          : 38
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
  default = {
    icon = {
      font = {
        -- brew install oschrenk/casks/font-sf-mono-nerd-font
        family = "SFMono Nerd Font",
        style = "Medium",
        size = 15.0,
      },
      color = palette.white,
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
      color = palette.white,
      padding_left = 2,
      padding_right = 2,
      y_offset = 0,
    },
    background = {
      color = palette.black,
      corner_radius = 5,
    },
    graph = {
      color = palette.white,
      fill_color = palette.white,
      line_width = 0.5,
    },
  },
  sessions = {
    active = palette.white,
    inactive = palette.grey,
  },
  windows = {
    active = palette.white,
    inactive = palette.grey,
  },
  workspaces = {
    active = palette.white,
    inactive = palette.grey,
  },
  pomodoro = {
    active = palette.white,
    done = palette.green,
    inactive = palette.grey,
    paused = palette.yellow,
  },
}
