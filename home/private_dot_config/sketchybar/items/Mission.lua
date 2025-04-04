local sbar = require("sketchybar")
local strings = require("utils.Strings")

-- Requirements
--  https://github.com/oschrenk/mission
--  brew tap oschrenk/made
--  brew install mission
--
-- To support focus changes, and faster feedback, run the service
--  brew services start mission
--
-- `mission` will watching iCloud and system files (to identify macOS Focus),
--  To work properly we need give to give sketchybar and mission full disk access
--  Then allow sketchybar full disk access
--   "System Settings" > "Privacy & Security" > "Full Disk Access", allow
--   `/opt/homebrew/bin/mission` and
--   `/opt/homebrew/bin/sketchybar`
--
--  Then restart both services
--   brew services restart mission
--   brew services restart sketchybar
local Mission = {}

-- @param icons Plugin specific icons
-- @param focus Instance of Focus
function Mission.new(icons, focus)
  local self = {}

  local MaxLength = 35

  local focus2icon = {
    [focus.work] = icons._work,
    [focus.personal] = icons._personal,
    [focus.sleep] = icons._sleep,
    [focus.dnd] = icons._dnd,
    ["default"] = icons._personal,
  }

  -- @param position right|left
  self.add = function(position)
    local mission = sbar.add("item", {
      position = position,
      update_freq = 60,
    })

    local onComplete = function(current_focus)
      local journal = "default"
      if current_focus == focus.work then
        journal = "work"
      end

      local cmd = "/opt/homebrew/bin/mission tasks --journal "
        .. journal
        .. " --show-done=false --show-cancelled=false --json"

      local icon = focus2icon[current_focus] or focus2icon["default"]

      sbar.exec(cmd, function(json)
        if current_focus == focus.dnd or current_focus == focus.sleep then
          mission:set({ icon = icon, label = { drawing = false } })
        else
          local maybeTasks = json.tasks
          if (maybeTasks ~= nil) and (maybeTasks[1] ~= nil) then
            local text = strings.Trim(maybeTasks[1].text, MaxLength)
            mission:set({ icon = icon, label = { string = text, drawing = true } })
          else
            mission:set({ icon = icon, label = { string = "", drawing = true } })
          end
        end
      end)
      local path = "10%2520Journals%252FPersonal%252F"
      if journal == "work" then
        path = "10%2520Journals%252FWork%252F"
      end

      mission:subscribe("mouse.clicked", function(_)
        local today = os.date("%Y-%m-%d")
        local click_cmd = 'open "obsidian://advanced-uri?vault=memex&filepath=' .. path .. today .. '.md"'
        sbar.exec(click_cmd)
      end)
    end

    mission:subscribe({ "forced", "routine", "system_woke", "mission_task", "mission_focus" }, function(_)
      focus.handler(onComplete)
    end)
  end

  return self
end

return Mission
