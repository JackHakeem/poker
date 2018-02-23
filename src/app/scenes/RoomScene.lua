--
-- Author: shineflag
-- Date: 2017-02-23 14:20:23
--
local RoomScene = class("RoomScene", function()
    return display.newScene("RoomScene")
end)

local RoomControler = require("app.scenes.controler.RoomControler")
local RoomModel = require("app.scenes.model.RoomModel")
local CoinPot = require("app.views.CoinPot")
local Expression = require("app.views.Expression")
local texaslogic = require("app.utils.texaslogic")

local zorder = {
	table   = 50,
	bet 	= 100,
	card 	= 200,
	seat 	= 300,
	anim    = 400,
	ui   	= 500,
	dialog 	= 600,
	socket 	= 1000,
}

local anims_tags = {
	seatMoveAnim = 100,
	show_win_anim = 101,
	vip_anim = 102,
	show_ctrl_cards = 103,
	round_clear_delay = 104,
}

local seat_pos = {}
--dealer 9 个位置
local dpos = {}
--每个玩家下注的位置
local bet_pos = {}
--每个玩家获得筹码的位置
local head_pos = {}
--每个玩家发牌的位置
local cards_pos = {}
--奖池的位置 --- 4
local potspos = {}
--弃牌与发牌的位置
local fold_pos = cc.p(640,400)

--公共牌的位置
local pcards_pos, pc_sx,pc_y , pc_w = {},370,400,90
for id = 1,5 do pcards_pos[id] = cc.p(pc_sx+id*pc_w,pc_y) end

local test = false
function RoomScene:ctor(mlv,match_id,room_type,params)
	self.mModel = RoomModel.new(self)
	self.mControler = RoomControler.new(self,self.mModel)
    self:initView()

	self.mModel:setLv(mlv)
	self.mModel:setRoomType(room_type)
	if room_type == 1 then
		self.mModel:setTid(match_id)
		local data = tt.nativeData.getCashInfoBy(mlv)
		if data then
			self:updateCashInfoView(data.name,data.sb,data.bb,data.ante)
		end
	elseif room_type == kCustomRoom then
		self.mModel:setTid(match_id)
		self.mModel:setCustomRoomParams(params)
		self:updateCashInfoView(params.name .. " " .. tt.gettext("房间ID:") ..  params.roomid,params.sb,params.sb*2,params.ante)
	else
		self.mModel:setMatchId(match_id)
	end
end

function RoomScene:initView()
	local node, width, height = cc.uiloader:load("room_layer.json")
	node:align(display.CENTER,display.cx,display.cy)
	self:addChild(node)
	self.mRoot = node

	self.loadView = display.newSprite("dec/juhua.png")
		:setPosition(cc.p(640,360))
		:setVisible(false)
	self.loadView:addTo(self.mRoot,zorder.ui)

	self.mSeatViews = {}
	self.mBetViews = {}
	self.mPotViews = {}
	self.mPublicCards = {}
	self.mCtlCards = {}

	self.mPreActionView = app:createView("PreActionView", self)
    	:addTo(self.mRoot,zorder.ui+1)

	self.mBetActionView = app:createView("BetActionView", self)
    	:addTo(self.mRoot,zorder.ui+1)

	--离座留桌 回到座位
    self.mReturnView = app:createView("ReturnView", self)
    	:setVisible(false)
    	:addTo(self.mRoot,zorder.ui+1)

    self.mAddCoinBtn = cc.uiloader:seekNodeByName(node,"add_coin_btn")
		:setButtonEnabled(false)
		:setVisible(false)
		:onButtonClicked(function()
				tt.play.play_sound("click")
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomAddCoinBtn)
				if self.mModel:getRoomType() == kCashRoom then
					self.mControler:onAddCoinClick()
				elseif self.mModel:getRoomType() == kCustomRoom then
					self:showBuyChipsDialog()
				end	
			end)

	self.mDealerIcon = display.newSprite("dec/dealer.png")
	:setVisible(false)
	:addTo(self.mRoot,zorder.bet)

	self.mPotLabel =  cc.uiloader:seekNodeByName(node,"pot_label")
		:setVisible(false)
	self.mPotIcon =  cc.uiloader:seekNodeByName(node,"pot_icon")
		:setVisible(false)
		
	self.mPotLabelBg = cc.uiloader:seekNodeByName(node,"pot_label_bg")
		:setVisible(false)

	self.mControlCard1Handler = cc.uiloader:seekNodeByName(node,"control_card_1_handler")
	self.mControlCard2Handler = cc.uiloader:seekNodeByName(node,"control_card_2_handler")

  	self.mMenuView = app:createView("RoomMenuView", self):addTo(self.mRoot,zorder.ui+1)
  	self.mMenuBtn = cc.uiloader:seekNodeByName(node,"menu_btn")
    	:onButtonClicked(function()
			tt.play.play_sound("click")
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomMenuBtn)
			self:showMenuView()
    	end)

	cc.uiloader:seekNodeByName(node,"rule_btn"):onButtonClicked(function()
			tt.play.play_sound("click")
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomRuleBtn)
			self:showRuleView()
    	end)

	self.mRuleView = app:createView("RoomRuleView", self)
    	:addTo(self.mRoot,zorder.ui+1)


	self.mMatchInfoHandler = cc.uiloader:seekNodeByName(node,"match_info_handler")
	self.mMatchInfoHandler:setVisible(false)

    self.mBlindTxt = cc.uiloader:seekNodeByName(self.mMatchInfoHandler,"blind_txt")
	self.mBlindTxt0 = cc.uiloader:seekNodeByName(self.mMatchInfoHandler,"blind_txt_0")
	self.mRankTxt = cc.uiloader:seekNodeByName(self.mMatchInfoHandler,"rank_txt")
	self.mBlindInfoBtn = cc.uiloader:seekNodeByName(self.mMatchInfoHandler,"blind_info_btn")
		:onButtonClicked(function()
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomBlindInfoBtn)
			tt.play.play_sound("click")
			self:showMatchInfoDialog()
		end)
	

	self.mCashInfoHandler = cc.uiloader:seekNodeByName(node,"cash_info_handler")
	self.mCashInfoHandler:setVisible(false)

	self.mVipView = cc.uiloader:seekNodeByName(node,"vip_view")
    self.mVipIcon = cc.uiloader:seekNodeByName(self.mVipView,"icon")
    self.mVipTxt = cc.uiloader:seekNodeByName(self.mVipView,"vip_txt")

    self.mVipView:setTouchEnabled(true)
	self.mVipView:setTouchSwallowEnabled(false)

	local startX,startY =0,0
	local down = false
	self.mVipView:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
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
        	if not self.mVipView:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
	    	return true 
	    elseif event.name ~= "began" and down then
	    	-- if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    	-- 	down = false
	    	-- end
	    	if event.name == "ended" then
		    	tt.play.play_sound("click")
				self:showPrizeCenterView()
			end
		end
		if event.name == "ended" then
		end
	end)

    self.mCurVipScore = tt.owner:getVipScore()
    self.mVipTxt:setString(tt.getNumStr(self.mCurVipScore))

	-- self.vipExpProgress = cc.ProgressTimer:create(cc.Sprite:create("dec/vip_progress_bar.png"))
	--     :setType(cc.PROGRESS_TIMER_TYPE_BAR)
	--     :setMidpoint(cc.p(0,0))
	--     :setBarChangeRate(cc.p(1, 0))
	--     :setPosition(80,0)
 --    	:addTo(cc.uiloader:seekNodeByName(self.mVipView,"process"))

 	self.mVipExpProgress = display.newDrawNode()
	local mask = display.newSprite("dec/vip_progress_bar.png")
	local clip_node = cc.ClippingNode:create()
	clip_node:setStencil(self.mVipExpProgress);
	clip_node:addChild(mask)
	clip_node:setPosition(cc.p(-12,0.5));
	clip_node:setAlphaThreshold(0.05)  --不显示模板的透明区域
	clip_node:setInverted( false ) --显示模板不透明的部分
	clip_node:addTo(cc.uiloader:seekNodeByName(self.mVipView,"process"))

	local lv = tt.owner:getVipLv()
	local lv_info = tt.game_data.vip_info[lv]
	local pre_exp = tt.game_data.vip_info[lv-1] and tt.game_data.vip_info[lv-1].exp or 0
	local exp = tt.owner:getVipExp()
	local percentage = (exp-pre_exp)*100/(lv_info.exp-pre_exp)
	if percentage < 0 then percentage = 0 end
	if percentage > 100 then percentage = 100 end
	self:updateProgress(percentage)

    self.mVipIcon:setTexture(string.format("dec/icon_vip".. tt.owner:getVipLv() .. ".png"))

	cc.uiloader:seekNodeByName(node,"touzhu_btn")
		:setVisible(not tt.nativeData.isIosLock())
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:showTouzhuGameDialog()
		end)
    

	self.mTimeTxt = cc.uiloader:seekNodeByName(node,"time_txt")
	self:startTimeClock()

	self.mCustomRoomBtn = cc.uiloader:seekNodeByName(node,"custom_room_btn")
			:onButtonClicked(function()
					tt.play.play_sound("click")
					self:showCustomRoomDialog()
				end)
	self.mInviteBtn = cc.uiloader:seekNodeByName(node,"invite_btn")
			:onButtonClicked(function()
					tt.play.play_sound("click")
					self:showRoomShareView()
				end)
	print("initView end")
