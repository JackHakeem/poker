local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")
local BLDialog = require("app.ui.BLDialog")

local TouzhuGameView = class("TouzhuGameView", function(...)
	return BLDialog.new(...)
end)

function TouzhuGameView:ctor(control)
	self.control_ = control 
	local node, width, height = cc.uiloader:load("touzhugame_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "back_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:dismiss()
		end)
	self.mVipView = cc.uiloader:seekNodeByName(node,"vip_view")
    self.mIcon = cc.uiloader:seekNodeByName(self.mVipView,"icon")
    self.mVipTxt = cc.uiloader:seekNodeByName(self.mVipView,"vip_txt")

	self.mVipShopBtn = cc.uiloader:seekNodeByName(node,"vip_shop_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
	    		self.control_:showPrizeCenterView()
			end)
	self.mVipShopBtn:setVisible(not tt.nativeData.isVipShopLock())
	
	self.mNumSelectBtns = {}
	self.mNumContents = {
		-1,-2,-3,-4,15,16,17,18,11,12,13,14,7,8,9,10,3,4,5,6,
	}
	self.mNumSelectGroup = cc.uiloader:seekNodeByName(node,"num_select_group")
	local lx,ly = 78,45
	for index,num in ipairs(self.mNumContents) do
		local btn
		if num >= 3 and num <= 18 then
			btn = cc.ui.UIPushButton.new("btn/btn_white_" .. num .. ".png")
		elseif num == -1 then
			btn = cc.ui.UIPushButton.new("btn/btn_single_nor.png")
		elseif num == -2 then
			btn = cc.ui.UIPushButton.new("btn/btn_small_nor.png")
		elseif num == -3 then
			btn = cc.ui.UIPushButton.new("btn/btn_big_nor.png")
		elseif num == -4 then
			btn = cc.ui.UIPushButton.new("btn/btn_double_nor.png")
		end
		btn:onButtonClicked(function()
				tt.play.play_sound("touzhu_bet")
				if not self.mIsLoaded then return end
				if self.mBeting then return end
				self:addNum(num,btn)
			end)
		btn:addTo(self.mNumSelectGroup)
		btn:setPosition(cc.p(lx,ly))
		lx = lx + 156
		if index % 4 == 0 then
			ly = ly + 90
			lx = 78
		end
		self.mNumSelectBtns[index] = btn
	end

	self.mCoinsIndex = 0
	self.mPreCoinsIndex = 0
	self.mCoinsSelectBtns = {}
	self.mCoinsContents = {
		"5k","10k","100k","500k","1m","5m","10m"
	}
	local k = 1000
	local m = k * 1000
	self.mCoinsNumContents = {
		5*k,10*k,100*k,500*k,1*m,5*m,10*m
	}
	self.mCoinsSelectGroup = cc.uiloader:seekNodeByName(node,"coins_select_group")
	local lx,ly = 45,0
	for index,coinStr in ipairs(self.mCoinsContents) do
		local btn = cc.ui.UIPushButton.new("btn/btn_" .. coinStr .. "_nor.png")
		btn:onButtonClicked(function()
				tt.play.play_sound("click")
				if not self.mIsLoaded then return end
				if self.mBeting then return end
				self:selectCoin(index)
			end)
		btn:addTo(self.mCoinsSelectGroup)
		btn:setPosition(cc.p(lx,ly))
		btn:setAnchorPoint(cc.p(0.5,0))
		btn:setLocalZOrder(2)
		lx = lx + 110
		self.mCoinsSelectBtns[index] = btn
	end

	self.mMyActions = {}
	self.mSelectCoins = 0
	self.mMyActionList = cc.uiloader:seekNodeByName(node,"my_action_list")

	cc.uiloader:seekNodeByName(node,"del_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if not self.mIsLoaded then return end
				if self.mBeting then return end
				self:clearAllAction()
			end)

	self.mStarIcon = cc.uiloader:seekNodeByName(node,"star_icon")
	self.mForecastTxt = cc.uiloader:seekNodeByName(node,"forecast_txt")

	cc.uiloader:seekNodeByName(node,"random_select_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if not self.mIsLoaded then return end
				if self.mBeting then return end
				self.control_:showTouzhuRandomView()
			end)

	cc.uiloader:seekNodeByName(node,"add_money_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if not self.mIsLoaded then return end
				if self.mBeting then return end
				self.control_:showTouzhuExchangeView()
			end)

	cc.uiloader:seekNodeByName(node,"rule_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.control_:showTouzhuRuleView()
			end)

	self.mHistoryBtn = cc.uiloader:seekNodeByName(node,"history_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if not self.mIsLoaded then return end
				if self.mBeting then return end
				self.control_:showTouzhuHistoryView()
			end)

	self.mPayBtn = cc.uiloader:seekNodeByName(node,"pay_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if not self.mIsLoaded then return end
				if self.mBeting then return end
				self:onBet()
			end)
		:onButtonPressed(handler(self,self.onPayBtnPressed))
		:onButtonRelease(handler(self,self.onPayBtnRelease))

	self.mCurStageTxt = cc.uiloader:seekNodeByName(node,"cur_stage_txt")
	self.mCountdownTxt = cc.uiloader:seekNodeByName(node,"countdown_txt")
	self.mLotteryInfoBg = cc.uiloader:seekNodeByName(node,"lottery_info_bg")

	self.mLastStageTxt = cc.uiloader:seekNodeByName(node,"last_stage_txt")
	self.mLastTipsTxt = cc.uiloader:seekNodeByName(node,"last_tips_txt")
	self.mLastLuckNums = {}
	for i=1,3 do
		self.mLastLuckNums[i] = cc.uiloader:seekNodeByName(node, "num_" .. i .. "_icon")
		self.mLastLuckNums[i]:setVisible(false)
	end

	self.mCoinsTxt = cc.uiloader:seekNodeByName(node,"money_txt")

	cc.uiloader:seekNodeByName(node,"index_txt"):setString(tt.gettext("期号"))
	cc.uiloader:seekNodeByName(node,"sum_txt"):setString(tt.gettext("和值"))
	self.mHistoryLotteryList = cc.uiloader:seekNodeByName(node,"history_lottery_list")
	

	self.mLoadView = display.newSprite("dec/dec_juhua1.png")
		:setPosition(cc.p(640,360))
		:setVisible(false)
	self.mLoadView:addTo(node)
	self.mIsLoaded = false
