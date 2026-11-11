local PICKER_LABEL = "sessionizer"
local PICKER_SIZE = 0.33
local PICKER_TOP = (1 - PICKER_SIZE) / 2
local BACKING_SCALE = 2

local function active_window(session_id)
  local view = rex.call("session.view", { session_id = session_id })
  for _, window in ipairs(view.windows) do
    if window.window_id == view.active_window_id then
      return window
    end
  end
end

local function find_picker_layer(window)
  for _, layer in ipairs(window.layers) do
    if layer.kind == "floating" and layer.blocks[1].label == PICKER_LABEL then
      return layer.layer_id
    end
  end
end

local function read_app_setting(key)
  local result = rex.exec({ "defaults", "read", "com.superlogical.rex", key })
  return tonumber(result.stdout:match("%d+"))
end

local function sidebar_width()
  if read_app_setting("Workspace.sidebarCollapsed") == 1 then
    return 0
  end
  return read_app_setting("Workspace.sidebarWidth")
end

local function picker_left(session_id, window)
  local node = window.layers[1].layout
  while node.split do
    node = node.split.before
  end
  local size = rex.call("block.method", { session_id = session_id, block_id = node.block_id, method = "size" })
  local area = size.columns * size.cell_width_px / BACKING_SCALE / node.rect[3]
  return math.max(0, (area - sidebar_width()) / (2 * area) - PICKER_SIZE / 2)
end

rex.unbind("cmd+n", "client.window.new")
rex.unbind("cmd+shift+s")
rex.bind("alt+shift+left", "pane.resize", { direction = "left" })
rex.bind("alt+shift+right", "pane.resize", { direction = "right" })
rex.bind("alt+shift+up", "pane.resize", { direction = "up" })
rex.bind("alt+shift+down", "pane.resize", { direction = "down" })
rex.bind("alt+shift+f", function(ctx)
  local window = active_window(ctx.session_id)
  local layer_id = find_picker_layer(window)
  if layer_id then
    rex.call("session.close_layer", { session_id = ctx.session_id, layer_id = layer_id })
    return true
  end
  rex.call("session.new_layer", {
    session_id = ctx.session_id,
    bounds = { picker_left(ctx.session_id, window), PICKER_TOP, PICKER_SIZE, PICKER_SIZE },
    layout = {
      block = {
        flavor = "com.superlogical.terminal.shell",
        label = PICKER_LABEL,
        options = { command = { "sessionizer", "search" } },
      },
    },
    focus = true,
  })
  return true
end)
