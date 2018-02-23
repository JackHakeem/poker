--
-- Author: he
-- Date: 2017-04-03 17:36
-- 
--

local MIN = 1
local HALF = 2
local FULL = 3
local MAX = 4

local RoomControler = require("app.scenes.controler.RoomControler")

local BetActionView = class("BetActionView", function(...)
	return display.newLayer()
end)

function BetActionView:ctor( ctl )
	self.ctl_ = ctl

	local node, width , height = cc.uiloader:load("bet_view.json")
	self:addChild(node)
	self.root_ = node

	assert(node)

	self.foldBtn = cc.uiloader:seekNodeByName(node, "foldBTN")
					:onButtonClicked(function(event)
						-- tt.play.play_sound("click")
						tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomFoldBtn)
						self:fold()
						self.mIsShow = false
						self:setVisible(false)
					end)
					:onButtonRelease(function()
							cc.uiloader:seekNodeByName(self.foldBtn, "handler"):setPosition(cc.p(0,14))
						end)
					:onButtonPressed(function()
							cc.uiloader:seekNodeByName(self.foldBtn, "handler"):setPosition(cc.p(0,6))
						end)
	assert(self.foldBtn)					

	self.checkBtn = cc.uiloader:seekNodeByName(node, "checkBTN")
					:onButtonClicked(function(event)
						-- tt.play.play_sound("click")
						tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomCheckBtn)
						self:checkcall()
						self.mIsShow = false
						self:setVisible(false)
					end)
					:onButtonRelease(function()
							cc.uiloader:seekNodeByName(self.checkBtn, "handler"):setPosition(cc.p(0,14))
						end)
					:onButtonPressed(function()
							cc.uiloader:seekNodeByName(self.checkBtn, "handler"):setPosition(cc.p(0,6))
						end)
					
	assert(self.checkBtn)					

	self.callLabel = cc.uiloader:seekNodeByName(node, "callLabel")				
	:setVisible(false)

	self.allinLabel = cc.uiloader:seekNodeByName(node, "allinLabel")
	:setVisible(false)
					
	self.checkLabel = cc.uiloader:seekNodeByName(node, "checkLabel")
	:setVisible(false)

	self.callNoLabel = cc.uiloader:seekNodeByName(node, "callNoLabel")
	:setVisible(false)

	self.allinNoLabel = cc.uiloader:seekNodeByName(node, "allinNoLabel")
	:setVisible(false)

	self.betBtn = cc.uiloader:seekNodeByName(node, "betBTN")
					:onButtonClicked(function(event)
						-- tt.play.play_sound("click")
						tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomRaiseBtn)
						self:raise()
						self.mIsShow = false
						self:setVisible(false)
					end)
					:onButtonRelease(function()
							cc.uiloader:seekNodeByName(self.betBtn, "handler"):setPosition(cc.p(0,14))
						end)
					:onButtonPressed(function()
							cc.uiloader:seekNodeByName(self.betBtn, "handler"):setPosition(cc.p(0,6))
						end)
	assert(self.betBtn)					
					
	self.betLabel = cc.uiloader:seekNodeByName(node, "betLabel")
	:setVisible(false)

	self.raiseLabel = cc.uiloader:seekNodeByName(node, "raiseLabel")
	:setVisible(false)

	self.raiseNoLabel = cc.uiloader:seekNodeByName(node, "raiseNoLabel")
	:setVisible(false)

	self.minBtn = cc.uiloader:seekNodeByName(node, "minBTN")
					:onButtonClicked(function(event)
						-- tt.play.play_sound("click")
						tt.log.d(TAG, "min btton flag is [%d]", MIN)
						self:quickBtnClicked(MIN)
					end)
	assert(self.minBtn)					

	self.halfBtn = cc.uiloader:seekNodeByName(node, "halfBTN")
	self.halfBtn:onButtonClicked(function(event)
					-- tt.play.play_sound("click")
					tt.log.d(TAG, "half btton flag is [%d]", HALF)
					self:quickBtnClicked(HALF)
				end)
	assert(self.halfBtn)					
					

	self.fullBtn = cc.uiloader:seekNodeByName(node, "fullBTN")
					:onButtonClicked(function(event)
						-- tt.play.play_sound("click")
						tt.log.d(TAG, "full btton flag is [%d]", FULL)
						self:quickBtnClicked(FULL)
					end)
	assert(self.fullBtn)					

	self.maxBtn = cc.uiloader:seekNodeByName(node, "maxBTN")
					:onButtonClicked(function(event)
						tt.play.play_sound("shove")
						tt.log.d(TAG, "max btton flag is [%d]", MAX)
						self:quickBtnClicked(MAX)
					end)
	assert(self.maxBtn)					

	self.bet_slider_handler = cc.uiloader:seekNodeByName(node,"bet_slider_handler")
	self.raise_mask = cc.uiloader:seekNodeByName(node,"mask")
		:setVisible(false)

	self.bet_slider = cc.uiloader:seekNodeByName(self.bet_slider_handler,"bet_slider")
		:onSliderValueChanged(handler(self,self.onBetValueChange))
		:setTouchSwallowEnabled(false)

	self.money_slider_progress = cc.ProgressTimer:create(cc.Sprite:create("dec/pbar.png"))
	    :setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    :setMidpoint(cc.p(0,0))
	    :setBarChangeRate(cc.p(1, 0))
	    :setPosition(-2,10)
    	:addTo(self.bet_slider,1)

    local size = self.bet_slider_handler:getContentSize()
    self.add_sub_touch_view = display.newNode()
    self.add_sub_touch_view:setContentSize(size)
    self.add_sub_touch_view:setTouchEnabled(true)
    local isLeft = false
    local isInButton = false
	self.add_sub_touch_view:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		local x,y = event.x,event.y
		if event.name == "began" and self.bet_slider.buttonSprite_:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
			isInButton = true
			return self.bet_slider:onTouch_(event.name, event.x, event.y)
		end

		if isInButton and event.name == "moved" then
			return self.bet_slider:onTouch_(event.name, event.x, event.y)
		end

		if isInButton and event.name ~= "moved" then
			isInButton = false
			return self.bet_slider:onTouch_(event.name, event.x, event.y)
		end

		local pos = self.bet_slider:convertToWorldSpaceAR(cc.p(self.bet_slider.buttonSprite_:getPosition()))
		local bx= pos.x
		local size = self.bet_slider.buttonSprite_:getContentSize()
		print(event.name,x,y,bx,bx - size.width/2,bx + size.width/2)
	    if event.name == "began" then
	    	if self.bet_slider.buttonSprite_ then
	    		if x < bx - size.width/2 then
	    			isLeft = true
	    		elseif x > bx + size.width/2 then
	    			isLeft = false
	    		end
	    		return true
	    	end
	    	return false
	    end

	    if event.name ~= "moved" then
	    	if self.add_sub_touch_view:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
	    		if x < bx - size.width/2  and isLeft then
	    			self:subBet()
	    		elseif x > bx + size.width/2 and not isLeft then
	    			self:addBet()
	    		end
	    	end
	    	isLeft = false
	    end
	end)
    self.add_sub_touch_view:addTo(self.bet_slider_handler,3)

	self:resetSlider()
	self.betDecBTN = cc.uiloader:seekNodeByName(self.bet_slider_handler,"betDecBTN")
		:onButtonClicked(function()
			-- tt.play.play_sound("click")
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomSubBtn)
			self:subBet()
		end)
	self.betIncBTN = cc.uiloader:seekNodeByName(self.bet_slider_handler,"betIncBTN")
		:onButtonClicked(function()
			-- tt.play.play_sound("click")
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomAddBtn)
			self:addBet()
		end)

	self.mIsShow = false
	self:setVisible(false)				
	self:setTouchSwallowEnabled(false)
	tt.log.d(TAG,"init betActionView over")
