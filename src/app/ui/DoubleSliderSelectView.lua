--
-- Author: shineflag
-- Date: 2017-02-24 17:51:26
--
-- 游戏中的圆形头像

local DoubleSliderSelectView = class("DoubleSliderSelectView", function()
	return display.newNode()
end)

local SliderBgLevel = 1
local ScaleViewLevel = 2
local SliderBg2Level = 3
local SliderBtnLevel = 4

function DoubleSliderSelectView:ctor()
	self.mSelectStartIndex = 1
	self.mSelectEndIndex = 1
	self.mSelectConfig = {}
	self.mOffsetWidth = 0
	self.mWidth = 0
	self.mHeight = 0
	self.mInTouch = false

	self.mScaleNorPath = "dec/dec_point.png"
	self.mScaleSelPath = "dec/dec_point01.png"
	self.mSliderBg = display.newScale9Sprite("bg/slider_bg.png",0,0,cc.size(14,13),cc.rect(7, 6,1, 1))
	self.mSliderSelBg = display.newScale9Sprite("bg/slider_bg01.png",0,0,cc.size(12,11),cc.rect(6, 5,1, 1))
	self.mSliderStartBtn = display.newSprite("btn/btn_slider2.png")
	self.mSliderEndBtn = display.newSprite("btn/btn_slider2.png")

	self.mSliderBg:addTo(self,SliderBgLevel)
	self.mSliderSelBg:addTo(self,SliderBg2Level)
	self.mSliderStartBtn:addTo(self,SliderBtnLevel)
	self.mSliderEndBtn:addTo(self,SliderBtnLevel)
	self.mScaleViews = {}



	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self,self.onTouch_))
	self.mSliderStartBtn:setTouchEnabled(true)
	self.mSliderStartBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self,self.onTouch_))
	self.mSliderEndBtn:setTouchEnabled(true)
	self.mSliderEndBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self,self.onTouch_))

	self.mIndexChangeListener = nil
end

function DoubleSliderSelectView:setSliderSize(width, height)
	local size = self:getContentSize()
	self.mWidth = width
	self.mHeight = height
	self.mSliderBg:setContentSize(cc.size(width, 13))
	self.mSliderBg:setPosition(cc.p(width/2, size.height/2))
	self.mSliderSelBg:setPositionY(size.height/2)
	for _,view in ipairs(self.mScaleViews) do
		view:setPositionY(size.height/2)
	end
	self.mSliderStartBtn:setPositionY(size.height/2)
	self.mSliderEndBtn:setPositionY(size.height/2)
end

function DoubleSliderSelectView:setSelectConfig(config)
	self.mSelectConfig = config
end

function DoubleSliderSelectView:resetSliderScale()
	local count = #self.mSelectConfig
	if count == 0 then return end
	if count == 1 then
		self.mSelectStartIndex = 1
		self.mSelectEndIndex = 1
		self:selectIndex(self.mSelectStartIndex,self.mSelectEndIndex)
		return 
	end
	self.mOffsetWidth = self.mWidth / (count - 1)

	for _,view in ipairs(self.mScaleViews) do
		view:removeSelf()
	end
	self.mScaleViews = {}

	local startX = 0
	for i,config in ipairs(self.mSelectConfig) do
		local scaleView = self:createScaleView(config)
		local size = scaleView:getContentSize()
		local fsize = self:getContentSize()
		scaleView:setPosition(cc.p(startX,fsize.height/2))
		startX = startX + self.mOffsetWidth
		scaleView:addTo(self,ScaleViewLevel)
		self.mScaleViews[i] = scaleView
	end

	local len = #self.mSelectConfig
	if self.mSelectStartIndex > len then self.mSelectStartIndex = len end
	if self.mSelectEndIndex > len then self.mSelectEndIndex = len end

	self:selectIndex(self.mSelectStartIndex,self.mSelectEndIndex)
end

