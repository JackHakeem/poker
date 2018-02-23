
local texaslogic = require("app.utils.texaslogic")
local IMHelper = require("app.libs.IMHelper")


local RoomControler = class("RoomControler",function()
    return display.newNode()
end)

local action_tags = {
	startBlindUpDownTime = 100,
	logoutDelay = 101,
}

RoomControler.contants = {}
-- -1:空闲阶段 0:准备开始 1:发手牌的第一轮行动 2:翻三张牌 3:转牌 4:河牌 5:结算时间
RoomControler.contants.status = {
	idle 		= -1;
	wait 		= 0;
	preflop 	= 1;
	flop    	= 2;
	turn 		= 3;
	river   	= 4;
	over        = 5;
}

function RoomControler:ctor(scene,model)
	self:addTo(scene)
	self.mScene = scene
	self.mModel = model
	self.loginSend = false -- 登陆请求发送中
	self.mSyning = false -- 房间数据同步中
	self.mUserSelfOffline = false -- 用戶主動離綫
	self.mAutoFull = false -- 自动补满筹码开关
	self.mAutoBuyChips = 0 -- 自动买筹码
	self.mIsNeedSitdown = true -- 第一次从房间外进来
	self.mEventListeners = {}
end

function RoomControler:addEventListeners()
	tt.backEventManager.addBackEventLayer(self)
	self.mCallbackHandler = tt.backEventManager.registerCallBack(handler(self, self.onKeypadListener))
	self.mEventListeners = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
		tt.gevt:addEventListener(tt.gevt.NATIVE_EVENT, handler(self, self.onNativeEvent)),
		tt.gevt:addEventListener(tt.gevt.SHAKE_OK, handler(self, self.onShakeOK)),
		tt.gevt:addEventListener(tt.gevt.EVT_HTTP_RESP, handler(self, self.onHttpResp)),
		tt.gevt:addEventListener(tt.gevt.EVENT_RECONNECTING, handler(self, self.reconnectServering)),
		tt.gevt:addEventListener(tt.gevt.EVENT_RECONNECT_FAILURE, handler(self, self.reconnectServerFail)),
	}
	-- local func
	-- local seat_id = 1
	-- local em = 1
	-- func = function ( ... )
	-- 	em = em%4 + 1
	-- 	seat_id = seat_id % self.mModel:getSeatNum() + 1
	-- 	self.mScene:playEmoticon(seat_id,em)
	-- 	self:performWithDelay(func, 1);
	-- end
	-- self:performWithDelay(func, 1);
end

function RoomControler:removeEventListeners()
	tt.backEventManager.unregisterCallBack(self.mCallbackHandler)
	for _, v in pairs(self.mEventListeners) do 
		tt.gevt:removeEventListener(v)
	end
end

function RoomControler:reconnectServering()
	self.mScene:getReconnectDialog():showReconnectView()
end

function RoomControler:reconnectServerFail()
	self.mScene:getReconnectDialog():showReconnectfailView()
end

--握手成功
function RoomControler:onShakeOK()
	self:loginRoom()
	self.mScene:getReconnectDialog():dismiss()
end

function RoomControler:loginRoom()
	self.loginSend = false
	self.mSendStanding = false
	self.mModel:setLogin(false)
	local roomType = self.mModel:getRoomType()

	if roomType == 1 then
		self.loginSend = true
		tt.gsocket.request("texas.login",{lv=self.mModel:getLv(), tid=self.mModel:getTid(), 
			mid = tt.owner:getUid(), uinfo = tt.owner:getUinfo()})
		tt.gsocket.request("texas.expfee",{lv=self.mModel:getLv(), tid=self.mModel:getTid()})
		self.mScene:showLoad()
	elseif roomType == 2 then
		self:getBlindInfo()
		self.mScene:showLoad()
	elseif roomType == 3 then
		self:getBlindInfo()
		self.mScene:showLoad()
	elseif roomType == 4 then
		self.loginSend = true
		tt.gsocket.request("texas.login",{lv=self.mModel:getLv(), tid=self.mModel:getTid(), 
			mid = tt.owner:getUid(), uinfo = tt.owner:getUinfo()})
		tt.gsocket.request("texas.expfee",{lv=self.mModel:getLv(), tid=self.mModel:getTid()})
		local params = self.mModel:getCustomRoomParams()
		tt.gsocket.request("custom.look_up",{
							roomid = params.roomid,
						})	
		self.mScene:showLoad()
	else
		tt.show_msg(tt.gettext("房间类型出错"))
		self:performWithDelay(function()
			app:enterScene("MainScene")
		end,2)
	end

end

function RoomControler:onLoginOk(data)
	dump(data,"onLoginOk")

	local roomType = self.mModel:getRoomType()
	self.mScene:clearGameView()
    self.mModel:clearGameData()

	self.mModel:onCashLogin(data)
	local lv = self.mModel:getLv()
	local tid = self.mModel:getTid()
	--游戏进行中
	if self:isPlayStatus() then 
		self.mSyning = true
		self.mScene:showLoad()
		tt.gsocket.request("texas.gameinfo",{lv=lv, tid=tid, mid=tt.owner:getUid()})
	else
		self.mScene:dismissBetActionView()
		self.mScene:dismissPreActionView()
	end

	--未坐下
	print("onLoginOk",self.mModel:getCtlSeat())
	if self.mModel:getCtlSeat() == 0 then
		if self.mIsNeedSitdown then
			if roomType == kCashRoom then
				if self.mModel:hasEmptySeat() then
					self:reqSitDown(0,self:getCashCarry(lv))
				end
			elseif roomType == kCustomRoom then
				local params = self.mModel:getCustomRoomParams()
				if params.sb and params.min_buy then
					local need = params.sb * 2 * params.min_buy
					local mmoney = tt.owner:getMoney()
					if mmoney < need then
						-- tt.show_msg(tt.gettext("您的筹码不足,請補充筹码"))
						-- print("autoBuyCoin money not enough coin,mmoney,need",coin,mmoney,need)
						self.mScene:showEmptySeats()
					else
						if self.mModel:hasEmptySeat() then
					 		self:reqSitDown(0,need)
					 	end
					end
				end
			end
		else
			self.mScene:showEmptySeats()
		end
	end
	self.mIsNeedSitdown = false
	self.mScene:updateAddCoinBtn()
end


--比赛分配房间成功
function RoomControler:onMatchJoinTable(data)
	dump(data,"onMatchJoinTable")
	self.mScene:clearGameView()
    self.mModel:clearGameData()

	self.mModel:onMatchLogin(data)

	local lv = self.mModel:getLv()
	local tid = self.mModel:getTid()
	local match_id = self.mModel:getMatchId()
	-- 同步lv info
	local roomType  = self.mModel:getRoomType()
	if roomType == 2 then
		dump(tt.game_data.sng_info)
		local sng_info = tt.nativeData.getSngInfo(lv)
		if not sng_info then 
			tt.gsocket.request("sng.mlv_info",{mlv=lv})
		end
	elseif roomType == 3 then
		local data = tt.nativeData.getMttInfo(match_id)
		if not data then 
			tt.gsocket.request("mtt.match_info",{
				match_id = match_id,    --比赛id
			})
		else
			local stime,jtime,atime = data.stime,data.jtime,data.atime
			local curTime = tt.time()
			print("onMatchJoinTable showMatchWaitAnim stime,jtime,atime,curTime",stime,jtime,atime,curTime)
			if curTime < stime then
				self.mScene:showMatchWaitAnim(stime-curTime)
			end
		end
	end

	if tid == 0 then 
		tt.show_msg(tt.gettext("等待配桌"))
		return
	end

	--游戏进行中
	if self:isPlayStatus() then 
		self.mSyning = true
		self.mScene:showLoad()
		tt.gsocket.request("texas.gameinfo",{lv=lv, tid=tid, mid=tt.owner:getUid()})
	else
		self.mScene:dismissBetActionView()
		self.mScene:dismissPreActionView()
	end

	self:startRankRefresh()
end

function RoomControler:isPlayStatus()
	return self.mModel:getGameStatus() > 0 and self.mModel:getGameStatus() < 5
end

