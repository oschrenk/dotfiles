local symbols = {
  ["battery.100percent"] = "􀛨",
  ["battery.75percent"] = "􀺸",
  ["battery.50percent"] = "􀺶",
  ["battery.25percent"] = "􀛩",
  ["battery.0percent"] = "􀛪",
  ["battery.100percent.bolt"] = "􀢋",
}

return {
  loading = "􀖇",
  apple = "􀣺",
  preferences = "􀺽",

  volume = {
    _100 = "􀊩",
    _66 = "􀊧",
    _33 = "􀊥",
    _10 = "􀊡",
    _0 = "􀊣",
  },
  battery = {
    _100 = symbols["battery.100percent"],
    _75 = symbols["battery.75percent"],
    _50 = symbols["battery.50percent"],
    _25 = symbols["battery.25percent"],
    _0 = symbols["battery.0percent"],
    charging = symbols["battery.100percent.bolt"],
  },
  mission = {
    _dnd = "􀟈",
    _personal = "􀉪",
    _sleep = "􀙪",
    _work = "􁕝",
  },
}