end

function BetActionView:show()
	local model = self.ctl_.mModel
	local seat_id = model:getCtlSeat()
	self.blind_ = model:getCurBB()
	self.raise_ = model:getActionInfoRaiseMin()
	self.max_ = model:getActionInfoRaiseMax()
	self.pot_ = model:getTotalPot()
	self.status_ = model:getGameStatus()
	
	assert( self.raise_ >= 0 , string.format("BetActionView:show raise %d",self.raise_))
	assert( self.blind_ >= 0 , string.format("BetActionView:show blind %d",self.blind_))
	assert( self.pot_ >= 0 , string.format("BetActionView:show pot %d",self.pot_))

	self.lastBet_ = model:getSeatBets(seat_id)
	-- tt.log.d(TAG, "player last bet is [%d]", self.lastBet_)
	self:setBetNo()
	self:setCallNo()

	tt.log.d(TAG, "show bet action view[%d],[%d],[%d],[%d],[%d],[%d]", self.blind_, self.call_, self.raise_, self.max_, self.pot_, self.status_)

	-- 有下注，显示弃牌、跟注和加注；否则显示过拍和下注
	if self.call_ ~= 0 then
		-- 有效加注则可以再次加注；否则只能call或fold
		-- 且全部人没有allin
		if self.raise_ ~= 0 and not model:isAllOtherPlayerAllin() then
			if self.call_ < self.max_ then
				self:setFoldCallRaise()
			else
				self:setFoldCall()
			end
		else
			self:setFoldCall()
		end
	else
		self:setCheckBet()
	end
	
	self:setQuickBtn()
	self.mIsShow = true
	self:setVisible(self.mIsShow and not self.mRetainStatus)