function RoomControler:getBlindInfo()
	local roomType = self.mModel:getRoomType()
	-- 查询当前盲注信息
	if roomType == 2 then
		tt.gsocket.request("sng.blind",{mlv=self.mModel:getLv(),match_id = self.mModel:getMatchId()})
	elseif roomType == 3 then
		tt.gsocket.request("mtt.match_blind",{mlv=self.mModel:getLv(),match_id = self.mModel:getMatchId()})
	end
end

function RoomControler:startBlindUpDownTime(left_time,data)
	local downtime = left_time or 0
	local blind_data = data or {}
	local sb = blind_data.sb or 0
	local bb = blind_data.bb or 0
	local ante = blind_data.ante or 0
	local updateFunc = function()
			if downtime < 0 then 
				self.mScene:updateBlindInfoView(0,sb,bb,ante)
				self:stopBlindUpDownTime()
				return 
			end
			print("startBlindUpDownTime",downtime)
			self.mScene:updateBlindInfoView(downtime,sb,bb,ante)
			downtime = downtime - 1
		end
	updateFunc()
	self:stopBlindUpDownTime()
	self:schedule(updateFunc, 1):setTag(action_tags.startBlindUpDownTime)
end

function RoomControler:stopBlindUpDownTime()
	self:stopAllActionsByTag(action_tags.startBlindUpDownTime)
end

--有用户坐下
function RoomControler:onPlayerSitDown(info)
	dump(info,"onPlayerSitDown")
	-- 用户坐下的时候 没有这个参数
	info.sretain = info.sretain or 1
	self.mModel:setSeatInfo(info.seatid,info)
	local seat = self.mScene:getSeatById(info.seatid)
	seat:setSeatInfo(info)
	seat:setIsPlaying(false)
	seat:setWait()
end

--有用户站起
function RoomControler:onPlayerStand(info)
	self.mModel:clearSeatInfo(info.seatid)
end

--同步当前游戏状态
function RoomControler:onGameInfo(info)
	dump(info,"onGameInfo")
	self.mModel:onGameInfo(info)
	if self:isPlayStatus() then 
		--设置座位的相关信息
		for _,v in pairs(info.playerinfo) do 
			local id = tonumber(v.seatid)
			local seat = self.mScene:getSeatById(id)
			seat:synGameInfo(v)
			self.mModel:addRoundPot(v.chips)
			self.mModel:updateActionMaxBet(v.chips)
			self.mModel:setSeatBets(id,v.chips)
			if self.mModel:getCtlSeat() == id and v.cards then 
				self.mModel:setCtlCards(v.cards)
				if v.isfold then
					self.mScene:playCtlCardsFold()
				end
			end
		end

		if not self.mModel:isSelfPlaying() then
			self.mScene:updateAddCoinBtn()
		end
		--公共牌信息
		self.mModel:setPublicCards(info.publiccards)
		self.mModel:setPots(info.pots)
		--用户行动信息
		if info.action.seatid ~= 0 then
			self.mModel:setActionSeat(info.action.seatid,info.action.timeout)
			self.mModel:updateActionInfo(info.action)
		end
		--庄家位
		self.mModel:setDealerSeat(info.dealerseat)
		if self.mModel:getGameStatus() >= 2 and self.mModel:getGameStatus() <= 4 then
			self:showCardTypeHint()
		end
	end

	self.mScene:updateTotalPot()
end

--有人买筹码
function RoomControler:onBuyCoin(info)
	local seat = self.mScene:getSeatById(info.seatid)
	seat:onBuyCoin(info)
	if info.seatid == self.mModel:getCtlSeat() then
		self.mScene:updateAddCoinBtn()
	end
end
--等游戏开始
function RoomControler:onWait(data)
	assert(data.status)
	self.mModel:setGameStatus(data.status)
	-- for id=1,self.seatnum_ do
	-- 	local seat = self.seats_[id]
	-- 	seat:setCardsFlag(false)
	-- end
	-- self:clearPreRoundAnim()
	-- tt.show_msg(string.format())
	-- self:dismissMatchWaitAnim()
	-- 清理上一局界面 -- 清理上一局动画
	self.mScene:clearGameView()
	-- 清理上一局数据
    self.mModel:clearGameData()

	self.mScene:dismissMatchWaitAnim()
end

--游戏开始
function RoomControler:onStart(data)
	self.mModel:changeNextBlindLv()
	self.mModel:setGameStatus(data.status)
	self.mModel:setDealerSeat(data.dealerseat)
	self.mModel:setBBSB(data.bbseat,data.sbseat)

    self.mScene:playStartAnim(data.playseat)
	self.isplayActionTipsSound = true
end

--发三张公共牌
function RoomControler:onFlop(data)
	tt.play.play_sound("flop")
	self.mModel:setGameStatus(RoomControler.contants.status.flop)
	for i,card in ipairs(data.cards) do
		self.mModel:addPublicCard(card,i)
	end
	self.mScene:updatePublicCards()
	self.mScene:playFlopAnim()
	self:showCardTypeHint()
end

--发转牌
function RoomControler:onTurn(data)
	tt.play.play_sound("fayizhangpai")
	self.mModel:setGameStatus(RoomControler.contants.status.turn)
	self.mModel:addPublicCard(data.card,4)
	self.mScene:updatePublicCards()
	self.mScene:playTurnAnim()
	self:showCardTypeHint()
end
--发河牌
function RoomControler:onRiver(data)
	tt.play.play_sound("fayizhangpai")
	self.mModel:setGameStatus(RoomControler.contants.status.river)
	self.mModel:addPublicCard(data.card,5)
	self.mScene:updatePublicCards()
	self.mScene:playRiverAnim()
	self:showCardTypeHint()
end

function RoomControler:showCardTypeHint()
	if self.mModel:isSelfPlaying() then
		local pcards = self.mModel:getPublicCards()
		local ccards = self.mModel:getCtlCards()
		local cardtype, bestcards = texaslogic.make_cards(pcards, ccards)
		self.mScene:showSelfBestCardsHint(cardtype, bestcards)
	end
end

--一圈结束，整理奖池
function RoomControler:onRoundEnd(data)
	dump(data,"onRoundEnd")

	local seatid = self.mModel:getActionSeat()
	print("onRoundEnd action seatid",seatid)
	if seatid ~= 0 then
		local seat = self.mScene:getSeatById(seatid)
		seat:stopBetTimeAnim()
		self.mModel:setActionSeat(0)
	end

	self.mModel:clearRoundData()
	self.mModel:addPots(data.pots)
	self.mScene:playRoundClearAnim()
	self.mScene:dismissBetActionView()
	self.mScene:dismissPreActionView()
	self.mScene:updateTotalPot()
end

--一局结束，整理奖池
function RoomControler:onGameOver(data)
	dump(data,"onGameOver")

	if data.show and next(data.show) then 
		local pcards = self.mModel:getPublicCards()
		for _,v in ipairs(data.show) do 
			local seat = self.mScene:getSeatById(v.seatid)

			if v.seatid == self.mModel:getCtlSeat() then
				self.mScene:playShowCtlCardsAnim(v.hands)
			else
				seat:showHands(v.hands)
			end
			local cardtype, bestcards =  texaslogic.make_cards(pcards, v.hands)
			printInfo("seat[%d] cardtype[%s] bestcards[%s]", v.seatid,texaslogic.type_str(cardtype),texaslogic.cards_str(bestcards))
			seat:setBestCards(cardtype,bestcards)
		end
	end
	-- 先播放亮手牌动画
	self:performWithDelay(function()
			self.mScene:playGameOverAnim(data.pots)
		end, 0.2)
	self.mModel:clearGameData()
end

--发手牌
function RoomControler:onDeal(data)
	printInfo("deal data [%s]",json.encode(data))
	self.mModel:setCtlCards(data.cards)
	self.mScene:playDealCtlAnim()
end

--用户亮手牌
function RoomControler:onShowHands(data)
	dump(data,"onShowHands")
	local seat = self.mScene:getSeatById(data.seatid)
	if data.seatid == self.mModel:getCtlSeat() then
		self.mScene:playShowCtlCardsAnim(data.cards)
	else
		seat:showHands(data.cards)
	end
end

