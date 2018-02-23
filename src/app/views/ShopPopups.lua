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
local ShopPopups = class("ShopPopups", function(...)
	return BLDialog.new(...)
end)

function ShopPopups:ctor(ctl)

	self.ctl_= ctl 
	--find view by layout
	local node, width, height = cc.uiloader:load("shop_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))
	-- self:setAnchorPoint(cc.p(0.5,0.5))
	-- 	:setPosition(CONFIG_SCREEN_WIDTH/2,CONFIG_SCREEN_HEIGHT/2)

	self.coin_label_ = cc.uiloader:seekNodeByName(node,"coin_label")


	self.close_btn_ = cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	self.vp_bg = cc.uiloader:seekNodeByName(node, "vp_bg")
	self.vp_bg:setTouchEnabled(true)
	self.vp_bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		    local x,y = event.x,event.y
		    if event.name == "began" then
		    	startX = x
	        	startY = y
	        	if not self.vp_bg:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
	        	down = true
		    	return true 
		    elseif event.name ~= "began" and down then
		    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
		    		down = false
		    	end
		    	if event.name == "ended" then
					tt.play.play_sound("click")
					self.ctl_:showVpDialog()
				end
			end
		end)
		


	self.goods_list_view = cc.uiloader:seekNodeByName(node, "goods_list_view")

	self.pmode_list_view = cc.uiloader:seekNodeByName(node, "pmode_list_view")

	self.pmode_btns = {}
	
	self.prop_type_btns = {}

	self.prop_type_btns[1] = cc.uiloader:seekNodeByName(node, "chips_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:selectShowType(1)
		end)

	self.prop_type_btns[2] = cc.uiloader:seekNodeByName(node, "gift_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:selectShowType(2)
		end)

	self.prop_type_btns[3] = cc.uiloader:seekNodeByName(node, "prop_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:selectShowType(3)
		end)

	cc.uiloader:seekNodeByName(node, "chips_titile"):setString(tt.gettext("筹码"))
	cc.uiloader:seekNodeByName(node, "gift_titile"):setString(tt.gettext("礼包"))
	cc.uiloader:seekNodeByName(node, "prop_titile"):setString(tt.gettext("道具"))

	self.mCurVp = cc.uiloader:seekNodeByName(node, "cur_vp")
	self.mNextVp = cc.uiloader:seekNodeByName(node, "next_vp")

	self.mVpExpBg = cc.uiloader:seekNodeByName(node, "vp_exp_bg")
	self.mVpExpProgress = display.newDrawNode()
	local mask = display.newSprite("bg/bg_article01_vipclub.png")
	local size = self.mVpExpBg:getContentSize()
	local clip_node = cc.ClippingNode:create()
	clip_node:setStencil(self.mVpExpProgress);
	clip_node:addChild(mask)
	clip_node:setPosition(cc.p(size.width/2-5,size.height/2+1));
	clip_node:setAlphaThreshold(0.05)  --不显示模板的透明区域
	clip_node:setInverted( false ) --显示模板不透明的部分
	clip_node:addTo(self.mVpExpBg)

	self.mExpProcessTxt = cc.uiloader:seekNodeByName(node, "exp_process_txt")
	self.mExpNeedTxt = cc.uiloader:seekNodeByName(node, "exp_need_txt")

	self:updateVp()
end

function ShopPopups:updateVp()
	local curLv = tt.owner:getVpLv()
	if curLv == 6 then curLv = 5 end
	self.mCurVp:setTexture(string.format("icon/vp_%d.png",curLv))
	local nextLv = curLv + 1
	self.mNextVp:setTexture(string.format("icon/vp_%d.png",nextLv))
	self:updateVpExpView()
end

function ShopPopups:updateVpExpView()
	local size = self.mVpExpBg:getContentSize()
	local curLv = tt.owner:getVpLv()
	local curExp = tt.owner:getVpExp()
	local vpExpConfig = tt.nativeData.getVpExpConfig()
	local per = 0
	if curLv == 6 then 
		per = 1 
		local nExp = vpExpConfig[curLv] or 0
		self.mExpProcessTxt:setString(string.format("%d/%d",curExp,nExp))
		self.mExpNeedTxt:setString(tt.gettext("尚需{s1}VP",0))
	else
		local nExp = vpExpConfig[curLv+1] or 0
		per = curExp / nExp
		self.mExpProcessTxt:setString(string.format("%d/%d",curExp,nExp))
		self.mExpNeedTxt:setString(tt.gettext("尚需{s1}VP",nExp - curExp))
	end
	if per < 0 then per = 0 end
	if per > 1 then per = 1 end
	self.mVpExpProgress:clear()
	local pts1 = {
	    cc.p(-size.width/2, -size.height/2),  -- point 1
	    cc.p(-size.width/2, size.height/2),  -- point 1
	    cc.p(size.width*per-size.width/2, size.height/2),  -- point 2
	    cc.p(size.width*per-size.width/2, -size.height/2),  -- point 2
	}
	self.mVpExpProgress:drawPolygon(pts1, {
        fillColor = cc.c4f(1, 1, 1, 1),
        borderWidth = 0,
        borderColor = cc.c4f(1, 1, 1, 1)
    })
end

