require("Appearance")
require("AppWatcher")
require("Audio")
require("Bluetooth")
require("Mail")
require("Notifications")
require("Wifi")
require("WifiWatcher")
require("Windows")

------------------------
-- Settings
------------------------
-- base dirs
local HAMMERSPOON_DIR = os.getenv("HOME") .. "/.config/hammerspoon"
local SCRIPTS_DIR = HAMMERSPOON_DIR .. "/scripts"

------------------------
-- Dependencies
------------------------

local notifications = Notifications.new(SCRIPTS_DIR)
local notify = notifications.notify
local bluetooth = Bluetooth.new(notify)
local audio = Audio.new(notify, bluetooth, SCRIPTS_DIR)
local wifi = Wifi.new(notify)
local windows = Windows.new(notify)
local appearance = Appearance.new()

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
local hyper = { "shift", "ctrl", "alt", "cmd" }

-- move windows
hs.hotkey.bind(hyper, "left", windows.left50)
hs.hotkey.bind(hyper, "right", windows.right50)
hs.hotkey.bind(hyper, "up", windows.toggleWindowMaximized)
hs.hotkey.bind(hyper, "x", windows.toggleFullScreen)
hs.hotkey.bind(hyper, "q", windows.sendWindowToPrevMonitor)
hs.hotkey.bind(hyper, "e", windows.sendWindowToNextMonitor)
hs.hotkey.bind(hyper, "down", windows.center)

-- appearance
-- will spawn:
-- > "Hammerspoon.app" wants access to control "SystemEvents.app".
-- > Allowing control will provide access to documents and data in "System Events.app",
-- > and to perform actions within that app.
hs.hotkey.bind(hyper, "p", appearance.toggleDarkMode)

-- audio
hs.hotkey.bind(hyper, "h", audio.connectHeadphones)
hs.hotkey.bind(hyper, "m", audio.toggleMute)

-- connectivity
hs.hotkey.bind(hyper, "b", bluetooth.toggle)
hs.hotkey.bind(hyper, "v", wifi.toggle)

-- mail, register cmd+i to copy messageid
Mail.new(SCRIPTS_DIR).bindHotkey({ "cmd" }, "i")
--

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
-- NotificationWatcher
-- *********************

-- Define a function to be called when a notification is received
function handleNotification(_)
	if appearance.isDarkMode() then
		os.execute("cd ~/.config/alacritty && ./appearance.sh dark")
	else
		os.execute("cd ~/.config/alacritty && ./appearance.sh light")
	end
end

-- Set up the notification listener for Slack
notificationWatcher = hs.distributednotifications.new(handleNotification, "AppleInterfaceThemeChangedNotification")
notificationWatcher:start()

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
