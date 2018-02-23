--
-- Author: shineflag
-- Date: 2017-02-24 17:51:26
--
-- 游戏中的圆形头像

local SliderProgressSelectView = class("SliderProgressSelectView", function()
	return display.newNode()
end)

local SliderBgLevel = 1
local ScaleViewLevel = 2
local SliderBg2Level = 3
local SliderBtnLevel = 4

function SliderProgressSelectView:ctor(params)
	params = checktable(params)
	self.mSelectIndex = 1
	self.mSelectConfig = {}
	self.mOffsetWidth = 0
	self.mWidth = 0
	self.mHeight = 0
	self.mInTouch = false
	dump(params)
	self.mSliderBg = display.newScale9Sprite(params.SliderBgFile or "bg/slider_bg05.png",0,0, params.SliderBgSize or cc.size(29,27),params.SliderBgCapInsets or cc.rect(14, 13,1, 1))
	self.mSliderSelBg = display.newScale9Sprite("bg/slider_bg04.png",0,0,cc.size(22,19),cc.rect(11, 9,1, 1))
	self.mSliderBtn = display.newSprite("btn/btn_slider.png")
	self.mSliderBtn:scale(0.8)

	self.mSliderBg:addTo(self,SliderBgLevel)
	self.mSliderSelBg:addTo(self,SliderBg2Level)
	self.mSliderBtn:addTo(self,SliderBtnLevel)

	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self,self.onTouch_))
	self.mSliderBtn:setTouchEnabled(true)
	self.mSliderBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self,self.onSliderBtnTouch_))

	self.mIndexChangeListener = nil
end

function SliderProgressSelectView:setSliderSize(width, height)
	local size = self:getContentSize()
	self.mWidth = width
	self.mHeight = height
	self.mSliderBg:setContentSize(cc.size(width+8, 28))
	self.mSliderBg:setPosition(cc.p(width/2, size.height/2))
	self.mSliderSelBg:setPositionY(size.height/2)
	self.mSliderBtn:setPositionY(size.height/2)
end

function SliderProgressSelectView:setSelectConfig(config)
	self.mSelectConfig = config
end

function SliderProgressSelectView:resetSliderScale()
	local count = #self.mSelectConfig
	if count == 0 then return end
	if count == 1 then
		self.mSelectIndex = 1
		self.mOffsetWidth = 0
		self:selectIndex(self.mSelectIndex)
		return 
	end
	self.mOffsetWidth = self.mWidth / (count - 1)

	local len = #self.mSelectConfig
	if self.mSelectIndex > len then self.mSelectIndex = len end
	self:selectIndex(self.mSelectIndex)
end

function SliderProgressSelectView:selectIndex(index)
	print(index,self.mSelectConfig[index])
	if not self.mSelectConfig[index] then return end

	self.mSelectIndex = index
	local x = self.mSliderBtn:getPosition()
	self.mSliderSelBg:setContentSize(cc.size(x,19))
	self.mSliderSelBg:setPositionX(x/2)

	if not self.mInTouch then
		-- 播放移动动画
		self:onTouchEnd()
	else
		local len = #self.mSelectConfig
		if self.mSelectIndex > len then self.mSelectIndex = len end

		if self.mIndexChangeListener then
			self.mIndexChangeListener(self.mSelectIndex)
		end
	end
end

-- 选择数字
function SliderProgressSelectView:selectNum(num)
	if #self.mSelectConfig == 0 then return end
	-- 修正选择数字
	local start = 1
	for i,config in ipairs(self.mSelectConfig) do
		if config <= num then
			start = i
		end
	end
	self:selectIndex(start)
end

function SliderProgressSelectView:setSliderBtnX(x)
	self.mSliderBtn:setPositionX(x)
end

function SliderProgressSelectView:registerIndexChangeListener(listener)
	self.mIndexChangeListener = listener
end

function SliderProgressSelectView:onTouchEnd()
	if #self.mSelectConfig == 0 then return end
	-- 修正选择数字
	
	print("onTouchEnd",self.mSelectIndex,self.mSelectConfig[self.mSelectIndex])
	local len = #self.mSelectConfig
	if self.mSelectIndex > len then self.mSelectIndex = len end

	if self.mIndexChangeListener then
		self.mIndexChangeListener(self.mSelectIndex)
	end

	local x = (self.mSelectIndex - 1) * self.mOffsetWidth
	if #self.mSelectConfig == 1 then
		x = self.mWidth
	end
	self.mSliderBtn:stopAllActions()
	self.mSliderBtn:moveTo(0.2, x)
	self.mSliderBtn:schedule(function()
			local x = self.mSliderBtn:getPosition()
			self.mSliderSelBg:setContentSize(cc.size(x,19))
			self.mSliderSelBg:setPositionX(x/2)
		end, 0)
	self.mSliderBtn:performWithDelay(function()
			self.mSliderBtn:stopAllActions()
		end, 0.3)
end

function SliderProgressSelectView:onTouch_(event)
    local name, x, y = event.name, event.x, event.y
    if name == "began" then
    	self.mSliderStartX = x
    	self.mSliderStartY = y
    	if not self:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
    	self.mSliderDown = true
    	self.mInTouch = true
    	return true 
    elseif event.name ~= "began" and self.mSliderDown then
    	if math.abs(self.mSliderStartX-x) > 10 or math.abs(self.mSliderStartY-y) > 10 then
    		self.mSliderDown = false
    	end

    	if event.name == "ended" and self.mSliderDown then
    		self.mSliderDown = false
    		self.mInTouch = false
			local pos = self:convertToNodeSpace(cc.p(x, y))
			if self.mWidth ~= 0 and self.mOffsetWidth ~= 0 then
				local px = pos.x
				if px < 0 then px = 0 end
				if px > self.mWidth then px = self.mWidth end
				local f = px % self.mOffsetWidth
				local index = ( px - f) / self.mOffsetWidth + math.round( f / self.mOffsetWidth ) + 1
				if index > #self.mSelectConfig then index = #self.mSelectConfig end
				if index < 1 then index = 1 end
				self:selectIndex(index)
			end
			self:onTouchEnd()
		end
	end
end

function SliderProgressSelectView:onSliderBtnTouch_(event)
    local name, x, y = event.name, event.x, event.y
    print("onSliderStartBtnTouch_",name)
    if name == "began" then
    	self.mSliderBtnStartX = x
    	self.mSliderBtnStartY = y
    	if not self.mSliderBtn:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
    	self.mSliderBtnDown = true
		self.mInTouch = true
    	return true 
    elseif event.name ~= "began" then
    	local ret = true
    	if math.abs(self.mSliderBtnStartX-x) > 10 or math.abs(self.mSliderBtnStartY-y) > 10 then
    		self.mSliderBtnDown = false
    	end
    	if not self.mSliderBtnDown then
    		local pos = self:convertToNodeSpace(cc.p(x, y))
			if self.mWidth ~= 0 and self.mOffsetWidth ~= 0 then
				local px = pos.x
				if px < 0 then px = 0 end
				if px > self.mWidth then px = self.mWidth end
				local f = px % self.mOffsetWidth
				local index = (px - f) / self.mOffsetWidth + math.round( f / self.mOffsetWidth ) + 1
				if index > #self.mSelectConfig then index = #self.mSelectConfig end
				if index < 1 then index = 1 end
				self:setSliderBtnX(px)
				self:selectIndex(index)
			end
		end

    	if event.name == "ended" then
    		self.mSliderBtnDown = false
    		self.mInTouch = false
			self:onTouchEnd()
		end
		return ret
	end
end

return SliderProgressSelectView