--通知某个玩家开始行动
function RoomControler:onStartAction(data)
	dump(data,"onStartAction")
	if self.isplayActionTipsSound then
		self.isplayActionTipsSound = false
		tt.play.play_sound("action_tips")
	end
	self.mModel:setActionSeat(data.seatid)
	self.mModel:updateActionInfo(data)
end

function RoomControler:onPlayerAction(data)
	dump(data,"onPlayerAction")
	local seat = self.mScene:getSeatById(data.seatid)
	if data.bettype == -1 then  --回合结束时 退回筹码
		seat:setCoin(data.coin)
		return 
	end

	-- 当前行动用户的话就清理
	if self.mModel:getActionSeat() == data.seatid then
		seat:stopBetTimeAnim()
		self.mModel:setActionSeat(0)
	end


	if data.bettype == 0 then  --弃牌
		if self.mModel:getCtlSeat() == data.seatid then
			self.mScene:playCtlCardsFold()
		else
			self.mScene:playFoldAnim(data.seatid)
		end
		seat:setIsPlaying(false)
		seat:fold()
		tt.play.play_sound("fold")
	elseif data.bettype == 1 then  --下注 or 看牌
		if data.chips > 0 then
			-- added by he 170407动态更新总底池信息
			-- 判断是不是加注 否则跟注或 allin
			local bet = self.mModel:getSeatBets(data.seatid) + data.chips
			local isBet = bet > self.mModel:getRoundMaxBet()
			self.mModel:addRoundPot(data.chips)
			self.mModel:updateActionMaxBet(bet)
			self.mModel:addSeatBets(data.seatid,data.chips)
			seat:betCoin(data.chips,isBet,self.mModel:getActionInfoCheck() ~= 0)

			if isBet then
    			tt.play.play_sound("raise")
			else
    			tt.play.play_sound("bet")
			end
		else
			seat:check()
    		tt.play.play_sound("check")
		end
	end
	self.mScene:updateConsoleView()
	self.mScene:updateTotalPot()
end

--有用户状态发生变化
function RoomControler:onUserStatus(data)
	dump(data,"onUserStatus")
	local seat = self.mScene:getSeatById(data.seatid)
	seat:setUserStatus(data.sretain)

	if self.mModel:getCtlSeat() == data.seatid then
		if not self.mModel:isSelfPlaying() and seat:getCoin() == 0 then
			self:autoBuyCoin()
		else
			self.mModel:setCtlRetain(data.sretain)
		end
	end
end
-- 提前亮手牌
function RoomControler:preShowHands(seats)
	for id,data in pairs(seats) do
		self:onShowHands(data)
	end
end
-- 	前注
function RoomControler:onAnte(data)
	local max = 0
	self.mModel:addPots(data.pots)
	for id, coin in pairs(data.pots) do 
		self.mModel:addRoundPot(coin)
	end

	for i,d_seat in pairs(data.seats) do
		local seat = self.mScene:getSeatById(d_seat.seatid)
		seat:setCoin(d_seat.coin)
	end
end
--用户坐下 --call by SeatView
function RoomControler:onSitDownClick(id)
	local money = tt.owner:getMoney()
	local roomType = self.mModel:getRoomType()

	if roomType == kCashRoom then
		local need = self:getCashCarry(self.mModel:getLv())
		if money < need then
			tt.play.play_sound("action_failed")
			local goods = tt.getSuitableGoodsByMoney(need-money)
			if goods then
				self.mScene:showRecommendGoodsDialog(goods)
			else
				tt.show_msg(tt.gettext("您的筹码不足"))
			end
		else
			self:reqSitDown(id, need)
		end
	elseif roomType == kCustomRoom then
		local params = self.mModel:getCustomRoomParams()
		if params.sb and params.min_buy then
			local need = params.sb * 2 * params.min_buy
			if money < need then
				tt.play.play_sound("action_failed")
				local goods = tt.getSuitableGoodsByMoney(need-money)
				if goods then
					self.mScene:showRecommendGoodsDialog(goods)
				else
					tt.show_msg(tt.gettext("您的筹码不足"))
				end
			else
			 	self:reqSitDown(id,need)
			end
		end
	end
	
	
end

function RoomControler:onOnlineClick()
	self.mUserSelfOffline = false
	local ctl_seat = self.mModel:getCtlSeat()
	if ctl_seat ~= 0 and self.mScene:getSeatById(ctl_seat):getCoin() == 0 then
		self:autoBuyCoin()
	else
		self:reqUserStatus(1,1)
	end
end
--退出 --call by RoomMenuView
function RoomControler:onBackClick()
	if self.mModel:getRoomType() == kCashRoom then
		if self.mModel:isSelfPlaying() then
			local view = self.mScene:showChooseDialog(tt.gettext("您要放棄當前手牌，離開牌局嗎？"),function()
					tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuBackBtnCancel)
				end,function()
					tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuBackBtnConfirm)
					self:reqLogout()
				end)
			view:setMode(3)
		else
			local view = self.mScene:showChooseDialog(tt.gettext("您要離開牌局，停止玩牌嗎？"),function()
					tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuBackBtnCancel)
				end,function()
					tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuBackBtnConfirm)
					self:reqLogout()
				end)
			view:setMode(3)
		end
	elseif self.mModel:getRoomType() == kCustomRoom then
		if self.mModel:isCustomOver() then 
			app:enterScene("MainScene",{false,nil,nil,{method="showCustomDialog"}})
		elseif self.mModel:isSelfPlaying() then
			local view = self.mScene:showChooseDialog(tt.gettext("您要放棄當前手牌，離開牌局嗎？"),function()
					tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuBackBtnCancel)
				end,function()
					tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuBackBtnConfirm)
					self:reqLogout()
				end)
			view:setMode(3)
		else
			local view = self.mScene:showChooseDialog(tt.gettext("您要離開牌局，停止玩牌嗎？"),function()
					tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuBackBtnCancel)
				end,function()
					tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuBackBtnConfirm)
					self:reqLogout()
				end)
			view:setMode(3)
		end
	 	
	else
		if self.mModel:isMatchOver() then
			app:enterScene("MainScene")
		else
			self.mScene:showChooseDialog(tt.gettext("離開房間后，您可以通過“大廳-我的牌局”重回牌局"),nil,function()
					app:enterScene("MainScene")
				end)
		end
	end
end

--站起 --call by RoomMenuView
function RoomControler:onStandClick()
	if self.mModel:getRoomType() == kCashRoom or self.mModel:getRoomType() == kCustomRoom then
		if self.mModel:getCtlSeat() > 0 then
			if self.mModel:isSelfPlaying() then
				self.mScene:showChooseDialog(tt.gettext("您要放棄當前底池，離開座位嗎？"),function()
						tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuStandBtnCancel)
					end,function()
						tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuStandBtnConfirm)
						self:sendStandMsg()
					end)
			else
				-- self:showChooseDialog("您要站起吗？",nil,function()
					self:sendStandMsg()
					-- end)
			end
		else
			printInfo("user not sitdown")
		end
	end
end

function RoomControler:onRetainClick()
	self.mUserSelfOffline = true
	self:reqUserStatus(1,0)
end

function RoomControler:onChangeRoomClick()
	self:reqChangeRoom()
end

function RoomControler:getCashCarry(lv)
	local data = tt.nativeData.getCashInfo()
	for _,v in ipairs(data) do
		if v.lv == lv then
			return v.default_buy
		end
	end
	return self.mModel:getMaxCarry()
end

function RoomControler:buyChips(chips)
	local chips = checkint(chips)
	if chips == 0 then return end
	local roomType = self.mModel:getRoomType()
	local ctl_seat = self.mModel:getCtlSeat()
	if roomType == kCustomRoom then
		if ctl_seat > 0 then
			local seat = self.mScene:getSeatById(ctl_seat)
			local mmoney = tt.owner:getMoney()
			local coin = seat:getCoin()
			local params = self.mModel:getCustomRoomParams()
			if params.sb and params.min_buy then
				local mmoney = tt.owner:getMoney()
				local need = params.sb * 2 * params.min_buy
				local buyChipsNum = math.min(chips,mmoney)
				if coin + buyChipsNum < need then
					tt.play.play_sound("action_failed")
					local goods = tt.getSuitableGoodsByMoney(need-coin-buyChipsNum)
					dump(goods,"buyChips")
					if goods then
						self.mScene:showRecommendGoodsDialog(goods)
					else
						tt.show_msg(tt.gettext("您的筹码不足,請補充筹码"))
					end
					return
				end
				self.mAutoBuyChips = buyChipsNum
				if not self.mModel:isPlaying(ctl_seat) then
					self:autoBuyCoin()
				else
					tt.show_msg(tt.gettext("下局自动购买"))
				end
			end
		else
			tt.show_msg(tt.gettext("請先坐下"))
			tt.play.play_sound("action_failed")
		end
	end