end

function RoomScene:updateRoomTypeView()
	local roomType = self.mModel:getRoomType()
	if roomType == kSngRoom then
		self.mMatchInfoHandler:setVisible(true)
		self.mCashInfoHandler:setVisible(false)
		self.mAddCoinBtn:setVisible(false)
		self.mVipView:setVisible(false)
		self.mCustomRoomBtn:setVisible(false)
		self.mInviteBtn:setVisible(false)
	elseif roomType == kMttRoom then
		self.mMatchInfoHandler:setVisible(true)
		self.mCashInfoHandler:setVisible(false)
		self.mAddCoinBtn:setVisible(false)
		self.mVipView:setVisible(false)
		self.mCustomRoomBtn:setVisible(false)
		self.mInviteBtn:setVisible(false)
	elseif roomType == kCustomRoom then
		self.mMatchInfoHandler:setVisible(false)
		self.mCashInfoHandler:setVisible(true)
		self.mAddCoinBtn:setVisible(true)
		self.mVipView:setVisible(true)
		self.mCustomRoomBtn:setVisible(true)
		self.mInviteBtn:setVisible(true)
	else
		self.mMatchInfoHandler:setVisible(false)
		self.mCashInfoHandler:setVisible(true)
		self.mAddCoinBtn:setVisible(true)
		self.mVipView:setVisible(true)
		self.mCustomRoomBtn:setVisible(false)
		self.mInviteBtn:setVisible(false)
	end
end

function RoomScene:showLoad()
	if self.loadView:isVisible() then return end
	self.loadView:setVisible(true)
	local index = 0
    self.loadView:schedule(function()
            index = (index + 40) % 360
            self.loadView:rotation(index)
        end,0.1)
end

function RoomScene:hideLoad()
	if not self.loadView:isVisible() then return end
	self.loadView:setVisible(false)
	self.loadView:stopAllActions()
end

function RoomScene:onEnter()
	print("RoomScene onEnter")	
	tt.gsocket.setHeartTime(3)
	tt.play.set_music_vol(0)
	self.mControler:addEventListeners()
	if test then
		local resp = {
			ret = 200,  --ok - 101 桌子找不到
			lv = 1,
			tid = 1001,
			min_carry = 200, --最小买入
			max_carry = 500, --最大买入
			seatnum = 9,  --几人桌
			ante = 0,   --前注
			sb = 50,   --小盲
			bb = 100,  --大盲
			bettime = 15, --下注思考时间
			watcher = 1,
			gamestatus = 0,  --当前的游戏状态-1:空闲阶段 0:准备开始 1:发手牌的第一轮行动 2:翻三张牌 3:转牌 4:河牌 5:结算时间
			seatinfo = {   --座位上的信息  sretain:0-离座留桌 1-回到座位  snet:0-断网 1-正常连接
				{seatid=1,coin=100,sretain=1,snet=1, player={mid=100,money=100,info="xxx"}},
			}
		}
		self.mControler:onLoginOk(resp)
		self:showMatchWaitAnim(100)
	else
		self.mControler:loginRoom()
	end
end

function RoomScene:onExit()
	tt.play.set_music_vol(1)
	self.mControler:removeEventListeners()
end


function RoomScene:getReconnectDialog()
	if tolua.isnull(self.mRoomReconnectView) then
		self.mRoomReconnectView = app:createView("RoomReconnectView", self)
			:addTo(self.mRoot,zorder.socket)
	end
	return self.mRoomReconnectView
end

function RoomScene:initSeatView(play_num)
	print("initSeatView:",play_num)
	for _,seatView in ipairs(self.mSeatViews) do
		seatView:removeSelf()
	end
	self.mSeatViews = {}
	for id=1,play_num do 
		local seatView = app:createView("SeatView",self,id)
		seatView:addTo(self.mRoot,zorder.seat)
		self:changeSeatViewByVId(seatView,id)
		self.mSeatViews[id] = seatView
	end

	for _,betView in ipairs(self.mBetViews) do
		betView:removeSelf()
	end

	self.mBetViews = {}
	for id=1,play_num do
		local betView = app:createView("CoinPot",self)
		betView:addTo(self.mRoot,zorder.bet)
		betView:setVisible(test)
		self:changeBetCoinByVId(betView,id)
		self.mBetViews[id] = betView
	end

	for _,potView in ipairs(self.mPotViews) do
		potView:removeSelf()
	end
	self.mPotViews = {}
	for id=1,play_num do
		local potView = app:createView("CoinPot",self)
		potView:addTo(self.mRoot,zorder.bet)
		potView:setVisible(test)
		self:changePotCoinByVId(potView,id)
		self.mPotViews[id] = potView
	end

	self:resetConfig(play_num)

	for id=1,play_num do
		local pos = potspos[id] or cc.p(0,0)
		self.mPotViews[id]:setPosition(pos)
	end
end

function RoomScene:setSeatInfo(seat_id,info)
	if self.mSeatViews[seat_id] then
		self.mSeatViews[seat_id]:setSeatInfo(info)
	end
end

function RoomScene:clearSeatInfo(seat_id)
	if self.mSeatViews[seat_id] then
		self.mSeatViews[seat_id]:clearSeat()
	end
end

--隐藏空座位
function RoomScene:hiddenEmptySeats()
	for id,seatView in ipairs(self.mSeatViews) do
		if not seatView:hasPlayer() then
			seatView:hiddenSeat()
		end
	end
end

--展示可以座的座位
function RoomScene:showEmptySeats()
	for id,seatView in ipairs(self.mSeatViews) do
		if not seatView:hasPlayer() then
			seatView:showSeat()
		end
	end
end

function RoomScene:showDealerIcon(seat_id)
	local pos = dpos[self.mModel:s2v(seat_id)] or cc.p(0,0)
	self.mDealerIcon:stopAllActionsByTag(anims_tags.seatMoveAnim)
	local action = cc.MoveTo:create(0.2,pos)
	action:setTag(anims_tags.seatMoveAnim)
	self.mDealerIcon:runAction(action)
	self.mDealerIcon:setVisible(true)
end

function RoomScene:updateConsoleView()
	if self.mModel:getCtlSeat() ~= 0 then
		self.mPreActionView:update()
	else
		self.mPreActionView:hide()
	end

	if self.mModel:getActionSeat() ~= self.mModel:getCtlSeat() then
		self.mBetActionView:hide()
		if self.mIsShowRuleView then
			self.mRuleView:show()
		end

		if not tolua.isnull(self.mTouzhuGameDialog) and self.mTouzhuGameDialog:isShowing() then
			self.mTouzhuGameDialog:setVisible(true)
		end
	end
end

function RoomScene:showBetActionView()
	if self.mPreActionView:getSetFlag() then
		self.mPreActionView:doAction()
		self.mBetActionView:hide()
		if self.mIsShowRuleView then
			self.mRuleView:show()
		end

		if not tolua.isnull(self.mTouzhuGameDialog) and self.mTouzhuGameDialog:isShowing() then
			self.mTouzhuGameDialog:setVisible(true)
		end
	else
		self.mPreActionView:hide()
		self.mBetActionView:show()
		if self.mIsShowRuleView then
			self.mRuleView:dismiss()
		end

		if not tolua.isnull(self.mTouzhuGameDialog) and self.mTouzhuGameDialog:isShowing() then
			self.mTouzhuGameDialog:setVisible(false)
		end
	end
end

function RoomScene:showPreActionView()
	-- 不在牌局中
	if not self.mModel:isSelfPlaying() then 
		self.mPreActionView:hide()
		return 
	end
	local seat_id = self.mModel:getCtlSeat()
	local maxBet = self.mModel:getRoundMaxBet()
	local selfBet = self.mModel:getSeatBets(seat_id)
	local isSelfBB = self.mModel:getBBSeat() == seat_id
	local isPreflop = self.mModel:getGameStatus() == self.mControler.contants.status.preflop
	local dealerSeat = self.mModel:getDealerSeat()   -- 当前dealer id
	local curActionSeat = self.mModel:getActionSeat() -- 当前行动id
	local selfSeat = seat_id		   -- 当前控制id
	local bbSeat = self.mModel:getBBSeat()                 -- 当前大盲位置
	local bb = self.mModel:getCurBB()
	local seat_num = self.mModel:getSeatNum()

	tt.log.d(TAG, "myself is playing maxBet:%d selfBet:%d isSelfBB:%s isPreflop:%s dealerSeat:%d curActionSeat:%d selfSeat:%d" 
		,maxBet,selfBet,tostring(isSelfBB),tostring(isPreflop),dealerSeat,curActionSeat,selfSeat)
	-- preflop 第一轮下注 最大是 大盲
	-- 其他 是 0
	local firstBet = (isPreflop and bb) or 0
	if maxBet == selfBet then
		-- 第一轮 和 下注不相等 更加下注顺序判断是否显示预操作界面
		if maxBet == firstBet then
			-- 第一轮 大盲的下一家开始说话
			-- 其他 Dealer 的下家 说话
			local startSeat = (isPreflop and bbSeat % seat_num + 1) or (dealerSeat % seat_num + 1)
			local endSeat = ( curActionSeat <  startSeat and curActionSeat + seat_num ) or curActionSeat
			local checkSeat = ( selfSeat <  startSeat and selfSeat + seat_num ) or selfSeat
			if not (checkSeat >= startSeat and checkSeat <= endSeat) then
				self.mPreActionView:show()
			else
				self.mPreActionView:hide()
			end
		else
			self.mPreActionView:hide()
		end
	else
		if self:getSeatById(selfSeat):getCoin() ~= 0 then
			self.mPreActionView:show()
		else
			self.mPreActionView:hide()
		end
	end
