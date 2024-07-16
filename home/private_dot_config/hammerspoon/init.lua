------------------------
-- Settings
------------------------
-- base dirs
local HAMMERSPOON_DIR = os.getenv("HOME") .. "/.config/hammerspoon"
local SCRIPTS_DIR = HAMMERSPOON_DIR .. "/scripts"

-- disable animation
hs.window.animationDuration = 0

require("audio")
require("bluetooth")
require("network")
require("notifications")
require("wifi")
require("windows")

local notifications = Notifications.new(SCRIPTS_DIR)
local notify = notifications.notify

local audio = Audio.new(notify)
local bluetooth = Bluetooth.new(notify)

local wifi = Wifi.new(notify)
local windows = Windows.new()

------------------------
-- Environment settings
------------------------
hs.caffeinate.watcher
	.new(function(event)
		if event == hs.caffeinate.watcher.systemWillSleep or event == hs.caffeinate.watcher.systemWillPowerOff then
			print("sleeping")
			audio.mute()
		elseif event == hs.caffeinate.watcher.systemDidWake then
			print("waking up")
			audio.mute()
		end
	end)
	:start()

function connectHeadphones()
	if not bluetooth.isEnabled() then
		bluetooth.enable()
	end
	_, _ = hs.osascript.applescriptFromFile(SCRIPTS_DIR .. "/connectHeadphones.applescript")
end

------------------------
-- Keyboard Bindings
------------------------
local hyper = { "ctrl", "alt", "shift", "cmd" }

hs.hotkey.bind(hyper, "a", windows.loopLeft)
hs.hotkey.bind(hyper, "d", windows.loopRight)
hs.hotkey.bind(hyper, "s", windows.toggleWindowMaximized)
hs.hotkey.bind(hyper, "x", windows.toggleFullScreen)

hs.hotkey.bind(hyper, "q", windows.sendWindowToPrevMonitor)
hs.hotkey.bind(hyper, "e", windows.sendWindowToNextMonitor)

hs.hotkey.bind(hyper, "h", connectHeadphones)

hs.hotkey.bind(hyper, "b", bluetooth.toggle)
hs.hotkey.bind(hyper, "v", wifi.toggle)

hs.hotkey.bind(hyper, "m", audio.mute)

---

function handleGlobalEvent(appName, eventType, appObject)
	if eventType == hs.application.watcher.activated then
		print("activated " .. appName)
	end

	if eventType == hs.application.watcher.launched then
		print("launched " .. appName)
	end
end

function handleAppEvent(element, event, watcher, info)
	local appName = element:application():title()
	local windowTitle = element:title()

	if event == hs.uielement.watcher.windowCreated then
		print("created")
		if appName:find("Google Chrome") then
			if windowTitle:find("(Private)", 1, true) then
				if hs.application.find("OpenVPN Connect") then
					notify("Created private window created while on VPN")
				end
			end
		end
	elseif event == hs.uielement.watcher.focusedWindowChanged then
		if appName:find("Google Chrome") then
			if windowTitle:find("(Private)", 1, true) then
				if hs.application.find("OpenVPN Connect") then
					notify("Switched to private window created while on VPN")
				end
			end
		end
	end
end

function watchApp(app, initializing)
	if appWatchers[app:pid()] then
		return
	end

	local watcher = app:newWatcher(handleAppEvent)
	appWatchers[app:pid()] = {
		watcher = watcher,
	}

	watcher:start({ hs.uielement.watcher.focusedWindowChanged })
end

function attachExistingApps()
	local apps = hs.application.runningApplications()
	apps = hs.fnutils.filter(apps, function(app)
		return app:title() ~= "Hammerspoon"
	end)
	hs.fnutils.each(apps, function(app)
		watchApp(app, true)
	end)
end

appWatchers = {}
globalWatcher = hs.application.watcher.new(handleGlobalEvent):start()
attachExistingApps()

wifiWatcher = hs.wifi.watcher.new(wifiListener)
wifiWatcher:watchingFor({ "SSIDChange" })
wifiWatcher:start()

------------------------
-- Reload
------------------------
hs.pathwatcher
	.new(HAMMERSPOON_DIR, function(files)
		hs.reload()
	end)
	:start()
notify("Config loaded")
