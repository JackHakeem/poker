local RoomModel = class("RoomModel")

function RoomModel:ctor(scene)
	self.mScene = scene
	self.mIsLogin = false -- 登陆状态
	self.mLv = 0 -- 玩法类型
	self.mTid = 0 -- 桌子id
	self.mMatchId = "" -- 比赛id
	self.mRoomType = 0 -- 房间类型 -- 客户端逻辑判断
	self.mBlindId = 0 -- 盲注表id
	self.mBlindLv = 0 -- 盲注等级
	self.mNextBlindLv = 0 -- 下一局盲注变化等级
	self.mMinCarry = 0 -- 现金场最小携带
	self.mMaxCarry = 0 -- 现金场最大携带
	self.mSb = 0   --小盲注
	self.mBb = 0   --大盲注
	self.mAnte = 0 -- 前注
	self.mBettime =  0 -- 下注时间 
	self.mWatcher = 0 -- 观战人数
	self.mGameStatus = -1 -- 游戏状态
	self.mSeatnum = 3 -- 座位数
	self.mCtlSeat = 0 -- 自己的座位号
	self.mDefaultCtl = 0 -- 默认展示座位
	self.mOffsetCtl = 0 -- 座位移动偏移量

	self.mSretain = 0 -- 自己离座留桌的状态
	self.mAutoBuyBet = 0 -- 自動購買籌碼量
	self.mSeatInfo = {} -- 座位信息

-- 游戏中数据
	self.mIsMatchOver = true
	self.mCustomRoomOver = true

	self.mRoundPot = 0 -- 当前圈总奖池
	self.mRoundMaxBet = 0 -- 当前圈最大下注
	self.mTotalPot = 0 -- 当前局抽水后总奖池
	self.mBBSeat = 0 -- 当前局大盲位置
	self.mSBSeat = 0 -- 当前局大盲位置
	self.mDealerSeatid = 0 -- dealer位置

	self.mPublicCards = {} -- 公共牌
	self.mPots = {} -- 奖池
	self.mBets = {} -- 玩家下注
	self.mActionSeatid = 0 -- 当前行动座位
	self.mActionInfo = {} -- 当前行动信息
	self.mCtlCards = {} -- 自己的手牌

	self.mExpFee = {} -- 互动道具价格

	self.mCustomRoomParams = {} --私人现金场配置
end

function RoomModel:clearGameData()
	self.mRoundPot = 0
	self.mRoundMaxBet = 0
	self.mTotalPot = 0
	self.mBBSeat = 0
	self.mSBSeat = 0
	self.mActionInfo = {}
	self.mPublicCards = {}
	self.mPots = {}
	self.mBets = {}
	self.mCtlCards = {}
end

function RoomModel:clearRoundData()
	self.mRoundPot = 0
	self.mRoundMaxBet = 0
	self.mActionInfo = {}
	self.mActionSeatid = 0
	self.mBets = {}
end

function RoomModel:onCashLogin(data)
	self.mMinCarry = data.min_carry 
	self.mMaxCarry = data.max_carry
	self.mSb = data.sb
	self.mBb = data.bb
	self.mAnte = data.ante
	self.mBettime =  data.bettime 
	self.mWatcher = data.watcher
	self.mGameStatus = data.gamestatus 
	self.mSeatnum = data.seatnum
	self.mCtlSeat = 0
	self.mSeatInfo = {}--data.seatinfo
	self.mAutoBuyBet = 0

	self.mCustomRoomOver = self.mRoomType ~= kCustomRoom

	self.mScene:initSeatView(self.mSeatnum)

	for id = 1,self.mSeatnum do 
		-- 连续数组 或者 hash 数组
		local v = data.seatinfo[id] or data.seatinfo[ id .. "" ]
		if v then
			self:setSeatInfo(id,v)
		else
			self.mScene:clearSeatInfo(id)
		end
	end
end

function RoomModel:onMatchLogin(data)
	self.mSb = data.sb
	self.mBb = data.bb
	self.mAnte = data.ante
	self.mTid = data.tid
	self.mBlindLv = data.blind_lv
	self.mBettime =  data.bettime 
	self.mGameStatus = data.gamestatus 
	self.mSeatnum = data.seatnum
	self.mCtlSeat = 0
	self.mSeatInfo = {}--data.seatinfo
	self.mAutoBuyBet = 0
	self.mIsMatchOver = false

	self.mScene:initSeatView(self.mSeatnum)

	for id = 1,self.mSeatnum do 
		-- 连续数组 或者 hash 数组
		local v = data.seatinfo[id] or data.seatinfo[ id .. "" ]
		if v then
			self:setSeatInfo(id,v)
		else
			self.mScene:clearSeatInfo(id)
		end
	end
end

function RoomModel:setCustomRoomParams(params)
	self.mCustomRoomParams = params
end

function RoomModel:getCustomRoomParams()
	return self.mCustomRoomParams
end

function RoomModel:onMatchLeaveTable()
	self.mTid = 0
end

function RoomModel:setMatchOver(flag)
	self.mIsMatchOver = flag
