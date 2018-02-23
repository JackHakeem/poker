--
-- Author: shineflag
-- Date: 2017-05-19 17:36:13
--


local ShopItem = class("ShopItem", function()
	return display.newNode()
end)


function ShopItem:ctor(ctl, data)
	self.ctl_ = ctl 
	self.mData=data
	--find view by layout
	local node, width, height = cc.uiloader:load("shop_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.shop_item = cc.uiloader:seekNodeByName(node,"shop_item")

	self.goods_icon = cc.uiloader:seekNodeByName(node,"goods_icon")

	--金币
	self.gold_txt = cc.uiloader:seekNodeByName(node,"money_txt"):setVisible(false)
		-- :setString(tt.getNumStr(data.coin))
	
	--价格
	self.price_str = cc.uiloader:seekNodeByName(node,"price_txt")
		:setString( string.format("%s %s",data.cy,data.price))
	-- self:setPriceTxt(price)

	--格外加赠多少
	self.offer_bg = cc.uiloader:seekNodeByName(node,"percent_bg")
	self.percent_txt = cc.uiloader:seekNodeByName(node,"percent_txt"):setVisible(false)

	self.old_money_txt = cc.uiloader:seekNodeByName(node,"old_money_txt")
	self.old_money_line = cc.uiloader:seekNodeByName(node,"old_money_line")
	self.old_money_txt:setString(tt.getNumStr(data.old_coin))
	local size = self.old_money_txt:getContentSize()
	local size2 = self.old_money_line:getContentSize()
	self.old_money_line:setScaleX(size.width/size2.width)

	cc.uiloader:seekNodeByName(node,"buy_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.ctl_:payGoods(self.mData)
			end)
	self:addTouch()

	self.mVpTxt = cc.uiloader:seekNodeByName(node,"vp_txt")
	self.tips_txt = cc.uiloader:seekNodeByName(node,"tips_txt")
	self:updateVpLv()
end

function ShopItem:updateVpNum()
	if tt.owner:isFirstPay() then
		self.mVpTxt:setString(string.format("+%dVP",self.mData.first_vp))
	else
		self.mVpTxt:setString(string.format("+%dVP",self.mData.vp))
	end
end

function ShopItem:setGoldTxt(num,isCenter)
	if not tolua.isnull(self.mChipsNumImg) then self.mChipsNumImg:removeSelf() end
	self.mChipsNumImg = tt.getBitmapStrAscii("number/green00_%d.png",tt.getNumStr(num))
	self.mChipsNumImg:scale(0.6)
	self.mChipsNumImg:addTo(self.shop_item)
	if isCenter then
		tt.LayoutUtil:layoutCenter(self.mChipsNumImg,self.gold_txt,0,-19)
	else
		tt.LayoutUtil:layoutCenter(self.mChipsNumImg,self.gold_txt)
	end
end

function ShopItem:setOffer(num)
	if not tolua.isnull(self.mOfferNumImg) then self.mOfferNumImg:removeSelf() end
	print(num)
	self.mOfferNumImg = tt.getBitmapStrAscii("number/yellow1_%d.png",num.."%")
	self.mOfferNumImg:addTo(self.offer_bg)
	tt.LayoutUtil:layoutCenter(self.mOfferNumImg,self.percent_txt)
end

function ShopItem:updateVpLv()
	local lv = tt.owner:getVpLv()
	local vpPayConfig = tt.nativeData.getVpPayConfig()
	local per = (vpPayConfig[lv] or 100) /100
	local money = math.ceil(self.mData.coin * per)
	local isGive = money ~= self.mData.old_coin and self.mData.old_coin ~= 0
	self:setGoldTxt(money,not isGive)
	self:updateOldMoney(isGive)
	if self.mData.old_coin == 0 then
		self:setOffer(0)
	else
		self:setOffer(checkint(money/self.mData.old_coin*100))
	end

	self.tips_txt:setString(string.format("1%s=%s",self.mData.cy,math.floor(money/self.mData.price_num)))
	self:updateVpNum()
end

function ShopItem:updateOldMoney(isShow)
	self.old_money_txt:setVisible(isShow)
	self.old_money_line:setVisible(isShow)
	self.offer_bg:setVisible(isShow)
end

function ShopItem:addTouch()
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(false)
	local startX,startY =0,0
	local down = false
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    -- event.name 是触摸事件的状态：began, moved, ended, cancelled
	    -- event.x, event.y 是触摸点当前位置
	    -- event.prevX, event.prevY 是触摸点之前的位置
	    -- printf("sprite: %s x,y: %0.2f, %0.2f",
	    --        event.name, event.x, event.y)

	    -- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
	    -- 则必须返回 true
	    local x,y = event.x,event.y
	    if event.name == "began" then
	    	startX = x
        	startY = y
        	if not self:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" then
				tt.play.play_sound("click")
				self.ctl_:payGoods(self.mData)
			end
		end
	end)
end

function ShopItem:onEnter()
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
		tt.owner:addEventListener(tt.owner.EVENT_VP_LV,handler(self,self.updateVpLv)),
		tt.owner:addEventListener(tt.owner.EVENT_FRIST_PAY,handler(self,self.updateVpNum)),
	}
end

function ShopItem:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
end

return ShopItem