end

function RoomScene:dismissBetActionView()
	self.mBetActionView:hide()
	if self.mIsShowRuleView then
		self.mRuleView:show()
	end

	if not tolua.isnull(self.mTouzhuGameDialog) and self.mTouzhuGameDialog:isShowing() then
		self.mTouzhuGameDialog:setVisible(true)
	end
end

function RoomScene:dismissPreActionView()
	self.mPreActionView:hide()
end

function RoomScene:updateRetainView()
	--sretain:0-离座留桌 1-回到座位
	local sretain = self.mModel:getCtlRetain()
	if sretain == 1 or self.mModel:getCtlSeat() == 0 then
		self.mReturnView:setVisible(false)
		self.mPreActionView:setRetainStatus(false)
		self.mBetActionView:setRetainStatus(false)
	else
		self.mReturnView:setVisible(true)
		self.mPreActionView:setRetainStatus(true)
		self.mBetActionView:setRetainStatus(true)
	end
end

function RoomScene:changeSeatViewByVId(seat,id)
	local num = self.mModel:getSeatNum()
	if num <= 3 then
		if id <= 2 then
			seat:setShowRight()
		else
			seat:setShowLeft()
		end
	elseif num <= 6 then
		if id < 4 then
			seat:setShowRight()
		else
			seat:setShowLeft()
		end
	else
		if id < 5 then
			seat:setShowRight()
		else
			seat:setShowLeft()
		end
	end
end

function RoomScene:changeBetCoinByVId(bet,id)
	local num = self.mModel:getSeatNum()
	if num <= 3 then
		if id == 1 then
			bet:setDirection(CoinPot.s_direction.left)
		else
			bet:setDirection(CoinPot.s_direction.right)
		end
	elseif num <= 6 then
		if id == 2 or id == 3 then
			bet:setDirection(CoinPot.s_direction.left)
		else
			bet:setDirection(CoinPot.s_direction.right)
		end
	else
		if id == 1 then
			bet:setDirection(CoinPot.s_direction.right)
			return
		end
		if id < 5 then
			bet:setDirection(CoinPot.s_direction.left)
		else
			bet:setDirection(CoinPot.s_direction.right)
		end
	end
end

function RoomScene:changePotCoinByVId(pot,id)
	if id == 7 or id == 8 then
		pot:setDirection(CoinPot.s_direction.down)
	else
		pot:setDirection(CoinPot.s_direction.right)
	end
end

--重新移动座位
function RoomScene:moveSeatView()
	--move seat
	for id,seatView in ipairs(self.mSeatViews) do
		local pos = seat_pos[self.mModel:s2v(id)] or cc.p(0,0)
		printInfo("moveSeatView id:%d x:%d ,y:%d", id,pos.x,pos.y)
		self:changeSeatViewByVId(seatView,self.mModel:s2v(id))
		seatView:stopAllActionsByTag(anims_tags.seatMoveAnim)
		local action = cc.MoveTo:create(0.2,pos)
		action:setTag(anims_tags.seatMoveAnim)
		seatView:runAction(action)
	end

	--move dearler icon
	local dealer_seatid = self.mModel:getDealerSeat()
	if dealer_seatid ~= 0 then
		self:showDealerIcon(dealer_seatid)
	end

	--move bet_coin
	for id,betView in ipairs(self.mBetViews) do
		local v_id = self.mModel:s2v(id)
		local pos = bet_pos[v_id] or cc.p(0,0)
		self:changeBetCoinByVId(betView,v_id)
		betView:stopAllActionsByTag(anims_tags.seatMoveAnim)
		local action = cc.MoveTo:create(0.2,pos)
		action:setTag(anims_tags.seatMoveAnim)
		betView:runAction(action)
	end
end

function RoomScene:updateSeatBets(seat_id)
	local chips = self.mModel:getSeatBets(seat_id)
	self.mBetViews[seat_id]:setVisible(chips ~= 0)
	self.mBetViews[seat_id]:setCoin(chips)
end

function RoomScene:isPlaying(seat_id)
	return self.mSeatViews[seat_id]:isPlaying()
end

function RoomScene:getSeatById(seat_id)
	return self.mSeatViews[seat_id]
end

function RoomScene:clearCtlView()
	for _,ctlCard in pairs(self.mCtlCards) do
		ctlCard:setVisible(false)
		ctlCard:setGray(false)
		ctlCard:normal()
	end
	self:dismissPreActionView()
	self:dismissBetActionView()
end

function RoomScene:clearGameView()
	self:stopAllActionsByTag(anims_tags.round_clear_delay)

	-- 界面延迟清理动画
	if self:getActionByTag(anims_tags.show_win_anim) then
		self.mControler:autoBuyCoin()
		self:stopAllActionsByTag(anims_tags.show_win_anim)
	end

	for _,seatView in ipairs(self.mSeatViews) do
		seatView:onStart()
		seatView:setCardsFlag(false)
		seatView:clearShowHands()
		seatView:clearWinShow()
		seatView:setIsPlaying(false)
		seatView:stopBetTimeAnim()
	end

	for _,betView in ipairs(self.mBetViews) do
		betView:setVisible(false)
	end
	for _,potView in ipairs(self.mPotViews) do
		potView:setVisible(false)
	end
	for _,publicCard in pairs(self.mPublicCards) do
		publicCard:setVisible(false)
		publicCard:setGray(false)
		publicCard:normal()
	end

	self:clearCtlView()
end

function RoomScene:updateTotalPot()
	local total = self.mModel:getTotalPot()
	-- total = 10000000000
	self.mPotLabel:setString("Pot:" .. tt.getNumStr(total))
	local width = math.max(self.mPotLabel:getContentSize().width+36,123)
	self.mPotLabelBg:setContentSize(width,self.mPotLabelBg:getContentSize().height)
	self.mPotIcon:setPosition(cc.p(640-width/2,532))
	self.mPotLabel:setVisible(true)
	self.mPotLabelBg:setVisible(true)
	self.mPotIcon:setVisible(true)
end

function RoomScene:updateAddCoinBtn()
	if self.mModel:getRoomType() == kCashRoom then
		local ctl_seat = self.mModel:getCtlSeat()
		if self.mControler:isCanAutoFull() or ctl_seat == 0 then
			self.mAddCoinBtn:setButtonEnabled(false)
			return 
		end

		local coin = self.mSeatViews[ctl_seat]:getCoin()
		local need = self.mControler:getCashCarry(self.mModel:getLv())
		print("RoomLayer:updateAddCoinBtn",coin,need)
		if coin < need then
		 	self.mAddCoinBtn:setButtonEnabled(true)
		else
			self.mAddCoinBtn:setButtonEnabled(false)
		end 
	elseif self.mModel:getRoomType() == kCustomRoom then
		self.mAddCoinBtn:setButtonEnabled(true)
	end	
end

function RoomScene:updatePublicCards()
	local card_values = self.mModel:getPublicCards()
	dump(card_values,"updatePublicCards")
	for id,value in pairs(card_values) do
		if tolua.isnull(self.mPublicCards[id]) then
			self.mPublicCards[id] = app:createView("Poker", value)
			local pos = pcards_pos[id]
			self.mPublicCards[id]:setPosition(pos)
			self.mPublicCards[id]:addTo(self.mRoot,zorder.card)
		else
			self.mPublicCards[id]:setCardValue(value)
		end
		self.mPublicCards[id]:setVisible(true)
	end
end

function RoomScene:updatePots()
	local pot_values = self.mModel:getPots()
	for id,value in pairs(pot_values) do
		self.mPotViews[id]:setCoin(value)
		self.mPotViews[id]:setVisible(true)
	end
end

function RoomScene:getRuleView()
	return self.mRuleView
end

function RoomScene:showRuleView()
	self.mIsShowRuleView = true
	self.mRuleView:show()
end

function RoomScene:dismissRuleView()
	self.mIsShowRuleView = false
	self.mRuleView:dismiss()
end

function RoomScene:getMenuView()
	return self.mMenuView
end

function RoomScene:showMenuView()
	self.mMenuView:show(self.mModel:getCtlSeat() > 0,self.mModel:getCtlSeat() > 0 and not self.mReturnView:isVisible() )
end