end

function RoomModel:setCustomRoomOver(flag)
	self.mCustomRoomOver = flag
end

function RoomModel:getSeatNum()
	return self.mSeatnum
end

function RoomModel:onGameInfo(info)
	self.mGameStatus = info.gamestatus 
	self.mRoundPot = 0
	self.mTotalPot = 0
	self.mRoundMaxBet = 0
end

function RoomModel:setBBSB(bb,sb)
	self.mBBSeat = bb
	self.mSBSeat = sb
end

function RoomModel:getBBSeat()
	return self.mBBSeat
end

function RoomModel:getSBSeat()
	return self.mSBSeat
end

function RoomModel:setSeatInfo(seatid,info)
	self.mSeatInfo[seatid] = info
	self.mScene:setSeatInfo(seatid,info)
	if info.player.mid == tt.owner:getUid() then 
		self:setCtlSeat(info.seatid)
		self:setCtlRetain(info.sretain)
		self.mScene:updateAddCoinBtn()
	end
end

function RoomModel:hasEmptySeat()
	for i=1,self.mSeatnum do
		if self.mSeatInfo[i] == nil then return true end
	end
	return false
end

function RoomModel:setDefaultCtl(seat_id)
	self.mDefaultCtl = seat_id
	if self.mCtlSeat ~= 0 then
		self.mOffsetCtl = self.mDefaultCtl - self.mCtlSeat
	end
	self.mScene:moveSeatView()
end

--设置控制者(自己)的座位号
function RoomModel:setCtlSeat(seatid)
	print("RoomLayer:setCtlSeat",seatid)
	-- local old_dif = self.mOffsetCtl
	self.mCtlSeat = seatid
	self.mOffsetCtl = self.mDefaultCtl - seatid

	self.mScene:hiddenEmptySeats()

	-- if old_dif ~= self.mOffsetCtl then 
		self.mScene:moveSeatView()
	-- end

	-- if self.seats_[self.ctl_seat_]:getCoin() == 0 and not self.seats_[self.ctl_seat_]:isPlaying() then
	-- 	self:autoBuyCoin()
	-- end
end

function RoomModel:clearSeatInfo(seatid)
	self.mSeatInfo[seatid] = nil
	self.mScene:clearSeatInfo(seatid)
	print("clearSeatInfo",seatid,self.mCtlSeat)
	if seatid == self.mCtlSeat then
		self.mCtlSeat = 0
		self.mScene:clearCtlView()
		self.mScene:showEmptySeats()
		self.mScene:updateAddCoinBtn()
		self.mScene:updateRetainView()
	elseif self.mCtlSeat == 0 then
		self.mScene:showEmptySeats()
	end
end

function RoomModel:getSeatIdByUid(uid)
	dump(self.mSeatInfo)
	for seat_id,seat in pairs(self.mSeatInfo) do
		if seat.player.mid == uid then
			return seat_id
		end
	end
	return 0
end

function RoomModel:isSelfPlaying()
	-- 如果自己沒有坐下
	if self.mCtlSeat == 0 then return false end
	-- 自己不在牌局中
	local seat = self.mScene:getSeatById(self.mCtlSeat)
	return seat:isPlaying()
end

function RoomModel:setCtlRetain(sretain)
	print("setCtlRetain",sretain)
	self.mSretain = sretain
	self.mScene:updateRetainView()
end

--sretain:0-离座留桌 1-回到座位
function RoomModel:getCtlRetain()
	return self.mSretain
end

function RoomModel:addRoundPot(chips)
	self.mRoundPot = self.mRoundPot + chips
end

function RoomModel:addTotalPot(chips)
	self.mTotalPot = self.mTotalPot + chips
end

function RoomModel:getTotalPot()
	return self.mTotalPot + self.mRoundPot
end

function RoomModel:updateActionMaxBet(bet)
	print("updateActionMaxBet",self.mRoundMaxBet,bet)
	self.mRoundMaxBet = math.max(self.mRoundMaxBet,bet)
end

function RoomModel:getRoundMaxBet()
	return self.mRoundMaxBet
end

function RoomModel:setCtlCards(cards)
	self.mCtlCards = cards
	self.mScene:updateCtlCards()
end

function RoomModel:getCtlCards()
	return self.mCtlCards
end

function RoomModel:setPublicCards(publiccards)
	self.mPublicCards = publiccards
	self.mScene:updatePublicCards()
end

function RoomModel:getPublicCards()
	return self.mPublicCards
end

function RoomModel:addPublicCard(card,index)
	self.mPublicCards[index] = card
end

function RoomModel:setPots(pots)
	self.mPots = pots
	for id, v in ipairs(pots) do 
		self:addTotalPot(v)
	end
	self.mScene:updatePots()
end

function RoomModel:addPots(pots)
	for id, coin in pairs(pots) do
		self.mPots[id] = self.mPots[id] or 0
		self.mPots[id] = self.mPots[id] + coin
		self:addTotalPot(coin)
	end
	self.mScene:updatePots()
end