end

function TouzhuGameView:showLoad()
	if self.mLoadView:isVisible() then return end
	self.mLoadView:setVisible(true)
	local index = 0
    self.mLoadView:schedule(function()
            index = (index + 40) % 360
            self.mLoadView:rotation(index)
        end,0.1)
end

function TouzhuGameView:hideLoad()
	if not self.mLoadView:isVisible() then return end
	self.mLoadView:setVisible(false)
	self.mLoadView:stopAllActions()
end

function TouzhuGameView:show(str)
	BLDialog.show(self)
	self.mBroadHappyid = ""
	self.mBroadStage = 0
	self:updateVipScoreView() 
	self:updateVipLvView()
	self.mIsLoaded = false
	self:showLoad()
	tt.gsocket.request("happydice.info",{mid=tt.owner:getUid()})
	tt.play.set_music_vol(0)
end

function TouzhuGameView:dismiss()
	BLDialog.dismiss(self)
	tt.play.set_music_vol(1)
	self:removeSelf()
end

function TouzhuGameView:initView()
	self.mIsLoaded = true
	self:checkPreSelectCoins()
	self:updateCoinsBtnsStatus()
	self:updateForecastView()
	self:updateNumSelectBtnsFactors()
	self:hideLoad()
end

function TouzhuGameView:updateCoins()
	local coins = tt.owner:getCoins() - self.mSelectCoins
	self.mCoinsTxt:setString(tt.getNumStr(coins))
	self:updateCoinsBtnsStatus()
end

function TouzhuGameView:addNum(num,btn)
	local coins = self.mCoinsNumContents[self.mCoinsIndex]
	if self.mCoinsIndex == 0 then
		self:checkShowRecommendDialog()
		return 
	end

	if not tolua.isnull(btn) then
		local animCsb = "gold_jump/gold_jump.csb"
		local animView = cc.CSLoader:createNode(animCsb)
		local action = cc.CSLoader:createTimeline(animCsb)
		animView:runAction(action)
		local x,y = btn:getPosition()
		animView:setPosition(cc.p(x,y))
		animView:addTo(self.mNumSelectGroup)
		animView:performWithDelay(function()
				animView:removeSelf()
			end, 0.8)
		action:gotoFrameAndPlay(0,false)
	end

	if not num or not coins then return end
	self:addAction(num,coins)
end

function TouzhuGameView:subNum(num)
	local coins = self.mCoinsNumContents[self.mCoinsIndex] or self.mCoinsNumContents[self.mPreCoinsIndex]
	if not num or not coins then return end
	self:subAction(num,coins)
end

