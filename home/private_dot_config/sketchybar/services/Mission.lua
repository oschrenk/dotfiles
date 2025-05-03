local sbar = require("sketchybar")
local table_util = require("utils.table")

local Mission = {}

-- @param config.mission_path Fully qualified path to mission
-- @param config.options Default options for parsing
function Mission.new(user_config)
  local self = {}

  local defaultConfig = {
    mission_path = "/opt/homebrew/bin/mission",
    options = {
      "--show-done=false",
      "--show-cancelled=false",
    },
  }

  local config = table_util.merge(defaultConfig, {})

  self.getTasks = function(journal, callback)
    local cmd = table.concat(
      table_util.flatten({
        config.mission_path,
        "tasks",
        "--journal",
        journal,
        " ",
        config.options,
        " --json",
      }),
      " "
    )
    sbar.exec(cmd, function(response)
      callback(response)
    end)
  end

  self.openObsidian = function(vault, rel_path)
    local cmd = table.concat({
      "open",
      '"obsidian://advanced-uri?vault=' .. vault .. "&filepath=" .. rel_path .. '"',
    }, " ")
    sbar.exec(cmd)
  end

  return self
end

return Mission