end
-- filter.newFilter(filters, params)
--         __sp:setFilter(filters)
function BetActionView:setQuickBtn()
	tt.log.d(TAG, "Game Status is [%d]", self.status_)

	-- preflop阶段，mini raise的额度超过3BB，则half button禁用
	if self.status_ == self.ctl_.mControler.contants.status.preflop then

		self.halfBtn:setButtonImage("normal","btn/btn_3bb_nor.png",true)
		self.halfBtn:setButtonImage("pressed","btn/btn_3bb_pre.png",true)
		self.halfBtn:setButtonImage("disabled", "btn/btn_3bb_gray.png", true)
		if self.raise_ + self.lastBet_ > self.blind_ * 3 then
			self.halfBtn:setButtonEnabled(false)
		end
	else
		self.halfBtn:setButtonImage("normal","btn/btn_half_nor.png",true)
		self.halfBtn:setButtonImage("pressed","btn/btn_half_pre.png",true)
		self.halfBtn:setButtonImage("disabled", "btn/btn_half_gray.png", true)
	end
	
	-- raise大于shove，则全禁 
	if self.raise_ > self.max_ then
		self.maxBtn:setButtonEnabled(false)
		self.minBtn:setButtonEnabled(false)
		self.halfBtn:setButtonEnabled(false)
		self.fullBtn:setButtonEnabled(false)

		tt.log.d(TAG, "all quick button was diabled")
		return
	end
	local maxBet = self.ctl_.mModel:getRoundMaxBet()
	local tmp
	if self.status_ == self.ctl_.mControler.contants.status.preflop then
		tmp = self.blind_ * 3
	else
		tmp = math.ceil(self.pot_ / 2 + maxBet + self.call_ / 2)
	end

	-- raise大于1/2 or 3BB，则禁用half button
	if self.raise_ + self.lastBet_ > tmp then
		tt.log.d(TAG, "half button was disabled")
		self.halfBtn:setButtonEnabled(false)

		-- raise大于满池，则禁用full button
		if self.raise_ + self.lastBet_ > self.pot_ + maxBet + self.call_ then
			tt.log.d(TAG, "full button was disabled")
			self.fullBtn:setButtonEnabled(false)
		end
	end


	-- mini raise即为shove，则禁用max按钮
	--[[
	if self.raise_ >= self.max_ then
		self.maxBtn:setButtonEnabled(false)
		-- 满池超过shove，则禁用
		if self.pot_ > self.max_ + self.lastBet_ then
			tt.log.d(TAG, "pot button is disable")
			self.fullBtn:setButtonEnabled(false)

			local tmp
			if self.status_ == 1 then
				tmp = self.blind_ * 3 
			else
				tmp = self.pot_ / 2
			end

			-- half的额度超过shove，则禁用
			if tmp > self.max_ + self.lastBet_ then
				tt.log.d(TAG, "half button is disable")
				self.halfBtn:setButtonEnabled(false)

				-- min的额度超过shvoe，则禁用
				if self.raise_ > self.max_ then
					tt.log.d(TAG, "min button is disable")
					self.minBtn:setButtonEnabled(false)
				end
			end
		end
	end
	--]]