function TouzhuGameView:selectCoin(index)
	local pre_index = self.mCoinsIndex
	if pre_index ~= 0  then
		self.mPreCoinsIndex = pre_index
	end
	self.mCoinsIndex = index
	local pre_btn = self.mCoinsSelectBtns[pre_index]
	local cur_btn = self.mCoinsSelectBtns[index]
	if pre_btn then
		if pre_btn:isButtonEnabled() then
			pre_btn:setButtonImage("normal","btn/btn_" .. self.mCoinsContents[pre_index] .. "_nor.png",true)
			pre_btn:setButtonImage("pressed","btn/btn_" .. self.mCoinsContents[pre_index] .. "_nor.png",true)
			pre_btn:setButtonImage("disabled", "btn/btn_" .. self.mCoinsContents[pre_index] .. "_nor.png", true)
		else
			pre_btn:setButtonImage("normal","btn/btn_" .. self.mCoinsContents[pre_index] .. "_grey.png",true)
			pre_btn:setButtonImage("pressed","btn/btn_" .. self.mCoinsContents[pre_index] .. "_grey.png",true)
			pre_btn:setButtonImage("disabled", "btn/btn_" .. self.mCoinsContents[pre_index] .. "_grey.png", true)
		end
	end

	if cur_btn then
		cur_btn:setLocalZOrder(2)
		cur_btn:setButtonImage("normal","btn/btn_" .. self.mCoinsContents[index] .. "_sel.png",true)
		cur_btn:setButtonImage("pressed","btn/btn_" .. self.mCoinsContents[index] .. "_sel.png",true)
		cur_btn:setButtonImage("disabled", "btn/btn_" .. self.mCoinsContents[index] .. "_sel.png", true)
	end

	tt.nativeData.saveXiazhuSelectIndex(self.mCoinsIndex)
end

function TouzhuGameView:updateCoinsBtnsStatus()
	local coins = tt.owner:getCoins() - self.mSelectCoins
	local find_index = nil
	local finde_index2 = nil
	local finde_index3 = nil
	for index,btn in ipairs(self.mCoinsSelectBtns) do
		local need_coins = self.mCoinsNumContents[index]
		if need_coins > coins then
			btn:setButtonImage("normal","btn/btn_" .. self.mCoinsContents[index] .. "_grey.png",true)
			btn:setButtonImage("pressed","btn/btn_" .. self.mCoinsContents[index] .. "_grey.png",true)
			btn:setButtonImage("disabled", "btn/btn_" .. self.mCoinsContents[index] .. "_grey.png", true)
			btn:setButtonEnabled(false)
		else
			if not find_index then
				find_index = index
			end
			finde_index3 = index
			btn:setButtonImage("normal","btn/btn_" .. self.mCoinsContents[index] .. "_nor.png",true)
			btn:setButtonImage("pressed","btn/btn_" .. self.mCoinsContents[index] .. "_nor.png",true)
			btn:setButtonImage("disabled", "btn/btn_" .. self.mCoinsContents[index] .. "_nor.png", true)
			btn:setButtonEnabled(true)
		end
		if need_coins <= coins/10 then
			finde_index2 = index
		end
	end
	local select_btn = self.mCoinsSelectBtns[self.mCoinsIndex]
	if select_btn then
		if select_btn:isButtonEnabled() then
			select_btn:setButtonImage("normal","btn/btn_" .. self.mCoinsContents[self.mCoinsIndex] .. "_sel.png",true)
			select_btn:setButtonImage("pressed","btn/btn_" .. self.mCoinsContents[self.mCoinsIndex] .. "_sel.png",true)
			select_btn:setButtonImage("disabled", "btn/btn_" .. self.mCoinsContents[self.mCoinsIndex] .. "_sel.png", true)
		else
			if finde_index3 then
				self:selectCoin(finde_index3)
			else
				self:selectCoin(0)
			end
		end
	else
		if finde_index2 then
			self:selectCoin(finde_index2)
		else
			if find_index then
				self:selectCoin(find_index)
			else
				self:selectCoin(0)
			end
		end
	end
end

function TouzhuGameView:checkPreSelectCoins()
	local index = tt.nativeData.getXiazhuSelectIndex()
	if not self.mCoinsSelectBtns[index] then
		local coins = math.floor(tt.owner:getCoins() / 10)
		for i=#self.mCoinsNumContents,1,-1 do
			local need_coins = self.mCoinsNumContents[i]
			if need_coins <= coins then
				self:selectCoin(i)
				break
			end
		end
	else
		self:selectCoin(index)
	end
end

function TouzhuGameView:checkShowRecommendDialog()
	local left = tt.nativeData.getXiazhuMinLeft()
	local unit = tt.nativeData.getXiazhuMinUnit()
	local money = tt.owner:getMoney() - left
	print(money,unit)
	if money < unit then
		local goods = tt.getSuitableGoodsByMoney(unit-money)
		if goods then
			self.control_:showRecommendGoodsDialog(goods)
		else
			tt.show_msg(tt.gettext("筹码不足"))
		end
	else
		self.control_:showTouzhuExchangeView()
	end
end