end

function RoomControler:autoBuyCoin()
	local roomType = self.mModel:getRoomType()
	local ctl_seat = self.mModel:getCtlSeat()
	if roomType == kCashRoom then
		if ctl_seat == 0 then return end
		if self.mUserSelfOffline then return end

		local seat = self.mScene:getSeatById(ctl_seat)
		local coin = seat:getCoin()
		local need = self:getCashCarry(self.mModel:getLv())
		if self.mAutoFull then
			self.mAutoFull = false
			if coin < need then
				self:buycoin(need-coin)
				return
			end
			self.mScene:updateAddCoinBtn()
		end

		if seat:getCoin() > 0 then return end

		local mmoney = tt.owner:getMoney()
		if mmoney < need - coin then 
			tt.show_msg(tt.gettext("您的筹码不足,請補充筹码"))
			print("autoBuyCoin money not enough coin,mmoney,need",coin,mmoney,need)
			self:sendStandMsg()
			return 
		end
		self:buycoin(need)
	elseif roomType == kCustomRoom then
		if ctl_seat == 0 then return end
		if self.mUserSelfOffline then return end
		local seat = self.mScene:getSeatById(ctl_seat)

		if self.mAutoBuyChips ~= 0 then
			local chips = self.mAutoBuyChips
			self.mAutoBuyChips = 0
			local mmoney = tt.owner:getMoney()
			local coin = seat:getCoin()
			local params = self.mModel:getCustomRoomParams()
			if params.sb and params.min_buy then
				local mmoney = tt.owner:getMoney()
				local need = params.sb * 2 * params.min_buy
				local buyChipsNum = math.min(chips,mmoney)
				if coin + buyChipsNum < need then
					tt.show_msg(tt.gettext("您的筹码不足,請補充筹码"))
					if coin == 0 then
						self:sendStandMsg()
					end
					return
				end
				self:buycoin(buyChipsNum)
			end
		end

		if seat:getCoin() > 0 then return end

		local params = self.mModel:getCustomRoomParams()
		if params.sb and params.min_buy then
			local need = params.sb * 2 * params.min_buy
			local mmoney = tt.owner:getMoney()
			if mmoney < need then
				tt.show_msg(tt.gettext("您的筹码不足,請補充筹码"))
				print("autoBuyCoin money not enough coin,mmoney,need",coin,mmoney,need)
				self:sendStandMsg()
				return 
			end
			self:buycoin(need)
		end
	end
end

function RoomControler:onAddCoinClick()
	local ctl_seat = self.mModel:getCtlSeat()
	if ctl_seat > 0 then

		local seat = self.mScene:getSeatById(ctl_seat)
		local mmoney = tt.owner:getMoney()
		local coin = seat:getCoin()
		local need = self:getCashCarry(self.mModel:getLv()) - coin

		if mmoney < need then 
			print("onAddCoinClick",mmoney,need)
			tt.play.play_sound("action_failed")
			local goods = tt.getSuitableGoodsByMoney(need-mmoney)
			if goods then
				self.mScene:showRecommendGoodsDialog(goods)
			else
				tt.show_msg(tt.gettext("您的筹码不足,請補充筹码"))
			end
			return
		end

		self.mAutoFull = not self.mAutoFull
		if not self.mModel:isPlaying(ctl_seat) then
			self:autoBuyCoin()
			return
		end
		if self.mAutoFull then
			tt.show_msg(tt.gettext("下局自動補滿"))
		else
			tt.show_msg(tt.gettext("關閉自動補滿"))
		end
		self.mScene:updateAddCoinBtn()
	else
		tt.show_msg(tt.gettext("請先坐下"))
		tt.play.play_sound("action_failed")
	end
end

function RoomControler:isCanAutoFull()
	return self.mAutoFull
end

--按下红色的按钮
function RoomControler:onFoldLogic()
	-- tt.play.play_sound("click")
	if self.mModel:isSelfPlaying() then 
		if self.mModel:getActionSeat() == self.mModel:getCtlSeat() then
			self:reqAction(0,0)
		else
			tt.show_msg(tt.gettext("還沒輪到你行動"))
			tt.play.play_sound("action_failed")
		end
	else
		print("not play")
	end
end

--按下绿色的按钮
function RoomControler:onCheckLogic()
	-- tt.play.play_sound("click")
	if self.mModel:isSelfPlaying() then 
		if self.mModel:getActionSeat() == self.mModel:getCtlSeat() then
			local coin = math.min(self.mModel:getActionInfoCheck(),self.mModel:getActionInfoRaiseMax())
			printInfo("onCheckLogic %d",coin)
			self:reqAction(1, coin)
			self.mScene:dismissPreActionView()
		else
			tt.show_msg(tt.gettext("還沒輪到你行動"))
			tt.play.play_sound("action_failed")
		end
	else
		print("not play")
	end

	--修改为新的操作界面bet_action_view_
	--self.ctl_panel_:setVisible(false)
end

--加注筹码 call by AddChipView
function RoomControler:addChips(chips)
	if self.mModel:isSelfPlaying() then 
		if self.mModel:getActionSeat() == self.mModel:getCtlSeat() then
			-- max < min 时候 是 allin
			local coin = math.max(math.min(self.mModel:getActionInfoRaiseMin(),self.mModel:getActionInfoRaiseMax()),chips)
			self:reqAction(1,coin)
			self.mScene:dismissPreActionView()
		else
			tt.show_msg(tt.gettext("還沒輪到你行動"))
			tt.play.play_sound("action_failed")
		end
	else
		print("not play")
	end
end

function RoomControler:startRankRefresh()
	local rankRefreshFunc = function()
		local match_id = self.mModel:getMatchId()
		local lv = self.mModel:getLv()
		local roomType = self.mModel:getRoomType()
		if match_id ~= 0 and lv ~= 0 and tt.gsocket:isConnected() then
			if roomType == 2 then
				local data = tt.nativeData.getSngInfo(lv)
				if not data then return end
				local playerNum = tonumber(data.player) or 0
				tt.gsocket.request("sng.rank",{
						mlv = lv,           --比赛场次
						match_id = match_id,   --比赛id
						mid = tt.owner:getUid(),           --用户的id
						begin = 1,         --排名起始值
						rnum = math.min(20,playerNum),         --排名个数   
					})
			elseif roomType == 3 then
				tt.gsocket.request("mtt.match_rank",{
						mlv = lv,           --比赛场次
						match_id = match_id,   --比赛id
						mid = tt.owner:getUid(),           --用户的id
						begin = 1,         --排名起始值
						rnum = 20,         --排名个数   
					})
			end
		end
	end
	rankRefreshFunc()
	if self.refreshRankAction then return end
	self.refreshRankAction = self:schedule(rankRefreshFunc, 10)
end

function RoomControler:stopRankRefresh()
	if self.refreshRankAction then
		self:stopAction(self.refreshRankAction)
		self.refreshRankAction = nil
	end
end

function RoomControler:onMttMatchResult( data )
	self:performWithDelay(function()
			tt.play.play_sound("match_over")
			self.mScene:showMatchResultView(data,"mtt")
		end,1)
	self:stopRankRefresh()
	self.mModel:setMatchOver(true)
end

-- 比赛结束
function RoomControler:onMatchResult( data )
	self:performWithDelay(function()
			tt.play.play_sound("match_over")
			self.mScene:showMatchResultView(data,"sng")
		end,1)
	self:stopRankRefresh()
	self.mModel:setMatchOver(true)
end

function RoomControler:onCustomRoomOver(data)
	self:performWithDelay(function()
			tt.play.play_sound("match_over")
			self.mScene:showCustomOverDialog(data)
		end,1)
	self.mModel:setCustomRoomOver(true)
