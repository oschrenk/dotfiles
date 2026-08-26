local sbar = require("sketchybar")

local Workspace = {}

-- @param icons Plugin specific icons
-- @param aerospace Helper app
function Workspace.new(icons, aerospace)
  local self = {}

  local labels = {
    ["1"] = "Primary",
    ["2"] = "Secondary",
    ["M"] = "Media",
  }

  self.add = function(position)
    local workspace = sbar.add("item", {
      position = position,
      icon = icons.default,
      label = {
        width = 0,
        string = "",
      },
    })

    local update = function(id)
      local icon = icons[id] ~= nil and icons[id] or icons.default
      local label = labels[id] ~= nil and labels[id] or ""
      workspace:set({ icon = icon, label = { string = label } })
    end

    workspace:subscribe({ "forced", "routine", "system_woke" }, function(_)
      aerospace.currentWorkspace(update)
    end)

    workspace:subscribe({ "aerospace_workspace_changed" }, function(env)
      update(env.FOCUSED_WORKSPACE)
    end)

    workspace:subscribe("mouse.entered", function(_)
      sbar.animate("tanh", 30, function()
        workspace:set({ label = { width = "dynamic" } })
      end)
    end)

    workspace:subscribe("mouse.exited", function(_)
      sbar.animate("tanh", 30, function()
        workspace:set({ label = { width = 0 } })
      end)
    end)
  end

  return self
end

return Workspace