end

function BetActionView:setFoldCallRaise()
	tt.log.d(TAG, "set fold call raise view")

	self.foldBtn:setVisible(true)

	self.callLabel:setVisible(true)

	self.callNoLabel:removeAllChildren()
	self.callNoLabel:setContentSize(0,self.callNoLabel:getContentSize().height)
	local num = tt.getBitmapStrAscii("number/call_%d.png",self.call_)
	tt.linearlayout(self.callNoLabel,num)

	self.callNoLabel:setVisible(true)
	self.checkBtn:setVisible(true)
	
	self.raiseLabel:setVisible(true)
	self:setBetView(self.thisBet_)
	self.raise_mask:setVisible(false)
	self:progChange(self.thisBet_)
	self.raiseNoLabel:setVisible(true)
	self.betBtn:setVisible(true)

	self.checkBtn:setButtonImage("normal","btn/btn_check_nor.png",true)
	self.checkBtn:setButtonImage("pressed","btn/btn_check_pre.png",true)
	self.checkBtn:setButtonImage("disabled", "btn/btn_check_pre.png", true)
	self.checkBtn:setPosition(cc.p(329,49))
end

function BetActionView:setFoldCall()
	tt.log.d(TAG, "set fold call view")

	self.foldBtn:setVisible(true)

	local model = self.ctl_.mModel
	local ctl_seat = model:getCtlSeat()
	local coin = self.ctl_:getSeatById(ctl_seat):getCoin()

	if coin == self.call_ then
		self.allinLabel:setVisible(true)
		self.allinNoLabel:setVisible(true)

		self.allinNoLabel:removeAllChildren()
		self.allinNoLabel:setContentSize(0,self.allinNoLabel:getContentSize().height)
		local num = tt.getBitmapStrAscii("number/raise_%d.png",self.call_)
		tt.linearlayout(self.allinNoLabel,num)
	else
		self.callLabel:setVisible(true)
		self.callNoLabel:setVisible(true)
		
		self.callNoLabel:removeAllChildren()
		self.callNoLabel:setContentSize(0,self.callNoLabel:getContentSize().height)
		local num = tt.getBitmapStrAscii("number/call_%d.png",self.call_)
		tt.linearlayout(self.callNoLabel,num)
	end

	-- self:setBetView(self.call_)
	self.raise_mask:setVisible(true)

	self.betBtn:setVisible(false)
	-- self.callNoLabel:setVisible(true)
	self.checkBtn:setVisible(true)

	self.checkBtn:setButtonImage("normal","btn/btn_raise_nor.png",true)
	self.checkBtn:setButtonImage("pressed","btn/btn_raise_pre.png",true)
	self.checkBtn:setButtonImage("disabled", "btn/btn_raise_pre.png", true)

	self.checkBtn:setPosition(cc.p(545,49))
end

