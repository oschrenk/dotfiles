Mail = {}
Mail.new = function(scripts_dir)
	local self = {}

	local copyMessageId = function()
		_, _ = hs.osascript.applescriptFromFile(scripts_dir .. "/copy-message-id-to-clipboard.applescript")
		hs.alert.show("Copied MessageId")
	end

	self.bindHotkey = function(modifier, key)
		local copyHotkey = hs.hotkey.new(modifier, key, function()
			copyMessageId()
		end)

		hs.window.filter
			.new("Mail")
			:subscribe(hs.window.filter.windowFocused, function()
				copyHotkey:enable()
			end)
			:subscribe(hs.window.filter.windowUnfocused, function()
				copyHotkey:disable()
			end)
	end

	return self
end

return Mail
