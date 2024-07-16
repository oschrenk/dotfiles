------------------------
-- Settings
------------------------
-- base dirs
local HAMMERSPOON_DIR = os.getenv("HOME") .. "/.config/hammerspoon"
local SCRIPTS_DIR = HAMMERSPOON_DIR .. "/scripts"

-- disable animation
hs.window.animationDuration = 0

require("bluetooth")
require("network")
require("wifi")
------------------------
-- Helpers
------------------------
function notify(message)
	hs.notify
		.new({
			title = "Hammerspoon",
			informativeText = message,
		})
		:send()
end

------------------------
-- Audio settings
------------------------

function mute()
	hs.audiodevice.defaultOutputDevice():setMuted(true)
	notify("Mute")
end

------------------------
-- Environment settings
------------------------
hs.caffeinate.watcher
	.new(function(event)
		if event == hs.caffeinate.watcher.systemWillSleep or event == hs.caffeinate.watcher.systemWillPowerOff then
			print("sleeping")
			mute()
		elseif event == hs.caffeinate.watcher.systemDidWake then
			print("waking up")
			mute()
		end
	end)
	:start()

function connectHeadphones()
	if not bluetoothEnabled() then
		enableBluetooth()
	end
	ok, result = hs.osascript.applescriptFromFile(SCRIPTS_DIR .. "/connectHeadphones.applescript")
end

------------------------
-- Keyboard Bindings
------------------------
require("windows")

local windows = Windows.new()
local hyper = { "ctrl", "alt", "shift", "cmd" }

hs.hotkey.bind(hyper, "a", windows.loopLeft)
hs.hotkey.bind(hyper, "d", windows.loopRight)
hs.hotkey.bind(hyper, "s", windows.toggleWindowMaximized)
hs.hotkey.bind(hyper, "x", windows.toggleFullScreen)

hs.hotkey.bind(hyper, "q", windows.sendWindowToPrevMonitor)
hs.hotkey.bind(hyper, "e", windows.sendWindowToNextMonitor)

hs.hotkey.bind(hyper, "h", connectHeadphones)

hs.hotkey.bind(hyper, "b", toggleBluetooth)
hs.hotkey.bind(hyper, "v", toggleWifi)

hs.hotkey.bind(hyper, "m", mute)

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
