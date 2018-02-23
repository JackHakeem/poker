--
-- Author: bearluo
-- Date: 2017-05-26 15:24:32
--

local CustomListItem = class("CustomListItem", function()
	return display.newNode()
end)


function CustomListItem:ctor(control)
	self.control_ = control 
	--find view by layout
	local node, width, height = cc.uiloader:load("custom_item.json")
	self:addChild(node)
	self.root_ = node

	self:setContentSize(cc.size(width,height))
	self.mIcon = cc.uiloader:seekNodeByName(node,"icon")
	self.mTouchHandler = cc.uiloader:seekNodeByName(node,"touch_handler")
	self.mTouchHandler:setTouchEnabled(true)
	self.mTouchHandler:setTouchSwallowEnabled(false)
	local startX,startY =0,0
	local down = false
	self.mTouchHandler:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    dump(event)
	    local x,y = event.x,event.y
	    if event.name == "began" then
	    	startX = x
        	startY = y
        	if not self.mTouchHandler:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
        	self.mIcon:scale(0.9)
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" then
		    	tt.play.play_sound("click")
				self.control_:showCustomRoomDialog()
			end
		end
		if event.name == "ended" then
			if not tolua.isnull(self.mIcon) then
    			self.mIcon:scale(1)
    		end
		end
	end)
end

return CustomListItem
