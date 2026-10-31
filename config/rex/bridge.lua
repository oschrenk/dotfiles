local visible
local attached = {}
local pending

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
    for _, window in ipairs(view.windows) do
      tabs[#tabs + 1] = { id = window.window_id, label = window.label }
    end
    sessions[#sessions + 1] = {
      id = session.session_id,
      label = session.label,
      active_tab = view.active_window_id,
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
  pending = rex.after(0.1, publish)
end

-- ponytail: no API reports the session on screen, so the last resized one counts, and none does until the first switch
rex.on("terminal.size_changed", function(ctx, _)
  visible = ctx.session_id
  schedule()
end)

for _, name in ipairs({
  "session_view_changed",
  "session_created",
  "session_destroyed",
  "session_label_changed",
}) do
  rex.on(name, schedule)
end

rex.every(15, publish)
