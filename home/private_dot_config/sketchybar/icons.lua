local symbols = {
  ["battery.0percent"] = "􀛪",
  ["battery.100percent"] = "􀛨",
  ["battery.100percent.bolt"] = "􀢋",
  ["battery.25percent"] = "􀛩",
  ["battery.50percent"] = "􀺶",
  ["battery.75percent"] = "􀺸",
  ["bed.double.fill"] = "􀙪",
  ["calendar"] = "􀉉",
  ["clock"] = "􀐫",
  ["cloud"] = "􀇂",
  ["cloud.bolt"] = "􀇒",
  ["cloud.bolt.rain"] = "􀇞",
  ["cloud.drizzle"] = "􀇄",
  ["cloud.fill"] = "􀇃",
  ["cloud.fog"] = "􀇊",
  ["cloud.heavyrain"] = "􀇈",
  ["cloud.sleet"] = "􀇐",
  ["cloud.snow"] = "􀇎",
  ["cloud.sun"] = "􀇔",
  ["cloud.sun.rain"] = "􀇖",
  ["ellipsis"] = "􀍠",
  ["folder"] = "􀈕",
  ["heavy.rain"] = "􀇈",
  ["list.clipboard"] = "􁕜",
  ["moon.fill"] = "􀆺",
  ["person.fill"] = "􀉪",
  ["sleet"] = "􀇐",
  ["snowflake"] = "􀇥",
  ["speaker"] = "􀊠",
  ["speaker.slash"] = "􀊢",
  ["speaker.wave.1"] = "􀊤",
  ["speaker.wave.2"] = "􀊦",
  ["speaker.wave.3"] = "􀊨",
  ["sun.max"] = "􀆭",
}

local emojis = {
  ["comet"] = "☄️",
  ["guatemala"] = "🇬🇹",
  ["vietnam"] = "🇻🇳",
}

local nerdfont = {
  ["nf-cod-terminal_tmux"] = "",
  ["nf-oct-dot_fill"] = "",
}

return {
  volume = {
    _100 = symbols["speaker.wave.3"],
    _66 = symbols["speaker.wave.2"],
    _33 = symbols["speaker.wave.1"],
    _10 = symbols["speaker"],
    _0 = symbols["speaker.slash"],
  },
  battery = {
    _100 = symbols["battery.100percent"],
    _75 = symbols["battery.75percent"],
    _50 = symbols["battery.50percent"],
    _25 = symbols["battery.25percent"],
    _0 = symbols["battery.0percent"],
    charging = symbols["battery.100percent.bolt"],
  },
  calendar = {
    default = symbols["calendar"],
  },
  clock = {
    clock = symbols["clock"],
    guatemala = emojis["guatemala"],
    vietnam = emojis["vietnam"],
  },
  sessions = {
    tmux = nerdfont["nf-cod-terminal_tmux"],
  },
  windows = {
    dot = nerdfont["nf-oct-dot_fill"],
  },

  weather = {
    ["cloudy"] = symbols["cloud"],
    ["fog"] = symbols["cloud.fog"],
    ["heavy.rain"] = symbols["cloud.heavyrain"],
    ["heavy.showers"] = symbols["heavy.rain"],
    ["heavy.snow"] = symbols["snowflake"],
    ["heavy.snow.showers"] = symbols["snowflake"],
    ["light.rain"] = symbols["cloud.sun.rain"],
    ["light.showers"] = symbols["cloud.drizzle"],
    ["light.sleet"] = symbols["sleet"],
    ["light.sleet.showers"] = symbols["cloud.sleet"],
    ["light.snow"] = symbols["cloud.snow"],
    ["light.snow.showers"] = symbols["cloud.snow"],
    ["partly.cloudy"] = symbols["cloud.sun"],
    ["sunny"] = symbols["sun.max"],
    ["thunder.heavy.rain"] = symbols["cloud.bolt"],
    ["thunder.snow.showers"] = symbols["cloud.bolt.rain"],
    ["unknown"] = symbols["ellipsis"],
    ["very.cloudy"] = symbols["cloud.fill"],
  },
  project = {
    folder = symbols["folder"],
  },
  mission = {
    _dnd = symbols["moon.fill"],
    _personal = symbols["person.fill"],
    _sleep = symbols["bed.double.fill"],
    -- can't find original focus icon, closest seems to be clipboard
    _work = symbols["list.clipboard"],
  },
}