function BetActionView:setCheckBet()
	tt.log.d(TAG, "set check bet")
	if self.ctl_.mModel:getGameStatus() == RoomControler.contants.status.river then
		self.foldBtn:setVisible(true)
	else
		self.foldBtn:setVisible(false)
	end
	self.checkLabel:setVisible(true)
	self.checkBtn:setVisible(true)
	self.betLabel:setVisible(true)
	self.raise_mask:setVisible(false)
	self:setBetView(self.thisBet_)
	self:progChange(self.thisBet_)
	self.raiseNoLabel:setVisible(true)
	self.betBtn:setVisible(true)

	self.checkBtn:setButtonImage("normal","btn/btn_check_nor.png",true)
	self.checkBtn:setButtonImage("pressed","btn/btn_check_pre.png",true)
	self.checkBtn:setButtonImage("disabled", "btn/btn_check_pre.png", true)

	self.checkBtn:setPosition(cc.p(329,49))
end

function BetActionView:setBetView(bet)
	bet = tonumber(bet) or 0
	self.raiseNoLabel:removeAllChildren()
	self.raiseNoLabel:setContentSize(0,self.raiseNoLabel:getContentSize().height)
	local num = tt.getBitmapStrAscii("number/raise_%d.png",bet)
	tt.linearlayout(self.raiseNoLabel,num)
end

function BetActionView:setCallNo()
	local check = self.ctl_.mModel:getActionInfoCheck()
	if check > self.max_ then
		check = self.max_
	end
	self.call_ = check
	tt.log.d(TAG, "This time call is [%d]", self.call_)
end

-- 设定最初的mini raise大小
function BetActionView:setBetNo()
	if self.raise_ > self.max_ then
		self.thisBet_ = self.max_ + self.lastBet_
	else
		self.thisBet_ = self.raise_ + self.lastBet_
	end

	tt.log.d(TAG, "This time bet is [%d]", self.thisBet_)
end

-- 修正超出范围的下注额度
function BetActionView:betNoCorrect()
	if self.thisBet_ > self.max_ + self.lastBet_ then
		self.thisBet_ = self.max_ + self.lastBet_
		return
	end

	if self.thisBet_ < self.lastBet_ + self.raise_ then
		self.thisBet_ = self.lastBet_ + self.raise_
		return 
	end

	tt.log.d(TAG, "bet number is right, need no correct")
end

function BetActionView:quickBtnClicked(flag)
	tt.log.d(TAG, "quick button was clicked [%d]", flag)

	-- tt.log.d(TAG, "pot is [%d],max bet is [%d], call is [%d]", 
	-- 	self.pot_, self.ctl_.maxBet, self.call_)

	local maxBet = self.ctl_.mModel:getRoundMaxBet()

	printInfo("pot is [%d],max bet is [%d], call is [%d]", 
		self.pot_, maxBet, self.call_)

	-- 根据快捷下注按钮，改变当前的下注额度
	if flag == MIN then
		self.thisBet_ = self.lastBet_ + self.raise_
		tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMinBtn)
	elseif flag == HALF then
		if self.status_ == self.ctl_.mControler.contants.status.preflop then
			assert(self.raise_+self.lastBet_ <= 3 * self.blind_)
			self.thisBet_ = self.blind_ * 3
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.room3BBBtn)
		else
			self.thisBet_ = self.pot_ / 2 + maxBet + self.call_ / 2
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomHalfBtn)
		end
	elseif flag == FULL then
		self.thisBet_ = self.pot_ + maxBet + self.call_
		tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomPotBtn)
	elseif flag == MAX then
		self.thisBet_ = self.max_ + self.lastBet_
		tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMaxBtn)
	else
		assert(nil)
	end

	self.thisBet_ = math.floor(self.thisBet_)
	self:betNoCorrect()

	tt.log.d(TAG, "shove is [%d] and this bet is [%d] and miniraise is [%d]", 
		self.max_ + self.lastBet_, self.thisBet_, self.lastBet_ + self.raise_)
	assert(self.max_ + self.lastBet_ >= self.thisBet_)

	self:setBetView(self.thisBet_)
	self:progChange(self.thisBet_)
end

function BetActionView:fold()
	self.ctl_.mControler:onFoldLogic()
	self:hide()
end

