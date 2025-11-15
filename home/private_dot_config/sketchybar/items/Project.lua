local sbar = require("sketchybar")
local strings = require("utils.strings")

-- Requirements
--  https://github.com/oschrenk/mission
--  brew tap oschrenk/made
--  brew install mission
--
local Project = {}

-- @param icons Plugin specific icons
-- @param focus Instance of Focus
function Project.new(icons, sessionizer)
  local self = {}

  local MaxLength = 30

  -- @param position right|left
  self.add = function(position)
    local project = sbar.add("item", {
      position = position,
      update_freq = 30,
    })

    local onComplete = function(maybe_session)
      if maybe_session == nil then
        project:set({ drawing = false })
        return
      end
      local todoPath = maybe_session.path .. "/" .. "TODO.md"
      local f = io.open(todoPath, "r")
      if f ~= nil then
        io.close(f)

        local cmd = "/opt/homebrew/bin/mission tasks --show-done=false --show-cancelled=false --json" .. " " .. todoPath

        sbar.exec(cmd, function(json)
          local maybeTasks = json.tasks
          if (maybeTasks ~= nil) and (maybeTasks[1] ~= nil) then
            local text = strings.Trim(maybeTasks[1].text, MaxLength)
            project:set({
              icon = icons.folder,
              label = { string = text, drawing = true },
              drawing = true,
            })
          else
            project:set({ drawing = false })
          end
        end)
      else
        project:set({ drawing = false })
      end
    end

    project:subscribe({ "forced", "routine", "system_woke", "tmux_sessions_update" }, function(_)
      sessionizer.currentSession(onComplete)
    end)
  end

  return self
end

return Project
