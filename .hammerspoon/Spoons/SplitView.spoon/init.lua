--- === SplitView ===
---
--- *Open two windows side by side in SplitView.*  Select by name and/or using a popup.  Also provides focus toggling between splitview "halves".
--- Important points:
--- * `SplitView` Relies on the undocumented `spaces` API, which _must_ be installed separately for it to work; see https://github.com/asmagill/hs._asm.undocumented.spaces
--- * This tool works by _simulating_ the split-view user interface: a long green-button click followed by a 2nd window click.  This requires hand tuned time delays to work reliably.  If it is unreliable for you, trying increasing these (see `delay*` variables, below).
--- * `SplitView` uses `hw.window.filter` to try to ignore atypical windows (menu panes, etc.), which see.  Unrecognized non-standard windows may interfere with `SplitView`'s operation.
--- * If there is only a single space, `SplitView` creates _and does not remove_ a new, empty space for temporarily holding unwanted windows from the same application(s).  This space can safely be deleted, but will recur on future invocations.
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SplitView.spoon.zip]
--- Example config in you `~/.hammerspoon/init.lua`:
--- ```
--- mash =      {"ctrl", "cmd"}
--- spoon.splitView=hs.loadSpoon("SplitView")
--- spoon.splitView:bindHotkeys({choose={mash,"s"},switchFocus={mash,"x"},chooseAppEmacs={mash,"e","Emacs"})
--- ```
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SplitView"
obj.version = "1.0"
obj.author = "JD Smith"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- SplitView:showImage
--- Variable
--- (Boolean) Whether to show a thumbnail image of the window in the choice selection list.  On by default (which slightly slows the interface).
obj.showImage = true

--- SplitView:debug
--- Variable
--- (Boolean) Whether to print debug information to the console
obj.debug = false

--- SplitView:delay*
--- Variable
--- (Boolean) Time in seconds to delay between actions:
---  * delayZoomHold: How long to "hold" the zoom button down.  Defaults to 0.75s.
---  * delayOtherClick: How long to delay until clicking the other window.  Defaults to 0.5s.
---  * delayOtherHold: How long to "hold" clicking on the other window.  Defaults to 0.25s.
---  * delayRestoreWins: How long to delay until restoring window and unhiding apps on the original space.  Defaults to 0.5s.
--- Only set these variables if you are encountering failures achieving split view.  
obj.delayZoomHold = 0.75
obj.delayOtherClick = 0.75
obj.delayOtherHold = 0.1
obj.delayRestoreWins = .5

-- Internal Function
function _getGoodFocusedWindow(nofull)
   local win = hs.window.focusedWindow()
   if not win or not win:isStandard() then return end
   if nofull and win:isFullScreen() then return end
   return win
end 

--- SplitView:choose()
--- Method
--- Choose another window to enter split-view with current window
---
--- Parameters:
---  * `winChoices`: (Optional) A table of windows to choose from (as, e.g., provided by `SplitView:byName`).  Defaults to choosing among all other windows on the same screen.  Only standard, non-fullscreen windows are considered.
---
--- Returns:
---  * None
function obj:choose(winChoices)
   local win = _getGoodFocusedWindow()
   if not win then return end
   local choices={}

   if winChoices then		-- Make sure not to include focused win
      winChoices=hs.fnutils.filter(winChoices,function(w) return w~=win end)
   else
      winChoices=win:otherWindowsSameScreen()
   end
   if #winChoices==1 then
      self:performSplit(win,winChoices[1])
      return self
   end
   for _,w in pairs(winChoices) do
      if w:isStandard() and not w:isFullScreen() then
	 local choice={text=w:title(),
		       subText=w:application():title(),
		       wid=w:id()}
	 if self.showImage then choice.image=w.snapshotForID(w:id()) end
	 table.insert(choices,choice)
      end
   end

   if not choices then return self end
      
   local chooser=hs.chooser.new(function(choice)
	 if choice then
	    local otherwin=hs.window.find(choice.wid)
	    if otherwin then
	       self:performSplit(win,otherwin)
	    end
	 end 
   end)

   chooser:choices(choices)
   chooser:searchSubText(true)
   chooser:subTextColor({hex="#424"})
   chooser:show()
   return self
end 
   
