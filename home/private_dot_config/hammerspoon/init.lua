require("AppWatcher")
require("audio")
require("bluetooth")
require("notifications")
require("wifi")
require("windows")

------------------------
-- Settings
------------------------
-- base dirs
local HAMMERSPOON_DIR = os.getenv("HOME") .. "/.config/hammerspoon"
local SCRIPTS_DIR = HAMMERSPOON_DIR .. "/scripts"

-- disable animation
hs.window.animationDuration = 0

------------------------
-- Dependencies
------------------------

local notifications = Notifications.new(SCRIPTS_DIR)
local notify = notifications.notify
local bluetooth = Bluetooth.new(notify)
local audio = Audio.new(notify, bluetooth, SCRIPTS_DIR)
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

hs.hotkey.bind(hyper, "h", audio.connectHeadphones)

hs.hotkey.bind(hyper, "b", bluetooth.toggle)
hs.hotkey.bind(hyper, "v", wifi.toggle)

hs.hotkey.bind(hyper, "m", audio.mute)

-- *********************
-- AppWatcher
-- *********************

local appHandler = function(event, appName, windowTitle)
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
AppWatcher.new(appHandler).start()

-- *********************
-- WifiWatcher
-- *********************
local workSSIDs = {}
local homeSSIDs = { "Citadel" }
local enteredHome = function(ssid)
	notify("Connected to home wifi" .. ' "' .. ssid .. '"')
end
local enteredWork = function(ssid)
	notify("Connected to work wifi" .. ' "' .. ssid .. '"')
end
local enteredUntrusted = function(ssid)
	notify("Connected to untrusted wifi" .. ' "' .. ssid .. '"')
end
require("WifiWatcher")
WifiWatcher.new(workSSIDs, homeSSIDs, enteredHome, enteredWork, enteredUntrusted).start()

------------------------
-- Reload
------------------------
hs.pathwatcher
	.new(HAMMERSPOON_DIR, function(_)
		hs.reload()
	end)
	:start()
notify("Config loaded")