function RoomScene:showRecommendGoodsDialog(goods)
	if not goods then return end
	if tolua.isnull(self.mRecommendGoodsDialog) then
		self.mRecommendGoodsDialog = app:createView("RecommendGoodsDialog",self):addTo(self.mRoot,zorder.dialog)
	end
	self.mRecommendGoodsDialog:setGoods(goods)
	self.mRecommendGoodsDialog:show()
end

function RoomScene:startTimeClock()
	local update = function() 
			local time = tt.time()
			if time % 2 == 1 then
				self.mTimeTxt:setString(os.date("%H:%M"))
			else
				self.mTimeTxt:setString(os.date("%H %M"))
			end
		end
	update()
	self:schedule(update, 1)
end

function RoomScene:playStartAnim(playseat)
	local spos = fold_pos
	for _,id in pairs(playseat) do 
		local seat = self.mSeatViews[id]
		local epos = cards_pos[self.mModel:s2v(id)] or cc.p(0,0)
		seat:setIsPlaying(true)
		if self.mModel:getCtlSeat() ~= id then
			tt.play_deal_cards(cc.pMidpoint(spos,epos), epos, 0.8, function()
					if not tolua.isnull(seat) then
						seat:setCardsFlag(true)
					end
				end):addTo(self.mRoot,zorder.anim)
		end
	end
end

function RoomScene:playCtlCardsFold()
	self:updateCtlCards()
	for i=1,2 do
		self.mCtlCards[i]:scaleTo(0.5, 0.9)
		self.mCtlCards[i]:setGray(true)
	end
end

function RoomScene:playShowCtlCardsAnim(cards)
	-- 手牌已经展示 不重复播放动画
	if not self.mCtlCards[1]:isVisible() then return end
	self:updateCtlCards()

	self.mCtlCards[1]:setVisible(false)
	self.mCtlCards[2]:setVisible(false)

	local seat_id = self.mModel:getCtlSeat()
	local seat = self:getSeatById(seat_id)

	local pos1,pos2 = seat:getShowCardPosition()
	pos1 = self.mRoot:convertToNodeSpace(pos1)
	pos2 = self.mRoot:convertToNodeSpace(pos2)

	self.mCtlCards[1]:setVisible(true)
	self.mCtlCards[1]:moveTo(0.2, pos1.x, pos1.y)
	self.mCtlCards[1]:rotateTo(0.2,0)
	self.mCtlCards[1]:scaleTo(0.2, 0.8)

	self.mCtlCards[2]:setVisible(true)
	self.mCtlCards[2]:moveTo(0.2, pos2.x, pos2.y)
	self.mCtlCards[2]:rotateTo(0.2,0)
	self.mCtlCards[2]:scaleTo(0.2, 0.8)

	self:stopAllActionsByTag(anims_tags.show_ctrl_cards)
	self:performWithDelay(function()
			if self.mCtlCards[1] then
				self.mCtlCards[1]:setVisible(false)
			end
			if self.mCtlCards[2] then
				self.mCtlCards[2]:setVisible(false)
			end
			if not tolua.isnull(seat) then
				seat:showHands(cards)
				local pcards = self.mModel:getPublicCards()
				local ccards = self.mModel:getCtlCards()
				local cardtype, bestcards = texaslogic.make_cards(pcards, ccards)
				self:showSelfBestCardsHint(cardtype, bestcards)
			end
		end, 0.2):setTag(anims_tags.show_ctrl_cards)
end

function RoomScene:updateCtlCards()
	self:stopAllActionsByTag(anims_tags.show_ctrl_cards)

	local pos1 = cc.p(self.mControlCard1Handler:getPosition())
	local pos2 = cc.p(self.mControlCard2Handler:getPosition())
	local rotation1 = self.mControlCard1Handler:getRotation()
	local rotation2 = self.mControlCard2Handler:getRotation()

	local ctl_cards = self.mModel:getCtlCards()
	for i=1,2 do
		local value = ctl_cards[i] or 0
		if not self.mCtlCards[i] then
			self.mCtlCards[i] = app:createView("Poker", value)
			self.mCtlCards[i]:addTo(self.mRoot,zorder.ui)
		else
			self.mCtlCards[i]:setCardValue(value)
		end
		self.mCtlCards[i]:setVisible(value ~= 0)
	end

	self.mCtlCards[1]:stopAllActions()
	self.mCtlCards[2]:stopAllActions()

	self.mCtlCards[1]:setPosition(pos1)
	self.mCtlCards[2]:setPosition(pos2)

	self.mCtlCards[1]:showFront()
	self.mCtlCards[2]:showFront()

	self.mCtlCards[1]:rotation(rotation1)
	self.mCtlCards[2]:rotation(rotation2)

	self.mCtlCards[1]:setVisible(true)
	self.mCtlCards[2]:setVisible(true)
end

function RoomScene:playDealCtlAnim()
	self:updateCtlCards()
	local time = 0.8
	local pos1 = cc.p(self.mControlCard1Handler:getPosition())
	local pos2 = cc.p(self.mControlCard2Handler:getPosition())
	local rotation1 = self.mControlCard1Handler:getRotation()
	local rotation2 = self.mControlCard2Handler:getRotation()

	for i=1,2 do
		self.mCtlCards[i]:scale(1)
		self.mCtlCards[i]:setGray(false)
		self.mCtlCards[i]:setCascadeOpacityEnabled(true)
		self.mCtlCards[i]:showBack()
		self.mCtlCards[i]:rotation(100)
		self.mCtlCards[i]:setVisible(true)
	end

	self.mCtlCards[1]:setPosition(cc.pMidpoint(fold_pos,cc.pMidpoint(fold_pos,pos1)))
	self.mCtlCards[2]:setPosition(cc.pMidpoint(fold_pos,cc.pMidpoint(fold_pos,pos2)))

	transition.moveTo(self.mCtlCards[1], {
			x=pos1.x,
			y=pos1.y,
			time=time,
			easing="exponentialOut",
		})

	transition.moveTo(self.mCtlCards[2], {
			x=pos2.x,
			y=pos2.y,
			time=time,
			easing="exponentialOut",
		})

	transition.rotateTo(self.mCtlCards[1], {
			rotate=rotation1,
			time=time,
			easing="exponentialOut",
		})

	transition.rotateTo(self.mCtlCards[2], {
			rotate=rotation2,
			time=time,
			easing="exponentialOut",
		})

	self.mCtlCards[1]:performWithDelay(function()
			self.mCtlCards[1]:showAnim()
		end, time-0.4)

	self.mCtlCards[2]:performWithDelay(function()
			self.mCtlCards[2]:showAnim()
		end, time-0.4)
end

function RoomScene:playFlopAnim()
	for i=1,3 do
		if self.mPublicCards[i] then
			self.mPublicCards[i]:showAnim(true)
		end
	end
end

function RoomScene:playTurnAnim()
	if self.mPublicCards[4] then
		self.mPublicCards[4]:showAnim(true)
	end
end

function RoomScene:playRiverAnim()
	if self.mPublicCards[5] then
		self.mPublicCards[5]:showAnim(true)
	end
end

function RoomScene:playFoldAnim(seat_id)
	local epos = fold_pos
	local spos = cards_pos[self.mModel:s2v(seat_id)] or cc.p(0,0)
	tt.play_deal_cards(spos, cc.pMidpoint(spos,epos), 0.8, function()
				end):addTo(self.mRoot,zorder.anim)
end

function RoomScene:playRoundClearAnim()
	self:stopAllActionsByTag(anims_tags.round_clear_delay)
	self:performWithDelay( function()
		for id,betView in ipairs(self.mBetViews) do
			if betView:isVisible() then
				local spos = bet_pos[self.mModel:s2v(id)] or cc.p(0,0)
				local epos = fold_pos
				tt.play_coin_fly(spos,epos,0.2,function()
						if not tolua.isnull(betView) then
							betView:setVisible(false)
						end
					end):addTo(self.mRoot,zorder.anim)
			end
		end
	end,0.5):setTag(anims_tags.round_clear_delay)
end

