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

-- @param mission Instance of Mission service
-- @param focus Instance of Focus service
-- @param icons Plugin specific icons
function Mission.new(mission, focus, icons)
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
    local item = sbar.add("item", {
      position = position,
      update_freq = 60,
    })

    local onComplete = function(current_focus)
      local journal = "default"
      if current_focus == focus.work then
        journal = "work"
      end

      local icon = focus2icon[current_focus] or focus2icon["default"]
      local callback = function(json)
        if current_focus == focus.dnd or current_focus == focus.sleep then
          item:set({ icon = icon, label = { drawing = false } })
        else
          local maybeTasks = json.tasks
          if (maybeTasks ~= nil) and (maybeTasks[1] ~= nil) then
            local text = strings.Trim(maybeTasks[1].text, MaxLength)
            item:set({ icon = icon, label = { string = text, drawing = true } })
          else
            item:set({ icon = icon, label = { string = "", drawing = true } })
          end
        end
        local vault = json.meta.vault
        local rel_path = strings.UrlEncode(json.meta.path.relative)

        item:subscribe("mouse.clicked", function(_)
          mission.openObsidian(vault, rel_path)
        end)
      end
      mission.getTasks(journal, callback)
    end

    item:subscribe({ "forced", "routine", "system_woke", "mission_task", "mission_focus" }, function(_)
      focus.handler(onComplete)
    end)
  end

  return self
end

return Mission
