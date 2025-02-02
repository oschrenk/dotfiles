local sbar = require("sketchybar")

local Aerospace = {}

function Aerospace.new()
  local self = {}

  self.listWorkspaces = function(onComplete)
    sbar.exec("aerospace list-workspaces --all", function(workspaces)
      onComplete(workspaces:gmatch("[^\r\n]+"))
    end)
  end

  self.currentWorkspace = function(onComplete)
    sbar.exec("aerospace list-workspaces --focused", function(workspace)
      onComplete(workspace:match("[^\r\n]+"))
    end)
  end

  self.listWindows = function(onComplete)
    sbar.exec(
      'aerospace list-windows --workspace focused --format "id=%{window-id}, name=%{app-name}"',
      function(windows)
        onComplete(windows)
      end
    )
  end

  self.currentWindow = function(onComplete)
    sbar.exec("aerospace list-windows --focused --format %{app-name}", function(window)
      onComplete(window)
    end)
  end

  return self
end

return Aerospace
