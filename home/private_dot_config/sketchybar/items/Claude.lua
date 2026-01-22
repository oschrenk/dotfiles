local sbar = require("sketchybar")

local Claude = {}

local function format_tokens(n)
  if n >= 1000000 then
    return string.format("%.1fM", n / 1000000)
  elseif n >= 1000 then
    return string.format("%.1fk", n / 1000)
  else
    return tostring(n)
  end
end

-- @param claude Claude service
function Claude.new(claude)
  local self = {}
  self.input = nil
  self.output = nil

  local callback = function(totals)
    self.input:set({
      label = { string = format_tokens(totals.inputTokens or 0) },
    })
    self.output:set({
      label = { string = format_tokens(totals.outputTokens or 0) },
    })
  end

  self.add = function(position, width)
    local itemWidth = width and (width / 2) or nil

    self.input = sbar.add("item", {
      position = position,
      width = itemWidth,
      icon = { string = "􂨨", y_offset = 1, width = 22 },
      label = { string = "0" },
    })

    self.output = sbar.add("item", {
      position = position,
      width = itemWidth,
      icon = { string = "􂨧", y_offset = 1, width = 22, align = "center" },
      label = { string = "0" },
    })

    self.output:subscribe({ "routine", "forced", "system_woke", "tmux_sessions_update", "ai_agent_done" }, function(_)
      claude.usage(callback)
    end)
  end

  return self
end

return Claude