function BetActionView:checkcall()
	self.ctl_.mControler:onCheckLogic()
	self:hide()
end

function BetActionView:raise()
	-- tt.play.play_sound("click")
	tt.log.d(TAG, "raise is [%d]", self.thisBet_ - self.lastBet_)
	self.ctl_.mControler:addChips(self.thisBet_ - self.lastBet_)
	self:hide()
end

function BetActionView:hide()
	self.foldBtn:setVisible(false)

	self.checkLabel:setVisible(false)
	self.callLabel:setVisible(false)
	self.allinLabel:setVisible(false)
	self.callNoLabel:setVisible(false)
	self.allinNoLabel:setVisible(false)
	self.checkBtn:setVisible(false)

	self.betLabel:setVisible(false)
	self.raiseLabel:setVisible(false)
	self.raiseNoLabel:setVisible(false)
	self.betBtn:setVisible(false)

	self.minBtn:setButtonEnabled(true)
	self.halfBtn:setButtonEnabled(true)
	self.fullBtn:setButtonEnabled(true)
	self.maxBtn:setButtonEnabled(true)

	self.blind_ = 0
	self.call_ = 0
	self.raise_ = 0
	self.max_ = 0
	self.status_ = self.ctl_.mControler.contants.status.idle
	self.pot_ = 0
	self.lastBet_ = 0
	self.thisBet_ = 0
	self.mIsShow = false
	self:setVisible(false)
end

function BetActionView:setRetainStatus(flag)
	self.mRetainStatus = flag
	self:setVisible(self.mIsShow and not self.mRetainStatus)
end

function BetActionView:subBet()
	assert(self.thisBet_)
	assert(self.blind_)
	assert(self.raise_)
	assert(self.lastBet_)
	assert(self.max_)

	local min = math.min(self.raise_ + self.lastBet_,self.max_)
	local dif = self.max_ - min

	local offset = self.thisBet_ - self.blind_
	if self.thisBet_%self.blind_ > 0 then
		offset = self.thisBet_ - self.thisBet_%self.blind_
	end
	offset = offset - min

	if offset < 0 then
		offset = 0
	end

	if offset > dif then
		offset = dif
	end

	self:setBatSelectSliderValue( (dif == 0 and 100) or (offset * 100  / dif) )
end

function BetActionView:addBet()
	assert(self.thisBet_)
	assert(self.blind_)
	assert(self.raise_)
	assert(self.lastBet_)
	assert(self.max_)

	local min = math.min(self.raise_ + self.lastBet_,self.max_)
	local dif = self.max_ - min

	local offset = self.thisBet_ + self.blind_

	if offset%self.blind_ > 0 then
		offset = offset - offset % self.blind_
	end
	offset = offset - min

	if offset < 0 then
		offset = 0
	end

	if offset > dif then
		offset = dif
	end


	self:setBatSelectSliderValue( (dif == 0 and 100) or (offset * 100 / dif) )
end

function BetActionView:setBatSelectSliderValue(value)
	if self.bet_slider:getSliderValue() ~= value then
		self.bet_slider:setSliderValue(value)
	else
		self:updateValue(value)
	end	
end

function BetActionView:onBetValueChange(v)
	tt.log.d(TAG,"CashSetView:onValueChange")
	self.money_slider_progress:setPercentage(v.value)

	assert(self.thisBet_)
	assert(self.raise_)
	assert(self.lastBet_)
	assert(self.max_)
	local min = math.min(self.raise_ + self.lastBet_,self.max_)
	local dif = self.max_ - min

	local offset = math.floor( dif * (v.value/100) + 0.5 ) + min
	print(offset,self.max_)
	if not ( offset == 0 or offset == self.max_ ) then
		offset = offset - offset % self.blind_
	end
	offset = offset - min

	if offset < 0 then
		offset = 0
	end

	self:updateValue((dif == 0 and 100) or (offset * 100 / dif))
end