function RoomScene:playGameOverAnim(pots)
	self:clearSelfBestCardsHint()

	function showWiners(id)
		local win_seats = {}
		local pot = pots[id]
		if pot then
			for _, winer in pairs(pot.winers) do 
				local seat = self.mSeatViews[winer.seatid]
				table.insert(win_seats,seat)
				self:onShowWinCardType(seat)
				local spos = potspos[id] or cc.p(0,0)
				local epos = bet_pos[self.mModel:s2v(winer.seatid)] or cc.p(0,0)
				seat:updateCoinLabel()
				self:performWithDelay(function()
						self.mPotViews[id]:setVisible(false)
						tt.play_coin_fly(spos,epos,0.4,function()
						end):addTo(self.mRoot,zorder.anim)
					end, 1)
			end
		end
		self:stopAllActionsByTag(anims_tags.show_win_anim)
		self:performWithDelay(function()
			self:clearWinShow(win_seats)
			if id > 1 then 
				showWiners(id-1) 
			else
				self:stopAllActionsByTag(anims_tags.show_win_anim)
				self:performWithDelay(function()
						self:stopAllActionsByTag(anims_tags.show_win_anim)
						self.mControler:autoBuyCoin()
						self:clearGameView()
					end, 1.5):setTag(anims_tags.show_win_anim)
			end
		end, 3):setTag(anims_tags.show_win_anim)
	end
	-- 先更新数据 后更新界面
	for id=1,#pots do
		local pot = pots[id]
		for _, winer in pairs(pot.winers) do 
			local seat = self.mSeatViews[winer.seatid]
			seat:winCoin(winer.coin)
		end
	end
	self:updateAddCoinBtn()
	showWiners(#pots)
end
--展示一个座位赢的时候的牌型和最好的牌
function RoomScene:onShowWinCardType(seat)
	--只有比牌的时候再需要亮牌
	if not seat.bestcards_ then
		return 
	end
	for _,v in pairs(self.mPublicCards) do 
		v:setGray(true)
		for _,c in pairs(seat.bestcards_) do
			if v.card_value_ == c then 
				v:setGray(false)
				v:winShow()
				break
			end
		end
	end
	-- print('------------',self.ctl_seat_,seat:getId())
	-- if seat:getId() == self.ctl_seat_ then
	-- 	print('+------------',self.ctl_seat_)
	-- 	for _,c in pairs(seat.bestcards_) do
	-- 		if self.ctl_card1_ and self.ctl_card1_.card_value_ == c then 
	-- 			self.ctl_card1_:winShow()
	-- 		elseif self.ctl_card2_ and self.ctl_card2_.card_value_ == c then 
	-- 			self.ctl_card2_:winShow()
	-- 		end
	-- 	end
	-- end
	seat:winShow()
end

--清理赢牌的高亮显示
function RoomScene:clearWinShow(seats)
	for k,v in pairs(self.mPublicCards) do 
		v:setGray(false)
		v:normal()
	end
	
	for _,v in pairs(seats) do 
		v:clearWinShow()
	end
end

function RoomScene:showSelfBestCardsHint(cardtype, bestcards)
	self:clearSelfBestCardsHint()

	-- for k,card in pairs(self.mPublicCards) do 
	-- 	card:setGray(true)
	-- end

	-- for _,ctlCard in pairs(self.mCtlCards) do
	-- 	ctlCard:setGray(true)
	-- end
	local kHighCard = 1
	local kOnePair = 2
	local kTwoPair = 3
	local kThreeKind = 4
	local kStraight = 5
	local kFlush = 6
	local kFullHouse = 7
	local kKingKong = 8
	local kFlushStraight = 9
	local kRoyalFlush = 10

	local tp_name = {
		"高牌",
		"一对",
		"二对",
		"三条",
		"顺子",
		"同花",
		"葫芦",
		"金刚",
		"同花顺",
		"皇家同花顺"
	}
	
	local showCards = {}
	if cardtype == kHighCard then 
		return
	elseif cardtype == kOnePair then
		for i=1,2 do
			table.insert(showCards,bestcards[i])
		end
	elseif cardtype == kTwoPair then
		for i=1,4 do
			table.insert(showCards,bestcards[i])
		end
	elseif cardtype == kThreeKind then
		for i=1,3 do
			table.insert(showCards,bestcards[i])
		end
	elseif cardtype == kKingKong then
		for i=1,4 do
			table.insert(showCards,bestcards[i])
		end
	else
		for i=1,5 do
			table.insert(showCards,bestcards[i])
		end
	end

	local seat_id = self.mModel:getCtlSeat()
	local seat = self:getSeatById(seat_id)
	local cards = {}
	if not tolua.isnull(seat) then
		cards = seat:getCardsView()
	end

	for _,c in pairs(showCards) do
		for k,card in pairs(self.mPublicCards) do 
			if card.card_value_ == c then 
				card:setGray(false)
				card:winShow()
			end
		end
		for _,ctlCard in pairs(self.mCtlCards) do
			if ctlCard.card_value_ == c then 
				ctlCard:setGray(false)
				ctlCard:winShow()
			end
		end

		for _,ctlCard in pairs(cards) do
			if ctlCard.card_value_ == c then 
				ctlCard:setGray(false)
				ctlCard:winShow()
			end
		end
	end
end

function RoomScene:clearSelfBestCardsHint()
	for k,v in pairs(self.mPublicCards) do 
		v:setGray(false)
		v:normal()
	end

	for _,ctlCard in pairs(self.mCtlCards) do
		ctlCard:setGray(false)
		ctlCard:normal()
	end

	local seat_id = self.mModel:getCtlSeat()
	local seat = self:getSeatById(seat_id)
	local cards = {}
	if not tolua.isnull(seat) then
		cards = seat:getCardsView()
	end

	for _,ctlCard in pairs(cards) do
		ctlCard:setGray(false)
		ctlCard:normal()
	end

end

function RoomScene:updateProgress(per)
	local view = self.mVipExpProgress
	view:clear()
	self.mVipPercentage = per
	local left,right,radius = -72,75.5,35
	local offsetl = right-left
	local length = offsetl*2+math.pi*radius
	local curlength = length*per/100
	print("updateVipView",per)
	if curlength >= offsetl then
		local pts1 = {
		    cc.p(right, 0),  -- point 1
		    cc.p(right, -radius),  -- point 1
		    cc.p(left, -radius),  -- point 2
		    cc.p(left, 0),  -- point 2
		}
		view:drawPolygon(pts1, {
	        fillColor = cc.c4f(1, 1, 1, 1),
	        borderWidth = 0,
	        borderColor = cc.c4f(1, 1, 1, 1)
	    })
	else
		local pts1 = {
		    cc.p(right, 0),  -- point 1
		    cc.p(right, -radius),  -- point 1
		    cc.p(right-curlength, -radius),  -- point 2
		    cc.p(right-curlength, 0),  -- point 2
		}
		view:drawPolygon(pts1, {
	        fillColor = cc.c4f(1, 1, 1, 1),
	        borderWidth = 0,
	        borderColor = cc.c4f(1, 1, 1, 1)
	    }) 
	end

	if curlength >= offsetl+math.pi*radius then
		local pts2 = tt.makePoint(left, 0,radius,-90,-270,100)
		table.insert(pts2,1,{left,0})
	    display.newPolygon(pts2, {
	        fillColor = cc.c4f(1, 1, 1, 1),
	        borderWidth = 0,
	        borderColor = cc.c4f(1, 1, 1, 1)
	    }, view)
	elseif curlength >= offsetl then
		local tl = curlength - offsetl
		local pp = tl/(math.pi*radius)
		local pts2 = tt.makePoint(left, 0,radius,-90,-90-pp*180,100)
		table.insert(pts2,1,{left,0})
	    display.newPolygon(pts2, {
	        fillColor = cc.c4f(1, 1, 1, 1),
	        borderWidth = 0,
	        borderColor = cc.c4f(1, 1, 1, 1)
	    }, view)
	end

	if curlength >= offsetl*2+math.pi*radius then
		local pts3 = {
		    cc.p(left, 0),  -- point 1
		    cc.p(left, radius),  -- point 1
		    cc.p(right, radius),  -- point 2
		    cc.p(right, 0),  -- point 2
		}
		view:drawPolygon(pts3, {
	        fillColor = cc.c4f(1, 1, 1, 1),
	        borderWidth = 0,
	        borderColor = cc.c4f(1, 1, 1, 1)
	    })
	elseif curlength >= offsetl+math.pi*radius then
		local tl = curlength - offsetl-math.pi*radius
		local pts3 = {
		    cc.p(left, 0),  -- point 1
		    cc.p(left, radius),  -- point 1
		    cc.p(left+tl, radius),  -- point 2
		    cc.p(left+tl, 0),  -- point 2
		}
		view:drawPolygon(pts3, {
	        fillColor = cc.c4f(1, 1, 1, 1),
	        borderWidth = 0,
	        borderColor = cc.c4f(1, 1, 1, 1)
	    })
	end
end

function RoomScene:showPrizeCenterView()
	if tt.nativeData.isVipShopLock() then return end

	if not tolua.isnull(self.mPrizeCenterView) then
		self.mPrizeCenterView:removeSelf()
	end
	self.mPrizeCenterView = app:createView("PrizeCenterView", self)
		:addTo(self.mRoot,zorder.dialog)
	self.mPrizeCenterView:show()
end

function RoomScene:onHttpVstore(data)
	if not tolua.isnull(self.mPrizeCenterView) then
		self.mPrizeCenterView:initMenuView(data)
	end
end

function RoomScene:onHttpExchange(data)
	if not tolua.isnull(self.mPrizeCenterView) then
		self.mPrizeCenterView:onExchange(data)
	end
end

function RoomScene:showMatchInfoDialog()
	local roonType = self.mModel:getRoomType()
	if roonType == 2 then
		local data = tt.nativeData.getSngInfo(self.mModel:getLv())
		if not data then 
			tt.gsocket.request("sng.mlv_info",{mlv=self.mModel:getLv()})
			return
		end
		if not tolua.isnull(self.mMatchInfoDialog) then
			self.mMatchInfoDialog:dismiss()
		end
		self.mMatchInfoDialog = app:createView("MatchInfoDialog",self,data):addTo(self.mRoot,zorder.dialog)
		self.mMatchInfoDialog:setInRoom(true)
		self.mMatchInfoDialog:setMatchId(self.match_id_,2) -- 2 進行中
		self.mMatchInfoDialog:show()
	elseif roonType == 3 then
		local match_id = self.mModel:getMatchId()
		if match_id == 0 then return end
		local data = tt.nativeData.getMttInfo(match_id)
		if not data then 
			tt.gsocket.request("mtt.match_info",{
				match_id = match_id,    --比赛id
			})
			return
		end
		if not tolua.isnull(self.mMatchInfoDialog) then
			self.mMatchInfoDialog:dismiss()
		end
		self.mMatchInfoDialog = app:createView("MttMatchInfoDialog",self,data):addTo(self.mRoot,zorder.dialog)
		self.mMatchInfoDialog:setInRoom(true)
		self.mMatchInfoDialog:show()
	end
end

-- star_small
-- xingxing
function RoomScene:showUpVipLvAnim(lv)
	self:performWithDelay(function()
		 --    local star = display.newSprite("dec/star_small.png")
		 --    local size = self.mVipView:getContentSize()
		 --    star:addTo(self.mVipView)
		 --    star:setPosition(cc.p(-60,-20))
		 --    local actions = {
		 --    	cc.MoveBy:create(1, cc.p(160,0)),
		 --    	cc.RotateBy:create(0.5, 360),
		 --    	cc.JumpTo:create(1, cc.p(-60,10), 20, 1),
			-- }
		 --    local sequence = transition.sequence(actions)
		 --    star:runAction(sequence)
		 --    star:schedule(function ()
		 --    		local x,y = star:getPosition()
		 --    		local num = 6
		 --    		for i=1,num do
		 --    			local sstar = display.newSprite("dec/xingxing.png")
		 --    			local scale = math.random(0.7,1)
		 --    			local offsetX = math.random(-5,5)
		 --    			local offsetY = math.random(-5,5)
		 --    			local delay = 0.8
		 --    			sstar:addTo(self.mVipView)
		 --    			sstar:setPosition(cc.p(x+offsetX,y+offsetY))
		 --    			sstar:scale(scale)
		 --    			sstar:scaleTo(delay, 0)
		 --    			sstar:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5, 360)))
		 --    			sstar:performWithDelay(function()
			-- 	    		sstar:removeSelf()
			-- 	    	end, delay)
		 --    		end

		 --    	end, 1/30)
		    -- star:performWithDelay(function()
		    -- 		star:removeSelf()
					self:updateProgress(0)
		    		self:updateVipView()
		    	-- end, 2.5)
		end, 1)