--- SplitView:byName()
--- Method
--- Select an application and window _by name_ to enter split-view along side the currently focused window
--- Useful for creating custom key bindings for specific applications and/or matching window title strings (see `SplitView:bindHotkeys`).  Also useful for calling from the command line (c.f. `hs.ipc.cliInstall`).  E.g., assuming `spoon.splitView` was assigned in your top level as in the example config above:
---   `hs -c "spoon.splitView.byName("Terminal","server1")`
---
--- Parameters:
---  * `otherapp`: (Optional) The (partial) name of the other window's application, or omitted/`nil` for no application filtering
---  * `otherwin`: (Optional) The (partial) title of the other window, or omitted/`nil` for no window name filtering
---  * `noChoose`: (Optional, Boolean) By default a chooser window is invoked if more than one window matches. To disable this behavior and always take the first match (if any), pass `false` for this parameter.
---
--- Returns:
---  * None
function obj:byName(otherapp,otherwin,noChoose)
   local win = _getGoodFocusedWindow()
   if not win then return end
   local selectWins={}

   if(win:isFullScreen()) then
      win:setFullScreen(false)
      hs.timer.usleep(1e6)
   end

   if otherapp then otherapp=hs.application.find(otherapp) end 
   if otherapp then    -- select window from given application
      if otherwin then
	 selectWins={otherapp:findWindow(otherwin)}
      else
	 selectWins=otherapp:allWindows()
      end 
   elseif otherwin then
      selectWins={hs.window.find(otherwin)}
   else
      selectWins=win:otherWindowsSameScreen()
   end

   if self.debug then
      print("byName: ",otherapp,otherwin," found: ",#selectWins," wins")
      for k,v in pairs(selectWins) do for l,m in pairs(v) do print(k,l,m) end end
   end 
   
   if not selectWins or #selectWins==0 then return end
   if #selectWins==1 or noChoose then 
      self:performSplit(win,selectWins[1])
      return 
   end
   self:choose(selectWins)
end

--  Internal function to perform the simulated split view
--  Splitview two windows as follows:
--    Find all the unrelated applications, and hide them
--    Find all the other windows of the same application, and send them to an adjacent space
--    Move the first window the top left of the current screen
--    Move the 2nd window to occupy the right half of the screen
--    Click on the zoom button for 0.75 second, then release it (activating split screen)
--    Click in the middle of the right hand side of the screen (which will contain the window of interest)
--    Unhide all hidden applications, and return windows from the adjacent screen to their original space
local spaces = require "hs._asm.undocumented.spaces"
function obj:performSplit(thiswin,otherwin)
   if not thiswin or not otherwin or thiswin==otherwin then return end
   local hsee=hs.eventtap.event
   hs.window.animationDuration=0
   
   local frame=thiswin:screen():fullFrame()
   local thisapp,otherapp=thiswin:application(),otherwin:application()

   local appsToHide, winsMinimized={},{}
   local thisSpace=nil

   local filter=hs.window.filter.new()
   local wins=filter:getWindows()
   filter:pause()
   for _,w in pairs(wins) do
      local wa=w:application()
      if w~=thiswin and w~=otherwin and w:id() and w:isVisible() and not w:isMinimized() then
   	 if (wa==thisapp and w~=thiswin) or (wa==otherapp and w~=otherwin) then
   	    winsMinimized[w:id()]=w -- same app, but different window
   	 end
      end 
      if (wa~=thisapp and wa~=otherapp) then appsToHide[wa:pid()]=wa end
   end

   -- Hide and/or remove everything else
   for _,ah in pairs(appsToHide) do
      if self.debug then print("Hiding ",ah:name()) end
      ah:hide() 
   end

   if winsMinimized then
      thisSpace=spaces.activeSpace()
      local screen=thiswin:screen()
      local uuid=screen:spacesUUID()
      local userSpaces,toSpace=nil,nil
      for k,v in pairs(spaces.layout()) do
   	 userSpaces=v
   	 if k==uuid then break end
      end

      for i = #userSpaces, 1, -1 do
   	 if userSpaces[i]==thisSpace then break end
   	 toSpace=userSpaces[i]
      end
      if not toSpace then toSpace=spaces.createSpace() end
      for _,wm in pairs(winsMinimized) do
	 if self.debug then print("Teleporting: ",wm:title()) end
	 wm:spacesMoveTo(toSpace)
      end
   end

   thiswin:setTopLeft(0,0)
   otherwin:setSize({w=frame.w/2,h=frame.h})
   local wsz=otherwin:size()  -- enlarge and move to RHS for click target
   otherwin:setTopLeft(frame.w/2+(frame.w/2-wsz.w)/2,(frame.h-wsz.h)/2)

   local clickPoint = thiswin:zoomButtonRect()
   hsee.newMouseEvent(hsee.types.leftMouseDown, clickPoint):post()
   hs.timer.doAfter(self.delayZoomHold, function()
		       hsee.newMouseEvent(hsee.types.leftMouseUp,clickPoint):post()
		       hs.timer.doAfter(self.delayOtherClick,
					function()
					   local otherclick={x=frame.w*3/4,y=frame.h/2}
					   hsee.newMouseEvent(hsee.types.leftMouseDown,otherclick):post()
					   hs.timer.doAfter(self.delayOtherHold,function()
							       hsee.newMouseEvent(hsee.types.leftMouseUp,otherclick):post()
							       hs.timer.doAfter(self.delayRestoreWins,function()
										   for _,ah in pairs(appsToHide) do ah:unhide() end
										   for _,w in pairs(winsMinimized) do w:spacesMoveTo(thisSpace) end
							       end)
					   end)
		       end)
   end)
end


obj.arrow=nil
obj.timer=nil
--- SplitView:switchFocus()
--- Method
--- Switch focus from one side of a Split View to another, with an animated arrow showing the switch.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:switchFocus()
   local win = _getGoodFocusedWindow()
   if not win or not win:isFullScreen() then return end
   local others=win:otherWindowsSameScreen()
   for _, wto in ipairs(others) do
      if wto:isFullScreen() then
	 wto:focus()

	 local thisWinTopLeft=win:topLeft()
	 local rect=wto:screen():fullFrame()
	 local left=wto:topLeft().x<thisWinTopLeft.x
	 local str= left and "⬅️" or "➡️"
	 local style={size=rect.h/5}
	 local txtSize=hs.drawing.getTextDrawingSize(str,style)

	 -- position it
	 rect.y=rect.y+rect.h/2-txtSize.h/2
	 rect.h=txtSize.h
	 rect.w=txtSize.w
	 if left then
	    rect.x= thisWinTopLeft.x
	 else 
	    rect.x=thisWinTopLeft.x+win:size().w - txtSize.w
	 end 

	 -- Animate a directional arrow
	 if self.arrow then 		-- already animating, stop
	    if self.timer then self.timer:stop() end
	    self.arrow:delete()
	 end
	 self.arrow=hs.drawing.text(rect,str)
	 self.arrow:setTextStyle(style):setAlpha(0.5)
	 local animSteps=1
	 local deltaX=(left and -1 or 1) * txtSize.w/12
	 self.arrow:show()
	 self.timer=hs.timer.doUntil(function() return animSteps>=15 end,
	    function()
	       animSteps=animSteps+1
	       rect.x=rect.x+deltaX
	       self.arrow:setFrame(rect)
	       if animSteps>=15 then
		  self.arrow:delete()
		  self.arrow=nil
	       end 
	    end, 1/40)
	 break
      end
   end
end


--- SplitView:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for SplitView
---
--- Parameters:
---  * mapping - A table containing hotkey details for the following items:
---   * choose - Interactively choose another window to enter split-view with
---   * switchFocus - Switch the split view window focus
---   * chooseApp* - Create one or more special `choose` bindings to choose among only those windows matching a given application string.  In this case, give the app string to match as the last table entry.  E.g. `chooseAppEmacs={{"cmd","ctrl"},"e","Emacs"}`
---   * chooseWin* - Create one or more special `choose` bindings to choose among only those windows matching a given title string.  Give the title string as the last table entry.  E.g. `{chooseWinProj={{"cmd","ctrl"},"p","MyProject"}}`
---   * chooseAppWin* - Create one or more special `choose` bindings to choose among only those applications matching a given string, and windows of that applicaiton matching a given title string.  Give the application string, then title string as the last two table entries. E.g. `{chooseAppWinEmacsProj={{"cmd","ctrl"},"1","Emacs","MyProject"}}
function obj:bindHotkeys(mapping)
   local def = {
      choose = hs.fnutils.partial(self.choose, self),
      switchFocus = hs.fnutils.partial(self.switchFocus, self),
   }
   for k,v in pairs(mapping) do
      if k:sub(1,6)=="choose" and #k>6 then
	 local sub=k:sub(7,9)
	 if sub=="App" then
	    if k:sub(10,12)=="Win" then -- AppWin flavor
	       def[k]=hs.fnutils.partial(self.byName,self,v[3],v[4])
	       table.remove(v)
	       table.remove(v)
	    else --- AppFlavor
	       def[k]=hs.fnutils.partial(self.byName,self,v[3])
	       table.remove(v)
	    end
	 elseif sub=="Win" then
	    def[k]=hs.fnutils.partial(self.byName,self,nil,v[3])
	    table.remove(v)
	 else
	    error("Unrecognized choose* binding: ",k)
	 end 
      end
   end

   if self.debug then
      print("DEF:")
      for k,v in pairs(def) do print(k,v) end
      print("MAPPING:")
      for k,v in pairs(mapping) do for l,m in pairs(v) do print(k,l,m) end end
   end 
   hs.spoons.bindHotkeysToSpec(def, mapping)
end

return obj
