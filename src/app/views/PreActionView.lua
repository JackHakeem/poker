--
-- Author: he
-- Data: 2017-04-13
--
--

local PreActionView = class("PreActionView", function(...)
	return display.newLayer()
end)

function PreActionView:ctor(ctl)
	self.ctl_ = ctl
	self.foldWasChosen = false -- fold预操作按钮是否被选中
	self.checkWasChosen = false -- check预操作按钮是否被选中
	self.callWasChosen = false -- call预操作按钮是否被选中

	local node, width, height = cc.uiloader:load("pre_action.json")
	self:addChild(node)
	self.root_ = node

	self.foldBtn = cc.uiloader:seekNodeByName(node, "foldBtn")
					:onButtonClicked(function(event)
						-- tt.play.play_sound("click")
						self:fold()
					end)

	self.mFoldTxt = cc.uiloader:seekNodeByName(node, "fold_txt")

	self.checkBtn = cc.uiloader:seekNodeByName(node, "checkBtn")
						:onButtonClicked(function(event)
							-- tt.play.play_sound("click")
							self:check()
						end)

	self.mCheckTxt = cc.uiloader:seekNodeByName(node, "check_txt")
	self.mCheckNumTxt = cc.uiloader:seekNodeByName(node, "check_num_txt")


	self.callBtn = cc.uiloader:seekNodeByName(node, "callAnyBtn")
					:onButtonClicked(function(event)
						-- tt.play.play_sound("click")
						self:call()
					end)

	self.mCallTxt = cc.uiloader:seekNodeByName(node, "call_txt")		

	self:hide()
	self:setTouchSwallowEnabled(false)

	tt.log.d(TAG, "init preActionView over")
end

--[Comment]
-- 显示 加注操作界面
function PreActionView:showRaiseView()
	self.mFoldTxt:setString(tt.gettext("弃牌"))

	local model = self.ctl_.mModel
	local seat_id = model:getCtlSeat()
	local maxBet = math.max(model:getRoundMaxBet(),model:getCurBB())
	local bet = maxBet - model:getSeatBets(seat_id)
	print("showRaiseView",maxBet,model:getSeatBets(seat_id))
	bet = math.min(self.ctl_:getSeatById(seat_id):getCoin(),bet)
	print("showRaiseView bet",bet,self.bet_)
	if bet ~= self.bet_ then
		self:resetCheck()
		self.bet_ = bet
	end
	
	self.mCheckTxt:setString(tt.gettext("跟注"))
	self.mCheckNumTxt:setVisible(true)
	self.mCheckNumTxt:setString(bet)

	self.mCallTxt:setString(tt.gettext("跟任何注"))
end

--[Comment]
-- 显示 跟牌操作界面
function PreActionView:showCheckView()

	self.mFoldTxt:setString(tt.gettext("弃牌/过牌"))


	self.mCheckTxt:setString(tt.gettext("过牌"))
	self.mCheckNumTxt:setVisible(false)

	self.mCallTxt:setString(tt.gettext("跟任何注/过牌"))
end

function PreActionView:show()
	tt.log.d(TAG, "pre action view show")
	
	self.foldBtn:setVisible(true)
	-- self:resetFold()

	self.checkBtn:setVisible(true)
	-- self:resetCheck()

	self.callBtn:setVisible(true)
	-- self:resetCall()

	if not self:isCanCheck() then
		self:showRaiseView()
	else
		self:showCheckView()
	end

	self.mIsShow = true
	self:setVisible(self.mIsShow and not self.mRetainStatus)
end

function PreActionView:setRetainStatus(flag)
	self.mRetainStatus = flag
	self:setVisible(self.mIsShow and not self.mRetainStatus)
end

function PreActionView:isCanCheck()
	local ctl_seat = self.ctl_.mModel:getCtlSeat()
	local bets = self.ctl_.mModel:getSeatBets(ctl_seat)
	local max_bets = self.ctl_.mModel:getRoundMaxBet()
	return bets == max_bets
end

