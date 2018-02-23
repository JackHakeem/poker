--
-- Author: bearluo
-- Date: 2017-05-26 15:24:32
--

local SngItem = class("SngItem", function()
	return display.newNode()
end)


function SngItem:ctor(control)
	self.control_ = control 
	--find view by layout
	local node, width, height = cc.uiloader:load("sng_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	-- self.apply_btn_ = cc.uiloader:seekNodeByName(node,"apply_btn")
	-- 	:onButtonClicked(function ()
	-- 		self.control_:onHallClick()
	-- 	end)
		-- :setTouchSwallowEnabled(false)
	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(false)
	local startX,startY =0,0
	local down = false
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    -- event.name 是触摸事件的状态：began, moved, ended, cancelled
	    -- event.x, event.y 是触摸点当前位置
	    -- event.prevX, event.prevY 是触摸点之前的位置
	    -- printf("sprite: %s x,y: %0.2f, %0.2f",
	    --        event.name, event.x, event.y)

	    -- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
	    -- 则必须返回 true
	    dump(event)
		if event.name == "ended" then
        	self.mContentBg:scale(1)
		end
	    local x,y = event.x,event.y
	    if event.name == "began" then
	    	startX = x
        	startY = y
        	if not self:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
        	self.mContentBg:scale(0.9)
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" then
		    	tt.play.play_sound("click")
				-- tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.cashBtn)
				self.control_:loadSngList()
			end
		end
	end)
end

return SngItem
