local BLDialog = require("app.ui.BLDialog")
local TAG = "EverydayListDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local EverydayListDialog = class("EverydayListDialog", function()
	return BLDialog.new()
end)


function EverydayListDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("everyday_list_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContextView = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	self.mReceiveBtn = cc.uiloader:seekNodeByName(node, "receive_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				tt.ghttp.request(tt.cmd.everyday_login,{})
			end)

	self.mVpNumBg = cc.uiloader:seekNodeByName(node, "vp_num_bg")
	self.mVpBg = cc.uiloader:seekNodeByName(node, "vp_bg")
	self.mVpIcon = cc.uiloader:seekNodeByName(node, "vp_icon")

	self.mGiftNumBg = cc.uiloader:seekNodeByName(node, "gift_num_bg")
	self.mGiftBg = cc.uiloader:seekNodeByName(node, "gift_bg")

	self.mDayItems = {}
end

function EverydayListDialog:show()
	BLDialog.show(self)
end

function EverydayListDialog:dismiss()
	BLDialog.dismiss(self)
end

function EverydayListDialog:onSuccess()
	self:playDaGouAnim()
	self:performWithDelay(function()
			self:dismiss()
		end, 1)
end

function EverydayListDialog:setData(data)
	local infos = checktable(data.info)
	local is_get = data.is_get

	for _,item in ipairs(self.mDayItems) do 
		item:removeSelf()
	end
	self.mDayItems = {}
	self.mCurItems = nil
	for i,info in ipairs(infos) do
		if i > 7 then break end
		local item = self:createDayItem(info)
		item:addTo(self.mContextView)
		table.insert(self.mDayItems,item)
		if self.mCurItems == nil and is_get == 0 and info.status == 0 then
			self.mCurItems = item
			local tips_view = display.newSprite("bg/bg_prize_sel.png")
			tips_view:setName("tips_view")
			tips_view:addTo(self.mCurItems)
			self.mCurItems:setLocalZOrder(1)
			tt.LayoutUtil:layoutParentCenter(tips_view,0,12)
		end
	end
	local len = #self.mDayItems
	if len > 0 then
		local offsetW = 1134/len
		for i,item in ipairs(self.mDayItems) do 
			tt.LayoutUtil:layoutParentLeft(item,28+offsetW*(i-1),-30)
		end
	end
	self.mReceiveBtn:setButtonEnabled(is_get == 0)

	self:setVpView(data.vp_money)
	self:setGiftView(data.gift_money)
end

function EverydayListDialog:playDaGouAnim()
	if self.mCurItems then
		local mask = cc.uiloader:seekNodeByName(self.mCurItems, "mask")
		local dagou = cc.uiloader:seekNodeByName(self.mCurItems, "dagou")
		local tips_view = self.mCurItems:getChildByName("tips_view")
		if tips_view then tips_view:removeSelf() end
		mask:setVisible(true)
		dagou:setVisible(true)
		dagou:stopAllActions()
		dagou:scale(8)
		dagou:opacity(0)
		dagou:scaleTo(0.4, 1)
		dagou:fadeTo(0.4,255)
	end
end

function EverydayListDialog:setVpView(num)
	if num == 0 then
		self.mVpNumBg:setVisible(false)
		self.mVpBg:setVisible(false)
	else
		self.mVpNumBg:setVisible(true)
		self.mVpBg:setVisible(true)
		local num = tt.getBitmapStrAscii("number/green00_%d.png","X"..tt.getNumShortStr(num))
		self.mVpNumBg:removeAllChildren()
		num:addTo(self.mVpNumBg)
		local size = num:getContentSize()
		local width = math.max(size.width+80,200)
		self.mVpNumBg:setContentSize(cc.size(width,59))
		tt.LayoutUtil:layoutParentLeft(num,60)

		local curLv = tt.owner:getVpLv()
		self.mVpIcon:setTexture(string.format("icon/vp_%d.png",curLv))
	end
end

function EverydayListDialog:updateVpLvView()
	local curLv = tt.owner:getVpLv()
	self.mVpIcon:setTexture(string.format("icon/vp_%d.png",curLv))
end

function EverydayListDialog:setGiftView(num)
	if num == 0 then
		self.mGiftNumBg:setVisible(false)
		self.mGiftBg:setVisible(false)
	else
		self.mGiftNumBg:setVisible(true)
		self.mGiftBg:setVisible(true)
		local num = tt.getBitmapStrAscii("number/green00_%d.png","X"..tt.getNumShortStr(num))
		self.mGiftNumBg:removeAllChildren()
		num:addTo(self.mGiftNumBg)
		local size = num:getContentSize()
		local width = math.max(size.width+80,200)
		self.mGiftNumBg:setContentSize(cc.size(width,59))
		tt.LayoutUtil:layoutParentLeft(num,60)
	end
end

function EverydayListDialog:createDayItem(info)
	local node, width, height = cc.uiloader:load("everyday_day_item.json")
	local title_txt = cc.uiloader:seekNodeByName(node, "title_txt")
	local mask = cc.uiloader:seekNodeByName(node, "mask")
	local dagou = cc.uiloader:seekNodeByName(node, "dagou")
	local item_bg = cc.uiloader:seekNodeByName(node, "item_bg")
	local status = checkint(info.status)
	local get_coin = checkint(info.get_coin)
	local get_gold = checkint(info.get_gold)
	title_txt:setString(tt.gettext("第{s1}天",checkint(info.day_num)))
	mask:setVisible(status == 1)
	dagou:setVisible(status == 1)

	local coinView = nil
	if get_coin ~= 0 then
		coinView = self:createRewardItem("icon/icon_chips00.png",get_coin)
		coinView:addTo(item_bg)
	end
	local goldView = nil
	if get_gold ~= 0 then
		goldView = self:createRewardItem("icon/icon_golds00.png",get_gold)
		goldView:addTo(item_bg)
	end

	if coinView and goldView then
		tt.LayoutUtil:layoutParentCenter(coinView,0,60)
		tt.LayoutUtil:layoutParentCenter(goldView,0,-60)
	else
		if coinView then
			tt.LayoutUtil:layoutParentCenter(coinView)
		end
		if goldView then
			tt.LayoutUtil:layoutParentCenter(goldView)
		end
	end
	return node
end

function EverydayListDialog:createRewardItem(iconImg,num)
	local icon = display.newSprite(iconImg)
	local numImg = tt.getBitmapStrAscii("number/yellow0_%d.png",tt.getNumShortStr(num))
	numImg:addTo(icon)
	tt.LayoutUtil:layoutParentBottom(numImg,0,-10)
	return icon
end

function EverydayListDialog:onEnter()
	self.gevt_handlers_ = {
		-- tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}

	self.mUserInfoEventHandlers = {
		-- tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateMoney)),
		-- tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_JUAN,handler(self,self.updateJuan)),
		tt.owner:addEventListener(tt.owner.EVENT_VP_LV,handler(self,self.updateVpLvView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VP_EXP,handler(self,self.updateVpExpView)),
	}
end

function EverydayListDialog:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

return EverydayListDialog