end

function RoomScene:showSpeaker(str)
	if not self.mSpeakerView then
		self.mSpeakerView = app:createView("SpeakerView",self)
			:align(display.CENTER,640,580)
			:addTo(self.mRoot,zorder.ui)
	end
	self.mSpeakerView:show(str)
end

function RoomScene:updateVipView()
	self:addVipScoreAnim()
	local lv = tt.owner:getVipLv()

	local lv_info = tt.game_data.vip_info[lv]
	local pre_exp = tt.game_data.vip_info[lv-1] and tt.game_data.vip_info[lv-1].exp or 0
	local exp = tt.owner:getVipExp()
	local percentage = (exp-pre_exp)*100/(lv_info.exp-pre_exp)
	if percentage < 0 then percentage = 0 end
	if percentage > 100 then percentage = 100 end
    self:addVipExpAnim(percentage)
    self.mVipIcon:setTexture(string.format("dec/icon_vip".. lv .. ".png"))
end

function RoomScene:addVipExpAnim(percentage)
	self:stopAllActionsByTag(anims_tags.vip_anim)
	local diff = percentage - self.mVipPercentage
	local add = diff / 30
	local start = self.mVipPercentage
	self:schedule(function()
			start = start + add
			print(start,percentage)
			self:updateProgress(start)
			if math.abs(start - percentage) < 1 then
				self:updateProgress(percentage)
				self:stopAllActionsByTag(anims_tags.vip_anim)
			end
		end,1/30):setTag(anims_tags.vip_anim)
end

function RoomScene:addVipScoreAnim()
	if self.mCurVipScore == tt.owner:getVipScore() then return end
	self.mVipTxt:stopAllActions()
	self.mVipTxt:schedule(function()
			local score = tt.owner:getVipScore()
    		local offset = score - self.mCurVipScore
    		self.mCurVipScore = self.mCurVipScore + math.ceil(offset * 0.9)
    		self.mVipTxt:setString(tt.getNumStr(self.mCurVipScore))
    		if self.mCurVipScore == score then
    			self.mVipTxt:stopAllActions()
    			return
    		end
		end,1/30)
end

function RoomScene:showMatchResultView(data,type_str)
	tt.play.play_sound("match_result")
	local view = app:createView("MatchResultView",self,data,type_str)
	view:addTo(self.mRoot,zorder.dialog)
	view:show()
	view:setBackEvent(function() return true end)
end

function RoomScene:showChooseDialog(str,cancelClick,confirmClick)
	local view = app:createView("ChooseDialog")
	view:addTo(self.mRoot,zorder.dialog)
	view:setContentStr(str)
	view:setOnCancelClick(cancelClick)
	view:setOnConfirmClick(confirmClick)
	view:show()
	return view
end

function RoomScene:showMatchWaitAnim(time)
	if not self.mMatchWaitAnimView then
		self.mMatchWaitAnimView = display.newSprite("bg/countdown_bg.png")
		self.mMatchWaitAnimView:addTo(self.mRoot,zorder.table)
		self.mMatchWaitAnimView:setPosition(cc.p(630,420))
		local clip = display.newClippingRectangleNode(cc.rect(28, 28, 120, 68))
		clip:addTo(self.mMatchWaitAnimView)
		self.mMatchWaitAnimView.num = {}
		self.mMatchWaitAnimView.num[1] = {}
		self.mMatchWaitAnimView.num[2] = {}
		for i=1,2 do
			local sprite = display.newSprite("number/countdown_1.png")
			sprite:addTo(clip)
			table.insert(self.mMatchWaitAnimView.num[1],sprite)
			local sprite = display.newSprite("number/countdown_1.png")
			sprite:addTo(clip)
			table.insert(self.mMatchWaitAnimView.num[2],sprite)
		end

		local x1 = 46
		local x2 = 114

		local y1 = 62
		local y2 = 150


		self.mMatchWaitAnimView.countDownTime = 0
		self.mMatchWaitAnimView.startCountDown = function(self,time)
			self.countDownTime = tonumber(time) or 0
			local a = self.countDownTime % 10
			local b = ( self.countDownTime % 100 - a ) / 10

			local flag = b % 2		

			local num1 = 1 + flag 
			local num2 = (1+flag)%2+1
			self.num[1][num1]:setPosition(cc.p(x1,y1))
			self.num[1][num2]:setPosition(cc.p(x1,y2))
			self.num[1][num1]:setTexture(string.format("number/countdown_%d.png",b))


			local flag = a % 2		

			local num1 = 1 + flag 
			local num2 = (1+flag)%2+1
			self.num[2][num1]:setPosition(cc.p(x2,y1))
			self.num[2][num2]:setPosition(cc.p(x2,y2))
			self.num[2][num1]:setTexture(string.format("number/countdown_%d.png",a))


			self:stopAllActions()
			transition.scaleTo(self, {scaleX = 1, time = 0.2})
			self:performWithDelay(handler(self, self.onCountDown), 1)
		end


		self.mMatchWaitAnimView.onCountDown = function(self)
			if self.countDownTime <= 0 then return end
			self.countDownTime = self.countDownTime - 1

			local a = self.countDownTime % 10
			local b = ( self.countDownTime % 100 - a ) / 10

			local flag = (a+1) % 2			
			local num1 = 1 + flag 
			local num2 = (1+flag)%2+1
			self.num[2][num1]:setPosition(cc.p(x2,y1))
			self.num[2][num2]:setPosition(cc.p(x2,y2))

			self.num[2][num2]:setTexture(string.format("number/countdown_%d.png",a))
			
			transition.moveBy(self.num[2][num1],{y = y1-y2, time = 0.5})
			transition.moveBy(self.num[2][num2],{y = y1-y2, time = 0.5})
			if a == 9 then

				local flag = (b+1) % 2			
				local num1 = 1 + flag 
				local num2 = (1+flag)%2+1

				self.num[1][num1]:setPosition(cc.p(x1,y1))
				self.num[1][num2]:setPosition(cc.p(x1,y2))
				self.num[1][num2]:setTexture(string.format("number/countdown_%d.png",b))

				transition.moveBy(self.num[1][num1],{y = y1-y2, time = 0.5})
				transition.moveBy(self.num[1][num2],{y = y1-y2, time = 0.5})
			end

			self:performWithDelay(handler(self, self.onCountDown), 1)
		end
	end

	self.mMatchWaitAnimView:setVisible(true)
	self.mMatchWaitAnimView:startCountDown(time)
end

function RoomScene:dismissMatchWaitAnim()
	if self.mMatchWaitAnimView then
		self.mMatchWaitAnimView:stopAllActions()
		self.mMatchWaitAnimView:setVisible(false)
	end
end