function BetActionView:updateValue(value)
	assert(self.thisBet_)
	assert(self.raise_)
	assert(self.lastBet_)
	assert(self.max_)

	local min = math.min(self.raise_ + self.lastBet_,self.max_)
	printInfo("BetActionView:updateValue raise %d max %d",self.raise_,self.max_)
	local dif = self.max_ - min

	self.thisBet_ = min + math.floor( dif * (value/100) + 0.5 )

	self:setBetView(self.thisBet_)
end

function BetActionView:progChange(number)
	local min = math.min(self.raise_ + self.lastBet_,self.max_)
	local dif = self.max_ - min
	local offset = number - min

	if offset < 0 then
		offset = 0
	end

	if offset > dif then
		offset = dif
	end
	
	self:setBatSelectSliderValue( (dif == 0 and 100) or (offset * 100 / dif) )
	-- 避免浮点数运算导致失精
	if self.thisBet_ ~= number then
		self.thisBet_ = number
		self:setBetView(self.thisBet_)
	end
end

function BetActionView:resetSlider()

	self.bet_slider.updateButtonPosition_ = function(self)
    	if not self.barSprite_ or not self.buttonSprite_ then return end

	    local x, y = 0, 0
	    local barSize = self.barSprite_:getContentSize()
	    barSize.width = barSize.width * self.barSprite_:getScaleX()
	    barSize.height = barSize.height * self.barSprite_:getScaleY()
	    local buttonSize = self.buttonSprite_:getContentSize()
	    local offset = (self.value_ - self.min_) / (self.max_ - self.min_)
	    local ap = self:getAnchorPoint()

	    if self.isHorizontal_ then
	        x = x - barSize.width * ap.x
	        y = y + barSize.height * (0.5 - ap.y)
	        self.buttonPositionRange_.length = barSize.width - buttonSize.width
	        self.buttonPositionRange_.min = x + buttonSize.width/2
	        self.buttonPositionRange_.max = self.buttonPositionRange_.min + self.buttonPositionRange_.length
	        
	        local lbPos = cc.p(0, 0)
	        if self.barfgSprite_ and self.scale9Size_ then
	            self:setContentSizeAndScale_(self.barfgSprite_, cc.size(offset * self.buttonPositionRange_.length, self.scale9Size_[2]))
	            lbPos = self:getbgSpriteLeftBottomPoint_()
	        end
	        if self.direction_ == display.LEFT_TO_RIGHT then
	            x = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length
	        else
	            if self.barfgSprite_ and self.scale9Size_ then
	                lbPos.x = lbPos.x + (1-offset)*self.buttonPositionRange_.length
	            end
	            x = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
	        end
	        if self.barfgSprite_ and self.scale9Size_ then
	            self.barfgSprite_:setPosition(lbPos)
	        end
	    else
	        x = x - barSize.width * (0.5 - ap.x)
	        y = y - barSize.height * ap.y
	        self.buttonPositionRange_.length = barSize.height
	        self.buttonPositionRange_.min = y
	        self.buttonPositionRange_.max = self.buttonPositionRange_.min + self.buttonPositionRange_.length

	        local lbPos = cc.p(0, 0)
	        if self.barfgSprite_ and self.scale9Size_ then
	            self:setContentSizeAndScale_(self.barfgSprite_, cc.size(self.scale9Size_[1], offset * self.buttonPositionRange_.length))
	            lbPos = self:getbgSpriteLeftBottomPoint_()
	        end
	        if self.direction_ == display.TOP_TO_BOTTOM then
	            y = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
	            if self.barfgSprite_ and self.scale9Size_ then
	                lbPos.y = lbPos.y + (1-offset)*self.buttonPositionRange_.length
	            end
	        else
	            y = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length
	            if self.barfgSprite_ then
	            end
	        end
	        if self.barfgSprite_ and self.scale9Size_ then
	            self.barfgSprite_:setPosition(lbPos)
	        end
	    end

	    self.buttonSprite_:setPosition(x, y+10)
	end
	self.bet_slider:updateButtonPosition_()
end

return BetActionView

