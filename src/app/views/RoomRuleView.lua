--
-- Author: shineflag
-- Date: 2017-03-03 17:40:14
--
local BLDialog = require("app.ui.BLDialog")
local RoomRuleView = class("RoomRuleView",function( ... )
	return BLDialog.new()
end) 

function RoomRuleView:ctor(ctl)

	self.ctl_ = ctl 

	local node, width, height = cc.uiloader:load("rule_view.json")
	self:addChild(node)
	self.root_ = node

	local bg = cc.uiloader:seekNodeByName(node,"content_view")
	bg:setTouchEnabled(true)
	bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event) return true end)
	
	self:initTouch()
end

function RoomRuleView:show()
	BLDialog.show(self)
end

function RoomRuleView:dismiss()
	BLDialog.dismiss(self)
end

function RoomRuleView:initTouch()
	self:setTouchEnabled(true)
		-- 注册触摸事件
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    if event.name == "began" then
    		self.ctl_:dismissRuleView()
	    end
	end)
end

return RoomRuleView