function TouzhuGameView:addAction(num,coins)
	if num < 0 then
		coins = coins * 8
	end

	local my_coins = tt.owner:getCoins() - self.mSelectCoins
	if my_coins < coins then
		self:checkShowRecommendDialog()
		return
	end
	self.mSelectCoins = self.mSelectCoins + coins

	if self.mMyActions[num] then
		self.mMyActions[num]:getContent():addCoins(coins)
	else
		local item = self.mMyActionList:newItem()
		local content = app:createView("TouzhuActionItem", self)
		local size = cc.size(287,84)
		content:setCoinsNum(coins)
		content:setNum(num)
		item:addContent(content)
		item:setItemSize(size.width, size.height)
		self.mMyActions[num] = item
		self.mMyActionList:addItem(item,1)
		self.mMyActionList:reload()
		self:updateNumSelectBtns()
	end
	self:updateForecastView()
	self:updateCoinsBtnsStatus()
	self:updatePayBtnStatus()
	self:updateCoins()
end

function TouzhuGameView:subAction(num,coins)
	if num < 0 then
		coins = coins * 8
	end

	if self.mMyActions[num] then
		coins = math.min(self.mMyActions[num]:getContent():getCoins(),coins)
		self.mSelectCoins = self.mSelectCoins - coins
		self.mMyActions[num]:getContent():subCoins(coins)
		if self.mMyActions[num]:getContent():getCoins() == 0 then
			self.mMyActionList:removeItem(self.mMyActions[num])
			self.mMyActions[num] = nil
			self:updateNumSelectBtns()
		end
		self:updateForecastView()
		self:updateCoinsBtnsStatus()
		self:updatePayBtnStatus()
		self:updateCoins()
	end
end

function TouzhuGameView:clearAllAction()
	self.mMyActionList:removeAllItems()
	self.mMyActionList:reload()
	self.mMyActions = {}
	self.mSelectCoins = 0
	self:updateNumSelectBtns()
	self:updateForecastView()
	self:updateCoinsBtnsStatus()
	self:updatePayBtnStatus()
	self:updateCoins()
end

function TouzhuGameView:playBetAnim()
	for index,num in ipairs(self.mNumContents) do
		if self.mMyActions[num] then
			local btn = self.mNumSelectBtns[index]
			local coin = display.newSprite("icon/icon_gold1.png")
			coin:addTo(self.mContentBg)
			coin:setPosition(self.mContentBg:convertToNodeSpace(self.mNumSelectGroup:convertToWorldSpace(cc.p(btn:getPosition()))))
			local x,y = self.mHistoryBtn:getPosition()
			coin:moveTo(0.5, x, y)
			coin:performWithDelay(function()
					coin:removeSelf()
				end, 0.6)	
		end
	end
end

function TouzhuGameView:updateForecastView()
	local minCoins
	local maxCoins 
	local factors = tt.nativeData:getXiazhuFactors()
	local coinsTab = {}

	for num,item in pairs(self.mMyActions) do
		if num >= 3 and num <= 18 then
			coinsTab[num] = (coinsTab[num] or 0) + item:getContent():getCoins()
		elseif num == -1 then
			for i=3,18,2 do
				coinsTab[i] = (coinsTab[i] or 0) + item:getContent():getCoins()/8
			end
		elseif num == -2 then
			for i=3,10,1 do
				coinsTab[i] = (coinsTab[i] or 0) + item:getContent():getCoins()/8
			end
		elseif num == -3 then
			for i=11,18,1 do
				coinsTab[i] = (coinsTab[i] or 0) + item:getContent():getCoins()/8
			end
		elseif num == -4 then
			for i=4,18,2 do
				coinsTab[i] = (coinsTab[i] or 0) + item:getContent():getCoins()/8
			end
		end
	end
	dump(coinsTab,"updateForecastView")

	for num,coins in pairs(coinsTab) do
		local factor = factors[tostring(num)] or factors[num] or 0
		if not minCoins then
			minCoins = coins * factor
		else
			minCoins = math.min(minCoins,coins * factor)
		end
		if not maxCoins then
			maxCoins = coins * factor
		else
			maxCoins = math.max(maxCoins,coins * factor)
		end
	end
	minCoins = minCoins or 0
	maxCoins = maxCoins or 0
	if minCoins == maxCoins then
		self.mForecastTxt:setString(string.format("%s",tt.getNumShortStr2(minCoins)))
	else
		self.mForecastTxt:setString(string.format("%s~%s",tt.getNumShortStr2(minCoins),tt.getNumShortStr2(maxCoins)))
	end
	local size = self.mForecastTxt:getContentSize()
	self.mStarIcon:setPositionX(138-size.width/2)
end

function TouzhuGameView:setSelectBtnNum(btn,isNor,num)
	if num >= 3 and num <= 18 then
		btn:removeChildByName("num_group")
		local factors = tt.nativeData:getXiazhuFactors()
		local factor = factors[tostring(num)] or factors[num] or 0
		local format = isNor and "number/bet01_%d.png" or "number/bet00_%d.png"
		local num_txt = tt.getBitmapStrAscii(format,"x" .. factor,isNor and 0 or -5)
		num_txt:setName("num_group")
		num_txt:setPosition(cc.p(-30 + (isNor and 0 or -4),-30 + (isNor and 0 or -3)))
		num_txt:addTo(btn)
	end
