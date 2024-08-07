local symbols = {
  ["battery.100percent"] = "􀛨",
  ["battery.75percent"] = "􀺸",
  ["battery.50percent"] = "􀺶",
  ["battery.25percent"] = "􀛩",
  ["battery.0percent"] = "􀛪",
  ["battery.100percent.bolt"] = "􀢋",
  ["speaker"] = "􀊠",
  ["speaker.slash"] = "􀊢",
  ["speaker.wave.1"] = "􀊤",
  ["speaker.wave.2"] = "􀊦",
  ["speaker.wave.3"] = "􀊨",
  ["moon.fill"] = "􀆺",
  ["person.fill"] = "􀉪",
  ["list.clipboard"] = "􁕜",
  ["bed.double.fill"] = "􀙪",
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
  mission = {
    _dnd = symbols["moon.fill"],
    _personal = symbols["person.fill"],
    _sleep = symbols["bed.double.fill"],
    -- can't find original focus icon, closest seems to be clipboard
    _work = symbols["list.clipboard"],
  },
}
