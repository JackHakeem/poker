--
-- Author: bearluo
-- Date: 2017-05-27
--

local BLDialog = require("app.ui.BLDialog")
local MyMatchListView = class("MyMatchListView", function()
	return BLDialog.new()
end)

local TAG = "MyMatchListView"

function MyMatchListView:ctor(control,data)
	self.control_ = control 
	self.data_ = data
	local node, width, height = cc.uiloader:load("my_match_list_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.back_btn = cc.uiloader:seekNodeByName(node,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	cc.uiloader:seekNodeByName(node,"serial_number"):setString(tt.gettext("序号"))
	cc.uiloader:seekNodeByName(node,"match_name"):setString(tt.gettext("名称"))
	cc.uiloader:seekNodeByName(node,"state"):setString(tt.gettext("状态"))

	self.match_view = cc.uiloader:seekNodeByName(node,"match_view")
	self.match_view_list_view = cc.uiloader:seekNodeByName(node,"list_view")
	-- self.back_btn = cc.uiloader:seekNodeByName(node,"close_btn")

    self.cashs_data = {}
    self.custom_room_data = {}
    self.matchs_data = {}
    self.mtt_matchs_data = {}
end

function MyMatchListView:show()
	BLDialog.show(self)
	self:setVisible(true)
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}
	self:showMatchListView()
end

function MyMatchListView:refresh()
	self.control_:getPlayingRoom()
end

function MyMatchListView:showMatchListView()
	self.control_:getPlayingRoom()
	self.match_view:setVisible(true)
end

function MyMatchListView:dismiss()
	BLDialog.dismiss(self)
	self:removeSelf()
end

function MyMatchListView:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end
	BLDialog.onExit(self)
end

function MyMatchListView:resetMatchList(matchs)
    self.matchs_data = matchs
    self:resetList()
end

function MyMatchListView:resetCashList(cashs)
    self.cashs_data = cashs
    self:resetList()
end

function MyMatchListView:resetCustomRoomList(room)
	self.custom_room_data = room
    self:resetList()
end

function MyMatchListView:resetMttMatchList(matchs)
    self.mtt_matchs_data = matchs
    self:resetList()
end


function MyMatchListView:resetList()
	self.match_view_list_view:removeAllItems()
	local sum = 0
	local cashs = self.cashs_data
	-- for i=1,10 do
	if cashs and next(cashs) then
		for index,data in ipairs(cashs) do
			sum = sum + 1
			local item = self.match_view_list_view:newItem()
			local content = app:createView("MyMatchListItem",self.control_,sum,data,kCashRoom)
			content:setDialogHandler(self)
			item:addContent(content)
			local size = content:getContentSize()
			item:setItemSize(size.width, size.height)
			item:setMargin({left = 0, right = 0, top = sum*10, bottom = 0})
			self.match_view_list_view:addItem(item)
		end
	end
	-- end

	local custom_room_data = self.custom_room_data
	if custom_room_data and next(custom_room_data) then
		for index,data in ipairs(custom_room_data) do
			sum = sum + 1
			local item = self.match_view_list_view:newItem()
			local content = app:createView("MyMatchListItem",self.control_,sum,data,kCustomRoom)
			content:setDialogHandler(self)
			item:addContent(content)
			local size = content:getContentSize()
			item:setItemSize(size.width, size.height)
			item:setMargin({left = 0, right = 0, top = sum*10, bottom = 0})
			self.match_view_list_view:addItem(item)
		end
	end

	local matchs = self.matchs_data
	if matchs and next(matchs) then
		for index,data in ipairs(matchs) do
			sum = sum + 1
			local item = self.match_view_list_view:newItem()
			local content = app:createView("MyMatchListItem",self.control_,sum,data,kSngRoom)
			content:setDialogHandler(self)
			item:addContent(content)
			local size = content:getContentSize()
			item:setItemSize(size.width, size.height)
			item:setMargin({left = 0, right = 0, top = sum*10, bottom = 0})
			self.match_view_list_view:addItem(item)
		end
	end


	local mtt_matchs = self.mtt_matchs_data
	if mtt_matchs and next(mtt_matchs) then
		for index,data in ipairs(mtt_matchs) do
			sum = sum + 1
			local item = self.match_view_list_view:newItem()
			local content = app:createView("MyMatchListItem",self.control_,sum,data,kMttRoom)
			content:setDialogHandler(self)
			item:addContent(content)
			local size = content:getContentSize()
			item:setItemSize(size.width, size.height)
			item:setMargin({left = 0, right = 0, top = sum*10, bottom = 0})
			self.match_view_list_view:addItem(item)
		end
	end
	self.match_view_list_view:reload()
end

function MyMatchListView:onSocketData(evt)
	printInfo("MyMatchListView:onSocketData cmd:[%s]",evt.cmd)	
	if evt.cmd == "sng.usersngs" then
		if evt.resp then
			local resp = evt.resp
			if resp.ret == 200 then
				local match = resp.matchs
				self:resetMatchList(match)
			else

			end
		end
	elseif evt.cmd == "cash.usercashs" then
		if evt.resp then
			local resp = evt.resp
			if resp.ret == 200 then
				local cashs = resp.cashs
				self:resetCashList(cashs)
			else

			end
		end
	elseif evt.cmd == "mtt.usermtts" then
		if evt.resp then
			local resp = evt.resp
			if resp.ret == 200 then
				local matchs = resp.matchs
				self:resetMttMatchList(matchs)
			else

			end
		end
	elseif evt.cmd == "custom.syn_tids" then
		if evt.resp then
			local resp = evt.resp
			if resp.ret == 200 then
				local tids = resp.tids
				self:resetCustomRoomList(tids)
			else

			end
		end
	end
end

return MyMatchListView