function RoomModel:getPots()
	return self.mPots
end

function RoomModel:setSeatBets(seatid,chips)
	self.mBets[seatid] = chips
	self.mScene:updateSeatBets(seatid)
end

function RoomModel:addSeatBets(seatid,chips)
	self.mBets[seatid] = self.mBets[seatid] or 0
	self.mBets[seatid] = self.mBets[seatid] + chips
	self.mScene:updateSeatBets(seatid)
end

function RoomModel:getSeatBets(seatid)
	return self.mBets[seatid] or 0
end

function RoomModel:setActionSeat(seatid,countdown)
	self.mActionSeatid = seatid
	if self.mActionSeatid == 0 then return end
	local seat = self.mScene:getSeatById(seatid)
	seat:playBetTimeAnim(countdown or self.mBettime,self.mBettime)
end

function RoomModel:getActionSeat()
	return self.mActionSeatid
end

function RoomModel:updateActionInfo(action)
	self.mActionInfo = action
	if self.mCtlSeat == action.seatid then
		self.mScene:showBetActionView()
	else
		self.mScene:showPreActionView()
	end
end

function RoomModel:getActionInfoCheck()
	return self.mActionInfo.check or 0
end

-- 当前阶段最大加注
function RoomModel:getActionInfoRaiseMax()
	return self.mActionInfo.raisemax or 0
end

-- 当前阶段最小加注  为0 只能check  否者 再 min 和 max 中取raise值
function RoomModel:getActionInfoRaiseMin()
	return self.mActionInfo.raisemin or 0
end

function RoomModel:changeNextBlindLv()
	-- 现金场不涨盲
	if self.mRoomType == kCashRoom or self.mRoomType == kCustomRoom then return end
	local datas = self:getBlindInfo()
	local data = datas[self.mNextBlindLv]

	if self.mSb ~= data.sb or self.mBb ~= data.bb or self.mAnte ~= data.ante then
		self.mSb = data.sb   --小盲注
		self.mBb = data.bb   --大盲注
		self.mAnte = data.ante -- 前注
		self.mScene:showBlindTips(self.mSb,self.mBb,self.mAnte)
	end
end

function RoomModel:getCurBB()
	return self.mBb
end

--设置庄家位置
function RoomModel:setDealerSeat(seatid)
	self.mDealerSeatid = seatid
	self.mScene:showDealerIcon(seatid)
end

function RoomModel:getDealerSeat()
	return self.mDealerSeatid
end

function RoomModel:setGameStatus(status)
	self.mGameStatus = status
end

function RoomModel:getGameStatus()
	return self.mGameStatus
end

function RoomModel:getCtlSeat()
	return self.mCtlSeat
end

function RoomModel:isLogin()
	return self.mIsLogin
end

function RoomModel:setLogin(flag)
	self.mIsLogin = flag
end

function RoomModel:setTid(tid)
	self.mTid = tid
end

function RoomModel:getTid()
	return self.mTid
end

function RoomModel:setLv(lv)
	self.mLv = lv
end

function RoomModel:getLv()
	return self.mLv
end

function RoomModel:setMatchId(matchId)
	self.mMatchId = matchId
end

function RoomModel:getMatchId()
	return self.mMatchId
end

function RoomModel:setRoomType(roomType)
	self.mRoomType = roomType
	self.mScene:updateRoomTypeView()
end

function RoomModel:getRoomType()
	return self.mRoomType
end

function RoomModel:setBlindId(blind_id)
	self.mBlindId = blind_id
end

function RoomModel:getBlindId()
	return self.mBlindId
end

function RoomModel:setBlindLv(blind_lv)
	self.mBlindLv = blind_lv
end

function RoomModel:getBlindLv()
	return self.mBlindLv
end

function RoomModel:setNextBlindLv(blind_lv)
	self.mNextBlindLv = blind_lv
end

function RoomModel:getNextBlindLv()
	return self.mNextBlindLv
end

function RoomModel:getBlindInfo()
	return tt.game_data.blind_table[self.mBlindId]
end

function RoomModel:getMaxCarry()
	return self.mMaxCarry
end

function RoomModel:s2v(sid)
	local vid = sid + self.mOffsetCtl
	if vid > self.mSeatnum then vid = vid - self.mSeatnum 
	elseif vid < 1 then vid = vid + self.mSeatnum end 
	return vid 
end

function RoomModel:isPlaying(seat_id)
	return self.mScene:isPlaying(seat_id)
end

function RoomModel:isAllOtherPlayerAllin()
	for id=1,self.mSeatnum do
		local seat = self.mScene:getSeatById(id)
		if id ~= self.mCtlSeat and seat:isPlaying() and seat:getCoin() ~= 0 then
			return false
		end 
	end
	return true
end

function RoomModel:isMatchOver()
	return self.mIsMatchOver
end

function RoomModel:isCustomOver()
	return self.mCustomRoomOver
end

function RoomModel:setExpFee(info)
	self.mExpFee = info
end

function RoomModel:getExpFee()
	return self.mExpFee
end

return RoomModel