--
-- Author: shineflag
-- Date: 2017-05-19 16:42:26
--


-- local shop_data = {
	
-- 	[1] = {price="0.99 USD",coin=100000,pid="coin_p1_999_0.99usd"},
-- 	[2] = {price="1.99 USD",coin=200000,extra="",pid="coin_p1_999_0.99usd"},
-- 	[3] = {price="10.99 USD",coin=300000,extra="+10%",pid="coin_p1_999_0.99usd"},
-- 	[4] = {price="99 USD",coin=400000,extra="+20%",pid="coin_p1_999_0.99usd"},
-- 	[5] = {price="199 USD",coin=500000,extra="+30%",pid="coin_p1_999_0.99usd"},
-- 	[6] = {price="299 USD",coin=600000,extra="+40%",pid="coin_p1_999_0.99usd"},
-- 	[7] = {price="399 USD",coin=700000,extra="+50%",pid="coin_p1_999_0.99usd"},
-- 	[8] = {price="499 USD",coin=800000,extra="+60%",pid="coin_p1_999_0.99usd"},
-- }

local BLDialog = require("app.ui.BLDialog")

--系统推荐玩家可玩的场次
local PrizeCenterView = class("PrizeCenterView", function(...)
	return BLDialog.new(...)
end)

function PrizeCenterView:ctor(ctl)

	self.ctl_= ctl 
	--find view by layout
	local node, width, height = cc.uiloader:load("prize_center_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.vip_coin_txt = cc.uiloader:seekNodeByName(node,"vip_coin_txt")
	self.coin_txt = cc.uiloader:seekNodeByName(node,"coin_txt")

	self.vip_icon = cc.uiloader:seekNodeByName(node,"vip_icon")

    self.vip_icon:setTexture(string.format("dec/icon_vip".. tt.owner:getVipLv() .. ".png"))

	self.close_btn_ = cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	local lv = tt.owner:getVipLv()
    if tt.game_data.vip_info[lv] then
		local lv_info = tt.game_data.vip_info[lv]
		local pre_exp = tt.game_data.vip_info[lv-1] and tt.game_data.vip_info[lv-1].exp or 0
		local exp = tt.owner:getVipExp()
		print("MainScene:updateVipView",lv_info.exp,pre_exp)
		local percentage = (exp-pre_exp)*100/(lv_info.exp-pre_exp)
		if percentage < 0 then percentage = 0 end
		if percentage > 100 then percentage = 100 end
	    self:setVipExpPercent(percentage)
    end


    cc.uiloader:seekNodeByName(node,"name"):setString(tt.gettext("名称"))
    cc.uiloader:seekNodeByName(node,"inventory"):setString(tt.gettext("庫存"))
    cc.uiloader:seekNodeByName(node,"vip_score"):setString(tt.gettext("vip點數"))
    cc.uiloader:seekNodeByName(node,"vip_level"):setString(tt.gettext("vip等級"))
		


	self.goods_list_view = cc.uiloader:seekNodeByName(node, "goods_list_view")
	self.menu_list = cc.uiloader:seekNodeByName(node, "menu_list")
	self.mGoodsItems = {}
    -- self:initMenuView()

   	self:setVisible(false)

end

function PrizeCenterView:initMenuView(data)
	local shop_data = data
	self.menu_list:removeAllItems()
	self.menu_view = {}
	for index,v in ipairs(shop_data) do
		local item = self.menu_list:newItem()
		local content = app:createView("PrizeCenterViewMenuItem", self.ctl_, index,clone(v))
		content:setOnChoiceClick(handler(self, self.choiceMenu))
		item:addContent(content)
		local size = content:getContentSize()
		item:setItemSize(size.width, size.height)
		self.menu_list:addItem(item)
		self.menu_view[index] = content
	end

	self.menu_list:reload()
	if #shop_data > 0 then
		self:choiceMenu(1,shop_data[1])
	end
end

function PrizeCenterView:setVipExpPercent(percent)

end

function PrizeCenterView:choiceMenu(index,data)
	for i,view in ipairs(self.menu_view) do
		view:setSelected(index == i)
	end
	self:initPageView(data)
end

function PrizeCenterView:initPageView(data)
	self.goods_list_view:removeAllItems()
	self.mGoodsItems = {}
	if not data or not data.vstoreinfo then
		self.goods_list_view:reload()
		return 
	end
	local vstoreinfo = data.vstoreinfo
	dump(data)
	for k,v in ipairs(vstoreinfo) do
		local item = self.goods_list_view:newItem()
		local content = app:createView("PrizeCenterViewItem", self.ctl_, v)
		item:addContent(content)
		local size = content:getContentSize()
		item:setItemSize(size.width, size.height)
		self.goods_list_view:addItem(item)
		table.insert(self.mGoodsItems,content)
	end
	self.goods_list_view:reload()
end

function PrizeCenterView:onExchange(data)
	if data.ret == 0 or data.ret == 6 then
		local params = data.data
		for i,item in ipairs(self.mGoodsItems) do
			if item:checkVsid(params.vsid) then
				item:setNum(params.num)
			end
			item:updateBtnCheck()
		end
	end
end

function PrizeCenterView:show()
	BLDialog.show(self)
	self:updateVipScoreView()
	self:updateMoney()
	self:setVisible(true)
	tt.ghttp.request(tt.cmd.vstore,{})
end

function PrizeCenterView:dismiss()
	BLDialog.dismiss(self)
	self:setVisible(false)
end

function PrizeCenterView:updateVipScoreView()
	self.vip_coin_txt:setString(tt.getNumStr(tt.owner:getVipScore()))
end

function PrizeCenterView:updateMoney()
	self.coin_txt:setString(tt.getNumStr(tt.owner:getMoney()))
end

function PrizeCenterView:onEnter()
	self.gevt_handlers_ = {
		-- tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}

	self.mUserInfoEventHandlers = {
		tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateMoney)),
		-- tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_JUAN,handler(self,self.updateJuan)),
	}
end

function PrizeCenterView:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

return PrizeCenterView