end

function TouzhuGameView:updateNumSelectBtnsFactors()
	for index,num in ipairs(self.mNumContents) do
		if self.mMyActions[num] then
			local btn = self.mNumSelectBtns[index]
			self:setSelectBtnNum(btn,false,num)
		else
			local btn = self.mNumSelectBtns[index]
			self:setSelectBtnNum(btn,true,num)
		end
	end
end

function TouzhuGameView:updateNumSelectBtns()
	for index,num in ipairs(self.mNumContents) do
		if self.mMyActions[num] then
			local btn = self.mNumSelectBtns[index]
			if num >= 3 and num <= 18 then
				btn:setButtonImage("normal","btn/btn_yellow_" .. num .. ".png",true)
				btn:setButtonImage("pressed","btn/btn_yellow_" .. num .. ".png",true)
				btn:setButtonImage("disabled", "btn/btn_yellow_" .. num .. ".png", true)
			elseif num == -1 then
				btn:setButtonImage("normal","btn/btn_single_pre.png",true)
				btn:setButtonImage("pressed","btn/btn_single_pre.png",true)
				btn:setButtonImage("disabled", "btn/btn_single_pre.png", true)
			elseif num == -2 then
				btn:setButtonImage("normal","btn/btn_small_pre.png",true)
				btn:setButtonImage("pressed","btn/btn_small_pre.png",true)
				btn:setButtonImage("disabled", "btn/btn_small_pre.png", true)
			elseif num == -3 then
				btn:setButtonImage("normal","btn/btn_big_pre.png",true)
				btn:setButtonImage("pressed","btn/btn_big_pre.png",true)
				btn:setButtonImage("disabled", "btn/btn_big_pre.png", true)
			elseif num == -4 then
				btn:setButtonImage("normal","btn/btn_double_pre.png",true)
				btn:setButtonImage("pressed","btn/btn_double_pre.png",true)
				btn:setButtonImage("disabled", "btn/btn_double_pre.png", true)
			end
		else
			local btn = self.mNumSelectBtns[index]
			if num >= 3 and num <= 18 then
				btn:setButtonImage("normal","btn/btn_white_" .. num .. ".png",true)
				btn:setButtonImage("pressed","btn/btn_white_" .. num .. ".png",true)
				btn:setButtonImage("disabled", "btn/btn_white_" .. num .. ".png", true)
			elseif num == -1 then
				btn:setButtonImage("normal","btn/btn_single_nor.png",true)
				btn:setButtonImage("pressed","btn/btn_single_nor.png",true)
				btn:setButtonImage("disabled", "btn/btn_single_nor.png", true)
			elseif num == -2 then
				btn:setButtonImage("normal","btn/btn_small_nor.png",true)
				btn:setButtonImage("pressed","btn/btn_small_nor.png",true)
				btn:setButtonImage("disabled", "btn/btn_small_nor.png", true)
			elseif num == -3 then
				btn:setButtonImage("normal","btn/btn_big_nor.png",true)
				btn:setButtonImage("pressed","btn/btn_big_nor.png",true)
				btn:setButtonImage("disabled", "btn/btn_big_nor.png", true)
			elseif num == -4 then
				btn:setButtonImage("normal","btn/btn_double_nor.png",true)
				btn:setButtonImage("pressed","btn/btn_double_nor.png",true)
				btn:setButtonImage("disabled", "btn/btn_double_nor.png", true)
			end
		end
	end
	self:updateNumSelectBtnsFactors()
end

function TouzhuGameView:onBet()
	if self.mBeting then return end
	tt.play.play_sound("touzhu_touzhu")
	if next(self.mMyActions) then
		local bets = {}
		for num,item in pairs(self.mMyActions) do
			if num >= 3 and num <= 18 then
				bets[num] = (bets[num] or 0) + item:getContent():getCoins()
			elseif num == -1 then
				bets[1] = (bets[1] or 0) + item:getContent():getCoins()
			elseif num == -2 then
				bets[19] = (bets[19] or 0) + item:getContent():getCoins()
			elseif num == -3 then
				bets[20] = (bets[20] or 0) + item:getContent():getCoins()
			elseif num == -4 then
				bets[2] = (bets[2] or 0) + item:getContent():getCoins()
			end
		end
		if next(bets) then
			self:showLoad()
			self.mBeting = true
			tt.gsocket.request("happydice.bet",{mid=tt.owner:getUid(),place = "dice",bets=bets})
		end
	end
end


function TouzhuGameView:onPayBtnPressed()
	if not tolua.isnull(self.mPayBtnAnimNode) then
		self.mPayBtnAnimNode:setPositionY(69)
	end
end


function TouzhuGameView:onPayBtnRelease()
	if not tolua.isnull(self.mPayBtnAnimNode) then
		self.mPayBtnAnimNode:setPositionY(85)
	end
