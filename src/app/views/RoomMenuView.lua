--
-- Author: shineflag
-- Date: 2017-03-03 17:40:14
--

local BLDialog = require("app.ui.BLDialog")
local RoomMenuView = class("RoomMenuView",function( ... )
	return BLDialog.new()
end) 

function RoomMenuView:ctor(ctl)

	self.ctl_ = ctl 

	local node, width, height = cc.uiloader:load("room_menu_view.json")
	self:addChild(node)
	self.root_ = node

	local touch_handler = cc.uiloader:seekNodeByName(node,"touch_handler")
	touch_handler:setTouchEnabled(true)
	touch_handler:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event) return true end)
	
	self.mTouchHandler = touch_handler


	self.continue_btn_ = cc.uiloader:seekNodeByName(node,"continue_btn")
        :onButtonClicked(function(event)
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuContinueBtn)
			tt.play.play_sound("click")
        	self:dismiss()
        end)


	self.back_btn_ = cc.uiloader:seekNodeByName(node,"back_btn")
        :onButtonClicked(function(event)
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuBackBtn)
			tt.play.play_sound("click")
        	self.ctl_.mControler:onBackClick()
        	self:dismiss()
        end)

    self.stand_btn_ = cc.uiloader:seekNodeByName(node,"stand_btn")
        :onButtonClicked(function(event)
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuStandBtn)
			tt.play.play_sound("click")
        	self.ctl_.mControler:onStandClick()
			self:dismiss()
        end)

    self.switch_btn_ = cc.uiloader:seekNodeByName(node,"change_btn")
        :onButtonClicked(function(event)
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuOfflineBtn)
			tt.play.play_sound("click")
        	self.ctl_.mControler:onRetainClick()
        	self:dismiss()
        end)


    self.help_btn_ = cc.uiloader:seekNodeByName(node,"help_btn")
        :onButtonClicked(function(event)
			tt.play.play_sound("click")
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuSettingBtn)
        	self.ctl_:showSettingView()
			self:dismiss()
        end)

    self.change_table_btn_ = cc.uiloader:seekNodeByName(node,"change_table_btn")
        :onButtonClicked(function(event)
			tt.play.play_sound("click")
        	self.ctl_.mControler:onChangeRoomClick()
        	self:dismiss()
        end)

	self:initTouch()
end

function RoomMenuView:show( is_sit ,is_offline)
	BLDialog.show(self)

	if is_sit and (self.ctl_.mModel:getRoomType() == kCashRoom or self.ctl_.mModel:getRoomType() == kCustomRoom) then 
		self.stand_btn_:setButtonEnabled(true)
	else
		self.stand_btn_:setButtonEnabled(false)
	end

	if self.ctl_.mModel:getRoomType() == kCashRoom then 
		self.change_table_btn_:setButtonEnabled(true)
	else
		self.change_table_btn_:setButtonEnabled(false)
	end

	if is_offline then
		self.switch_btn_:setButtonEnabled(true)
	else
		self.switch_btn_:setButtonEnabled(false)
	end
end

function RoomMenuView:dismiss()
	BLDialog.dismiss(self)
end

function RoomMenuView:initTouch()
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

return RoomMenuView

