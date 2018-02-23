local RoomReconnectView = class("RoomReconnectView", function()
	return display.newLayer()
end)

local TAG = "RoomReconnectView"
local net = require("framework.cc.net.init")

function RoomReconnectView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("room_reconnect_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))


	self.reconnect_view = cc.uiloader:seekNodeByName(node,"reconnect_view")

	self.reconnect_view_ = {}

	self.reconnectfail_view = cc.uiloader:seekNodeByName(node,"reconnectfail_view")

	cc.uiloader:seekNodeByName(node,"reconnect_txt"):setString(tt.gettext("網絡異常,重新連接中..."))
	cc.uiloader:seekNodeByName(node,"reconnectfail_txt"):setString(tt.gettext("網絡無法連接，請稍後再試！"))

	local rotationAction = cc.RepeatForever:create(cc.RotateBy:create(1.5, 360))
	cc.uiloader:seekNodeByName(node,"loading_anim"):runAction(rotationAction)

	self.reconnectfail_view_ = {}
	self.reconnectfail_view_.sure_btn = cc.uiloader:seekNodeByName(self.reconnectfail_view,"sure_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			tt.gsocket:reconnect()
			self:showReconnectView()
		end)
end

function RoomReconnectView:showReconnectView()
	self.reconnect_view:setVisible(true)
	self.reconnectfail_view:setVisible(false)
	self:setVisible(true)
end

function RoomReconnectView:showReconnectfailView()
	self.reconnect_view:setVisible(false)
	self.reconnectfail_view:setVisible(true)
	self:setVisible(true)
end

function RoomReconnectView:show()
	self:setVisible(true)
end

function RoomReconnectView:dismiss()
	self:setVisible(false)
end

return RoomReconnectView