end


function RoomControler:buycoin(coin)
	tt.gsocket.request("texas.buycoin",{lv=self.mModel:getLv(), tid=self.mModel:getTid(),mid = tt.owner:getUid(), coin=tonumber(coin)})
end

function RoomControler:sendStandMsg()
	if self.mModel:getCtlSeat() > 0 and not self.mSendStanding then
		self.mSendStanding = true
		tt.gsocket.request("texas.standup",{lv=self.mModel:getLv(), tid=self.mModel:getTid(),mid = tt.owner:getUid(), seatid=self.mModel:getCtlSeat()})
	end
end
--用户请求坐下
function RoomControler:reqSitDown(seatid,coin)
	tt.gsocket.request("texas.sitdown",{lv=self.mModel:getLv(), tid=self.mModel:getTid(),mid = tt.owner:getUid(), seatid=seatid, coin=tonumber(coin)})
end
--用户请求离开
function RoomControler:reqLogout()
	tt.gsocket.request("texas.logout",{lv=self.mModel:getLv(), tid=self.mModel:getTid(),mid = tt.owner:getUid()})
	self:performWithDelay(function()
			local roomType = self.mModel:getRoomType()
			if roomType == kCashRoom then
				app:enterScene("MainScene",{false,nil,true})
			elseif roomType == kCustomRoom then
				app:enterScene("MainScene",{false,nil,nil,{method="showCustomDialog"}})
			else
				app:enterScene("MainScene")
			end
		end, 3):setTag(action_tags.logoutDelay)
end
--用户行动
function RoomControler:reqAction(t, chips)
	tt.gsocket.request("texas.useraction",{lv=self.mModel:getLv(), tid=self.mModel:getTid(), bettype=t, chips=chips})
end

function RoomControler:reqChangeRoom()
	tt.gsocket.request("alloc.change",{lv=self.mModel:getLv(), old_tid=self.mModel:getTid()})
end

function RoomControler:reqUserStatus(t, v)
	if self.mModel:getCtlSeat() > 0 then
		tt.gsocket.request("texas.userstatus",{lv=self.mModel:getLv(), tid=self.mModel:getTid(),mid = tt.owner:getUid(), seatid=self.mModel:getCtlSeat(), stype=t,value=v})
	else
		printError("%s %s",TAG,"user not sitdown")
	end
end

function RoomControler:sendEmoticonMsg(emoticon_id)
	local lv = self.mModel:getLv()
	local tid = self.mModel:getTid()
	local seat_id = self.mModel:getCtlSeat()

	if not seat_id or seat_id == 0 then 
		tt.show_msg(tt.gettext("请先坐下"))
		return
	end

	if lv == 0 or tid == 0 or self.mEmoticonLock then return end
	self.mEmoticonLock = true
	self:performWithDelay(function()
			self.mEmoticonLock = false
		end, 2)
	IMHelper.sendEmoticonMsg(lv,tid,seat_id,emoticon_id)
end

function RoomControler:isEmoticonLock()
	return self.mEmoticonLock
end

function RoomControler:sendExpressionMsg(dst_seatid,expression_id)
	local lv = self.mModel:getLv()
	local tid = self.mModel:getTid()
	local seat_id = self.mModel:getCtlSeat()

	if not dst_seatid or dst_seatid == 0 then 
		print("user not in seat")
		tt.show_msg(tt.gettext("玩家已离桌"))
		return 
	end

	if not seat_id or seat_id == 0 then 
		tt.show_msg(tt.gettext("请先坐下"))
		return
	end

	if lv == 0 or tid == 0 or self.mExpressionLock then return end
	self.mExpressionLock = true
	self:performWithDelay(function()
			self.mExpressionLock = false
		end, 2)
	IMHelper.sendExpressionMsg(lv,tid,seat_id,dst_seatid,expression_id)
end

function RoomControler:isExpressionLock()
	return self.mExpressionLock
end

--[Comment]
-- 检查是否是当前桌子命令
function RoomControler:checkTableEvt(evt,ignoreSyn)
	-- if self.mSyning and not ignoreSyn then
	-- 	print("数据同步中...")
	-- 	return false
	-- end

	local data = evt.resp or evt.broadcast
	local lv = data.mlv or data.lv
	if not self.mModel:isLogin() then 
		print("is not login")
		dump(evt)
		return 
	end
	assert(data, string.format("cmd:[%s] is not evt.resp and evt.broadcast",evt.cmd))
	
	local mTid = self.mModel:getTid() 
	local mLv = self.mModel:getLv()

	if data.tid ~= mTid or lv ~= mLv then
		printInfo("cmd:[%s] is not cur table", evt.cmd)
		printInfo("%s %s",data.tid,lv)
		printInfo("%s %s",mTid,mLv)
		return false
	end
	return true
end
--[Comment]
-- 检查是否是当前比赛命令
function RoomControler:checkMatchEvt(evt)
	local data = evt.resp or evt.broadcast
	local lv = data.mlv or data.lv
	local match_id = data.match_id
	assert(data, string.format("cmd:[%s] is not evt.resp and evt.broadcast",evt.cmd))

	local mMatchId = self.mModel:getMatchId() 
	local mLv = self.mModel:getLv()

	if lv ~= mLv or mMatchId ~= match_id then
		printInfo("cmd:[%s] is not cur match",evt.cmd)
		printInfo("%s %s",lv,match_id)
		printInfo("%s %s",mLv,mMatchId)
		return false
	end
	return true
end


