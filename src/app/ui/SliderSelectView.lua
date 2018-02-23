--
-- Author: shineflag
-- Date: 2017-02-24 17:51:26
--
-- 游戏中的圆形头像

local SliderSelectView = class("SliderSelectView", function()
	return display.newNode()
end)

local SliderBgLevel = 1
local ScaleViewLevel = 2
local SliderBtnLevel = 3

function SliderSelectView:ctor()
	self.mSelectNum = 0
	self.mSelectConfig = {}
	self.mOffsetWidth = 0
	self.mWidth = 0
	self.mHeight = 0
	self.mInTouch = false

	self.mScalePath = "dec/dec_point.png"
	self.mSliderBg = display.newScale9Sprite("bg/slider_bg.png",0,0,cc.size(20,19),cc.rect(10, 10,1, 1))
	self.mSliderBtn = display.newSprite("btn/btn_slider2.png")

	self.mSliderBg:addTo(self,SliderBgLevel)
	self.mSliderBtn:addTo(self,SliderBtnLevel)
	self.mScaleViews = {}

	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self,self.onTouch_))
	self.mSliderBtn:setTouchEnabled(true)
	self.mSliderBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self,self.onSliderBtnTouch_))
	local size = self.mSliderBtn:getContentSize()
	local node = display.newNode()
	node:setContentSize(cc.size(size.width+40,size.height+40))
	node:addTo(self.mSliderBtn)
	tt.LayoutUtil:layoutParentCenter(node)

	self.mIndexChangeListener = nil
end

function SliderSelectView:setSliderSize(width, height)
	local size = self:getContentSize()
	self.mWidth = width
	self.mHeight = height
	self.mSliderBg:setContentSize(cc.size(width, height))
	self.mSliderBg:setPosition(cc.p(width/2, size.height/2))
	for _,view in ipairs(self.mScaleViews) do
		view:setPositionY(size.height/2)
	end
	self.mSliderBtn:setPositionY(size.height/2)
end

function SliderSelectView:setSelectConfig(config)
	self.mSelectConfig = config
end

function SliderSelectView:resetSliderScale()
	local count = #self.mSelectConfig
	if count == 0 then return end
	if count == 1 then
		self:selectNum(self.mSelectNum)
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

	self:selectNum(self.mSelectNum)
end

function SliderSelectView:createScaleView(config)
	local scaleView = display.newSprite(self.mScalePath)
	local numTxt = display.newTTFLabel({
            text = config,
            size = 25,
            color=cc.c3b(0x1c,0x76,0xac),
        })
	local select_status = false

	numTxt:addTo(scaleView)
	tt.LayoutUtil:layoutParentTop(numTxt,0,25)

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
	return scaleView
end

function SliderSelectView:selectIndex(index)
	if not self.mSelectConfig[index] then return end
	self.mSelectNum = self.mSelectConfig[index]
	for i,view in ipairs(self.mScaleViews) do
		-- 播放选中动画
		-- 播放取消选中动画
		view:setSelect(i==index)
	end

	if not self.mInTouch then
		-- 播放移动动画
		self:onTouchEnd()
	else
		if self.mIndexChangeListener then
			self.mIndexChangeListener(index)
		end
	end
end

-- 选择数字
function SliderSelectView:selectNum(num)
	if #self.mSelectConfig == 0 then return end
	-- 修正选择数字
	local find = 1
	for i,config in ipairs(self.mSelectConfig) do
		if config <= num then
			find = i
		end
	end
	self:selectIndex(find)
end

function SliderSelectView:setSliderBtnX(x)
	self.mSliderBtn:setPositionX(x)
end

function SliderSelectView:registerIndexChangeListener(listener)
	self.mIndexChangeListener = listener
end

function SliderSelectView:onTouchEnd()
	if #self.mSelectConfig == 0 then return end
	-- 修正选择数字
	local find = 1
	for i,config in ipairs(self.mSelectConfig) do
		if config <= self.mSelectNum then
			find = i
		end
	end

	if self.mIndexChangeListener then
		self.mIndexChangeListener(find)
	end

	local size = self.mSliderBtn:getContentSize()
	local x = (find - 1) * self.mOffsetWidth
	self.mSliderBtn:stopAllActions()
	self.mSliderBtn:moveTo(0.2, x)
end

function SliderSelectView:onTouch_(event)
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

function SliderSelectView:onSliderBtnTouch_(event)
    local name, x, y = event.name, event.x, event.y
    if name == "began" then
    	self.mSliderBtnStartX = x
    	self.mSliderBtnStartY = y
    	local rect = self.mSliderBtn:getCascadeBoundingBox()
    	rect.x = rect.x - 20
    	rect.y = rect.y - 20
    	rect.width = rect.width + 40
    	rect.height = rect.height + 40
    	if not rect:containsPoint(cc.p(x, y)) then return false end
    	self.mSliderBtnDown = true
    	self.mInTouch = true
    	return true 
    elseif event.name ~= "began" then
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
				self:selectIndex(index)
				self:setSliderBtnX(px)
			end
		end

    	if event.name == "ended" then
    		self.mSliderBtnDown = false
    		self.mInTouch = false
			self:onTouchEnd()
		end
	end
end

return SliderSelectView
