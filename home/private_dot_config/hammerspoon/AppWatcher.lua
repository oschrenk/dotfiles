------------------------
-- AppWatcher
------------------------
AppWatcher = {}
AppWatcher.new = function(handler)
	local self = {}

	-- interface: (appName, eventType, appObject)
	self.handleGlobalEvent = function(appName, eventType, _)
		if eventType == hs.application.watcher.activated then
			print("activated " .. appName)
		end

		if eventType == hs.application.watcher.launched then
			print("launched " .. appName)
		end
	end

	-- interface: (element, event, watcher, info)
	self.handleAppEvent = function(element, event, _, _)
		local appName = element:application():title()
		local windowTitle = element:title()

		handler(event, appName, windowTitle)
	end

	-- interface:(app, initializing)
	self.watchApp = function(app, _)
		if self.appWatchers[app:pid()] then
			return
		end

		local watcher = app:newWatcher(self.handleAppEvent)
		self.appWatchers[app:pid()] = {
			watcher = watcher,
		}

		watcher:start({ hs.uielement.watcher.focusedWindowChanged })
	end

	self.attachExistingApps = function()
		local apps = hs.application.runningApplications()
		apps = hs.fnutils.filter(apps, function(app)
			return app:title() ~= "Hammerspoon"
		end)
		hs.fnutils.each(apps, function(app)
			self.watchApp(app, true)
		end)
	end

	self.start = function()
		self.appWatchers = {}
		self.globalWatcher = hs.application.watcher.new(self.handleGlobalEvent):start()
		self.attachExistingApps()
	end

	return self
end