function RoomControler:onSocketData(evt)
	printInfo("cmd:[%s]",evt.cmd)

	if evt.cmd == "texas.login" then
		if evt.resp then 
			self.mScene:hideLoad()
			self.loginSend = false
			if evt.resp.ret == 200 then 
				self.mModel:setLogin(true)
				self:onLoginOk(evt.resp)
			elseif evt.resp.ret == -101 then
				tt.show_msg(tt.gettext("服務器維護，您已被請出房間"))
				self:performWithDelay(function()
					app:enterScene("MainScene")
				end,2)
			elseif evt.resp.ret == -102 then
				tt.show_msg(tt.gettext("房间不存在"))
				self:performWithDelay(function()
					app:enterScene("MainScene")
				end,2)
			else
				tt.show_msg(tt.gettext("登陸房間失敗"))
				self:performWithDelay(function()
					app:enterScene("MainScene")
				end,2)
				printInfo("login faild ret[%s]",evt.resp.ret)
			end
		elseif evt.broadcast then
			local data = evt.broadcast
			printInfo("user[%d] login lv[%d] tid[%d]",data.mid, data.lv, data.tid)
		end

	elseif evt.cmd == "texas.sitdown" then 
		if self:checkTableEvt(evt) then
			if evt.broadcast then
				self:onPlayerSitDown(evt.broadcast)
			elseif evt.resp then
				if evt.resp.ret == 200 then
					tt.owner:setMoney(evt.resp.money)
				else
					tt.show_msg(tt.gettext("坐下失敗！") .. evt.resp.ret)
					tt.play.play_sound("action_failed")
				end
			end
		end
	elseif evt.cmd == "texas.standup" then 
		if self:checkTableEvt(evt) then
			if evt.broadcast then
				self:onPlayerStand(evt.broadcast)
				if evt.broadcast.mid == tt.owner:getUid() then
					self.mUserSelfOffline = false
					tt.owner:setMoney(evt.broadcast.money)
				end
			elseif evt.resp then
				self.mSendStanding = false
				if evt.resp.ret == 200 then
					tt.owner:setMoney(evt.resp.money)
				else
					tt.show_msg(tt.gettext("站起失敗！") .. evt.resp.ret)
					tt.play.play_sound("action_failed")
				end
			end
		else
			if evt.broadcast and  evt.broadcast.mid == tt.owner:getUid() then
				tt.owner:setMoney(evt.broadcast.money)
			end
		end
	elseif evt.cmd == "texas.logout" then 
		if self:checkTableEvt(evt) then
			if evt.broadcast then
				printInfo("user[%d] leave tid[%d]",evt.broadcast.mid, evt.broadcast.tid)
				if evt.broadcast.mid == tt.owner:getUid() and evt.broadcast.rz == 2 then
					local roomType = self.mModel:getRoomType()
					if roomType == kCustomRoom and self.mModel:isCustomOver() then
						--展示结算界面中..
					else
						tt.show_msg(tt.gettext("太久未操作，您已被請出房間"))
						self:performWithDelay(function()
							app:enterScene("MainScene")
						end,2)
					end
				end
			elseif evt.resp then
				if evt.resp.ret == 200 then
					tt.owner:setMoney(evt.resp.money)
					local roomType = self.mModel:getRoomType()
					if roomType == kCashRoom then
						app:enterScene("MainScene",{false,nil,true})
					elseif roomType == kCustomRoom then
						app:enterScene("MainScene",{false,nil,nil,{method="showCustomDialog"}})
					else
						app:enterScene("MainScene")
					end
				elseif evt.resp.ret == -101 then
					-- 不在房间
					local roomType = self.mModel:getRoomType()
					if roomType == kCashRoom then
						app:enterScene("MainScene",{false,nil,true})
					elseif roomType == kCustomRoom then
						app:enterScene("MainScene",{false,nil,nil,{method="showCustomDialog"}})
					else
						app:enterScene("MainScene")
					end
				else
					tt.show_msg(tt.gettext("退出失敗！") .. evt.resp.ret)
					tt.play.play_sound("action_failed")
				end
			end
		end
	elseif evt.cmd == "texas.gameinfo" then 
		if self:checkTableEvt(evt) then
			self.mScene:hideLoad()
			self.mSyning = false
			self:onGameInfo(evt.resp)
		end
	elseif evt.cmd == "texas.buycoin" then 
		if self:checkTableEvt(evt) then
			if evt.broadcast then
				self:onBuyCoin(evt.broadcast)
			elseif evt.resp then
				if evt.resp.ret == 200 then
					tt.owner:setMoney(evt.resp.tmoney)
				end
			end
		end
	elseif evt.cmd == "texas.wait" then 
		if self:checkTableEvt(evt) then
			self:onWait(evt.broadcast)
		end
	elseif evt.cmd == "texas.start" then 
		if self:checkTableEvt(evt) then
			self:onStart(evt.broadcast)
		end
	elseif evt.cmd == "texas.flop" then 
		if self:checkTableEvt(evt) then
			self:onFlop(evt.broadcast)
		end
	elseif evt.cmd == "texas.turn" then 
		if self:checkTableEvt(evt) then
			self:onTurn(evt.broadcast)
		end
	elseif evt.cmd == "texas.river" then 
		if self:checkTableEvt(evt) then
			self:onRiver(evt.broadcast)
		end
	elseif evt.cmd == "texas.roundend" then 
		if self:checkTableEvt(evt) then
			self:onRoundEnd(evt.broadcast)
		end
	elseif evt.cmd == "texas.showhands" then 
		if self:checkTableEvt(evt) then
			self:onShowHands(evt.broadcast)
		end
	elseif evt.cmd == "texas.gameover" then 
		if self:checkTableEvt(evt) then
			self:onGameOver(evt.broadcast)
		end
	elseif evt.cmd == "texas.deal" then 
		if self:checkTableEvt(evt) then
			self:onDeal(evt.resp)
		end
	elseif evt.cmd == "texas.startbet" then 
		if self:checkTableEvt(evt) then
			self:onStartAction(evt.broadcast)
		end
	elseif evt.cmd == "texas.useraction" then 
		if self:checkTableEvt(evt) then
			if evt.broadcast then
				self:onPlayerAction(evt.broadcast)
			elseif evt.resp and evt.resp.ret ~= 200 then
				-- tt.show_msg("texas.useraction 操作失败！ret is" .. evt.resp.ret)
			end
		end
	elseif evt.cmd == "texas.userstatus" then 
		if self:checkTableEvt(evt) then
			if evt.broadcast then
				self:onUserStatus(evt.broadcast)
			elseif evt.resp and evt.resp.ret ~= 200 then
				tt.show_msg(tt.gettext("操作失敗！ret：") .. evt.resp.ret)
				tt.play.play_sound("action_failed")
			end
		else
			local data = evt.resp or evt.broadcast
			local lv = data.mlv or data.lv
			printInfo(string.format("userstatus lv %s =？%s tid %s =？%s",self.mlv_,lv,self.mTid,data.tid))
		end
		--match
	elseif evt.cmd == "sng.jointable" then 
		if evt.resp then
			self.mScene:hideLoad()
			self.loginSend = false
			if evt.resp.mlv == self.mModel:getLv() then
				printInfo("jointable resp[%s]",json.encode(evt.resp))
				if  evt.resp.ret == 200 then 
					self.mModel:setLv(evt.resp.mlv)
					self.mModel:setTid(evt.resp.tid)
					self.mModel:setLogin(true)
					self:onMatchJoinTable(evt.resp)
					tt.gsocket.request("texas.expfee",{lv=self.mModel:getLv(), tid=self.mModel:getTid()})
				else
					tt.show_msg(tt.gettext("比賽已經結束"))
					self:performWithDelay(function()
						app:enterScene("MainScene")
						end,2)
					printInfo("join match faild ret[%s]",evt.resp.ret)
				end
			end
		elseif evt.broadcast then
			if self:checkTableEvt(evt) then
				printInfo("jointable broadcast[%s]",json.encode(evt.broadcast))
				self:onPlayerSitDown(evt.broadcast)
			end
		end
	elseif evt.cmd == "sng.result" then 
		local match_id = self.mModel:getMatchId()
		local lv = self.mModel:getLv()
		printInfo("sng.result match_id %s lv %d",match_id,lv)
		if self:checkMatchEvt(evt) then
			printInfo("sng.result checkMatchEvt evt.resp: %s",type(evt.resp))
			if evt.resp then
				local resp = evt.resp
				printInfo("sng.result checkMatchEvt mlv: %s match_id: %s",resp.mlv,resp.match_id )
				printInfo("sng.result checkMatchEvt mlv: %s match_id: %s",lv,match_id )
				if resp.mlv == lv and resp.match_id == match_id then
		    		-- tt.show_msg("你在比赛中的名次是" .. resp.urank)
		    		self:onMatchResult(evt.resp)
				end
				tt.owner:setMoney(resp.money)
			end
		end
	elseif evt.cmd == "sng.leavetable" then
		if self:checkTableEvt(evt) then
			if evt.broadcast then
				if evt.broadcast then
					if evt.broadcast.mid == tt.owner:getUid() then
						self.mModel:onMatchLeaveTable()
						-- tt.show_msg("正在为你重新配桌...")
					else
						self:onPlayerStand(evt.broadcast)
					end
				end
			end
		end
	elseif evt.cmd == "sng.blind" then
		if self:checkMatchEvt(evt) then
			if evt.resp then
				local lv = evt.resp.cur_lv
				local blind_id = evt.resp.blind_id
				self.mModel:setBlindId(blind_id)
				self.mModel:setBlindLv(lv)
				self.mModel:setNextBlindLv(lv)
				local data = self.mModel:getBlindInfo()
				if not data then 
					tt.gsocket.request("match.blind_info",{blind_id=blind_id})
					return
				end
				if lv == 0 then
					self:startBlindUpDownTime(evt.resp.left_time,data[2] or data[1])
				else
					self:startBlindUpDownTime(evt.resp.left_time,data[lv+1] or data[lv])
				end
				if not self.loginSend and not self.mModel:isLogin() then
					self.loginSend = true
					tt.gsocket.request("sng.jointable",{mlv=self.mModel:getLv(),match_id = self.mModel:getMatchId(), mid = tt.owner:getUid()})
				end
			elseif evt.broadcast then
				dump(evt.broadcast)
				if evt.broadcast.left_time <= 0 then
					local lv = evt.broadcast.change_lv
					self.mModel:setNextBlindLv(lv)
					local data = self.mModel:getBlindInfo()
					if not data then return end
					local nextData = data[lv+1]
					if nextData then
						self:startBlindUpDownTime(nextData.tm,nextData)
					else
						self:startBlindUpDownTime(0,data[lv])
					end
				else
					local data = self.mModel:getBlindInfo()
					if data then
						self:startBlindUpDownTime(evt.broadcast.left_time,data[evt.broadcast.change_lv])
					end
				end
			end
		end
	elseif evt.cmd == "match.blind_info" then
		if evt.resp.ret == 200 then 
			tt.nativeData.saveBlindInfo(evt.resp.blind_id,evt.resp.blind_table)
			if not self.loginSend and not self.mModel:isLogin() and self.mModel:getBlindId() == evt.resp.blind_id then
				self:getBlindInfo()
			end
		end
	elseif evt.cmd == "texas.preshowhands" then
		if self:checkTableEvt(evt) then
			if evt.broadcast then
				self:preShowHands(evt.broadcast.seats)
			end
		end
	elseif evt.cmd == "texas.ante" then
		if self:checkTableEvt(evt) then
			if evt.broadcast then
				self:onAnte(evt.broadcast)
			end
		end
	elseif evt.cmd == "sng.rank" then
		if self:checkMatchEvt(evt) then
			if evt.resp.ret == 200 then
			-- 	urank = 1,  --用户自己的名次  
			-- left_num = 30, --比赛还剩的玩家
				self.mScene:updateMyRank(evt.resp.urank, evt.resp.left_num)
			end
		end
	elseif evt.cmd == "sng.start" then 
		if evt.broadcast then
			local data = evt.broadcast 
			if data.apply_num == data.start_num and tt.game_data.sng_info and tt.nativeData.getSngInfo(data.mlv) then
				tt.show_msg(tt.gettext("您报名的“{s1}”比赛已经开赛，您可以通过“大厅-我的牌局”查看详情",tt.nativeData.getSngInfo(data.mlv).mname))
			end
		end
	elseif evt.cmd == "sng.wait" then
		print("sng.wait")
		dump(evt)
		if self:checkMatchEvt(evt) then
			if evt.broadcast then
				if evt.broadcast.wait_type == "start" then
					tt.show_msg(tt.gettext("比賽將在{s1}秒内開始",evt.broadcast.wait_time))
					self.mScene:showMatchWaitAnim(evt.broadcast.wait_time)
				elseif evt.broadcast.wait_type == "alloc" then
					tt.show_msg(string.format(tt.gettext("等待系統配桌...")))
				else
					tt.show_msg(tt.gettext("請等待{s1}秒",evt.broadcast.wait_time))
				end
			end
		end
	elseif evt.cmd == "vip.vip_info" then
		if evt.resp and evt.resp.ret == 200 then
			self.mScene:updateVipView()
		end
		if evt.broadcast then
			self.mScene:updateVipView()
		end
	elseif evt.cmd == "vip.upgrade" then
		if evt.broadcast then
			-- 0--表示达到最高级
			dump(evt.broadcast,"vip.upgrade")
			tt.owner:setVipScore(evt.broadcast.total_score)
			if evt.broadcast.uplv ~= 0 then
				tt.owner:setVipLv(evt.broadcast.uplv)
				self.mScene:showUpVipLvAnim(evt.broadcast.uplv)
			else
				self.mScene:updateVipView()
			end
		end
	elseif evt.cmd == "mtt.match_blind" then
		print("mtt.match_blind match_id lv",self.mModel:getMatchId(),self.mModel:getLv())
		if self:checkMatchEvt(evt) then
			if evt.resp then
				local lv = evt.resp.cur_lv
				local blind_id = evt.resp.blind_id
				self.mModel:setBlindId(blind_id)
				self.mModel:setBlindLv(lv)
				self.mModel:setNextBlindLv(lv)
				local data = self.mModel:getBlindInfo()
				if not data then 
					tt.gsocket.request("match.blind_info",{blind_id=blind_id})
					return
				end
				if lv == 0 then
					self:startBlindUpDownTime(evt.resp.left_time,data[2] or data[1])
				else
					self:startBlindUpDownTime(evt.resp.left_time,data[lv+1] or data[lv])
				end
				if not self.loginSend and not self.mModel:isLogin() then
					self.loginSend = true
					tt.gsocket.request("mtt.jointable",{mlv=self.mModel:getLv(),match_id = self.mModel:getMatchId(), mid = tt.owner:getUid()})
				end
			elseif evt.broadcast then
				dump(evt.broadcast)
				if evt.broadcast.left_time <= 0 then
					local lv = evt.broadcast.change_lv
					self.mModel:setNextBlindLv(lv)
					local data = self.mModel:getBlindInfo()
					if not data then return end
					local nextData = data[lv+1]
					if nextData then
						self:startBlindUpDownTime(nextData.tm,nextData)
					else
						self:startBlindUpDownTime(0,data[lv])
					end
				else
					local data = self.mModel:getBlindInfo()
					if data then
						self:startBlindUpDownTime(evt.broadcast.left_time,data[evt.broadcast.change_lv])
					end
				end
			end
		end
	elseif evt.cmd == "mtt.jointable" then
		if evt.resp then 
			self.mScene:hideLoad()
			self.loginSend = false
			if self:checkMatchEvt(evt) then
				printInfo("jointable resp[%s]",json.encode(evt.resp))
				if  evt.resp.ret == 200 then 
					self.mModel:setLv(evt.resp.mlv)
					self.mModel:setTid(evt.resp.tid)
					self.mModel:setLogin(true)
					self:onMatchJoinTable(evt.resp)
					tt.gsocket.request("texas.expfee",{lv=self.mModel:getLv(), tid=self.mModel:getTid()})
				elseif evt.resp.ret == -101 then
					tt.show_msg(tt.gettext("没参加此场比赛"))
					self:performWithDelay(function()
						app:enterScene("MainScene")
						end,2)
				else
					tt.show_msg(tt.gettext("比賽已經結束"))
					self:performWithDelay(function()
						app:enterScene("MainScene")
						end,2)
					printInfo("join match faild ret[%s]",evt.resp.ret)
				end
			end
		elseif evt.broadcast then
			if self:checkTableEvt(evt) then
				printInfo("jointable broadcast[%s]",json.encode(evt.broadcast))
				self:onPlayerSitDown(evt.broadcast)
			end
		end
	elseif evt.cmd == "mtt.leavetable" then
		if self:checkTableEvt(evt) then
			if evt.broadcast then
				if evt.broadcast then
					if evt.broadcast.mid == tt.owner:getUid() then
						self.mModel:onMatchLeaveTable()
						-- tt.show_msg("正在为你重新配桌...")
					else
						self:onPlayerStand(evt.broadcast)
					end
				end
			end
		end
	elseif evt.cmd == "mtt.start" then 
		if evt.broadcast then
			if evt.broadcast.match_id ~= self.mModel:getMatchId() then
				-- if evt.broadcast.stype == 1 then -- 1:代表可以提前入场， 2.代表比赛正式开始(第一次发牌前)
				-- elseif evt.broadcast.stype == 2 then
					local data = tt.nativeData.getMttInfo(evt.broadcast.match_id)
					if not data then 
						tt.show_msg(tt.gettext("您报名的比赛已经开赛，您可以通过“大厅-我的牌局”查看详情"))
					else
						tt.show_msg(tt.gettext("您报名的“{s1}”比赛已经开赛，您可以通过“大厅-我的牌局”查看详情",data.mname))
					end
				-- end
			end
		end
	elseif evt.cmd == "mtt.wait" then
		print("sng.wait")
		dump(evt)
		if self:checkMatchEvt(evt) then
			if evt.broadcast then
				if evt.broadcast.wait_type == "start" then
					tt.show_msg(tt.gettext("比賽將在{s1}秒内開始",evt.broadcast.wait_time))
					self.mScene:showMatchWaitAnim(evt.broadcast.wait_time)
				elseif evt.broadcast.wait_type == "alloc" then
					tt.show_msg(string.format(tt.gettext("等待系統配桌...")))
				else
					tt.show_msg(tt.gettext("請等待{s1}秒",evt.broadcast.wait_time))
				end
			end
		end
	elseif evt.cmd == "mtt.result" then 

		local match_id = self.mModel:getMatchId()
		local lv = self.mModel:getLv()
		printInfo("mtt.result match_id %s lv %d",match_id,lv)
		if self:checkMatchEvt(evt) then
			printInfo("mtt.result checkMatchEvt evt.resp: %s",type(evt.resp))
			if evt.resp then
				local resp = evt.resp
				printInfo("mtt.result checkMatchEvt mlv: %s match_id: %s",resp.mlv,resp.match_id )
				printInfo("mtt.result checkMatchEvt mlv: %s match_id: %s",lv,match_id )
				if resp.mlv == lv and resp.match_id == match_id then
		    		-- tt.show_msg("你在比赛中的名次是" .. resp.urank)
		    		self:onMttMatchResult(evt.resp)
				end
				local trich = resp.trich
				if trich.money then
					tt.owner:setMoney(trich.money)
				end
				if trich.score then
					tt.owner:setVipScore(score)
				end
			end
		end
	elseif evt.cmd == "mtt.match_rank" then
		if self:checkMatchEvt(evt) then
			if evt.resp.ret == 200 then
			-- 	urank = 1,  --用户自己的名次  
			-- left_num = 30, --比赛还剩的玩家
				self.mScene:updateMyRank(evt.resp.urank, evt.resp.left_num)
			end
		end
	elseif evt.cmd == "mtt.match_info" then
		if evt.resp and evt.resp.ret == 200 then
			local data = evt.resp.info
			local stime,jtime,atime = data.stime,data.jtime,data.atime
			local curTime = tt.time()
			if curTime < stime then
				self.mScene:showMatchWaitAnim(stime-curTime)
			end
		end
	elseif evt.cmd == "texas.chat" then
		if self:checkTableEvt(evt) then
			if evt.broadcast then
				if IMHelper.EMOTICON_MSG == evt.broadcast.ct then
					self.mScene:playEmoticon(evt.broadcast.seatid, evt.broadcast.content.emoticon_id)
				end
			end
		end
	elseif evt.cmd == "texas.intexp" then
		if self:checkTableEvt(evt) then
			if evt.resp and evt.resp.ret == -102 then
				local goods = tt.getSuitableGoodsByMoney(0)
				if goods then
					self.mScene:showRecommendGoodsDialog(goods)
				else
					tt.show_msg(tt.gettext("您的筹码不足"))
				end
			elseif evt.broadcast then
				self.mScene:playExpression(evt.broadcast.exp, evt.broadcast.src_seatid,evt.broadcast.dst_seatid)
			end
		end
	elseif evt.cmd == "texas.expfee" then
		if self:checkTableEvt(evt) then
			if evt.resp and evt.resp.ret == 200 then
				self.mModel:setExpFee(evt.resp.info)
			end
		end
	elseif evt.cmd == "msgbox.pushmsg" then
		dump(evt)
		if evt.broadcast then
			-- 0--表示达到最高级
			dump(evt.broadcast)
			if evt.broadcast.mtype == 1001 then
				local data = json.decode(evt.broadcast.msg)
				if data then
					if data.message and data.message ~= "" then
						tt.show_msg(data.message)
					end
				end
			elseif evt.broadcast.mtype == 1002 then
				local data = json.decode(evt.broadcast.msg)
				if data then
					self.mScene:updateVipView()
					if data.message and data.message ~= "" then
						tt.show_msg(data.message)
					end
				end
			elseif evt.broadcast.mtype == 1003 then
				local data = json.decode(evt.broadcast.msg)
				if data then
					if data.message and data.message ~= "" then
						tt.show_msg(data.message)
					end
				end
			end
		end
	elseif evt.cmd == "happydice.open_stage" then
		if evt.resp then
		elseif evt.broadcast then
			if tt.nativeData.checkXiazhuBetHistory(evt.broadcast.happyid,evt.broadcast.stage) then
				if tolua.isnull(self.mScene.mTouzhuGameDialog) or not self.mScene.mTouzhuGameDialog:isShowing() then
					local num1 = evt.broadcast.luck_num[1] or 1
					local num2 = evt.broadcast.luck_num[2] or 1
					local num3 = evt.broadcast.luck_num[3] or 1
					local sum = num1 + num2 + num3
					tt.show_msg(tt.gettext("{s1} 期 开奖号码是 {s2} {s3} {s4} 和值{s5}",evt.broadcast.stage,num1,num2,num3,sum))
				end
			end
		end
	elseif evt.cmd == "msgbox.live_broad" then
		if evt.broadcast then
			if evt.broadcast.mtype == "bar" then
				self.mScene:showSpeaker(evt.broadcast.content)
			elseif evt.broadcast.mtype == "user_bar" then
				local data = json.decode(evt.broadcast.content)
				self.mScene:showSpeaker(data.name .. ":" .. data.content)
			elseif evt.broadcast.mtype == "custom_bugle" then
				local data = json.decode(evt.broadcast.content)
				self.mScene:showSpeaker(data.msg)
			end
		end
	elseif evt.cmd == "alloc.change" then
		if evt.resp then
			if evt.resp.ret == 200 then
				tt.gsocket.request("texas.logout",{lv=self.mModel:getLv(), tid=self.mModel:getTid(),mid = tt.owner:getUid()})
				self.mModel:setLv(evt.resp.lv)
				self.mModel:setTid(evt.resp.tid)
				self.mScene:clearGameView()
			    self.mModel:clearGameData()
			    self.mIsNeedSitdown = true
			    self:loginRoom()
			end
		end
	elseif evt.cmd == "custom.look_up" then
		if evt.resp then
			local params = self.mModel:getCustomRoomParams()
			if evt.resp.ret == 200 and params.roomid == evt.resp.room.roomid then
				self.mModel:setCustomRoomParams(evt.resp.room)
				self.mScene:startCustomCountdown(evt.resp.room.left_time)
			end
		end
	elseif evt.cmd == "custom.room_over" then
		if evt.broadcast then
			local params = self.mModel:getCustomRoomParams()
			if params.roomid == evt.broadcast.roomid then
				self:onCustomRoomOver(evt.broadcast)
			end
		end
	else
		if evt.broadcast then
			dump(evt.broadcast)
		end
	end
