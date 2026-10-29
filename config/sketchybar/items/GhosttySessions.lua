local sbar = require("sketchybar")

local GhosttySessions = {}

-- running() check: addressing a closed Ghostty would launch it
local POLL <const> = [[osascript -l JavaScript -e 'const g = Application("Ghostty"); if (!g.running()) JSON.stringify({windows: []}); else { const f = g.frontWindow.id(); JSON.stringify({windows: g.windows().map(w => ({id: w.id(), title: w.name(), focused: g.frontmost() && w.id() === f, tabs: w.tabs().map(t => ({id: t.id(), index: t.index(), title: t.name(), selected: t.selected()}))}))}) }']]

-- One item per Ghostty window, then one dot per tab of the focused window,
-- fed by the ghostty_tabs_update event payload.
-- @param icons Plugin specific icons
-- @param style Plugin specific colors
-- @param tabIcons Icons for the tab dots
-- @param tabStyle Colors for the tab dots
function GhosttySessions.new(icons, style, tabIcons, tabStyle)
  local self = {}

  self.add = function(position, display)
    local items = {}
    local focused = {}
    local order = {} -- window ids in first-seen order

    -- support fixed amount of windows
    for i = 1, 7, 1 do
      local item = sbar.add("item", {
        position = position,
        display = display,
        icon = { string = icons.ghostty, color = style.inactive },
        drawing = false,
      })
      items[i] = item

      item:subscribe("mouse.entered", function(_)
        sbar.animate("tanh", 30, function()
          item:set({ label = { width = "dynamic" } })
        end)
      end)

      item:subscribe("mouse.clicked", function(_)
        if order[i] ~= nil then
          sbar.exec(
            "osascript -e 'tell application \"Ghostty\" to activate window (first window whose id is \""
              .. order[i]
              .. "\")'"
          )
        end
      end)

      item:subscribe("mouse.exited", function(_)
        if not focused[i] then
          sbar.animate("tanh", 30, function()
            item:set({ label = { width = 0 } })
          end)
        end
      end)
    end

    local dots = {}
    local selected = {}
    for i = 1, 7, 1 do
      local dot = sbar.add("item", {
        position = position,
        display = display,
        icon = { string = tabIcons.dot, color = tabStyle.inactive },
        label = { width = 0 },
        drawing = false,
      })
      dots[i] = dot

      dot:subscribe("mouse.entered", function(_)
        sbar.animate("tanh", 30, function()
          dot:set({ label = { width = "dynamic" } })
        end)
      end)

      dot:subscribe("mouse.exited", function(_)
        if not selected[i] then
          sbar.animate("tanh", 30, function()
            dot:set({ label = { width = 0 } })
          end)
        end
      end)
    end

    local render = function(list)
      local byId = {}
      for _, w in ipairs(list) do
        byId[w.id] = w
      end
      -- Ghostty lists windows front to back; keep first-seen order so slots don't jump on focus
      local kept = {}
      for _, id in ipairs(order) do
        if byId[id] then
          table.insert(kept, id)
          byId[id].seen = true
        end
      end
      for _, w in ipairs(list) do
        if not w.seen then
          table.insert(kept, w.id)
        end
      end
      order = kept
      local windows = {}
      for _, id in ipairs(order) do
        table.insert(windows, byId[id])
      end
      for i, item in ipairs(items) do
        local w = windows[i]
        if w ~= nil then
          focused[i] = w.focused
          local color = w.focused and style.active or style.inactive
          item:set({
            icon = { color = color },
            label = {
              string = w.title,
              color = color,
              width = w.focused and "dynamic" or 0,
            },
            drawing = true,
          })
        else
          focused[i] = false
          item:set({ drawing = false })
        end
      end

      local tabs = {}
      for _, w in ipairs(windows) do
        if w.focused then
          tabs = w.tabs or {}
        end
      end
      for i, dot in ipairs(dots) do
        local t = tabs[i]
        if t ~= nil then
          selected[i] = t.selected
          local color = t.selected and tabStyle.active or tabStyle.inactive
          dot:set({
            icon = { color = color },
            label = { string = t.title, color = color, width = t.selected and "dynamic" or 0 },
            drawing = true,
          })
        else
          selected[i] = false
          dot:set({ drawing = false })
        end
      end
    end

    items[1]:subscribe("ghostty_tabs_update", function(env)
      render(type(env.INFO) == "table" and env.INFO.windows or {})
    end)

    items[1]:set({ update_freq = 60 })
    items[1]:subscribe({ "forced", "routine", "system_woke" }, function(_)
      sbar.exec(POLL, function(result)
        render(type(result) == "table" and result.windows or {})
      end)
    end)
  end

  return self
end

return GhosttySessions
