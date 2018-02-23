--
-- Author: shineflag
-- Date: 2017-02-23 19:10:54
--

local LevelItem = class("LevelItem", function()
	return display.newNode()
end)


function LevelItem:ctor(control, data)



	self.control_ = control 

	self.lv_ = data.lv

	--find view by layout
	local node, width, height = cc.uiloader:load("level_node.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.bb_label_ = cc.uiloader:seekNodeByName(node,"bb_label")
		:setString( tostring(data.bb) )

	self.player_label_ = cc.uiloader:seekNodeByName(node,"player_label")
		:setString( tostring(data.player) )

	self:addTouchEvt()

end

function LevelItem:addTouchEvt()
	self:setTouchEnabled(true)

	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    -- event.name 是触摸事件的状态：began, moved, ended, cancelled
	    -- event.x, event.y 是触摸点当前位置
	    -- event.prevX, event.prevY 是触摸点之前的位置
	    -- printf("sprite: %s x,y: %0.2f, %0.2f",
	    --        event.name, event.x, event.y)

	    -- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
	    -- 则必须返回 true
	    if event.name == "began" then
	    	return true 
	    elseif event.name == "moved" then

	    elseif  event.name == "ended" then
	    	if self:hitTest(cc.p(event.x, event.y)) then 
	    		--print(self.lv_)
	    		self.control_:onItemClick(self.lv_)
	    	else
	    		--print(event.x,event.y)

	    	end
		end
	end)
end



return LevelItem
