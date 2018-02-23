--
-- Author: shineflag
-- Date: 2017-05-19 17:36:13
--


local ShopItem2 = class("ShopItem2", function()
	return display.newNode()
end)


function ShopItem2:ctor(ctl, data)
	self.ctl_ = ctl 
	self.mData=data
	--find view by layout
	local node, width, height = cc.uiloader:load("shop_item_2.json")
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

	cc.uiloader:seekNodeByName(node,"buy_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.ctl_:payGoods(self.mData)
			end)
	self:addTouch()

	self.num_txt = cc.uiloader:seekNodeByName(node,"num_txt"):setVisible(false)
	self.day_num_txt = cc.uiloader:seekNodeByName(node,"day_num_txt"):setVisible(false)

	self.mVpTxt = cc.uiloader:seekNodeByName(node,"vp_txt")
	self:updateVpNum()
	self:setGoldTxt(self.mData.coin)

	if self.mData.gettype == 1 then
		cc.uiloader:seekNodeByName(node,"gift_icon"):setTexture("icon/libao.png")
	elseif self.mData.gettype == 2 then
		cc.uiloader:seekNodeByName(node,"gift_icon"):setTexture("icon/libao_gold.png")
	elseif self.mData.gettype == 3 then
		cc.uiloader:seekNodeByName(node,"gift_icon"):setTexture("icon/laba.png")
		cc.uiloader:seekNodeByName(node,"gift_icon"):scale(0.8)
	end

	if self.mData.gettype == 1 then
		self:setNumTxt(self.mData.num)
		self:setDayNumTxt(self.mData.daygetnum,self.mData.day)
	else
		self:setNumTxt(self.mData.num,true)
	end
end

function ShopItem2:setDayNumTxt(daygetnum,day)
	if not tolua.isnull(self.mDayNumImg) then self.mDayNumImg:removeSelf() end
	self.mDayNumImg = tt.getBitmapStrAscii("number/green00_%d.png",string.format("(%dX%d",daygetnum,day))
	local day = display.newSprite("fonts/day.png")
	local dec = display.newSprite("number/green00_41.png")
	tt.linearlayout(self.mDayNumImg,day)
	tt.linearlayout(self.mDayNumImg,dec)
	self.mDayNumImg:addTo(self.shop_item)
	self.mDayNumImg:scale(0.5)
	tt.LayoutUtil:layoutRight(self.mDayNumImg,self.day_num_txt)
end

function ShopItem2:setNumTxt(num,isCenter)
	if not tolua.isnull(self.mNumImg) then self.mNumImg:removeSelf() end
	self.mNumImg = tt.getBitmapStrAscii("number/green00_%d.png",tt.getNumStr(num))
	self.mNumImg:addTo(self.shop_item)
	self.mNumImg:scale(0.5)
	if isCenter then
		tt.LayoutUtil:layoutRight(self.mNumImg,self.num_txt,0,-19)
	else
		tt.LayoutUtil:layoutRight(self.mNumImg,self.num_txt)
	end
end

function ShopItem2:setGoldTxt(num)
	if not tolua.isnull(self.mChipsNumImg) then self.mChipsNumImg:removeSelf() end
	self.mChipsNumImg = tt.getBitmapStrAscii("number/green00_%d.png",tt.getNumStr(num))
	self.mChipsNumImg:scale(0.5)
	self.mChipsNumImg:addTo(self.shop_item)
	tt.LayoutUtil:layoutCenter(self.mChipsNumImg,self.gold_txt)
end

function ShopItem2:updateVpNum()
	if tt.owner:isFirstPay() then
		self.mVpTxt:setString(string.format("+%dVP",self.mData.first_vp))
	else
		self.mVpTxt:setString(string.format("+%dVP",self.mData.vp))
	end
end

function ShopItem2:addTouch()
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

function ShopItem2:onEnter()
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
		-- tt.owner:addEventListener(tt.owner.EVENT_VP_LV,handler(self,self.updateVpLv)),
		tt.owner:addEventListener(tt.owner.EVENT_FRIST_PAY,handler(self,self.updateVpNum)),
	}
end

function ShopItem2:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
end

return ShopItem2