end

function TouzhuGameView:updatePayBtnStatus()
	if not self.mIsCanBet then
		self.mPayBtn:setButtonEnabled(false)
		if not tolua.isnull(self.mPayBtnAnimNode) then
			self.mPayBtnAnimNode:removeSelf()
			self.mPayBtnAnimNode = nil
		end
	else
		self.mPayBtn:setButtonEnabled( next(self.mMyActions) ~= nil )
		if next(self.mMyActions) ~= nil then
			if tolua.isnull(self.mPayBtnAnimNode) then
				local clip = cc.ClippingNode:create()
				local mask = display.newSprite("dec/shaoguangfanwei.png")
				clip:setStencil(mask)
				clip:setAlphaThreshold(0.9)  --不显示模板的透明区域
				clip:setInverted( false ) --显示模板不透明的部分
				clip:setContentSize(mask:getContentSize().width,mask:getContentSize().height)
				clip:setPosition(cc.p(0,0))

				self.mContentBg:addChild(clip)
				clip:setPosition(self.mPayBtn:getPosition())

				-- self.join_room_btn:addChild(clip)
				local animView = display.newSprite("dec/shaoguang.png")
				animView:setBlendFunc(gl.DST_ALPHA, gl.DST_ALPHA)
				animView:setOpacity(128)
				animView:setPosition(cc.p(-300, 0))
				clip:addChild(animView)
				local sequence = transition.sequence({
				    cc.DelayTime:create(1.4),
				    cc.MoveTo:create(0, cc.p(-300, 0)),
				    cc.MoveTo:create(2, cc.p(300, 0)),
				    cc.DelayTime:create(0),
				})

				animView:runAction(cc.RepeatForever:create(sequence))

				-- local sequence = transition.sequence({
				--     cc.FadeTo:create(0, 255),
				--     cc.DelayTime:create(2.4),
				--     cc.FadeTo:create(0.3, 0),
				--     cc.DelayTime:create(0.7),
				-- })
				-- animView:runAction(cc.RepeatForever:create(sequence))

				self.mPayBtnAnimNode = clip
				self:onPayBtnRelease()
			end
		else
			if not tolua.isnull(self.mPayBtnAnimNode) then
				self.mPayBtnAnimNode:removeSelf()
				self.mPayBtnAnimNode = nil
			end
		end
		

	end
end

function TouzhuGameView:setCurStage(happyid,stage)
	self.mCurHappyid = happyid
	self.mCurStage = stage
	self.mCurStageTxt:setString(tt.gettext("距{s1}期截止",stage))
	self:updatePayBtnStatus()
end

function TouzhuGameView:startCurStageCountDown(time)
	self:stopAllActionsByTag(1)

	local function update()
		local countdown = time - tt.time()
		if countdown < 0 then countdown = 0 end
		-- self.mCountdownTxt:setString(os.date("%M:%S",countdown))
		self.mLotteryInfoBg:removeChildByName("countdown_img_str")

		if self.mIsCanBet then
			self.mCountdownTxt:setString("")

			local str = os.date("%M:%S",countdown)
			local num_txt = tt.getBitmapStrAscii("number/bet002_%d.png",str,2)
			num_txt:addTo(self.mLotteryInfoBg)
			num_txt:setPosition(self.mCountdownTxt:getPosition())
			num_txt:setName("countdown_img_str")
			num_txt:setAnchorPoint(cc.p(0.5,0.5))
		else
			self.mCountdownTxt:setString(tt.gettext("暂停销售"))
		end
		
		if countdown == 0 then
			self:stopAllActionsByTag(1)
		end
	end
	update()
	self:schedule(update,1):setTag(1)
end

function TouzhuGameView:setLastStage(happyid,stage)
	self.mLastHappyid = happyid
	self.mLastStage = stage
	if stage == 0 then
		self.mLastStageTxt:setString("-")
	else
		self.mLastStageTxt:setString(tt.gettext("{s1}期开奖中...",stage))
	end
end

function TouzhuGameView:setLastLuck(luck)
	if next(luck) then
		for i=1,3 do
			local num = luck[i]
			if num and num <= 6 and num >= 1 then
				self.mLastLuckNums[i]:setTexture("dec/dec_".. num ..".png")
				self.mLastLuckNums[i]:setVisible(true)
			end
		end
		self.mLastStageTxt:setString(tt.gettext("{s1}期开奖:",self.mLastStage))
		self.mLastTipsTxt:setString("")
	else
		for i=1,3 do
			self.mLastLuckNums[i]:setVisible(false)
		end
		if self.mLastStage == 0 then
			self.mLastTipsTxt:setString("")
		else
			self.mLastTipsTxt:setString(tt.gettext("等待开奖"))
		end
	end
	self:stopAllActionsByTag(2)
end

