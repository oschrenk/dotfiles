------------------------
-- Fast user switching
------------------------
-- this is currently crippled in BigSur
-- see https://apple.stackexchange.com/questions/409820/access-fast-user-switching-from-a-script-in-big-sur

-- Fast User Switching
-- `id -u` to find curent id
local personalUserId = "501"
local workUserId     = "504"

function currentAccountId()
  local file = assert(io.popen('/usr/bin/id -u', 'r'))
  local output = file:read('*all')
  file:close()

  return output:gsub("%s+", ""):gsub("%s+$", "")
end

function switchUser(id, name)
  notify("Switch to " .. name)
  os.execute('/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -switchToUserID ' .. id)
end

function toggleUser()
  if (currentAccountId() == personalUserId ) then
    switchUser(workUserId, "work")
  else
    switchUser(personalUserId, "personal")
  end
end