function ShopPopups:initPageView()
	local pmodeInfos = tt.nativeData.getShopInfo()
	self.pmode_list_view:removeAllItems()
	local find = false 
	self.pmode_btns = {}
	for _,pmodeInfo in ipairs(pmodeInfos) do
		local labelTxt = nil
		if pmodeInfo.pmode == 1 then
			labelTxt = "gl"
		elseif pmodeInfo.pmode == 2 then
			labelTxt = "appstore"
		elseif pmodeInfo.pmode == 3 then
			labelTxt = "sms"
		elseif pmodeInfo.pmode == 4 then
			labelTxt = "bluecoins"
		elseif pmodeInfo.pmode == 5 then
			-- labelTxt = "Dtac"
		elseif pmodeInfo.pmode == 6 then
			labelTxt = "truemoney"
		elseif pmodeInfo.pmode == 7 then
			labelTxt = "12call"
		elseif pmodeInfo.pmode == 8 then
			labelTxt = "lineplay"
		end
		if labelTxt then
			local item = self.pmode_list_view:newItem()
			local w = 239
			local h = 90
			local content = display.newNode()
			-- local label = display.newTTFLabel({
			-- 	    text = labelTxt,
			-- 	    size = 36,
			-- 	    color = cc.c3b(255,255,255),
			-- 	    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
			-- 	})
			local btn = cc.ui.UIPushButton.new({
					normal = string.format("btn/tab_%s.png",labelTxt),
					pressed = string.format("btn/tab_%s_sel.png",labelTxt),
					disabled = string.format("btn/tab_%s_sel.png",labelTxt),
				})
			btn:setTouchEnabled(true)
			btn:setTouchSwallowEnabled(false)
			btn:onButtonClicked(function()
					for _,view in ipairs(self.pmode_btns) do
						view:setButtonEnabled(true)
					end
					btn:setButtonEnabled(false)
					self:setShowShopData(pmodeInfo.goods)
				end)
			btn:addTo(content)
			btn:setPosition(cc.p(w/2, h/2))
			-- label:addTo(content)
			-- label:setPosition(cc.p(w/2, h/2))
			content:setContentSize(w, h)
			item:addContent(content)
			item:setItemSize(w, h)
			item:setMargin({left = 0, right = 0, top = 10, bottom = 0})
			self.pmode_list_view:addItem(item)
			table.insert(self.pmode_btns,btn)
			if not find then
				find = true
				btn:setButtonEnabled(false)
				self:setShowShopData(pmodeInfo.goods)
			end
		end
	end

	self.pmode_list_view:reload()
end

function ShopPopups:setShowShopData(data)
	self.mGoodsDatas = data
	self:selectShowType(1)
end

function ShopPopups:selectShowType(index)
	for i,btn in ipairs(self.prop_type_btns) do
		btn:setButtonEnabled(i~=index)
	end

	if not self.mGoodsDatas then return end
	self.goods_list_view:removeAllItems()
	dump(pmodeInfos,"initPageView")
	local shop_data = {}
	local className = "ShopItem"
	if index == 2 then
		className = "ShopItem2"
	elseif index == 3 then
		self:initLabaItems()
		return 
	end
	for k,v in ipairs(self.mGoodsDatas) do
		if v.type == index then
			table.insert(shop_data,v)
		end
	end
	for k,data in ipairs(shop_data) do
		local item = self.goods_list_view:newItem()
		local content = app:createView(className, self.ctl_, data)
		local size = content:getContentSize()
		item:addContent(content)
		item:setItemSize(size.width, size.height)
		item:setMargin({left = 0, right = 0, top = 20, bottom = 0})
		self.goods_list_view:addItem(item)
	end
	self.goods_list_view:reload()
end

function ShopPopups:initLabaItems()
	local shop_data = {}
	-- for i=1,10 do
		for k,v in ipairs(self.mGoodsDatas) do
			if v.type == 3 then
				table.insert(shop_data,v)
			end
		end
	-- end
	for k=1,#shop_data,3 do
		local item = self.goods_list_view:newItem()
		local content = display.newNode()
		for i=0,2 do
			local index = i+k
			local data = shop_data[index]
			if data then
				local prop = app:createView("ShopItem3", self.ctl_, data)
				tt.linearlayout(content,prop,31)
			end
		end
		local size = content:getContentSize()
		content:setContentSize(cc.size(size.width, 222))
		item:addContent(content)
		item:setItemSize(size.width, 222)
		item:setMargin({left = 0, right = 0, top = 20, bottom = 0})
		self.goods_list_view:addItem(item)
	end
	self.goods_list_view:reload()
end

function ShopPopups:show()
	BLDialog.show(self)
	self:updateMoney()
	self:setVisible(true)
	self:initPageView()

	local params = {}
	tt.ghttp.request(tt.cmd.getshops,params)
 --   	self:setScale(0.2)
	-- local action = cc.ScaleTo:create(0.5, 1, 1)
	-- self:runAction(transition.newEasing(action,"BACKINOUT"))
end

function ShopPopups:dismiss()
	BLDialog.dismiss(self)
	self:setVisible(false)
end

function ShopPopups:updateMoney()
	self.coin_label_:setString(tt.getNumStr(tt.owner:getMoney()))
end

function ShopPopups:onEnter()
	self.gevt_handlers_ = {
		-- tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}

	self.mUserInfoEventHandlers = {
		tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateMoney)),
		-- tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_JUAN,handler(self,self.updateJuan)),
		tt.owner:addEventListener(tt.owner.EVENT_VP_LV,handler(self,self.updateVp)),
		tt.owner:addEventListener(tt.owner.EVENT_VP_EXP,handler(self,self.updateVpExpView)),
	}
end

function ShopPopups:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

return ShopPopups