function TouzhuGameView:playLuckAnim(luck)
	tt.play.play_sound("touzhu_lottery")
	self.mRandomSum = 0
	local cnt = 50
	local time = 5/cnt
	local nums = {0,0,0}
	self:stopAllActionsByTag(2)
	self.mLastTipsTxt:setString("")

	for i=1,3 do
		local num = math.random(1,6)
		self.mLastLuckNums[i]:setTexture("dec/dec_".. num ..".png")
		self.mLastLuckNums[i]:setVisible(true)
	end

	self:schedule(function()
			cnt = cnt - 1
			for i=1,3 do
				if i == 1 and cnt >= 10 then
					if cnt == 10 then
						tt.play.play_sound("touzhu_lottery_dice")
						nums[i] = luck[i]
					else
						nums[i] = math.random(1,6)
					end
				elseif i == 2 and cnt >= 5 then
					if cnt == 5 then
						tt.play.play_sound("touzhu_lottery_dice")
						nums[i] = luck[i]
					else
						nums[i] = math.random(1,6)
					end
				elseif i == 3 and cnt >= 0 then
					if cnt == 0 then
						tt.play.play_sound("touzhu_lottery_dice")
						nums[i] = luck[i]
					else
						nums[i] = math.random(1,6)
					end
				end
				self.mLastLuckNums[i]:setTexture("dec/dec_".. nums[i] ..".png")
			end
			if cnt == 0 then
				self:setLastLuck(luck)
				self:stopAllActionsByTag(2)
			end
		end,time):setTag(2)
end

function TouzhuGameView:addHistoryLotteryItems(data)
	local item = self.mHistoryLotteryList:newItem()
	local content = app:createView("TouzhuLuckItems", self.control_)
	content:setStage(data.stage)
	content:setLuck(data.luck_num)
	item:addContent(content)
	local size = content:getContentSize()
	item:setItemSize(size.width, size.height)
	item:setMargin({left = 0, right = 0, top = 0, bottom = 0})
	self.mHistoryLotteryList:addItem(item,1)
end

function TouzhuGameView:onHistoryLotteryLoad(datas)
	self.mHistoryLotteryList:removeAllItems()
	self.mHistoryLotteryLoadDatas = datas
	self.mHistoryLotteryLoadIndex = 1
	self.mHistoryLotteryList:setVisible(false)
	self.mHistoryLotteryList:stopAllActionsByTag(1)
	self.mHistoryLotteryList:schedule(function()
			if self.mHistoryLotteryLoadIndex < #self.mHistoryLotteryLoadDatas then
				for i=self.mHistoryLotteryLoadIndex,#self.mHistoryLotteryLoadDatas do
					self.mHistoryLotteryLoadIndex = i + 1
					local data = self.mHistoryLotteryLoadDatas[i]
					local item = self.mHistoryLotteryList:newItem()
					local content = app:createView("TouzhuLuckItems", self.control_)
					content:setStage(data.stage)
					content:setLuck(data.luck_num)
					item:addContent(content)
					local size = content:getContentSize()
					item:setItemSize(size.width, size.height)
					item:setMargin({left = 0, right = 0, top = 0, bottom = 0})
					self.mHistoryLotteryList:addItem(item)
					if i%2 == 0 then 
						break
					end
				end
				print(self.mHistoryLotteryLoadIndex,#self.mHistoryLotteryLoadDatas)
			else
				-- self.mHistoryLotteryList:removeAllItems()
				-- local content = display.printscreen(self.mHistoryLotteryList.container, {})
				-- local item = self.mHistoryLotteryList:newItem()
				-- item:addContent(content)
				-- local size = content:getContentSize()
				-- item:setItemSize(size.width, size.height)
				-- self.mHistoryLotteryList:addItem(item)
				-- self.mHistoryLotteryList:reload()
				self.mHistoryLotteryList:setVisible(true)
				self.mHistoryLotteryList:reload()
				self.mHistoryLotteryList:stopAllActionsByTag(1)
			end
		end,0):setTag(1)
	self.mHistoryLotteryList:reload()
end

function TouzhuGameView:updateVipScoreView()
	if self.isLockVipsScore then return end
    self.mVipTxt:setString(tt.getNumStr(tt.owner:getVipScore()))
end

function TouzhuGameView:updateVipLvView()
    self.mIcon:setTexture(string.format("dec/icon_vip".. tt.owner:getVipLv() .. ".png"))
end

function TouzhuGameView:onEnter()
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}

	self.mUserInfoEventHandlers = {
		-- tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateMoney)),
		-- tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_JUAN,handler(self,self.updateJuan)),
		tt.owner:addEventListener(tt.owner.EVENT_COINS,handler(self,self.updateCoins)),

	}
end

function TouzhuGameView:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

