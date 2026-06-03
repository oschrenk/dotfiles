local sbar = require("sketchybar")
local strings = require("utils.strings")

local Sessionizer = {}
function Sessionizer.new()
  local self = {}

  -- tlink is installed via home-manager (nix-darwin module flavor, so packages
  -- live under /etc/profiles/per-user/$USER, not ~/.nix-profile). Sketchybar
  -- runs under launchd with a minimal PATH, so reference the path explicitly.
  local tlink = "/etc/profiles/per-user/" .. os.getenv("USER") .. "/bin/tlink"

  self.open = function(sessionName)
    local encoded = strings.UrlEncode(sessionName)
    sbar.exec(tlink .. ' open "tmux://' .. encoded .. '"')
  end

  self.sessions = function(onComplete)
    local cmd = "/opt/homebrew/bin/sessionizer sessions --json"
    sbar.exec(cmd, function(sessions)
      onComplete(sessions)
    end)
  end

  self.currentSession = function(onComplete)
    local cmd = "/opt/homebrew/bin/sessionizer sessions --json"
    sbar.exec(cmd, function(sessions)
      if sessions == "" or sessions == "[]" then
        onComplete(nil)
        return
      end
      local session = nil
      for _, v in pairs(sessions) do
        if v.attached then
          session = v
        end
      end
      onComplete(session)
    end)
  end

  return self
end

return Sessionizer