function RoomScene:payGoods(goods)
	printInfo("shop pmode[%d] price[%s] coin[%d] pid[%s]",goods.pmode, goods.price,goods.coin, goods.pid)
	tt.ghttp.request(tt.cmd.order,{pmode=goods.pmode,pid = goods.pid})
end

function RoomScene:playEmoticon(seat_id,id)
	if id < 1 or id > 4 then return end
	if not self.mSeatViews[seat_id] then return end
	local emoticon = app:createView("Emoticon", "emoticon/emoticon_" .. id .. ".csb")
	local size = self.mSeatViews[seat_id]:getContentSize()
	emoticon:setPosition(cc.p(size.width/2-3,size.height/2+10))
	emoticon:addTo(self.mSeatViews[seat_id])
	emoticon:play()
	emoticon:performWithDelay(function(self)
				emoticon:removeSelf()
			end, 2)
end

function RoomScene:playExpression(id,seat_id_src,seat_id_des)
	local size = self.mSeatViews[seat_id_src]:getContentSize()
	local pos_src = cc.pAdd(seat_pos[self.mModel:s2v(seat_id_src)],cc.p(size.width/2,size.height/2)) 
	local pos_des = cc.pAdd(seat_pos[self.mModel:s2v(seat_id_des)],cc.p(size.width/2,size.height/2)) 
	local expression = Expression.createExpression(id,pos_src,pos_des)
	if not expression then return end
	expression:play()
	expression:addTo(self.mRoot,zorder.anim)
	expression:performWithDelay(function(self)
				expression:removeSelf()
			end, expression:getPlayTime())
end

function RoomScene:updateMyRank(rank,remaining)
	self.mRankTxt:setString( tt.gettext("我的排名:{s1}/{s2}",rank,remaining))
end

function RoomScene:updateBlindInfoView(downtime,sb,bb,ante)
	local downtime = downtime or 0
	local sb = sb or 0
	local bb = bb or 0
	local ante = ante or 0
	local str = ""
	if downtime > 0 then
		str = tt.gettext("{s1}分钟内涨盲:{s2}/{s3}",math.ceil(downtime/60),tt.getNumStr(sb),tt.getNumStr(bb))
		-- self.m_blind_txt:setVisible(true)
	else
		str = tt.gettext("-分钟内涨盲:{s1}/{s2}",tt.getNumStr(sb),tt.getNumStr(bb))
		-- self.m_blind_txt:setVisible(false )
	end

	self.mBlindTxt:setString(str)

	if ante > 0 then
		self.mBlindTxt0:setString(tt.gettext("前注:{s1}",tt.getNumStr(ante)))
	else
		self.mBlindTxt0:setString("")
	end
end

function RoomScene:updateCashInfoView(name,sb,bb,ante)
	if name then
		cc.uiloader:seekNodeByName(self.mCashInfoHandler,"cash_name_txt"):setString(name)
	end

	local blind_txt = cc.uiloader:seekNodeByName(self.mCashInfoHandler,"cash_blind_txt")
	blind_txt:setString(string.format("%s/%s",tt.getNumShortStr(sb),tt.getNumShortStr(bb)))

	local ante_txt = cc.uiloader:seekNodeByName(self.mCashInfoHandler,"cash_ante_txt")
	local ante_pre = cc.uiloader:seekNodeByName(self.mCashInfoHandler,"cash_ante_pre_txt")
	if ante > 0 then
		ante_txt:setString(tt.getNumShortStr(ante))
		ante_pre:setString(tt.gettext("前注:"))
		local size = ante_txt:getContentSize()
		local x,y = ante_txt:getPosition()
		ante_txt:setVisible(true)
		ante_pre:setVisible(true)
		ante_pre:setPosition(cc.p(x-size.width,y))

		local size2 = ante_pre:getContentSize()
		blind_txt:setPosition(cc.p(x-size.width-size2.width-10,y))
	else
		local x,y = ante_txt:getPosition()
		ante_txt:setVisible(false)
		ante_pre:setVisible(false)
		blind_txt:setPosition(cc.p(x,y))
	end
end

function RoomScene:showSettingView()
	local settingView = app:createView("SettingView", self)
		:addTo(self.mRoot,zorder.dialog)
	settingView:setIsChangeLogout(false)
	settingView:show()
end

function RoomScene:showUserInfoDialog(player)
	local roomUserinfoDialog = app:createView("RoomUserinfoDialog", self)
		:addTo(self.mRoot,zorder.dialog)
	roomUserinfoDialog:setUserinfo(player)
	roomUserinfoDialog:show()
end

function RoomScene:showBlindTips(sb,bb,ante)
	tt.play.play_sound("up_bilnd")

	local node = display.newNode()
	local content = display.newScale9Sprite("bg/bg_blind_tip.png",0,0,cc.size(52,28),cc.rect(12, 7,2, 2))

	local bilnd_txt = display.newTTFLabel({
            text = tt.gettext("盲注:"),
            size = 43,
            color=cc.c3b(0xff,0xff,0xff),
        })

	local bilnd_num = display.newTTFLabel({
            text = string.format("%s/%s",tt.getNumShortStr(sb),tt.getNumShortStr(bb)),
            size = 43,
            color=cc.c3b(0xee,0xd6,0x0c),
        })

	tt.linearlayout(node,bilnd_txt)
	tt.linearlayout(node,bilnd_num)

	if ante > 0 then
		local ante_txt = display.newTTFLabel({
            text = tt.gettext("前注:"),
            size = 43,
            color=cc.c3b(0xff,0xff,0xff),
        })
        local ante_num = display.newTTFLabel({
            text = tt.getNumShortStr(ante),
            size = 43,
            color=cc.c3b(0xee,0xd6,0x0c),
        })
		tt.linearlayout(node,ante_txt,10)
		tt.linearlayout(node,ante_num)
    end
    node:addTo(content)
	local size = node:getContentSize()
	local n_h = bilnd_txt:getContentSize().height
	local w = math.max(size.width+40,24)
	local h = 70
	node:setPosition(cc.p(w/2-size.width/2,h/2-n_h/2))

	content:setPosition(cc.p(640,300))
	content:setContentSize(w,h)
	content:addTo(self.mRoot,zorder.dialog)
	content:performWithDelay(function()
			if not tolua.isnull(content) then
				content:removeSelf()
			end
		end, 3)
end

function RoomScene:showTouzhuGameDialog()
	if not tolua.isnull(self.mTouzhuGameDialog) then
		self.mTouzhuGameDialog:removeSelf()
	end
	self.mTouzhuGameDialog = app:createView("TouzhuGameRoomView",self)
		:addTo(self.mRoot,zorder.dialog)
	self.mTouzhuGameDialog:show()
end

function RoomScene:showTouzhuRandomView()
	if not tolua.isnull(self.mTouzhuRandomView) then
		self.mTouzhuRandomView:removeSelf()
	end
	self.mTouzhuRandomView = app:createView("TouzhuRandomView",self)
		:addTo(self.mRoot,zorder.dialog)
	self.mTouzhuRandomView:setTouzhuGameView(self.mTouzhuGameDialog)
	self.mTouzhuRandomView:show()
end

function RoomScene:showTouzhuExchangeView()
	if not tolua.isnull(self.mTouzhuExchangeView) then
		self.mTouzhuExchangeView:removeSelf()
	end
	self.mTouzhuExchangeView = app:createView("TouzhuExchangeView",self)
		:addTo(self.mRoot,zorder.dialog)
	self.mTouzhuExchangeView:show()
end

function RoomScene:showTouzhuRuleView()
	if not tolua.isnull(self.mTouzhuRuleView) then
		self.mTouzhuRuleView:removeSelf()
	end
	self.mTouzhuRuleView = app:createView("TouzhuRuleView",self)
		:addTo(self.mRoot,zorder.dialog)
	self.mTouzhuRuleView:show()
end

function RoomScene:showTouzhuHistoryView()
	if not tolua.isnull(self.mTouzhuHistoryView) then
		self.mTouzhuHistoryView:removeSelf()
	end
	self.mTouzhuHistoryView = app:createView("TouzhuHistoryView",self)
		:addTo(self.mRoot,zorder.dialog)
	self.mTouzhuHistoryView:show()
end

function RoomScene:showTouzhuWinningDialog(score)
	if not tolua.isnull(self.mTouzhuWinningDialog) then
		self.mTouzhuWinningDialog:removeSelf()
	end
	self.mTouzhuWinningDialog = app:createView("TouzhuWinningDialog",self)
		:addTo(self.mRoot,zorder.dialog)
	self.mTouzhuWinningDialog:setScore(score)
	self.mTouzhuWinningDialog:show()
end

function RoomScene:showBuyChipsDialog()
	local config = tt.nativeData.getCustomConfig()
	if not config then
		local config = tt.nativeData.getCustomConfig()
		tt.gsocket.request("custom.config",{
				ver = config.ver or 0,
			})
		return 
	end
	if not tolua.isnull(self.mBuyChipsDialog) then
		self.mBuyChipsDialog:removeSelf()
	end
	self.mBuyChipsDialog = app:createView("BuyChipsDialog",self)
		:addTo(self.mRoot,zorder.dialog)
	local params = self.mModel:getCustomRoomParams()
	local chipsConfig = {}
	for _,chips in ipairs(config.buyin) do
		if chips >= params.min_buy and chips <= params.max_buy then
			table.insert(chipsConfig,chips*params.sb*2)
		end
	end
	dump(chipsConfig,"showBuyChipsDialog")
	self.mBuyChipsDialog:setConfig(chipsConfig)
	self.mBuyChipsDialog:setBlindInfo(params.sb,params.ante)
	self.mBuyChipsDialog:show()