function TouzhuGameView:onSocketData(evt)
	print("TouzhuGameView onSocketData",evt.cmd)
	if evt.cmd == "happydice.info" then
		if evt.resp then
			self:initView()
			local resp = evt.resp
			if resp.ret == 200 then
				self.mIsCanBet = true
			elseif resp.ret == -101 then
				self.mIsCanBet = false
			end

			self:setCurStage(resp.happyid,resp.stage)
			self:startCurStageCountDown(tt.time()+resp.luck_time)

			if resp.last_stage ~= 0 then
				self:setLastStage(resp.last_happyid,resp.last_stage)
				self:setLastLuck(resp.last_luck)
			else
				self:setLastStage("",0)
				self:setLastLuck({})
			end

			tt.owner:setCoins(evt.resp.left_gold)
			-- tt.gsocket.request("happydice.luck_history",{happyid=resp.happyid,num=1})

			if resp.happyid and resp.happyid ~= "" then
				tt.gsocket.request("happydice.luck_history",{
						happyid = resp.happyid,  --总期标记(用日期表示)
						num = 32,    --几条历史记录 -1:表示拉所有
					})
			end

			if tt.nativeData.getXiazhuFactorVersion() ~= resp.show_ver then
				tt.gsocket.request("happydice.show_table")
			end
		elseif evt.broadcast then
			self.mIsCanBet = evt.broadcast.flag == 1
			self:updatePayBtnStatus()
		end
	elseif evt.cmd == "happydice.show_table" then
		self:updateNumSelectBtnsFactors()
		self:updateForecastView()
	elseif evt.cmd == "happydice.new_stage" then
		if evt.broadcast then
			if self.mCurHappyid == evt.broadcast.happyid and evt.broadcast.stage == self.mCurStage then -- 服务器重启会重新广播
				self:setCurStage(evt.broadcast.happyid,evt.broadcast.stage)
				self:startCurStageCountDown(tt.time()+evt.broadcast.luck_time)
			else
				self:setLastStage(self.mCurHappyid or "",self.mCurStage or 0)
				self:setLastLuck({})
				self:setCurStage(evt.broadcast.happyid,evt.broadcast.stage)
				self:startCurStageCountDown(tt.time()+evt.broadcast.luck_time)
			end
		end
	elseif evt.cmd == "happydice.open_stage" then
		if evt.resp then
		 	if evt.resp.ret == 200 then
		 		if self.mBroadHappyid == evt.resp.happyid and self.mBroadStage == evt.resp.stage then
		 			self.mBroadHappyid = ""
					self.mBroadStage = 0
					self.mWinningScore = evt.resp.winscore
			 		if self.mWinningScore ~= 0 and self.mCanShowWinning then
						self.control_:showTouzhuWinningDialog(self.mWinningScore)
						self.mWinningScore = 0
						self.mCanShowWinning = false
			 		end
			 	end
		 	end
		elseif evt.broadcast then
			if self.mLastHappyid == evt.broadcast.happyid and self.mLastStage == evt.broadcast.stage then
				self.mBroadHappyid = self.mLastHappyid
				self.mBroadStage = self.mLastStage
				self.mCanShowWinning = false
				self.mWinningScore =  0

				self:playLuckAnim(evt.broadcast.luck_num)
				self.isLockVipsScore = true

				self:addHistoryLotteryItems({
						stage = evt.broadcast.stage,
						luck_num = evt.broadcast.luck_num,
					})
				self:performWithDelay(function()
						self.isLockVipsScore = false
						self.mCanShowWinning = true
						self:updateVipScoreView()
						self.mHistoryLotteryList:reload()
				 		if self.mWinningScore ~= 0 and self.mCanShowWinning then
							self.control_:showTouzhuWinningDialog(self.mWinningScore)
							self.mWinningScore = 0
							self.mCanShowWinning = false
				 		end
					end, 5)
			end
		end

	elseif evt.cmd == "happydice.money2gold" then
		if evt.resp then
			local ret = evt.resp.ret
			if ret == 200 then
				-- tt.show_msg(tt.gettext("兑换成功"))
			elseif ret == -101 then
				tt.show_msg(tt.gettext("筹码不足"))
			else
				tt.show_msg(tt.gettext("兑换失败"))
			end
		end

	elseif evt.cmd == "happydice.bet" then
		if evt.resp then
			self.mBeting = false
			self:hideLoad()
			local ret = evt.resp.ret
			if ret == 200 then
				self:playBetAnim()
				self:clearAllAction()
			elseif ret == -102 then
				tt.show_msg(tt.gettext("金币不足"))
			else
				tt.show_msg(tt.gettext("投注失败"))
			end
		end
	elseif evt.cmd == "happydice.luck_history" then
		if evt.resp and evt.resp.ret == 200 then
			if evt.resp.happyid == self.mCurHappyid then
				self:onHistoryLotteryLoad(evt.resp.record)
			end
		end
		
	end
end

return TouzhuGameView