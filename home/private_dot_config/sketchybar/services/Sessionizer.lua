local sbar = require("sketchybar")
local strings = require("utils.strings")

local Sessionizer = {}

-- @param socket optional tmux socket name (tmux -L); nil = default socket
function Sessionizer.new(socket)
  local self = {}

  -- Absolute paths: sketchybar runs under launchd with a minimal PATH. tlink is
  -- installed via home-manager (nix-darwin flavor), so it lives under the
  -- per-user profile, not ~/.nix-profile.
  local bin = "/opt/homebrew/bin/sessionizer"
  local tlink = "/etc/profiles/per-user/" .. os.getenv("USER") .. "/bin/tlink"
  local socketArg = socket and (" --socket-name " .. socket) or ""

  -- Run a sessionizer subcommand on the configured socket; sbar.exec parses the
  -- --json output and hands the table to onComplete.
  local function run(subcommand, onComplete)
    sbar.exec(bin .. socketArg .. " " .. subcommand, onComplete)
  end

  self.open = function(sessionName)
    local encoded = strings.UrlEncode(sessionName)
    sbar.exec(tlink .. ' open "tmux://' .. encoded .. '"')
  end

  self.sessions = function(onComplete)
    run("sessions --json", onComplete)
  end

  self.windows = function(onComplete)
    run("windows --json", onComplete)
  end

  self.currentSession = function(onComplete)
    self.sessions(function(sessions)
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