function PreActionView:update()
	if self:isCanCheck() then
		self:showCheckView()
		return
	end
	-- 只有当不是fold or call被选中时，才重置
	if self.foldWasChosen or self.callWasChosen then
		-- 只改变上面的内容，不改变状态
	else
		self:resetFold()
		-- self:resetCheck()
		self:resetCall()
	end
	self:showRaiseView()
end

function PreActionView:fold()
	tt.log.d(TAG, "fold button was clicked[%s]", self.foldWasChosen)
	if self.foldWasChosen then
		self:resetFold()
	else
		self.foldWasChosen = true	
		self.foldBtn:setButtonImage("normal","btn/checkbox_red_pre.png",true)
		self.foldBtn:setButtonImage("pressed","btn/checkbox_red_nor.png",true)

		self:resetCheck()
		self:resetCall()
	end
end

function PreActionView:check()
	tt.log.d(TAG, "check button was clicked[%s]", self.checkWasChosen)
	if self.checkWasChosen then
		self:resetCheck()
	else
		self.checkWasChosen = true

		self.checkBtn:setButtonImage("normal","btn/checkbox_green_pre.png",true)
		self.checkBtn:setButtonImage("pressed","btn/checkbox_green_nor.png",true)

		self:resetFold()
		self:resetCall()
		tt.log.d(TAG, "check button was clicked[%s]", self.checkWasChosen)
	end
end

function PreActionView:call()
	tt.log.d(TAG, "call button was clicked[%s]", self.callWasChosen)
	if self.callWasChosen then
		self:resetCall()
	else
		self.callWasChosen = true
		
		self.callBtn:setButtonImage("normal","btn/checkbox_yellow_pre.png",true)
		self.callBtn:setButtonImage("pressed","btn/checkbox_yellow_nor.png",true)

		self:resetFold()
		self:resetCheck()
	end
end


function PreActionView:resetFold()
	self.foldWasChosen = false
	self.foldBtn:setButtonImage("normal","btn/checkbox_red_nor.png",true)
	self.foldBtn:setButtonImage("pressed","btn/checkbox_red_pre.png",true)
end

function PreActionView:resetCheck()
	self.bet_ = nil
	self.checkWasChosen = false

	self.checkBtn:setButtonImage("normal","btn/checkbox_green_nor.png",true)
	self.checkBtn:setButtonImage("pressed","btn/checkbox_green_pre.png",true)
end

function PreActionView:resetCall()
	self.callWasChosen = false

	self.callBtn:setButtonImage("normal","btn/checkbox_yellow_nor.png",true)
	self.callBtn:setButtonImage("pressed","btn/checkbox_yellow_pre.png",true)
end

function PreActionView:doAction()

	assert(self.foldWasChosen or self.checkWasChosen or self.callWasChosen)

	if self.foldWasChosen then
		tt.log.d(TAG, "Do action fold")
		assert( not self.checkWasChosen )
		assert( not self.callWasChosen )

		if not self:isCanCheck() then
			self.ctl_.mControler:onFoldLogic()
		else
			self.ctl_.mControler:onCheckLogic()
		end
	elseif self.checkWasChosen then
		tt.log.d(TAG, "Do action check")
		assert( not self.foldWasChosen )
		assert( not self.callWasChosen )
		self.ctl_.mControler:onCheckLogic()
	elseif self.callWasChosen then
		tt.log.d(TAG, "Do action call")
		assert( not self.foldWasChosen )
		assert( not self.checkWasChosen )
		self.ctl_.mControler:onCheckLogic()
	else
		assert(nil)
	end
	self:hide()
end

function PreActionView:getSetFlag()
	return self.foldWasChosen or self.checkWasChosen or self.callWasChosen
end

function PreActionView:reset()
	self:hide()
end

function PreActionView:actionDone()
	self:hide()
end

function PreActionView:hide()
	self:resetFold()
	self:resetCheck()
	self:resetCall()

	self:setVisible(false)
	self.mIsShow = false
end

return PreActionView
