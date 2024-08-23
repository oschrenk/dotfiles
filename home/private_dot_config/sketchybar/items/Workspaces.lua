local sbar = require("sketchybar")

local Workspaces = {}

-- @param icons Plugin specific icons
-- @param style Plugin specific style
-- @param aerospace Helper app
function Workspaces.new(icons, style, aerospace)
  local self = {}

  local workspaceWatcher = sbar.add("item", {
    drawing = false,
    updates = true,
  })

  local spaces = {}

  local selectCurrentWorkspace = function(workspace)
    for sid, item in pairs(spaces) do
      if item ~= nil then
        local isSelected = sid == "workspaces." .. workspace
        item:set({
          icon = { color = isSelected and style.active or style.inactive },
          label = {
            color = isSelected and style.active or style.inactive,
          },
        })
      end
    end
  end

  local labels = {
    ["1"] = "Primary",
    ["2"] = "Secondary",
    ["M"] = "Media",
  }

  self.add = function(position)
    workspaceWatcher:subscribe("aerospace_workspace_changed", function(env)
      selectCurrentWorkspace(env.FOCUSED_WORKSPACE)
    end)

    local ids = { "1", "2", "M" }
    for _, id in pairs(ids) do
      local name = "workspaces." .. id

      spaces[name] = sbar.add("item", name, {
        position = position,
        icon = icons[id],
        click_script = "aerospace workspace " .. id,
        label = {
          width = 0,
          string = labels[id],
        },
      })

      spaces[name]:subscribe("mouse.entered", function(_)
        sbar.animate("tanh", 30, function()
          spaces[name]:set({ label = { width = "dynamic" } })
        end)
      end)

      spaces[name]:subscribe("mouse.exited", function(_)
        sbar.animate("tanh", 30, function()
          spaces[name]:set({ label = { width = 0 } })
        end)
      end)
    end
    aerospace.currentWorkspace(selectCurrentWorkspace)
  end

  return self
end

return Workspaces
