--
-- Author: shineflag
-- Date: 2017-05-19 17:36:13
--

local PropDataHelper = require("app.libs.PropDataHelper")

local PrizeCenterViewItem = class("PrizeCenterViewItem", function()
	return display.newNode()
end)


function PrizeCenterViewItem:ctor(ctl, data)
	self:setNodeEventEnabled(true)


	self.ctl_ = ctl 
	self.mData = data
	--find view by layout
	local node, width, height = cc.uiloader:load("prize_center_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.vip_icon = cc.uiloader:seekNodeByName(node, "vip_icon")
	
	self.mName = cc.uiloader:seekNodeByName(node, "name")
	self.mNum = cc.uiloader:seekNodeByName(node, "num")
	self.mVipNum = cc.uiloader:seekNodeByName(node, "vip_num")

	self.mExchangeBtn = cc.uiloader:seekNodeByName(node, "exchange_btn")
		
	self:setNum(data.num)
	self.mDefaultIcon = cc.uiloader:seekNodeByName(node, "default_icon")

	local sprite = display.newSprite("dec/juhua.png")
	sprite:setTag(1)
	local index = 0
	sprite:schedule(function()
        index = (index + 40) % 360
        sprite:rotation(index)
    end,0.1)

	local size = self.mDefaultIcon:getContentSize()
	sprite:setTag(1)
	sprite:addTo(self.mDefaultIcon)
	sprite:setPosition(cc.p(size.width/2,size.height/2))

	self.mHandler = PropDataHelper.register(data.pid,handler(self,self.setPropData))
	self:addTouch()
	self:updateVpLv()
end

function PrizeCenterViewItem:checkVsid(vsid)
	return self.mData.vsid == vsid
end

function PrizeCenterViewItem:updateVpLv()
	local lv = tt.owner:getVpLv()
	local vpExchangeConfig = tt.nativeData.getVpExchangeConfig()
	local per = (vpExchangeConfig[lv] or 100) /100
	local money = math.ceil(self.mData.coin * per)
	self.mVipNum:setString(money)
	self:updateBtnCheck()
end

function PrizeCenterViewItem:setNum(num)
	num = tonumber(num) or 0
	self.mNum:setString(num)
	self.mData.num = num
end

function PrizeCenterViewItem:updateBtnCheck()

	local lv = tt.owner:getVpLv()
	local vpExchangeConfig = tt.nativeData.getVpExchangeConfig()
	local per = (vpExchangeConfig[lv] or 100) /100
	local money = math.ceil(self.mData.coin * per)
	
	if tt.owner:getMaxVipLv() < tonumber(self.mData.vlevel) or money > tt.owner:getVipScore() or tonumber(self.mData.num) <= 0 then
		if tt.owner:getMaxVipLv() < tonumber(self.mData.vlevel) then
    		self.vip_icon:setTexture(string.format("dec/icon_vip".. self.mData.vlevel .. "_grey.png"))
    	else
    		self.vip_icon:setTexture(string.format("dec/icon_vip".. self.mData.vlevel .. ".png"))
    	end

    	if money > tt.owner:getVipScore() then
    		self.mVipNum:setColor(cc.c3b(0xc5,0xc4,0xc4))
    	else
    		self.mVipNum:setColor(cc.c3b(0xff,0xff,0xff))
    	end

    	if tonumber(self.mData.num) <= 0 then
    		self.mNum:setColor(cc.c3b(0xc5,0xc4,0xc4))
    	else
    		self.mNum:setColor(cc.c3b(0xff,0xff,0xff))
    	end

    	self.mExchangeBtn:setButtonEnabled(false)
	else
    	self.vip_icon:setTexture(string.format("dec/icon_vip".. self.mData.vlevel .. ".png"))
    	self.mExchangeBtn:setButtonEnabled(true)
	end
end

function PrizeCenterViewItem:setPropData(data)
	if tolua.isnull(self) then return end
	self.mPropData = data
	print("setPropData",data.sname)
	self.mName:setLineHeight(30)
	self.mName:setString(data.sname)
	tt.asynGetHeadIconSprite(string.urldecode(data.iconurl or ""),function(sprite)
		if sprite and not tolua.isnull(self) and not tolua.isnull(self.mDefaultIcon) then
			self.mDefaultIcon:removeChildByTag(1)
			local size = self.mDefaultIcon:getContentSize()
			sprite:setTag(1)
			sprite:addTo(self.mDefaultIcon)
			sprite:setPosition(cc.p(size.width/2,size.height/2))
			local scalX=size.width/sprite:getContentSize().width--设置x轴方向的缩放系数
			local scalY=size.height/sprite:getContentSize().height--设置y轴方向的缩放系数
			sprite:setScaleX(scalX)
				:setScaleY(scalY)
			
			-- local size = self.head_handler:getContentSize()
			-- local mask = display.newSprite("dec/zhezhao.png")
			-- if self.head_ then
			-- 	self.head_:removeSelf()
			-- 	self.head_ = nil
			-- end
			-- self.head_ = CircleClip.new(sprite,mask)
			-- 	:addTo(self.head_handler,99)
			-- 	:setPosition(cc.p(-1,-1))
			-- 	:setCircleClipContentSize(size.width,size.width)
		end
	end)
end

function PrizeCenterViewItem:addTouch()
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
        	if self.mExchangeBtn:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" then
				tt.play.play_sound("click")
				if self.mPropData then
					self.ctl_:showChooseDialog(self.mPropData.descp or tt.gettext("未知"),nil,function()
						end):setMode(4)
				end
			end
		end
	end)

	self.mExchangeBtn:setTouchEnabled(true)
	self.mExchangeBtn:setTouchSwallowEnabled(false)
	local startX,startY =0,0
	local down = false
	self.mExchangeBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
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
        	if not self.mExchangeBtn:getCascadeBoundingBox():containsPoint(cc.p(x, y)) or not self.mExchangeBtn:isButtonEnabled() then return false end
        	down = true
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" then
				tt.play.play_sound("click")
				if self.mPropData then
					print("exchangeVipPrize vsid,pid,type",self.mData.vsid,self.mData.pid,self.mPropData.type)
					local params = {}
					params.vsid = self.mData.vsid
					params.pid = self.mData.pid
					params.type = self.mPropData.type
					tt.ghttp.request(tt.cmd.exchange,params)
				end
			end
		end
	end)
end


function PrizeCenterViewItem:onCleanup()
	PropDataHelper.unregister(self.mHandler)
end

function PrizeCenterViewItem:onEnter()
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
		-- tt.owner:addEventListener(tt.owner.EVENT_VP_EXP,handler(self,self.updateVpExpView)),
	}
end

function PrizeCenterViewItem:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
end

return PrizeCenterViewItem
