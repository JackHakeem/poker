--
-- Author: shineflag
-- Date: 2017-03-03 17:40:14
--

local BLDialog = require("app.ui.BLDialog")
local RoomShareView = class("RoomShareView",function( ... )
	return BLDialog.new()
end) 

function RoomShareView:ctor(ctl)

	self.ctl_ = ctl 

	local node, width, height = cc.uiloader:load("room_share_view.json")
	self:addChild(node)
	self.root_ = node

	local touch_handler = cc.uiloader:seekNodeByName(node,"touch_handler")
	touch_handler:setTouchEnabled(true)
	touch_handler:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event) return true end)
	
	self.mTouchHandler = touch_handler


   	cc.uiloader:seekNodeByName(node,"close_btn")
        :onButtonClicked(function(event)
			tt.play.play_sound("click")
        	self:dismiss()
        end)

   	cc.uiloader:seekNodeByName(node,"line_share_btn")
        :onButtonClicked(function(event)
			tt.play.play_sound("click")
			local params = tt.platformEventHalper.cmds.sysShareString
			local room = self.ctl_.mModel:getCustomRoomParams()
			local msg = ""
			if room.ante > 0 then
				msg = tt.gettext("专属房[{s1}]-[ID:{s2}],盲注{s3}前注{s4}.快来加入",room.name,room.roomid,string.format("%s/%s",room.sb,room.sb*2),room.ante)
			else
				msg = tt.gettext("专属房[{s1}]-[ID:{s2}],盲注{s3}.快来加入",room.name,room.roomid,string.format("%s/%s",room.sb,room.sb*2))
			end
			params.args = {
				msg = msg,
				url = kShareUrl,
			}
			local ok,ret = tt.platformEventHalper.callEvent(params)
        	self:dismiss()
        end)

   	cc.uiloader:seekNodeByName(node,"laba_btn")
        :onButtonClicked(function(event)
			tt.play.play_sound("click")
			self.ctl_:showSpeakerEditDialog()
        	self:dismiss()
        end)

	self:initTouch()
end

function RoomShareView:show( is_sit ,is_offline)
	BLDialog.show(self)
end

function RoomShareView:dismiss()
	BLDialog.dismiss(self)
end

function RoomShareView:initTouch()
	self:setTouchEnabled(true)
		-- 注册触摸事件
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    local x,y = event.x,event.y
	    if event.name == "began" then
	    	if self.mTouchHandler and not self.mTouchHandler:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
	    		self:dismiss()
	    	end
	    end	
	end)
end

return RoomShareView

