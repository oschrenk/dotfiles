local sbar = require("sketchybar")

local RexSessions = {}

local REX <const> = os.getenv("HOME")
  .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"

local show = function(args)
  sbar.exec("'" .. REX .. "' do session.select " .. args .. " && open -b com.superlogical.rex")
end

-- One item per Rex session, then one dot per tab of the visible session,
-- fed by the rex_update event payload.
-- @param icons Plugin specific icons
-- @param style Plugin specific colors
-- @param tabIcons Icons for the tab dots
-- @param tabStyle Colors for the tab dots
function RexSessions.new(icons, style, tabIcons, tabStyle)
  local self = {}

  self.add = function(position, display)
    local items = {}
    local visible = {}
    local sessionIds = {}
    local tabIds = {}
    local shownId

    -- support fixed amount of sessions
    for i = 1, 7, 1 do
      local item = sbar.add("item", {
        position = position,
        display = display,
        icon = { string = icons.ghostty, color = style.inactive },
        label = { width = 0 },
        drawing = false,
      })
      items[i] = item

      item:subscribe("mouse.entered", function(_)
        sbar.animate("tanh", 30, function()
          item:set({ label = { width = "dynamic" } })
        end)
      end)

      item:subscribe("mouse.clicked", function(_)
        if sessionIds[i] ~= nil then
          show("session_id=" .. sessionIds[i])
        end
      end)

      item:subscribe("mouse.exited", function(_)
        if not visible[i] then
          sbar.animate("tanh", 30, function()
            item:set({ label = { width = 0 } })
          end)
        end
      end)
    end

    local dots = {}
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

      dot:subscribe("mouse.clicked", function(_)
        if tabIds[i] ~= nil then
          show("session_id=" .. shownId .. " window_id=" .. tabIds[i])
        end
      end)

      dot:subscribe("mouse.exited", function(_)
        sbar.animate("tanh", 30, function()
          dot:set({ label = { width = 0 } })
        end)
      end)
    end

    items[1]:subscribe("rex_update", function(env)
      local state = type(env.INFO) == "table" and env.INFO or {}
      local sessions = state.sessions or {}

      local shown
      for i, item in ipairs(items) do
        local s = sessions[i]
        sessionIds[i] = s and s.id
        if s ~= nil then
          visible[i] = s.id == state.visible
          if visible[i] then
            shown = s
          end
          local color = visible[i] and style.active or style.inactive
          item:set({
            icon = { color = color },
            label = { string = s.label, color = color, width = visible[i] and "dynamic" or 0 },
            drawing = true,
          })
        else
          visible[i] = false
          item:set({ drawing = false })
        end
      end

      shownId = shown and shown.id
      local tabs = shown and shown.tabs or {}
      for i, dot in ipairs(dots) do
        local t = tabs[i]
        tabIds[i] = t and t.id
        if t ~= nil then
          local color = t.id == shown.active_tab and tabStyle.active or tabStyle.inactive
          dot:set({
            icon = { color = color },
            label = { string = t.label, color = color },
            drawing = true,
          })
        else
          dot:set({ drawing = false })
        end
      end
    end)
  end

  return self
end

return RexSessions