function DoubleSliderSelectView:createScaleView(config)
	local scaleView = display.newSprite(self.mScaleNorPath)
	local scaleSelView = display.newSprite(self.mScaleSelPath)
	local numTxt = display.newTTFLabel({
            text = config,
            size = 25,
            color=cc.c3b(0x1c,0x76,0xac),
        })
	local select_status = false

	scaleSelView:addTo(scaleView)
	numTxt:addTo(scaleView)
	tt.LayoutUtil:layoutParentTop(numTxt,0,25)
	tt.LayoutUtil:layoutParentCenter(scaleSelView)

	local x,y = numTxt:getPosition()

	scaleView.setSelect = function(view,flag)
		if select_status == flag then return end
		select_status = flag
		numTxt:stopAllActions()
		if select_status then
			numTxt:setColor(cc.c3b(0xff,0xff,0xff))
			numTxt:moveTo(0.2, x, y+3)
		else
			numTxt:setColor(cc.c3b(0x1c,0x76,0xac))
			numTxt:moveTo(0.2, x, y)
		end
	end

	scaleView.setSelVisible = function(view,flag)
		scaleSelView:setVisible(flag)
	end

	return scaleView
end

function DoubleSliderSelectView:selectIndex(startIndex,endIndex)
	if not self.mSelectConfig[startIndex] or not self.mSelectConfig[endIndex] then return end

	self.mSelectStartIndex = startIndex
	self.mSelectEndIndex = endIndex
	local startX = self.mSliderStartBtn:getPosition()
	local endX = self.mSliderEndBtn:getPosition()
	for i,view in ipairs(self.mScaleViews) do
		-- 播放选中动画
		-- 播放取消选中动画
		view:setSelect(i == startIndex or i == endIndex)
		local x = view:getPosition()
		view:setSelVisible(x >= startX and x <= endX)
	end

	self.mSliderSelBg:setContentSize(cc.size(endX-startX,11))
	self.mSliderSelBg:setPositionX(startX/2+endX/2)

	if not self.mInTouch then
		-- 播放移动动画
		self:onTouchEnd()
	else
		local len = #self.mSelectConfig
		if self.mSelectStartIndex > len then self.mSelectStartIndex = len end
		if self.mSelectEndIndex > len then self.mSelectEndIndex = len end

		if self.mIndexChangeListener then
			self.mIndexChangeListener(self.mSelectStartIndex,self.mSelectEndIndex)
		end
	end
end

-- 选择数字
function DoubleSliderSelectView:selectNum(num1,num2)
	if #self.mSelectConfig == 0 then return end
	-- 修正选择数字
	local findStart = 1
	local endStart = 1
	for i,config in ipairs(self.mSelectConfig) do
		if config <= num1 then
			findStart = i
		end
		if config <= num2 then
			endStart = i
		end
	end
	self:selectIndex(findStart,endStart)
end

function DoubleSliderSelectView:setSliderStartBtnX(x)
	self.mSliderStartBtn:setPositionX(x)
end

function DoubleSliderSelectView:setSliderEndBtnX(x)
	self.mSliderEndBtn:setPositionX(x)
end

function DoubleSliderSelectView:registerIndexChangeListener(listener)
	self.mIndexChangeListener = listener
end

function DoubleSliderSelectView:onTouchEnd()
	if #self.mSelectConfig == 0 then return end
	-- 修正选择数字
	
	local len = #self.mSelectConfig
	if self.mSelectStartIndex > len then self.mSelectStartIndex = len end
	if self.mSelectEndIndex > len then self.mSelectEndIndex = len end

	if self.mIndexChangeListener then
		self.mIndexChangeListener(self.mSelectStartIndex,self.mSelectEndIndex)
	end

	local x = (self.mSelectStartIndex - 1) * self.mOffsetWidth
	self.mSliderStartBtn:stopAllActions()
	self.mSliderStartBtn:moveTo(0.2, x)
	self.mSliderStartBtn:schedule(function()
			local startX = self.mSliderStartBtn:getPosition()
			local endX = self.mSliderEndBtn:getPosition()
			for i,view in ipairs(self.mScaleViews) do
				-- 播放选中动画
				-- 播放取消选中动画
				local x = view:getPosition()
				view:setSelVisible(x >= startX and x <= endX)
			end
			self.mSliderSelBg:setContentSize(cc.size(endX-startX,11))
			self.mSliderSelBg:setPositionX(startX/2+endX/2)
		end, 0)
	self.mSliderStartBtn:performWithDelay(function()
			self.mSliderStartBtn:stopAllActions()
		end, 0.3)

	local x = (self.mSelectEndIndex - 1) * self.mOffsetWidth
	self.mSliderEndBtn:stopAllActions()
	self.mSliderEndBtn:moveTo(0.2, x)
end

