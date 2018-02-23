local HallReconnectView = class("HallReconnectView", function()
	return display.newLayer()
end)

local TAG = "HallReconnectView"
local net = require("framework.cc.net.init")

function HallReconnectView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("hall_reconnect_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))


	self.reconnect_view = cc.uiloader:seekNodeByName(node,"reconnect_view")

	self.reconnect_view_ = {}
	self.reconnect_view_.close_btn = cc.uiloader:seekNodeByName(self.reconnect_view,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			tt.gsocket:disconnect()
			self:dismiss()
		end)

	cc.uiloader:seekNodeByName(node,"reconnect_txt"):setString(tt.gettext("網絡異常,重新連接中..."))
	cc.uiloader:seekNodeByName(node,"reconnectfail_txt"):setString(tt.gettext("網絡無法連接，請稍後再試！"))

	local rotationAction = cc.RepeatForever:create(cc.RotateBy:create(1.5, 360))
	cc.uiloader:seekNodeByName(node,"loading_anim"):runAction(rotationAction)

	self.reconnectfail_view = cc.uiloader:seekNodeByName(node,"reconnectfail_view")

	self.reconnectfail_view_ = {}
	self.reconnectfail_view_.sure_btn = cc.uiloader:seekNodeByName(self.reconnectfail_view,"sure_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:dismiss()
		end)
end

function HallReconnectView:showReconnectView()
	self.reconnect_view:setVisible(true)
	self.reconnect_view_.close_btn:setVisible(false)
	self.reconnect_view_.close_btn:stopAllActions()
	self.reconnect_view_.close_btn:performWithDelay(function()
           		self.reconnect_view_.close_btn:setVisible(self.reconnect_view:isVisible())
           	end, 2)

	self.reconnectfail_view:setVisible(false)
	self:setVisible(true)
end

function HallReconnectView:showReconnectfailView()

	self.reconnect_view:setVisible(false)

	self.reconnectfail_view:setVisible(true)
	self:setVisible(true)
end

function HallReconnectView:show()
	self:setVisible(true)
end

function HallReconnectView:dismiss()
	self:setVisible(false)
end

return HallReconnectView
