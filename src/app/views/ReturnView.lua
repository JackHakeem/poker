--
-- Author: shineflag
-- Date: 2017-04-20 16:18:51
--

local ReturnView = class("ReturnView", function()
	return display.newNode()
end)


function ReturnView:ctor(control)

	self.control_ = control 

	--find view by layout
	local node, width, height = cc.uiloader:load("return_view.json")
	self:addChild(node)
	self.root_ = node

    self.return_btn_ = cc.uiloader:seekNodeByName(node,"return_btn")
    	:onButtonClicked(function ()
			tt.play.play_sound("click")
			self.control_.mControler:onOnlineClick()
			self:setVisible(false)
    	end)
    self.root_:setTouchEnabled(true)
    self.root_:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    return true
	end)
end

return ReturnView