function DoubleSliderSelectView:onTouch_(event)
    local name, x, y = event.name, event.x, event.y
    if name == "began" then
    	self.mSliderStartBtnInTouch = self:onSliderStartBtnTouch_(event)
    	self.mSliderEndBtnInTouch = self:onSliderEndBtnTouch_(event)
    	if not self.mSliderStartBtnInTouch and not self.mSliderEndBtnInTouch then return false end
    	self.mInTouch = true
    	return true 
    elseif event.name ~= "began" then
    	print(self.mSliderStartBtnInTouch,self.mSliderEndBtnInTouch)
    	if self.mSliderStartBtnInTouch then
    		if not self.mSliderStartBtnInTouch then
    			self:onSliderStartBtnTouch_(event)
    		else
    			self.mSliderStartBtnInTouch = self:onSliderStartBtnTouch_(event)
    		end
    	end

    	if self.mSliderEndBtnInTouch then
    		-- 2个同时被按下的时候进行选择判断 选择判断完后就不在进行2次判断了
    		if not self.mSliderStartBtnInTouch then
    			self:onSliderEndBtnTouch_(event)
    		else
    			self.mSliderEndBtnInTouch = self:onSliderEndBtnTouch_(event)
    		end
    	end

    	if event.name == "ended" then
    		self.mInTouch = false
    		self.mSliderStartBtnInTouch = false
    		self.mSliderEndBtnInTouch = false
		end
	end
end

function DoubleSliderSelectView:onSliderStartBtnTouch_(event)
    local name, x, y = event.name, event.x, event.y
    print("onSliderStartBtnTouch_",name)
    if name == "began" then
    	self.mSliderStartBtnStartX = x
    	self.mSliderStartBtnStartY = y
    	local rect = self.mSliderStartBtn:getCascadeBoundingBox()
    	rect.x = rect.x - 20
    	rect.y = rect.y - 20
    	rect.width = rect.width + 40
    	rect.height = rect.height + 40
    	if not rect:containsPoint(cc.p(x, y)) then return false end
    	self.mSliderStartBtnDown = true
    	return true 
    elseif event.name ~= "began" then
    	local ret = true
    	if math.abs(self.mSliderStartBtnStartX-x) > 10 or math.abs(self.mSliderStartBtnStartY-y) > 10 then
    		self.mSliderStartBtnDown = false
    	end
    	if not self.mSliderStartBtnDown then
    		local pos = self:convertToNodeSpace(cc.p(x, y))
			if self.mWidth ~= 0 and self.mOffsetWidth ~= 0 then
				local px = pos.x
				if px < 0 then px = 0 end
				if px > self.mWidth then px = self.mWidth end
				local ex = (self.mSelectEndIndex - 1) * self.mOffsetWidth
				if px > ex then 
					ret = false
					px = ex 
				end
				local f = px % self.mOffsetWidth
				local index = (px - f) / self.mOffsetWidth + math.round( f / self.mOffsetWidth ) + 1
				if index > #self.mSelectConfig then index = #self.mSelectConfig end
				if index < 1 then index = 1 end
				self:setSliderStartBtnX(px)
				self:selectIndex(index,self.mSelectEndIndex)
			end
		end

    	if event.name == "ended" then
    		self.mSliderStartBtnDown = false
			self:onTouchEnd()
		end
		return ret
	end
end


function DoubleSliderSelectView:onSliderEndBtnTouch_(event)
    local name, x, y = event.name, event.x, event.y
    print("onSliderEndBtnTouch_",name)
    if name == "began" then
    	self.mSliderBtnStartX = x
    	self.mSliderBtnStartY = y
    	local rect = self.mSliderEndBtn:getCascadeBoundingBox()
    	rect.x = rect.x - 20
    	rect.y = rect.y - 20
    	rect.width = rect.width + 40
    	rect.height = rect.height + 40
    	if not rect:containsPoint(cc.p(x, y)) then return false end
    	self.mSliderBtnDown = true
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
				local sx = (self.mSelectStartIndex - 1) * self.mOffsetWidth
				if px < sx then 
					ret = false
					px = sx 
				end
				local f = px % self.mOffsetWidth
				local index = (px - f) / self.mOffsetWidth + math.round( f / self.mOffsetWidth ) + 1
				if index > #self.mSelectConfig then index = #self.mSelectConfig end
				if index < 1 then index = 1 end
				self:setSliderEndBtnX(px)
				self:selectIndex(self.mSelectStartIndex,index)
			end
		end

    	if event.name == "ended" then
    		self.mSliderBtnDown = false
			self:onTouchEnd()
		end
		return ret
	end
end

return DoubleSliderSelectView