end

function RoomScene:showCustomRoomDialog()
	local params = self.mModel:getCustomRoomParams()
	if not params.roomid then return end

	if params.ownerid == tt.owner:getUid() then
		if not tolua.isnull(self.mCustomMasterDialog) then
			self.mCustomMasterDialog:removeSelf()
		end
		self.mCustomMasterDialog = app:createView("CustomMasterDialog",self,params)
			:addTo(self.mRoot,zorder.dialog)
		self.mCustomMasterDialog:show()
	else
		if not tolua.isnull(self.mCustomGuestDialog) then
			self.mCustomGuestDialog:removeSelf()
		end
		self.mCustomGuestDialog = app:createView("CustomGuestDialog",self)
			:addTo(self.mRoot,zorder.dialog)
		self.mCustomGuestDialog:setRoomName(params.name)
		self.mCustomGuestDialog:setNameView(params.owner_name,params.roomid)
		self.mCustomGuestDialog:setCreateTime(params.create_time)
		self.mCustomGuestDialog:setTime(params.left_time,params.ttime)
		self.mCustomGuestDialog:setBlindInfo(params.sb,params.ante)
		self.mCustomGuestDialog:setBuyin(params.min_buy,params.max_buy)
		self.mCustomGuestDialog:setDec(params.msg)
		self.mCustomGuestDialog:setPlayerNum(params.seat)

		self.mCustomGuestDialog:show()
	end
	
end

function RoomScene:showCustomOverDialog(data)
	if not tolua.isnull(self.mCustomOverDialog) then
		self.mCustomOverDialog:removeSelf()
	end
	self.mCustomOverDialog = app:createView("CustomOverDialog",self,data)
		:addTo(self.mRoot,zorder.dialog)
	self.mCustomOverDialog:show()
end

function RoomScene:showRoomShareView()
	if not tolua.isnull(self.mRoomShareView) then
		self.mRoomShareView:removeSelf()
	end
	self.mRoomShareView = app:createView("RoomShareView",self)
		:addTo(self.mRoot,zorder.dialog)
	self.mRoomShareView:show()
end

function RoomScene:showShopDialog(index)
	if not tolua.isnull(self.mShopPopups) then
		self.mShopPopups:removeSelf()
	end
	self.mShopPopups = app:createView("ShopPopups", self)
		:addTo(self.mRoot,zorder.dialog)
	self.mShopPopups:show()
	if index then
		self.mShopPopups:selectShowType(index)
	end
end

function RoomScene:showSpeakerEditDialog()
	if not tolua.isnull(self.mSpeakerEditDialog) then
		self.mSpeakerEditDialog:removeSelf()
	end
	self.mSpeakerEditDialog = app:createView("SpeakerEditDialog", self):addTo(self.mRoot,zorder.dialog)
	self.mSpeakerEditDialog:show()
end

function RoomScene:showVpDialog()
	if not tolua.isnull(self.mVpDialog) then
		self.mVpDialog:removeSelf()
	end
	self.mVpDialog = app:createView("VpDialog",self):addTo(self.mRoot,zorder.dialog)
	self.mVpDialog:show()
end

function RoomScene:startCustomCountdown(left_time)
	local countdown_txt = cc.uiloader:seekNodeByName(self.mCustomRoomBtn,"countdown_txt")
	local endTime = os.time() + left_time
	local update = function()
			local countdown = endTime - os.time()
			if countdown < 0 then countdown = 0 end
			if countdown > 60 then
				countdown_txt:setColor(cc.c3b(0x21, 0x21, 0x21))
			else
				countdown_txt:setColor(cc.c3b(0xd2, 0x21, 0x21))
			end
			countdown_txt:setString(os.date("!%H:%M:%S",countdown))
			if countdown == 0 then 
				countdown_txt:stopAllActions()
				return
			end
		end
	countdown_txt:stopAllActions()
	update()
	countdown_txt:schedule(function()
			update()
		end, 1)
end

function RoomScene:resetConfig(num)
	if num <= 3 then
		seat_pos = {[1] = cc.p(1048,446),[2] = cc.p(523,113),[3] = cc.p(107,443)}
		--dealer 9 个位置
		dpos = {[1] = cc.p(1056,435),[2] = cc.p(670,209),[3] = cc.p(212,428)}
        --每个玩家下注的位置
	 	bet_pos = {[1] = cc.p(1015,446),[2] = cc.p(646,253),[3] = cc.p(263,438)}
        --100-15每个玩家获得筹码的位置
		head_pos = {[1] = cc.p(1117,516),[2] = cc.p(597,189),[3] = cc.p(178,518)}
        --每个玩家发牌的位置
		cards_pos = {[1] = cc.p(1117,516),[2] = cc.p(597,189),[3] = cc.p(178,518)}
        --奖池的位置 --- 4
        potspos = {[1] = cc.p(452,313),[2] = cc.p(591,312)}
		self.mModel:setDefaultCtl(2)
	elseif num <= 6 then
		seat_pos = {[1] = cc.p(568,559),[2] = cc.p(1025,474),[3] = cc.p(1054,244),
		[4] = cc.p(522,111),[5] = cc.p(87,243),[6] = cc.p(114,474)}

		--dealer 9 个位置
		dpos = {[1] = cc.p(725,600),[2] = cc.p(1054,461),[3] = cc.p(1026,291),
		[4] = cc.p(671,209),[5] = cc.p(265,279),[6] = cc.p(224,458)}

        --每个玩家下注的位置
	 	bet_pos = {[1] = cc.p(755,572),[2] = cc.p(1010,461),[3] = cc.p(981,307),
	 	[4] = cc.p(647,253),[5] = cc.p(302,301),[6] = cc.p(267,453)}

        --100-15每个玩家获得筹码的位置
		head_pos = {[1] = cc.p(638,633),[2] = cc.p(1094,554),[3] = cc.p(1121,320),
		[4] = cc.p(499,190),[5] = cc.p(151,320),[6] = cc.p(183,553)}

        --每个玩家发牌的位置
		cards_pos = {[1] = cc.p(638,633),[2] = cc.p(1094,554),[3] = cc.p(1121,320),
		[4] = cc.p(499,190),[5] = cc.p(151,320),[6] = cc.p(183,553)}

        --奖池的位置 --- 4
        potspos = {[1] = cc.p(452,313),[2] = cc.p(591,312),[3] = cc.p(733,312),[4] = cc.p(451,485),
    	[5] = cc.p(591,485)}
		self.mModel:setDefaultCtl(4)
	else
		seat_pos = {[1] = cc.p(713,560),[2] = cc.p(1043,454),[3] = cc.p(1064,279),[4] = cc.p(957,129),
			[5] = cc.p(523,110),[6] = cc.p(163,137),[7] = cc.p(77,280),[8] = cc.p(102,455),[9] = cc.p(407,558)}

		--dealer 9 个位置
		dpos = {[1] = cc.p(875,597),[2] = cc.p(1059,444),[3] = cc.p(1039,312),[4] = cc.p(940,223),
			[5] = cc.p(669,209),[6] = cc.p(313,234),[7] = cc.p(235,320),[8] = cc.p(220,439),[9] = cc.p(386,599)}

        --每个玩家下注的位置
	 	bet_pos = {[1] = cc.p(870,559),[2] = cc.p(1013,443),[3] = cc.p(1005,339),[4] = cc.p(916,259),
			[5] = cc.p(646,253),[6] = cc.p(344,267),[7] = cc.p(281,330),[8] = cc.p(260,424),[9] = cc.p(367,551)}

        --100-15每个玩家获得筹码的位置
		head_pos = {[1] = cc.p(779,636),[2] = cc.p(1111,526),[3] = cc.p(1129,360),[4] = cc.p(1025,208),
			[5] = cc.p(595,190),[6] = cc.p(229,218),[7] = cc.p(145,358),[8] = cc.p(169,528),[9] = cc.p(477,634)}

        --每个玩家发牌的位置
		cards_pos = {[1] = cc.p(779,636),[2] = cc.p(1111,526),[3] = cc.p(1129,360),[4] = cc.p(1025,208),
			[5] = cc.p(595,190),[6] = cc.p(229,218),[7] = cc.p(145,358),[8] = cc.p(169,528),[9] = cc.p(477,634)}

        --奖池的位置 --- 4
        potspos = {[1] = cc.p(452,313),[2] = cc.p(591,312),[3] = cc.p(733,312),[4] = cc.p(451,485),
    	[5] = cc.p(591,485),[6] = cc.p(734,485),[7] = cc.p(903,411),[8] = cc.p(377,411)}
		self.mModel:setDefaultCtl(5)
	end
end


return RoomScene
