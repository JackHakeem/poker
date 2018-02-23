--
-- Author: bearluo
-- Date: 2017-05-26 15:24:32
--

local CashMatchItem = class("CashMatchItem", function()
	return display.newNode()
end)


function CashMatchItem:ctor(control,data,banner_icon)
	self.control_ = control 
	--find view by layout
	local node, width, height = cc.uiloader:load("cash_match_item.json")
	self:addChild(node)
	self.root_ = node
	self.mData = data
	self:setContentSize(cc.size(width,height))


	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")


	self.mBannerIcon = cc.uiloader:seekNodeByName(node,"banner_icon")
	self.mBannerIcon:setTexture(banner_icon)
	self.mNameTxt = cc.uiloader:seekNodeByName(node,"name_txt")
	self.mNameTxt:setString(data.name)

	self.mBlindNum = cc.uiloader:seekNodeByName(node,"blind_num")

	self.mBlindNum:setString(string.format("%s/%s",tt.getNumShortStr(data.sb),tt.getNumShortStr(data.bb)))

	self.mAnteNum = cc.uiloader:seekNodeByName(node,"ante_num")

	if data.ante > 0 then
		self.mAnteNum:setString(string.format("ante:%s",tt.getNumShortStr(data.ante)))
	else
		self.mBlindNum:setPosition(cc.p(97,46))
		self.mAnteNum:setString("")
	end

	self.mCarryHandler = cc.uiloader:seekNodeByName(node,"carry_handler")
	self.mCarryHandler:scale(0.9)

	self:setCarry(data.default_buy)

	self:addTouch()
end

function CashMatchItem:setCarry(num)
	self.mCarryHandler:removeAllChildren()
	self.mCarryHandler:setContentSize(0,0)

	local pre = display.newSprite("fonts/dairu.png")
	tt.linearlayout(self.mCarryHandler,pre,0,5)
	local str = tt.getNumShortStr(num)
	local num_img = tt.getBitmapStrAscii("number/yellow0_%d.png",str)
	tt.linearlayout(self.mCarryHandler,num_img)

	local size = self.mCarryHandler:getContentSize()
	self.mCarryHandler:setPosition(cc.p(221/2-size.width/2,243/2-101))
end

function CashMatchItem:searchTable()
	local money = tt.owner:getMoney()
	local default_buy = self.mData.default_buy
	if money >= default_buy then
		if tt.gsocket:isConnected() then
			tt.show_wait_view(tt.gettext("匹配中..."))
		end
		tt.gsocket.request("alloc.search",{lv = self.mData.lv})
	else

		local goods = tt.getSuitableGoodsByMoney(default_buy-money)
		if goods then
			-- tt.show_msg(tt.gettext("筹码不足"))
			self.control_:showRecommendGoodsDialog(goods)
		else
			tt.show_msg(tt.gettext("筹码不足"))
		end
	end
end

function CashMatchItem:addTouch()
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
	    dump(event)
	    local x,y = event.x,event.y
	    if event.name == "began" then
	    	startX = x
        	startY = y
        	if not self:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
			self.mContentBg:scale(0.95)
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" then
		    	tt.play.play_sound("click")
				self:searchTable()
			end
		end
		if event.name == "ended" then
			self.mContentBg:scale(1)
		end
	end)
end

return CashMatchItem