end

function RoomControler:onNativeEvent(evt)
end

function RoomControler:onHttpResp(evt)
	if evt.cmd == tt.cmd.vstore then
		local data = evt.data
		if data and data.ret == 0 then
			self.mScene:onHttpVstore(data.data)
		end
	elseif evt.cmd == tt.cmd.exchange then
		local data = evt.data
		if data then
			if data.ret == 0 then
				local params = data.data
				local ptype = tonumber(params.type)
				if ptype == 1 or ptype == 2 then
					tt.show_msg(tt.gettext("兌換成功，請到您的個人信息欄中查看具體信息"))
				else
					tt.show_msg(tt.gettext("兌換成功"))
				end
				dump(params)
				if params.amount then
					tt.owner:setMoney(params.amount)
				end
				tt.owner:setVipScore(params.coin)
				self.mScene:addVipScoreAnim()
			elseif data.ret == 6 then
				tt.show_msg(tt.gettext("库存不足"))
			else
				tt.show_msg(tt.gettext("兌換失敗"))
			end
			self.mScene:onHttpExchange(data)
		end
	elseif evt.cmd == tt.cmd.gconsume then 
		if evt.data.ret == 0 then
			local data = evt.data.data
			if data.score then
				self.mScene:addVipScoreAnim()
			end
		end
	elseif evt.cmd == tt.cmd.ivalidate then 
		if evt.data.ret == 0 then
			local data = evt.data.data
			if data.score then
				self.mScene:addVipScoreAnim()
			end
		end
	end
end

function RoomControler:onKeypadListener(evt)
	if device.platform == "android" then
		if evt.key == "back" and evt.type == "Released" then
			local menu_view = self.mScene:getMenuView()
			local rule_view = self.mScene:getRuleView()

			if rule_view:isShowing() then
				self.mScene:dismissRuleView()
				return true
			end

			if menu_view:isShowing() then
				menu_view:dismiss()
			else
				self.mScene:showMenuView()
			end
			return true
		end
	elseif device.platform == "windows" then
		if evt.code == 140 and evt.type == "Released" then
			local menu_view = self.mScene:getMenuView()
			local rule_view = self.mScene:getRuleView()

			if rule_view:isShowing() then
				self.mScene:dismissRuleView()
				return true
			end

			if menu_view:isShowing() then
				menu_view:dismiss()
			else
				self.mScene:showMenuView()
			end
			return true
		end
	end
end

return RoomControler
