--
-- Author: shineflag
-- Date: 2017-02-26 17:51:38
--


local CoinPot = class("CoinPot",function( ... )
	return display.newNode()
end) 

CoinPot.s_direction = {
	top = 1,
	down = 2,
	left = 3,
	right = 4,
	top_right = 5,
}


function CoinPot:ctor(base,direction)
	direction = direction or CoinPot.s_direction.left
	self.base_ = base

	self.mCoinBg = display.newScale9Sprite("dec/pot_bg.png",0,0,cc.size(52,28),cc.rect(30, 14,2, 2))
		:addTo(self)
	self.coin_img_ = display.newSprite("icon/icon_chip.png")
		:addTo(self)


	 -- 左对齐，并且多行文字顶部对齐
	self.coin_label_ = display.newTTFLabel({
	    text = "10000",
	    size = 31,
	    color = cc.c3b(255, 255, 255), -- 
	    align = cc.TEXT_ALIGNMENT_CENTER,
	    valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
	    -- dimensions = cc.size(100, 32)
	})
	:setPosition(0, 0)
	:addTo(self,100)

	self:setDirection(direction)

	self.coin_ = 0
	self:addCoin(0)

end

function CoinPot:setDirection(direction)
	if direction == CoinPot.s_direction.left then
		self.coin_img_:setTexture("icon/icon_chip.png")
		local size = self.coin_img_:getContentSize()
		self.coin_label_:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
		self.coin_label_:setAnchorPoint(cc.p(1,0.5))
		self.coin_label_:setPosition(-size.width/2-7,0)
		self.mCoinBg:setAnchorPoint(cc.p(1,0.5))
		self.mCoinBg:setPosition(0,0)
	elseif direction == CoinPot.s_direction.top then
		self.coin_img_:setTexture("icon/icon_pool_note.png")
		local size = self.coin_img_:getContentSize()
		self.coin_label_:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)
		self.coin_label_:setAnchorPoint(cc.p(0,0.5))
		self.coin_label_:setPosition(size.width/2+7,0)
		self.mCoinBg:setAnchorPoint(cc.p(0,0.5))
		self.mCoinBg:setPosition(0,0)
	elseif direction == CoinPot.s_direction.down then
		self.coin_img_:setTexture("icon/icon_pool_note.png")
		local size = self.coin_img_:getContentSize()
		self.coin_label_:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
		self.coin_label_:setAnchorPoint(cc.p(0.5,1))
		self.coin_label_:setPosition(0,-size.height/2+8)
		self.mCoinBg:setAnchorPoint(cc.p(0.5,1))
		self.mCoinBg:setPosition(0,-size.height/2+3)
	elseif direction == CoinPot.s_direction.right then
		self.coin_img_:setTexture("icon/icon_chip.png")
		local size = self.coin_img_:getContentSize()
		self.coin_label_:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)
		self.coin_label_:setAnchorPoint(cc.p(0,0.5))
		self.coin_label_:setPosition(size.width/2+7,0)
		self.mCoinBg:setAnchorPoint(cc.p(0,0.5))
		self.mCoinBg:setPosition(0,0)
	end
end

function CoinPot:setCoin(coin)
	self.coin_ = coin
	local str = tostring(self.coin_)
	self.coin_label_:setString(str)
	self:updateCoinBg()
end

function CoinPot:addCoin(coin)
	self.coin_ = self.coin_ + coin

	local str = tostring(self.coin_)
	self.coin_label_:setString(str)
	self:updateCoinBg()
end

function CoinPot:addCoinNotUpdateView(coin)
	self.coin_ = self.coin_ + coin
end

function CoinPot:updateView()
	local str = tostring(self.coin_)
	self.coin_label_:setString(str)
	self:updateCoinBg()
end

function CoinPot:updateCoinBg()
	local size = self.coin_label_:getContentSize()
	local w = math.max(size.width+40,52)
	self.mCoinBg:setContentSize(w,28)
end

function CoinPot:getCoin()
	return self.coin_
end
return CoinPot
