--
-- Author: shineflag
-- Date: 2017-02-23 19:10:54
--
local factory = require("app.utils.factory")
local CircleClip = require("app.ui.CircleClip")
local scheduler = require("framework.scheduler")
local net = require("framework.cc.net.init")
local log = tt.log

local TAG = "SEAT"

local left_pos = {
	flag = cc.p(-11,83),
	
} 

local right_pos = {
	flag = cc.p(144,86),
} 



local SeatView = class("SeatView", function()
	return display.newNode()
end)

local allin = 1
local bet = 2
local raise = 6
local call = 3
local check = 4
local fold = 5


function SeatView:ctor(control,seatid)

	self.control_ = control 

	self.playFlag = false

	self.id_ = seatid 

	--find view by layout
	local node, width, height = cc.uiloader:load("seat_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.play_view = cc.uiloader:seekNodeByName(node,"play_view")

	self.head_handler = cc.uiloader:seekNodeByName(self.play_view,"head_bg")


	self.userinfo_btn = cc.uiloader:seekNodeByName(self.play_view,"userinfo_btn")
		:onButtonClicked(function()
			if self:hasPlayer() then
				self.control_:showUserInfoDialog(self.player_)
			end
		end)

	

	self.mUserInfoBg = cc.uiloader:seekNodeByName(self.play_view,"user_info_bg"):setVisible(false)
	self.mShowWin = false
	self.mUserWinBg = cc.uiloader:seekNodeByName(self.play_view,"user_win_bg")
	self.mWinTypeTxt = cc.uiloader:seekNodeByName(self.play_view,"win_type_txt")

	self.name_label_ = cc.uiloader:seekNodeByName(self.play_view,"name_txt")
	self.coin_label_ = cc.uiloader:seekNodeByName(self.play_view,"coin_txt")


	self.mActionTip =  cc.uiloader:seekNodeByName(self.play_view,"action_tip")
	self.mActionTip:setVisible(false)

	self.play_flag_ =  cc.uiloader:seekNodeByName(self.play_view,"flag")
	self:setCardsFlag(false)

	local size = self.head_handler:getContentSize()
	local sp = display.newSprite("dec/def_head1.png")
	local mask = display.newSprite("dec/zhezhao.png")
	self.head_  = CircleClip.new(sp,mask)
		:addTo(self.head_handler,99)
		:setPosition(cc.p(-1,-1))
		:setCircleClipContentSize(size.width,size.width)
	self.userStatus = cc.uiloader:seekNodeByName(self.play_view,"user_status_bg")
		:setVisible(false)
	self.userStatusVisible = false
	self.userStatusTxtImg = cc.uiloader:seekNodeByName(self.userStatus,"status_txt")

	self.card1_ = nil --亮牌
	self.card2_ = nil
	self.poker =  cc.uiloader:seekNodeByName(self.play_view,"poker")
	self.poker_1_handler = cc.uiloader:seekNodeByName(self.poker,"poker_1_handler")
	self.poker_2_handler = cc.uiloader:seekNodeByName(self.poker,"poker_2_handler")
	
	
	self.progress_handler = cc.uiloader:seekNodeByName(self.play_view,"progress_handler")

	self.coin_ = 0  --筹码

	--bet action 
    self.bet_anim_  = cc.ProgressTimer:create(cc.Sprite:create("dec/dec_pbar_white.png"))
	    :setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	    :setReverseDirection(true)
	    :setMidpoint(cc.p(0.5,0.5))
	    :setPosition(0,0)
	    :setVisible(false)
	    :setAnchorPoint(cc.p(0,0))
    	:addTo(self.progress_handler,100)

    -- 控制座位是否生效
    self.seat_visible_ = true

    self:setNodeEventEnabled(true, listener)
	self.sit_view_visible = false

	
	cc.uiloader:seekNodeByName(node,"sit_btn")
		:onButtonClicked(function() 
				tt.play.play_sound("click")
				self.control_.mControler:onSitDownClick(seatid)
			end)

	self:setSeatdownView(cc.uiloader:seekNodeByName(node,"set_view"))

	self:updateSeatBottomShow()
end

function SeatView:getId()
	return self.id_
end

function SeatView:onExit()
	self:stopTimer()
end

function SeatView:userAction(action_id)
	self.mActionTip:stopAllActionsByTag(1)
	self.mActionTip:setVisible(true)
	if action_id == allin then
		self.mActionTip:setTexture("dec/dec_allin.png")
	elseif action_id == bet then
		self.mActionTip:setTexture("dec/dec_bet.png")
	elseif action_id == call then
		self.mActionTip:setTexture("dec/dec_call.png")
	elseif action_id == check then
		self.mActionTip:setTexture("dec/dec_check.png")
	elseif action_id == fold then
		self.mActionTip:setTexture("dec/dec_fold.png")
	elseif action_id == raise then
		self.mActionTip:setTexture("dec/dec_raise.png")
	else
		self.mActionTip:setVisible(false)
	end
	self.mActionTip:performWithDelay(function()
			self.mActionTip:setVisible(false)
		end, 3):setTag(1)
end

function SeatView:setSeatdownView(view)
	self.sit_view_ = view
	self.sit_view_:setVisible(self.sit_view_visible)
end

function SeatView:setNameLabel(str)
	self.name_label_:setString(str)
end

function SeatView:updateCoinLabel()
	self.coin_label_:setString(tt.getNumStr(self.coin_))
end

function SeatView:setShowLeft()
	-- self.play_flag_:setPosition(left_pos.flag)
end

function SeatView:setShowRight()
	-- self.play_flag_:setPosition(right_pos.flag)
end

function SeatView:onBuyCoin(info)
	self.coin_ = info.tcoin 
	self:updateCoinLabel()
	log.d(TAG,"seat[%d] buy coin[%d] ",self.id_,self.coin_)
end

function SeatView:setSeatVisible(flag)
	self.seat_visible_ = flag == true
end

function SeatView:synGameInfo(info)
	-- {seatid=1,coin=100,chips=1000,isfold=false,allin=false,cards={0x0,0x0}}
	self:onStart()
	self:setCardsFlag(not info.isfold)
	self:setIsPlaying(not info.isfold)
	self:setCoin(info.coin)
end

--用户坐下，设置用户信息
function SeatView:setSeatInfo(info)
	self.sit_view_visible = false
	if self.sit_view_ then
		self.sit_view_:setVisible(self.sit_view_visible and self.seat_visible_ )
	end
	self.play_view:setVisible(true)


	self.coin_ = info.coin 
	self.player_ = info.player 

	self.pinfo_  = json.decode(info.player.info) or {name="user" .. self.player_.mid}

	self:updateCoinLabel()
	self:setNameLabel(self.pinfo_.name)
	self:setUserStatus(info.sretain)

	self:setVisible(self.seat_visible_)

	print('SeatView:setSeatInfo',self.pinfo_.img_url)
	if self.head_ then
		self.head_:removeSelf()
		self.head_ = nil
	end
	tt.asynGetHeadIconSprite(string.urldecode(self.pinfo_.img_url or ""),function(sprite)
		if sprite and self and self.head_handler then
			local size = self.head_handler:getContentSize()
			local mask = display.newSprite("dec/zhezhao.png")
			if self.head_ then
				self.head_:removeSelf()
				self.head_ = nil
			end
			self.head_ = CircleClip.new(sprite,mask)
				:addTo(self.head_handler,99)
				:setPosition(cc.p(-1,-1))
				:setCircleClipContentSize(size.width,size.width)
		end
	end)
	printInfo("seat[%d] sit player[%d] coin[%d] ",checknumber(self.id_),checknumber(self.player_.mid),checknumber(self.coin_))
end

--是否有玩家座下
function SeatView:hasPlayer()
	return self.player_ ~= nil
end

function SeatView:onStand()
	self:clearSeat()
	log.d(TAG,"seat[%d] stand up",self.id_)
end

function SeatView:clearSeat()
	self.play_view:stopAllActionsByTag(1)
	self.play_view:scaleTo(0.2, 1):setTag(1)
	self:hiddenSeat()
	self.player_ = nil 
end

--展示坐下的按钮
function SeatView:showSeat()

	self.sit_view_visible = true
	if self.sit_view_ then
		self.sit_view_:setVisible(self.sit_view_visible and self.seat_visible_ )
	end
	self.play_view:setVisible(false)

	self:setVisible(self.seat_visible_)
end

function SeatView:hiddenSeat()
	self:stopBetTimeAnim()
	self:setVisible(false)
	if self.sit_view_ then
		self.sit_view_:setVisible(false)
	end
end

function SeatView:setCardsFlag(flag)
	local isSelf = self:isSelf()
	self.play_flag_visible = flag
	self.play_flag_:setVisible(flag and not isSelf)
end

function SeatView:getShowCardPosition()
	local size = self.poker_1_handler:getContentSize()
	return self.poker_1_handler:convertToWorldSpace(cc.p(size.width/2,size.height/2-10)),self.poker_2_handler:convertToWorldSpace(cc.p(size.width/2,size.height/2-10))
end

function SeatView:showHands(cards)
	if not cards then return end
	self:clearShowHands()
	-- if self:isSelf() then return end

	local size = self.poker_1_handler:getContentSize()

	self.card1_ = factory.getPoker(cards[1])
		:setPosition(cc.p(size.width/2,size.height/2-10))
		:addTo(self.poker_1_handler)

	self.card2_ = factory.getPoker(cards[2])
		:setPosition(cc.p(size.width/2,size.height/2-10))
		:addTo(self.poker_2_handler)

	if self.play_flag_visible then
		local time = 0.4
		transition.moveTo(self.card1_, {
					x=size.width/2,
					y=size.height/2,
					time=time,
				})
		transition.moveTo(self.card2_, {
				x=size.width/2,
				y=size.height/2,
				time=time,
			})
	else
		self.card1_:setPosition(cc.p(size.width/2,size.height/2))
		self.card2_:setPosition(cc.p(size.width/2,size.height/2))
	end
		
	self:setCardsFlag(false)
end

function SeatView:clearShowHands()
	if self.card1_ then 
		self.card1_:removeSelf()
		self.card1_ = nil
	end
	if self.card2_ then 
		self.card2_:removeSelf()
		self.card2_ = nil
	end
end

function SeatView:setBestCards(cardtype, bestcards)
	self.cardtype_ = cardtype 
	self.bestcards_ = bestcards

	-- if self.win_type_img_ then 
	-- 	self.win_type_img_:removeSelf()
	-- 	self.win_type_img_ = nil 
	-- end
	local size = self.mUserWinBg:getContentSize()
	-- self.win_type_img_ = display.newSprite(string.format("fonts/cardtype_%d.png",cardtype)) 
	-- 		:align(display.CENTER, size.width/2, size.height/2)
	-- 		:addTo(self.mUserWinBg)
	-- 		:setVisible(false)

end

function SeatView:getCardsView()
	return {self.card1_,self.card2_}
end

function SeatView:winShow() 
	-- if self:isSelf() then 
	-- 	if self.win_type_img_ then 
	-- 		self.win_type_img_:setVisible(true)
	-- 	end
	-- 	self.mShowWin = true
	-- 	self:updateSeatBottomShow()
	-- 	return 
	-- end
	if self.bestcards_ then
		if self.card1_ then
			self.card1_:setGray(true)
		end
		if self.card2_ then
			self.card2_:setGray(true)
		end

		for _,c in pairs(self.bestcards_) do
			if self.card1_ and self.card1_.card_value_ == c then 
				self.card1_:setGray(false)
				self.card1_:winShow()
			elseif self.card2_ and self.card2_.card_value_ == c then 
				self.card2_:setGray(false)
				self.card2_:winShow()
			end
		end

		local tp_name = {
			tt.gettext("高牌"),
			tt.gettext("一对"),
			tt.gettext("二对"),
			tt.gettext("三条"),
			tt.gettext("顺子"),
			tt.gettext("同花"),
			tt.gettext("葫芦"),
			tt.gettext("金刚"),
			tt.gettext("同花顺"),
			tt.gettext("皇家同花顺"),
		}
		self.mWinTypeTxt:setString(tp_name[self.cardtype_])
		self.mWinTypeTxt:setVisible(true)
		-- if self.win_type_img_ then 
		-- 	self.win_type_img_:setVisible(true)
		-- end

		self.play_flag_:setVisible(false)
		self.mShowWin = true
		self:updateSeatBottomShow()
	end
end

function SeatView:winCoin(coin)
	self.coin_ = self.coin_ + coin 
	-- self:updateCoinLabel()
end

function SeatView:setUserStatus(sr)
	self.sr_ = sr or 1   --离座留桌状态
	--1:回到座位 0:离座留桌
	if self.sr_ == 0 and self:canShowOffline() then 
		self:setUserStatusTxtImg(true,tt.gettext("离座留桌"))
	else
		self:setUserStatusTxtImg(false)
	end
end

function SeatView:setUserStatusTxtImg(flag,str)
	self.userStatusVisible = flag
	self:updateSeatBottomShow()
	if str then
		self.userStatusTxtImg:setString(str)
	end
end

function SeatView:updateSeatBottomShow()
	self.mUserWinBg:setVisible(self.mShowWin)
	self.userStatus:setVisible(self.userStatusVisible and not self.mShowWin)
	self.mUserInfoBg:setVisible(not self.userStatusVisible and not self.mShowWin)
end

function SeatView:isOffline()
	return self.sr_ == 0
end

--设置当前座位的筹码数
function SeatView:setCoin(coin)
	log.d(TAG,"seatid[%d], setCoin [%d]",self.id_, coin)
	self.coin_ = coin 
	self:updateCoinLabel()
end

function SeatView:playBetTimeAnim(t,total)
	--log.d(TAG,"action time [%d]",t)
	self:stopBetTimeAnim()
	-- self:startTimer(t,total)
	if self.id_ == self.control_.mModel:getCtlSeat() then
		self.play_view:stopAllActionsByTag(1)
		self.play_view:scaleTo(0.2, 1.1):setTag(1)
	end

	local per = 100 
	total = tonumber(total) or t
	if total and total > 0 then 
		per = math.ceil(t*100/total) 
	end
	local action  = cc.ProgressFromTo:create(t, per,0)
	self.bet_anim_:runAction(action)
	self.bet_anim_:setVisible(true)

	local offsetT = total - t
	local time1 = total/2
	local time2 = total/3

	self.bet_anim_:setColor(cc.c3b(0x90, 0xff, 0x64))
	-- if offsetT <= time1 then
	-- 	local mul = offsetT/time1
	-- 	self.bet_anim_:setColor(cc.c3b(3+(222-3)*mul, 173+(219-173)*mul, 27+(4-27)*mul))
	-- 	local actions = {
	-- 		cc.TintTo:create(time1-offsetT, 222, 219, 4),
	-- 		cc.TintTo:create(total/3, 170, 32, 0),
	-- 	}
	-- 	self.bet_anim_:runAction(transition.sequence(actions))
	-- elseif offsetT <= time2 + time1 then
	-- 	local mul = (offsetT-time1)/time2
	-- 	self.bet_anim_:setColor(cc.c3b(222+(170-222)*mul, 219+(32-219)*mul, 4+(0-4)*mul))
	-- 	local actions = {
	-- 		cc.TintTo:create(time2 + time1 - offsetT, 170, 32, 0),
	-- 	}
	-- 	self.bet_anim_:runAction(transition.sequence(actions))
	-- else
	-- 	self.bet_anim_:setColor(cc.c3b(170, 32, 0))
	-- end

	if self:isSelf() and t > 5  then
		self.bet_anim_:performWithDelay(function()
    			tt.play.play_sound("action_timedown")
			end, t-5)
	end

end


function SeatView:stopBetTimeAnim()
	self.play_view:stopAllActionsByTag(1)
	self.play_view:scaleTo(0.2, 1):setTag(1)
	--log.d(TAG,"stop ")
	--1:回到座位 0:离座留桌
	if self.sr_ == 0 and self:canShowOffline() then 
		self:setUserStatusTxtImg(true,tt.gettext("离座留桌"))
	else
		self:setUserStatusTxtImg(false)
	end

	-- self:stopTimer()
	self.bet_anim_:stopAllActions()
	self.bet_anim_:setVisible(false)
end

--用户下注
function SeatView:betCoin(coin,isBet,isRaise)
	log.d(TAG,"seatid[%d], now coin[%d] betCoin [%d]",self.id_, self.coin_, coin)
	self.coin_ = self.coin_ - coin 
	self:updateCoinLabel()
	if self.coin_ == 0 then
		self:userAction(allin)
	elseif isBet then
		if isRaise then
			self:userAction(raise)
		else
			self:userAction(bet)
		end
	else
		self:userAction(call)
	end
end

function SeatView:check()
	self:userAction(check)
end

--弃牌
function SeatView:fold()
	log.d(TAG,"seat[%d] fold ",self.id_)
	self:setCardsFlag(false)
	
	self.playFlag = false

	self:userAction(fold)
end

function SeatView:isSelf()
	if self.player_ == nil then return false end
	return self.player_.mid == tt.owner:getUid()
end

-- added by hy 170413 是否还在玩牌
function SeatView:isPlaying()
	if not self:hasPlayer() then return false end
	return self.playFlag == true
end

function SeatView:setIsPlaying(flag)
	self.playFlag = flag == true
end

function SeatView:setWait()
	if self.sr_ ~= 0 then 
		self:setUserStatusTxtImg(true,tt.gettext("等待入局"))
	end
end

--游戏开始时做一些清理工作
function SeatView:onStart()
	self:clearShowHands()

	self.bestcards_ = nil 

	if self.sr_ == 0 and self:canShowOffline() then 
		self:setUserStatusTxtImg(true,tt.gettext("离座留桌"))
	else
		self:setUserStatusTxtImg(false)
	end

	self.playFlag = true
end

function SeatView:canShowOffline()
	return self.control_.mModel:getRoomType() ~= 3 or self:isSelf()
end

--清理赢牌的高亮显示
function SeatView:clearWinShow()
	if self.card1_ then 
		self.card1_:setGray(false)
		self.card1_:normal()
	end
	if self.card2_ then 
		self.card2_:setGray(false)
		self.card2_:normal()
	end

	-- if self.win_type_img_ then 
	-- 	self.win_type_img_:removeSelf()
	-- 	self.win_type_img_ = nil
	-- end

	self.mWinTypeTxt:setString("")

	self.mShowWin = false
	self:updateSeatBottomShow()
end

function SeatView:getCoin()
	return self.coin_
end

function SeatView:startTimer(t,total)
	self:stopTimer()
	if t <= 0 then return end
	total = tonumber(total) or t
	if total < t or total < 0 then total = t end
	
	-- update view
	local function onInterval(dt)
		t = t - dt
		if t <= 0 then
			self:stopTimer()
			return 
		end
		self.bet_anim_:setPercentage(t/total * 100)
	end
	self.timerHandler = scheduler.scheduleUpdateGlobal(onInterval)
end


function SeatView:stopTimer()
	if self.timerHandler then
		scheduler.unscheduleGlobal(self.timerHandler)
		self.timerHandler = nil
	end
end

return SeatView
