local sbar = require("sketchybar")
local strings = require("utils.strings")

local Sessionizer = {}

-- @param socket   tmux socket name (tmux -L); nil = default socket
-- @param fallback optional socket to query when `socket` has no sessions/windows
--                 (e.g. secondary bar falls back to the primary pool)
function Sessionizer.new(socket, fallback)
  local self = {}

  -- Absolute paths: sketchybar runs under launchd with a minimal PATH. tlink is
  -- installed via home-manager (nix-darwin flavor), so it lives under the
  -- per-user profile, not ~/.nix-profile.
  local bin = "/etc/profiles/per-user/" .. os.getenv("USER") .. "/bin/sessionizer"
  local tlink = "/etc/profiles/per-user/" .. os.getenv("USER") .. "/bin/tlink"

  local function socketArg(sock)
    return sock and (" --socket-name " .. sock) or ""
  end

  local function isEmpty(result)
    return result == nil or result == "" or result == "[]"
      or (type(result) == "table" and #result == 0)
  end

  -- Run a sessionizer subcommand on `socket`; if the result is empty and a
  -- fallback socket is configured, retry there. sbar.exec parses the --json.
  -- `onComplete` also receives the socket the result actually came from, so
  -- callers can open a deeplink against the right tmux server.
  local function run(subcommand, onComplete)
    sbar.exec(bin .. socketArg(socket) .. " " .. subcommand, function(result)
      if fallback and isEmpty(result) then
        sbar.exec(bin .. socketArg(fallback) .. " " .. subcommand, function(fallbackResult)
          onComplete(fallbackResult, fallback)
        end)
      else
        onComplete(result, socket)
      end
    end)
  end

  -- @param sock socket the session lives on; nil = default tmux server
  self.open = function(sessionName, sock)
    local encoded = strings.UrlEncode(sessionName)
    local query = sock and ("?socket=" .. strings.UrlEncode(sock)) or ""
    sbar.exec(tlink .. ' open "tmux://' .. encoded .. query .. '"')
  end

  self.sessions = function(onComplete)
    run("sessions --json", onComplete)
  end

  self.windows = function(onComplete)
    run("windows --json", onComplete)
  end

  self.currentSession = function(onComplete)
    self.sessions(function(sessions)
      if isEmpty(sessions) then
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
