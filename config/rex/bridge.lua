local PUBLISH_DELAY_SECONDS = 0.1
local PUBLISH_INTERVAL_SECONDS = 15

local visible
local attached = {}
local pending

local function is_waiting(session_id, window)
  for _, layer in ipairs(window.layers) do
    for _, block in ipairs(layer.blocks) do
      if block.creator_name == "com.superlogical.terminal" then
        local ok, status = pcall(rex.call, "block.method", {
          session_id = session_id,
          block_id = block.block_id,
          method = "program_status",
        })
        for _, record in ipairs(ok and status.records or {}) do
          if record.state == "blocked" then
            return true
          end
        end
      end
    end
  end
  return false
end

local function publish()
  pending = nil
  local sessions = {}
  for _, session in ipairs(rex.call("session.list").sessions) do
    if not attached[session.session_id] then
      rex.call("session.attach", { session_id = session.session_id })
      attached[session.session_id] = true
    end
    local view = rex.call("session.view", { session_id = session.session_id })
    local tabs = {}
    local waiting = false
    for _, window in ipairs(view.windows) do
      local tab_waiting = is_waiting(session.session_id, window)
      waiting = waiting or tab_waiting
      tabs[#tabs + 1] = { id = window.window_id, label = window.label, waiting = tab_waiting }
    end
    sessions[#sessions + 1] = {
      id = session.session_id,
      label = session.label,
      active_tab = view.active_window_id,
      waiting = waiting,
      tabs = tabs,
    }
  end
  rex.exec({
    "sketchybar",
    "--trigger",
    "rex_update",
    "INFO=" .. rex.json.encode({ visible = visible, sessions = sessions }),
  })
end

local function schedule()
  if pending then
    pending:cancel()
  end
  pending = rex.after(PUBLISH_DELAY_SECONDS, publish)
end

-- no API reports the session on screen, so the last resized one counts, and none does until the first switch
rex.on("terminal.size_changed", function(ctx, _)
  visible = ctx.session_id
  schedule()
end)

for _, name in ipairs({
  "session_view_changed",
  "session_created",
  "session_destroyed",
  "session_label_changed",
  "terminal.program_status_changed",
}) do
  rex.on(name, schedule)
end

rex.every(PUBLISH_INTERVAL_SECONDS, publish)
