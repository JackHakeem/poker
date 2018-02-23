local BLDialog = require("app.ui.BLDialog")
local TAG = "TouzhuExchangeView"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local TouzhuExchangeView = class("TouzhuExchangeView", function()
	return BLDialog.new()
end)


function TouzhuExchangeView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("touzhu_exchange_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	self.mSliderView = cc.uiloader:seekNodeByName(node,"slider_view")
	self.mSliderBtn = cc.uiloader:seekNodeByName(self.mSliderView,"slider_btn")
	self.mSliderBtn:setTouchEnabled(true)
	self.mSliderBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))
	self.mSliderProgress = cc.uiloader:seekNodeByName(self.mSliderView,"slider_progress")

	cc.uiloader:seekNodeByName(node, "add_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			if self.mMinExchange < self.mMaxExchange then
				self:setExchange( self.mCurExchange + self.mMinExchange )
			end
		end)

	cc.uiloader:seekNodeByName(node, "sub_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			if self.mMinExchange < self.mMaxExchange then
				self:setExchange( self.mCurExchange - self.mMinExchange )
			end
		end)

	cc.uiloader:seekNodeByName(node, "sure_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			local left = tt.nativeData.getXiazhuMinLeft()
			local unit = tt.nativeData.getXiazhuMinUnit()
			local money = tt.owner:getMoney() - left
			if self.mCurExchange < money then
				tt.gsocket.request("happydice.money2gold",{
						mid = tt.owner:getUid(),
						num = self.mCurExchange,
					})
				self:dismiss()
			else
				local goods = tt.getSuitableGoodsByMoney(unit-money)
				if goods then
					self.control_:showRecommendGoodsDialog(goods)
				else
					tt.show_msg(tt.gettext("筹码不足"))
				end
			end
		end)

	self.mChipsBg = cc.uiloader:seekNodeByName(node, "chips_bg")
	self.mCoinsBg = cc.uiloader:seekNodeByName(node, "coins_bg")
end

function TouzhuExchangeView:show()
	BLDialog.show(self)
	self:updateSlider()
end

function TouzhuExchangeView:dismiss()
	BLDialog.dismiss(self)
end

function TouzhuExchangeView:updateSlider()
	local left = tt.nativeData.getXiazhuMinLeft()
	local unit = tt.nativeData.getXiazhuMinUnit()
	local money = tt.owner:getMoney() - left
	self.mMinExchange = unit
	if money < 0 then
		money = 0
	end
	self.mMaxExchange = money - money % self.mMinExchange
	-- if self.mMaxExchange < self.mMinExchange then
	-- 	self.mMaxExchange = self.mMinExchange
	-- 	self:setPercent(100)
	-- else
		self:setPercent(0)
	-- end
end

function TouzhuExchangeView:setPercent(percent)
	if percent > 100 then percent = 100 end
	if percent < 0 then percent = 0 end

	local size = self.mSliderView:getContentSize()
	self.mSliderBtn:setPositionX(30+(size.width-60)*percent/100)
	self.mSliderProgress:setPercent(percent)
	if self.mMinExchange <= self.mMaxExchange then
		self.mCurExchange = self.mMinExchange + (self.mMaxExchange - self.mMinExchange) * percent / 100
		self.mCurExchange = self.mCurExchange - self.mCurExchange % self.mMinExchange
	else
		self.mCurExchange = 0
	end
	print(tt.owner:getMoney(),self.mCurExchange,self.mMaxExchange,self.mMinExchange,percent)
	self:setChipsNum(tt.owner:getMoney() - self.mCurExchange)
	self:setCoinsNum(self.mCurExchange)
end

function TouzhuExchangeView:setExchange(exchange)
	if exchange > self.mMaxExchange then exchange = self.mMaxExchange end
	if exchange < self.mMinExchange then exchange = self.mMinExchange end

	self.mCurExchange = exchange
	local percent = (self.mCurExchange - self.mMinExchange) / (self.mMaxExchange - self.mMinExchange) * 100
	local size = self.mSliderView:getContentSize()
	self.mSliderBtn:setPositionX(30+(size.width-60)*percent/100)
	self.mSliderProgress:setPercent(percent)
	print(tt.owner:getMoney(),self.mCurExchange,self.mMaxExchange,self.mMinExchange,percent)
	self:setChipsNum(tt.owner:getMoney() - self.mCurExchange)
	self:setCoinsNum(self.mCurExchange)
end

function TouzhuExchangeView:setChipsNum(num)
	self.mChipsBg:removeAllChildren()
	local node = display.newNode()
	local icon = display.newSprite("icon/icon_chip7.png")
	local numTxt = display.newTTFLabel({
		    text = "X" .. tt.getNumShortStr2(num),
		    size = 43,
		    color = cc.c3b(255,255,255),
		})

	tt.linearlayout(node,icon,0,3)
	tt.linearlayout(node,numTxt,0,-5)
	local size = node:getContentSize()
	local w = math.max(size.width+30,77)

	node:addTo(self.mChipsBg)
	node:setPosition(cc.p(10,0))
	self.mChipsBg:setContentSize(cc.size(w,50))
end

function TouzhuExchangeView:setCoinsNum(num)
	self.mCoinsBg:removeAllChildren()
	local node = display.newNode()
	local icon = display.newSprite("icon/icon_gold1.png")
	local numTxt = display.newTTFLabel({
		    text = "X" .. tt.getNumShortStr2(num),
		    size = 43,
		    color = cc.c3b(255,255,255),
		})

	tt.linearlayout(node,icon,0,3)
	tt.linearlayout(node,numTxt,0,-5)
	local size = node:getContentSize()
	local w = math.max(size.width+30,77)

	node:addTo(self.mCoinsBg)
	node:setPosition(cc.p(10,0))
	self.mCoinsBg:setContentSize(cc.size(w,50))
end

function TouzhuExchangeView:onTouch_(event)
    local name, x, y = event.name, event.x, event.y
    local pos = self.mSliderView:convertToNodeSpace(cc.p(x,y))
	local size = self.mSliderView:getContentSize()
	if self.mMinExchange < self.mMaxExchange then
    	self:setPercent(pos.x/size.width*100)
    end

 --    if "began" == event.name then
 --    	self.select_btn:setPosition(self.start_w+diff,25)
	-- elseif "moved" == event.name then
	-- 	self.select_btn:setPosition(self.start_w+diff,25)
	-- elseif "ended" == event.name then
	-- 	self.select_btn:setPosition(self.start_w + (self.mSelectIndex-1)*self.offset_w,25)
	-- end
    return true
end

return TouzhuExchangeView