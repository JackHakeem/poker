--
-- Author: bearluo
-- Date: 2017-05-27
--

local PropDataHelper = require("app.libs.PropDataHelper")
local BLDialog = require("app.ui.BLDialog")
local net = require("framework.cc.net.init")
local MttMatchInfoDialog = class("MttMatchInfoDialog", function()
	return BLDialog.new()
end)

local TAG = "MttMatchInfoDialog"
local net = require("framework.cc.net.init")
local scheduler = require("framework.scheduler")
local LocalNotication = require("app.libs.LocalNotication")

function MttMatchInfoDialog:ctor(control,matchData)
	self:setNodeEventEnabled(true)
	self.control_ = control 
	dump(matchData)
	local node, width, height = cc.uiloader:load("mtt_match_info_dialog.json")
	self:addChild(node)
	self.root_ = node
	self.mData = matchData
	self.mHandlers = {}
	self:setContentSize(cc.size(width,height))

	self.back_btn = cc.uiloader:seekNodeByName(node,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	-- display.newColorLayer(cc.c4b(16/255,24/255,42/255,60)):addTo(self,-1)

	self:setVisible(false)

	self.mSignNumBg = cc.uiloader:seekNodeByName(node, "sign_num_bg")
	self.mSignNumBg:setVisible(false)

	-- info view
	self.info_view_ = {}
	self.info_view = cc.uiloader:seekNodeByName(node, "info_view")


	cc.uiloader:seekNodeByName(self.info_view, "Label_40"):setString(tt.gettext("名次"))
	cc.uiloader:seekNodeByName(self.info_view, "Label_40_0"):setString(tt.gettext("獎勵"))


	self.info_view_.rank_reward_list = cc.uiloader:seekNodeByName(self.info_view, "rank_reward_list")

	-- self.info_view_.sign_view_ = {}
	-- self.info_view_.sign_view = cc.uiloader:seekNodeByName(self.info_view, "sign_view")
	self.info_view_.match_info_list = cc.uiloader:seekNodeByName(self.info_view, "match_info_list")
	-- self.info_view_.match_info_list = display.newScale9Sprite(params.scrollbarImgH, 100):addTo(self)

	self.info_view_.sign_cost_info = cc.uiloader:seekNodeByName(self.info_view, "sign_cost_info")
	self.info_view_.sign_cost_info:setVisible(false)
	self.info_view_.cost_btn = {}
	self.info_view_.cost_btn_info = {}
	for i=1,3 do
		self.info_view_.cost_btn[i] = cc.uiloader:seekNodeByName(self.info_view, "cost_btn_"..i)
		self.info_view_.cost_btn[i]:setVisible(false)
		self.info_view_.cost_btn[i]:onButtonClicked(function()
				for j=1,3 do
					if i == j then
						self.info_view_.cost_btn[j]:setButtonEnabled(false)
						self.mSignCostIndex = j
					else
						self.info_view_.cost_btn[j]:setButtonEnabled(true)
					end
				end
			end)
		self.info_view_.cost_btn_info[i] = {}
	end

	self.info_view_.sign_info_bg = cc.uiloader:seekNodeByName(self.info_view, "sign_info_bg")
	self.info_view_.running_info_bg = cc.uiloader:seekNodeByName(self.info_view, "running_info_bg")
	self.info_view_.running_info_list = cc.uiloader:seekNodeByName(self.info_view, "running_info_list")

	self.info_view_.push_btn = cc.uiloader:seekNodeByName(self.info_view, "push_btn")
		:onButtonClicked(function()
				local stime,jtime,atime = self.mData.stime,self.mData.jtime,self.mData.atime
				local ok,ret = tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.isNotificationEnabled)
				if ok and ret == 1 then
					local id = LocalNotication.addLocalNotication(self.mData.mname or "Tips",tt.gettext("已为您设置按时提醒，当比赛开放报名时会发送提醒信息，请留意查看！"),stime - atime)
					if id then
						LocalNotication.saveMatchNoticationId(self.mData.match_id,id,stime - atime)
						self:refreshSignView()
						tt.show_msg(tt.gettext("提醒添加成功!"))
					else
						tt.show_msg(tt.gettext("提醒添加失败,稍后再试!"))
					end
				else
					self.control_:showPushSetDialog()
				end
			end)
	self.info_view_.sign_btn = cc.uiloader:seekNodeByName(self.info_view, "sign_btn")
		:onButtonClicked(function()
				self.info_view_.sign_btn:setTouchEnabled(false)
				self.info_view_.sign_btn:performWithDelay(function()
						if tolua.isnull(self.info_view_.sign_btn) then return end
						self.info_view_.sign_btn:setTouchEnabled(true)
					end, 1)
				tt.play.play_sound("click")
				if self.mSignCostIndex ~= 0 then
					self.control_:signMttMatch(self.mData.mlv,self.mData.match_id,self.info_view_.cost_btn_info[self.mSignCostIndex].etype,self.info_view_.cost_btn_info[self.mSignCostIndex].num)
				else
					if #self.mData.entry > 0 then
						-- 如果报名费为0 self.mSignCostIndex 肯定不为0
						if self.mMoneySignCost ~= 0 then
							local goods = tt.getSuitableGoodsByMoney(self.mMoneySignCost-tt.owner:getMoney())
							if goods then
								self.control_:showRecommendGoodsDialog(goods)
							else
								tt.show_msg(tt.gettext("筹码不足"))
							end
							self:dismiss()
						else
							tt.show_msg(tt.gettext("报名费用不足"))
						end
					else
						self.control_:signMttMatch(self.mData.mlv,self.mData.match_id,0,0)
					end
				end
			end)
	self.info_view_.unsign_btn = cc.uiloader:seekNodeByName(self.info_view, "unsign_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.control_:showChooseDialog(tt.gettext("是否取消報名？"),nil,function()
						self.control_:unsignMttMatch(self.mData.match_id)
					end)
			end)

	self.info_view_.enter_room_btn = cc.uiloader:seekNodeByName(self.info_view, "enter_room_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.control_:gotoRoom(self.mData.mlv,self.mData.match_id,kMttRoom)
			end)

	self:initSignBtn()
	

	-- -- blind view
	self.blind_view_ = {}
	self.blind_view = cc.uiloader:seekNodeByName(node, "blind_view")

	cc.uiloader:seekNodeByName(self.blind_view, "Label_94"):setString(tt.gettext("等级"))
	cc.uiloader:seekNodeByName(self.blind_view, "Label_94_0"):setString(tt.gettext("盲注"))
	cc.uiloader:seekNodeByName(self.blind_view, "Label_94_1"):setString(tt.gettext("前注"))
	cc.uiloader:seekNodeByName(self.blind_view, "Label_94_2"):setString(tt.gettext("涨盲时间"))

	self.blind_view_.blind_info_list = cc.uiloader:seekNodeByName(self.blind_view, "blind_info_list")

	self.user_view_ = {}
	self.user_view = cc.uiloader:seekNodeByName(node, "user_view")

	cc.uiloader:seekNodeByName(self.user_view, "Label_94"):setString(tt.gettext("名次"))
	cc.uiloader:seekNodeByName(self.user_view, "Label_94_0"):setString(tt.gettext("名称"))
	cc.uiloader:seekNodeByName(self.user_view, "Label_94_1"):setString(tt.gettext("筹码量"))

	self.user_view_.user_info_list = cc.uiloader:seekNodeByName(self.user_view, "user_info_list")
	self.user_view_.my_rank_txt = cc.uiloader:seekNodeByName(self.user_view, "my_rank_txt")
	self.user_view_.my_name_txt = cc.uiloader:seekNodeByName(self.user_view, "my_name_txt"):setString(tt.owner:getName())
	self.user_view_.my_chips_txt = cc.uiloader:seekNodeByName(self.user_view, "my_chips_txt")

	self.info_view_btn = cc.uiloader:seekNodeByName(node, "info_view_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			if self.isInRoom then
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomInfoViewBtn,{name=matchData.mname})
			else
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.infoViewBtn,{name=matchData.mname})
			end
			self:showInfoView()
		end)

	self.blind_view_btn = cc.uiloader:seekNodeByName(node, "blind_view_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			if self.isInRoom then
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.blindViewBtn,{name=matchData.mname})
			else
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomBlindViewBtn,{name=matchData.mname})

			end
			self:showBlindView()
		end)

	self.user_view_btn = cc.uiloader:seekNodeByName(node, "user_view_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			if self.isInRoom then
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.userViewBtn,{name=matchData.mname})
			else
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.roomUserViewBtn,{name=matchData.mname})
			end
			self:showUserView()
		end)


	self:updateSignNumView()

    self.isInRoom = false
    self:initRunningView()

end

function MttMatchInfoDialog:show()
	BLDialog.show(self)
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}
	-- self:initBlindInfo()
	self:showInfoView()

	-- self:setMatchInfo("ทุกxนาที  จะมอบรางวัลแก่ผู้เล่นตามอ ันดับและสัดส่วนชิปของผู้เล่น aadasdasda sdsaasdasdas dasdasasddas dasdadsadsdas 123112312313211231232131232312 asdasdasdsa ")
	self:getMatchDesc()
end

function MttMatchInfoDialog:getMatchDesc()
	tt.gsocket.request("mtt.match_desc",{match_id=self.mData.match_id})
end

function MttMatchInfoDialog:setMatchInfo(str)
	local node = self.info_view_.match_info_list:getScrollNode()
	node:removeAllChildren()
	local view = display.newTTFLabel({
	    text = str,
	    size = 36,
	    color = cc.c3b(0xd9, 0xd8, 0xd8),
	    align = cc.TEXT_ALIGNMENT_LEFT,
	    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
	    dimensions = cc.size(431, 0)
	})
	view:setAnchorPoint(cc.p(0,1))
	view:setPosition(0,0)
	node:addChild(view)
end

function MttMatchInfoDialog:isMatchCanJoin()
	local stime,jtime,atime = self.mData.stime,self.mData.jtime,self.mData.atime
	local curTime = tt.time()
	local canJoinRoomTime = stime - jtime
	print("isMatchCanJoin",stime,jtime,atime,canJoinRoomTime,curTime)
	return curTime >= canJoinRoomTime
end

function MttMatchInfoDialog:nextMatch()
	if self.mData.left == 0 then
		-- 刪除自己
		return
	else
		print("比赛报名结束 换比赛了")
		self:updateApplyNum(0)
		local data = clone(self.mData)
		data.apply_num = 0
		data.stime = self.mData.stime + self.mData.ntime
		data.match_id = self.mData.match_pre .. self.mData.left
		data.left = self.mData.left - 1
		self.mData = tt.nativeData.getMttInfo(data.match_id)
		dump(self.mData,"MttMatchInfoDialog:nextMatch")
		if not self.mData then
			self.mData = data
			tt.nativeData.saveMttInfo(data.match_id,data)
		end
	end
end
-- 报名时间
function MttMatchInfoDialog:updateSignCountdownView()
	self:stopAllActionsByTag(1)
	local stime,jtime,atime = self.mData.stime,self.mData.jtime,self.mData.atime
	local curTime = tt.time()
	local canJoinRoomTime = stime - jtime
	print(string.format("updateSignCountdownView stime %d,jtime %d,atime %d,curTime %d,canJoinRoomTime %d",stime,jtime,atime,curTime,canJoinRoomTime))
	local status 
	if curTime >= stime then
		-- 切换比赛
		print(curTime,stime,jtime,atime)
		status = 1
		self:nextMatch()
	elseif curTime >= canJoinRoomTime then
		-- 显示即将开始
		status = 2
		self.info_view_.push_btn:setVisible(false)
		self.info_view_.sign_btn:setButtonEnabled(true)
		self.info_view_.sign_info_bg:setVisible(true)
		self:updateSignInfoText(stime,curTime,true)
	elseif atime < 0 or stime - atime <= curTime then
		status = 3
		-- 报名中
		self.info_view_.push_btn:setVisible(false)
		self.info_view_.sign_btn:setButtonEnabled(true)
		self.info_view_.sign_info_bg:setVisible(true)
		self:updateSignInfoText(stime,curTime)
	else
		-- 等待比赛开放
		status = 4
		dump(LocalNotication.getMatchNoticationId(self.mData.match_id),"updateSignCountdownView")
		if LocalNotication.getMatchNoticationId(self.mData.match_id) then
			print("updateSignCountdownView show sign")
			self.info_view_.push_btn:setVisible(false)
		else
			print("updateSignCountdownView show push")
			self.info_view_.sign_btn:setVisible(false)
		end
		self.info_view_.sign_btn:setButtonEnabled(false)
		self.info_view_.sign_info_bg:setVisible(true)
		self:waitForSign(stime,atime)
	end
	-- 报名状态发生变化需要更新报名界面
	if self.mMatchRuningStatus ~= status then
		self.mMatchRuningStatus = status
		self:refreshSignView()
	else
		self.mMatchRuningStatus = status
	end

	self:performWithDelay(function()
			self:updateSignCountdownView()
		end, 1):setTag(1)
end

function MttMatchInfoDialog:waitForSign(stime,jtime)
	self.info_view_.sign_info_bg:removeAllChildren()

	local node2 = display.newNode()

	local timeStr = ""

	if jtime >= 3600 then
		if jtime % 3600 == 0 then
			timeStr = tt.gettext("赛前{s1}小时开放",string.format("%d",jtime/3600))
		else
			timeStr = tt.gettext("赛前{s1}小时开放",math.floor("%.1f",jtime/3600))
		end
	else
		timeStr = tt.gettext("赛前{s1}分钟开放",math.floor(jtime/60))
	end

	local signTxt = display.newTTFLabel({
        text = timeStr,
        size = 36,
        color=cc.c3b(0xd9,0xd8,0xd8),
    })


    tt.linearlayout(node2,signTxt,10)


	local node1 = display.newNode()

	local preStr = tt.gettext("开赛时间 {s1}",os.date("%H:%M:%S",stime))
	local preTxt = display.newTTFLabel({
        text = preStr,
        size = 36,
        color=cc.c3b(0xd9,0xd8,0xd8),
    })

    tt.linearlayout(node1,preTxt,10)

	local w1 = node1:getContentSize().width
	local w2 = node2:getContentSize().width

	node1:addTo(self.info_view_.sign_info_bg)
	node2:addTo(self.info_view_.sign_info_bg)

	local ww = math.max(w1+30,w2+30,85)
    self.info_view_.sign_info_bg:setContentSize(ww,80)

    node1:setPosition(ww/2-w1/2,30)
    node2:setPosition(ww/2-w2/2,0)
end

function MttMatchInfoDialog:updateSignInfoText(stime,curTime,isShowJoining)
	countdownTime = stime - curTime
	print("MttMatchInfoDialog:updateSignInfoText",countdownTime,isShowJoining,countdownTime < 120)
	local preStr = ""
	if isShowJoining then
		if self.control_:isSignedMtt(self.mData.match_id) then
			preStr = tt.gettext("已报名")
		else
			preStr = tt.gettext("即将开始")
		end
	else
		if self.control_:isSignedMtt(self.mData.match_id) then
			preStr = tt.gettext("已报名")
		else
			preStr = tt.gettext("报名中")
		end
	end

	self.info_view_.sign_info_bg:removeAllChildren()

	local node2 = display.newNode()

	local preTxt = display.newTTFLabel({
        text = preStr,
        size = 36,
        color=cc.c3b(0xd9,0xd8,0xd8),
    })

	local color = cc.c3b(0xd9,0xd8,0xd8)
	if countdownTime < 120 then
		color = cc.c3b(0xb9,0x12,0x12)
	end
    local timeTxt = display.newTTFLabel({
        text = os.date("!%H:%M:%S",countdownTime),
        size = 36,
        color=color,
    })

    tt.linearlayout(node2,preTxt,10)
    tt.linearlayout(node2,timeTxt,10)

    local node1 = display.newNode()

	local startStr = tt.gettext("开赛时间 {s1}",os.date("%H:%M:%S",stime))
	local startTxt = display.newTTFLabel({
        text = startStr,
        size = 36,
        color=cc.c3b(0xd9,0xd8,0xd8),
    })

    tt.linearlayout(node1,startTxt,10)

	local w1 = node1:getContentSize().width
	local w2 = node2:getContentSize().width

	node1:addTo(self.info_view_.sign_info_bg)
	node2:addTo(self.info_view_.sign_info_bg)

	local ww = math.max(w1+30,w2+30,85)
    self.info_view_.sign_info_bg:setContentSize(ww,80)

    node1:setPosition(ww/2-w1/2,30)
    node2:setPosition(ww/2-w2/2,0)
end

function MttMatchInfoDialog:setInRoom(flag)
	self.isInRoom = flag
	self.info_view_.enter_room_btn:setVisible(not flag)
end

function MttMatchInfoDialog:dismiss()
	BLDialog.dismiss(self)
	
	self:stopRankRefresh()
	self:stopBlindTimeClock()

	-- if self.mBlur then 
	-- 	self.mBlur:removeSelf() 
	-- 	self.mBlur=nil 
	-- end
	self:removeSelf()
end

function MttMatchInfoDialog:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end
	BLDialog.onExit(self)
end

function MttMatchInfoDialog:refreshSignView()
	printInfo("MttMatchInfoDialog refreshSignView")
	if self.isInRoom then
		self.mSignNumBg:setVisible(false)
		self.info_view_.sign_btn:setVisible(false)
		self.info_view_.push_btn:setVisible(false)
		self.info_view_.sign_cost_info:setVisible(false)
		self.info_view_.unsign_btn:setVisible(false)
		self.info_view_.enter_room_btn:setVisible(false)
		self.info_view_.running_info_bg:setVisible(true)
		self.info_view_.sign_info_bg:setVisible(false)
		self:startRankRefresh()
		self:getPlayingInfo()
	elseif self.control_:isSignedMtt(self.mData.match_id) then
		self.mSignNumBg:setVisible(true)
		self.info_view_.sign_info_bg:setVisible(true)
		local status = self.control_:getMttStatus(self.mData.match_id)
		printInfo("MttMatchInfoDialog refreshSignView %d",status)
		if status == 1 then
			if self:isMatchCanJoin() then
				self.info_view_.sign_btn:setVisible(false)
				self.info_view_.push_btn:setVisible(false)
				self.info_view_.sign_cost_info:setVisible(false)
				self.info_view_.unsign_btn:setVisible(false)
				self.info_view_.enter_room_btn:setVisible(true)
				self.info_view_.running_info_bg:setVisible(false)
			else
				self.info_view_.sign_btn:setVisible(false)
				self.info_view_.push_btn:setVisible(false)
				self.info_view_.sign_cost_info:setVisible(false)
				self.info_view_.unsign_btn:setVisible(true)
				self.info_view_.enter_room_btn:setVisible(false)
				self.info_view_.running_info_bg:setVisible(false)
			end
			self:updateSignCountdownView()
		elseif status == 2 then 
			self.info_view_.sign_btn:setVisible(false)
			self.info_view_.push_btn:setVisible(false)
			self.info_view_.sign_cost_info:setVisible(false)
			self.info_view_.unsign_btn:setVisible(false)
			self.info_view_.enter_room_btn:setVisible(true)
			self.info_view_.running_info_bg:setVisible(false)
		else
			self.info_view_.sign_btn:setVisible(false)
			self.info_view_.push_btn:setVisible(false)
			self.info_view_.sign_cost_info:setVisible(false)
			self.info_view_.unsign_btn:setVisible(false)
			self.info_view_.enter_room_btn:setVisible(false)
			self.info_view_.running_info_bg:setVisible(false)
		end
	else
		self.mSignNumBg:setVisible(true)
		self.info_view_.sign_btn:setVisible(true)
		self.info_view_.push_btn:setVisible(true)
		self.info_view_.sign_cost_info:setVisible(true)
		self.info_view_.unsign_btn:setVisible(false)
		self.info_view_.enter_room_btn:setVisible(false)
		self.info_view_.running_info_bg:setVisible(false)
		self:updateSignCountdownView()
	end
end


function MttMatchInfoDialog:initBlindInfo()
	local blind_id = self.mData.blind_id
	local data = tt.game_data.blind_table[blind_id]
	if not data then
		tt.gsocket.request("match.blind_info",{blind_id=blind_id})
	else
		local level_1 = data[1]
		if not level_1 then return end
		-- local str =  tt.gettext("起始盲注: {s1}/{s2} ante {s3}",tt.getNumStr(level_1.sb),tt.getNumStr(level_1.bb),tt.getNumStr(level_1.ante))
		self:onBlindInfo(data)
	end
end

function MttMatchInfoDialog:rankRefreshFunc()
	if tt.gsocket:isConnected() then
		tt.gsocket.request("mtt.match_rank",{
				mlv = self.mData.mlv,           --比赛场次
				match_id = self.mData.match_id,   --比赛id
				mid = tt.owner:getUid(),           --用户的id
				begin = 1,         --排名起始值
				rnum = 20,         --排名个数   
			})
	end
end

function MttMatchInfoDialog:startRankRefresh()
	if self.refreshRankAction then return end
	if self.isInRoom then return end
	self:rankRefreshFunc()
	self.refreshRankAction = self:schedule(handler(self, self.rankRefreshFunc), 10)
end

function MttMatchInfoDialog:stopRankRefresh()
	if self.refreshRankAction then
		self:stopAction(self.refreshRankAction)
		self.refreshRankAction = nil
	end
end

function MttMatchInfoDialog:checkFunc(view,fileFormat,flag)
	if flag then
		view:setButtonImage("normal",string.format(fileFormat,"pre"),true)
	else
		view:setButtonImage("normal",string.format(fileFormat,"nor"),true)
	end
end
-- 开始新的旅程
function MttMatchInfoDialog:showInfoView()
	self:checkFunc(self.info_view_btn,"btn/btn_detrules_%s.png", true)
	self:checkFunc(self.blind_view_btn,"btn/btn_blstructure_%s.png", false)
	self:checkFunc(self.user_view_btn,"btn/btn_maninfo_%s.png", false)
	self.info_view:setVisible(true)
	self.blind_view:setVisible(false)
	self.user_view:setVisible(false)
	self:updateReward()
	self:refreshSignView()
end

function MttMatchInfoDialog:showBlindView()
	self:checkFunc(self.info_view_btn,"btn/btn_detrules_%s.png", false)
	self:checkFunc(self.blind_view_btn,"btn/btn_blstructure_%s.png", true)
	self:checkFunc(self.user_view_btn,"btn/btn_maninfo_%s.png", false)
	self.info_view:setVisible(false)
	self.blind_view:setVisible(true)
	self.user_view:setVisible(false)
	if not self.mBlindViewInit then
		self.mBlindViewInit = true
		self:initBlindInfo()
	end
end

function MttMatchInfoDialog:showUserView()
	self:checkFunc(self.info_view_btn,"btn/btn_detrules_%s.png", false)
	self:checkFunc(self.blind_view_btn,"btn/btn_blstructure_%s.png", false)
	self:checkFunc(self.user_view_btn,"btn/btn_maninfo_%s.png", true)
	self.info_view:setVisible(false)
	self.blind_view:setVisible(false)
	self.user_view:setVisible(true)

	if self.isInRoom then
		self:rankRefreshFunc()
	end
end

function MttMatchInfoDialog:updateApplyNum(num)
	self.mData.apply_num = tonumber(num) or 0
	print("updateApplyNum ApplyNum old new",self.mOldNum,self.mData.apply_num)
	if self.mData.reward_type == 2 and self.mOldNum ~= self.mData.apply_num then
		self:updateReward()
	end
	self.mOldNum = tonumber(num) or 0
	self:updateSignNumView()
end

function MttMatchInfoDialog:updateSignNumView()
	self.mSignNumBg:removeAllChildren()

	local node = display.newNode()
	local icon = display.newSprite("dec/dec_people.png")
	local num_img = tt.getBitmapStrAscii("number/yellow1_%d.png",self.mData.apply_num or 0)
	tt.linearlayout(node,icon,0,12)
	tt.linearlayout(node,num_img,5,19)

	node:addTo(self.mSignNumBg)

	local size = node:getContentSize()
	local w = math.max(59,size.width+30)	
	self.mSignNumBg:setContentSize(w,59)

	node:setPosition(cc.p(w/2-size.width/2,0))
end

function MttMatchInfoDialog:getMatchId()
	return self.mData.match_id
end

function MttMatchInfoDialog:getRewardId()
	return self.mData.reward_id
end

function MttMatchInfoDialog:getRewardType()
	return self.mData.reward_type
end

function MttMatchInfoDialog:updateReward()
	local reward_type,reward_id = self.mData.reward_type,self.mData.reward_id
	print("updateReward",reward_type,reward_id)
	if reward_type == 1 then
		local data = tt.nativeData.getRewardInfo(reward_id)
		if data then
			self:setRewardInfo(data)
		else
			tt.gsocket.request("match.reward_info",{reward_id=reward_id})
		end
	elseif reward_type == 2 then
		local data = tt.nativeData.getDrewardInfo(reward_id)
		local apply_num = math.max(self.mData.apply_num,self.mData.min_player)
		local total_jackpot = apply_num * (self.mMoneySignCost - self.mData.fee)
		print("updateReward reward_type 2 apply_num cost fee",apply_num,self.mMoneySignCost,self.mData.fee)
		if data then
			self:setDrewardInfo( data,apply_num,total_jackpot )
		else
			tt.gsocket.request("match.dreward_info",{reward_id=reward_id})
		end
	elseif reward_type == 3 then
		local data = tt.nativeData.getMrewardInfo(reward_id)
		if data then
			self:setMrewardInfo(data)
		else
			tt.gsocket.request("match.mreward_info",{reward_id=reward_id})
		end
	end
end

function MttMatchInfoDialog:setMrewardInfo(reward_table)
	-- local reward_table = {
	-- 			[1] = 60,  -- 最小名次的
	-- 			[3] = 40,  -- 第一名的为奖励60 2-3名为40 
	-- 			[6] = 20,  -- 4-6名的为20
	-- 		}--
	if not reward_table then return end
	self.info_view_.rank_reward_list:removeAllItems()
	local list = self.info_view_.rank_reward_list
	if not next(reward_table) then return end
	dump(reward_table,"setMrewardInfo")
	local ranks = {}
	for key,_ in pairs(reward_table) do 
		table.insert(ranks,tonumber(key))
	end
	table.sort(ranks)
	local start_rank = 1
	for i,rank in ipairs(ranks) do
		local end_rank = rank
		local reward = reward_table[tostring(end_rank)] or reward_table[tonumber(end_rank)]
		local item = list:newItem()
		local content = display.newNode()
		local top = 58
		local size = cc.size(495,top)
		content:setContentSize(size.width, size.height)
		item:addContent(content)
		item:setItemSize(size.width, size.height)

		local rank_str = tostring(start_rank)
		if start_rank ~= end_rank then
			rank_str = rank_str .. "~" .. end_rank
		end
		start_rank = end_rank + 1

		local rankLable = display.newTTFLabel({
			    text = rank_str,
			    size = 43,
			    color = cc.c3b(0xd9, 0xd8, 0xd8),
			    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
			})
		rankLable:setPosition(48,top/2)
		local reward_str = ""
		local addRewardStr = function(str)
			if reward_str ~= "" then
				reward_str = reward_str .. "+" .. str
			else
				reward_str = str
			end
		end
		if reward.vgoods then
			for goods_id,num in pairs(reward.vgoods) do
				local propData = tt.nativeData.getPropData(goods_id)
				if propData then
					if num > 1 then
						addRewardStr(propData.sname .. 'X' .. num)
					else
						addRewardStr(propData.sname)
					end
				else
					if num > 1 then
						addRewardStr("***X" .. num)
					else
						addRewardStr("***")
					end
					if self.mHandlers[goods_id] then
						PropDataHelper.unregister(self.mHandlers[goods_id])
					end
					self.mHandlers[goods_id] = PropDataHelper.register(goods_id,function(data)
							if tolua.isnull(self) then return end
							self:updateReward()
						end)
				end
			end
		end
		if reward.money then
			addRewardStr(tt.getNumShortStr(reward.money) .. tt.gettext("筹码"))
		end
		if reward.score then
			addRewardStr(tt.getNumShortStr(reward.score) .. tt.gettext("vip点"))
		end
		print("setMrewardInfo",rank_str,reward_str)
		local rewardLable = display.newTTFLabel({
		    text = reward_str,
		    size = 43,
		    color = cc.c3b(0xd9, 0xd8, 0xd8),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		rewardLable:setPosition(292,top/2)
		tt.limitStr(rewardLable,reward_str,320)

		local dec = display.newSprite("dec/dec_enrolrules_list.png")
			:setPosition(248,top/2)

		content:addChild(dec)
		content:addChild(rankLable)
		content:addChild(rewardLable)

		list:addItem(item)
	end

	list:reload()
end

function MttMatchInfoDialog:setDrewardInfo(reward_table,apply_num,total_jackpot)
	if not reward_table then return end
	dump(reward_table)
	self.info_view_.rank_reward_list:removeAllItems()
	local list = self.info_view_.rank_reward_list
	local pnum = reward_table.pnum
    local rank = reward_table.rank
    local reward_per = reward_table.reward_per
    local col = #pnum

    for i,v in ipairs(pnum) do
        if v <= apply_num then
            col = i
            break
        end
    end

    local max_row = 0
	for frow,key in ipairs(rank) do 
		if not reward_per[frow][col] then
			max_row = frow - 1
			break
		end
	end
	local start_rank = 1
	print("setDrewardInfo max_row",max_row)
	for i=1,max_row do
    	local row = i
    	print("setDrewardInfo row col",row,col)
    	print("setDrewardInfo",reward_per[row][col],total_jackpot)
		local reward = math.floor(reward_per[row][col] * total_jackpot / 100)
		local end_rank = rank[i]
		local item = list:newItem()
		local content = display.newNode()
		local top = 58
		local size = cc.size(495,top)
		content:setContentSize(size.width, size.height)
		item:addContent(content)
		item:setItemSize(size.width, size.height)

		local rank_str = tostring(start_rank)
		if start_rank ~= end_rank then
			rank_str = "~" .. end_rank
		end
		start_rank = end_rank + 1

		local rankLable = display.newTTFLabel({
			    text = rank_str,
			    size = 43,
			    color = cc.c3b(0xd9, 0xd8, 0xd8),
			    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
			})
		rankLable:setPosition(48,top/2)


		local rewardLable = display.newTTFLabel({
		    text = tt.getNumShortStr(reward),
		    size = 43,
		    color = cc.c3b(0xd9, 0xd8, 0xd8),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		rewardLable:setPosition(292,top/2)

		local dec = display.newSprite("dec/dec_enrolrules_list.png")
			:setPosition(248,top/2)

		content:addChild(dec)
		content:addChild(rankLable)
		content:addChild(rewardLable)

		list:addItem(item)
	end

	list:reload()
end

function MttMatchInfoDialog:setRewardInfo(reward_table)
	-- local reward_table = {
	-- 			[1] = 60,  -- 最小名次的
	-- 			[3] = 40,  -- 第一名的为奖励60 2-3名为40 
	-- 			[6] = 20,  -- 4-6名的为20
	-- 		}--
	dump(reward_table,"setRewardInfo")
	if not reward_table then return end
	self.info_view_.rank_reward_list:removeAllItems()
	local list = self.info_view_.rank_reward_list
	if not next(reward_table) then return end
	dump(reward_table)
	local ranks = {}
	for key,_ in pairs(reward_table) do 
		table.insert(ranks,key)
	end
	table.sort(ranks)
	local max_rank = ranks[#ranks]
	local reward = 0
	for i=1,max_rank do
		if reward_table[i] then
			reward = reward_table[i]
		end
		local item = list:newItem()
		local content = display.newNode()
		local top = 58
		local size = cc.size(495,top)
		content:setContentSize(size.width, size.height)
		item:addContent(content)
		item:setItemSize(size.width, size.height)
		local rankLable = display.newTTFLabel({
			    text = i,
			    size = 43,
			    color = cc.c3b(0xd9, 0xd8, 0xd8),
			    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
			})
		rankLable:setPosition(48,top/2)


		local rewardLable = display.newTTFLabel({
		    text = tt.getNumShortStr(reward),
		    size = 43,
		    color = cc.c3b(0xd9, 0xd8, 0xd8),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		rewardLable:setPosition(292,top/2)

		local dec = display.newSprite("dec/dec_enrolrules_list.png")
			:setPosition(248,top/2)

		content:addChild(dec)
		content:addChild(rankLable)
		content:addChild(rewardLable)

		list:addItem(item)
	end

	list:reload()
end

function MttMatchInfoDialog:onBlindInfo(blind_info)
	if not blind_info then return end
	self.blind_view_.blind_info_list:removeAllItems()
	local list = self.blind_view_.blind_info_list
	-- [1]  = {sb=10,   bb=20,   ante=0,   tm=60, tbank=15},
	if not next(blind_info) then return end
	for i=1,#blind_info do
		local data = blind_info[i]
		local item = list:newItem()
		local content = display.newNode()
		local top = 58
		local size = cc.size(918,top)
		item:addContent(content)
		item:setItemSize(size.width, size.height)
		content:setContentSize(size.width, size.height)
		local levelLable = display.newTTFLabel({
		    text = i,
		    size = 43,
		    color = cc.c3b(0xd9, 0xd8, 0xd8),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		levelLable:setPosition(58,top/2)

		local blindLable = display.newTTFLabel({
		    text = string.format("%s / %s",tt.getNumStr(data.sb),tt.getNumStr(data.bb)),
		    size = 43,
		    color = cc.c3b(0xd9, 0xd8, 0xd8),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		blindLable:setPosition(343,top/2)

		local anteLable = display.newTTFLabel({
		    text = tt.getNumStr(data.ante),
		    size = 43,
		    color = cc.c3b(0xd9, 0xd8, 0xd8),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		anteLable:setPosition(622,top/2)

		local downtime = display.newTTFLabel({
		    text = data.tm.."s",
		    size = 43,
		    color = cc.c3b(0xd9, 0xd8, 0xd8),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		downtime:setPosition(857,top/2)

		local dec = display.newSprite("dec/dec_blstructure_list.png")
			:setPosition(459,top/2)

		content:addChild(levelLable)
		content:addChild(blindLable)
		content:addChild(anteLable)
		content:addChild(downtime)
		content:addChild(dec)

		list:addItem(item)
	end

	list:reload()
end

function MttMatchInfoDialog:onRankUserView(rank_list)
	-- rank_list = {{mid=100,nick="xxx",coin=100,rank=1},{mid=100,nick="xxx",coin=100,rank=1},{mid=100,nick="xxx",coin=100,rank=1},{mid=100,nick="xxx",coin=100,rank=1},{mid=100,nick="xxx",coin=100,rank=1},{mid=100,nick="xxx",coin=100,rank=1}}
	if not rank_list then return end
	self.user_view_.user_info_list:removeAllItems()
	local list = self.user_view_.user_info_list
	-- {mid=100,nick="xxx",coin=100,rank=1}
	dump(rank_list)
	if not next(rank_list) then return end
	for i=1,#rank_list do
		local data = rank_list[i]
		local item = list:newItem()
		local content = display.newNode()
		local top = 58
		local size = cc.size(917,top)
		item:addContent(content)
		item:setItemSize(size.width, size.height)
		content:setContentSize(size.width, size.height)

		local rankLable = display.newTTFLabel({
		    text = data.rank,
		    size = 43,
		    color = cc.c3b(0xd9, 0xd8, 0xd8),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		rankLable:setPosition(58,top/2)

		local nickLable = display.newTTFLabel({
		    text = data.nick,
		    size = 43,
		    color = cc.c3b(0xd9, 0xd8, 0xd8),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		nickLable:setPosition(326,top/2)

		local coinLable = display.newTTFLabel({
		    text = tt.getNumStr(data.coin),
		    size = 43,
		    color = cc.c3b(0xd9, 0xd8, 0xd8),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		coinLable:setPosition(680,top/2)

		local dec = display.newSprite("dec/dec_blstructure_list.png")
			:setPosition(458,top/2)

		content:addChild(rankLable)
		content:addChild(nickLable)
		content:addChild(coinLable)
		content:addChild(dec)

		list:addItem(item)
	end

	list:reload()
end

function MttMatchInfoDialog:getPlayingInfo()
	-- if self.isInRoom then return end
	tt.gsocket.request("mtt.match_blind",{mlv=self.mData.mlv,match_id = self.mData.match_id})
end

function MttMatchInfoDialog:updateBlindTxt()
	if not self.downtime then return end
	local downtime = self.downtime
	if downtime > 0 then
		-- self.info_view_.running_view_.blind_timer_txt:setString(tt.gettext("{s1}分鍾後",math.ceil(downtime/60)))
		-- self.info_view_.running_view_.blind_timer_txt:setVisible(true)
		-- self.info_view_.running_view_.next_blind_info_txt:setVisible(true)
		-- self.info_view_.running_view_.clock_dec:setVisible(true)
	else
		-- self.info_view_.running_view_.blind_timer_txt:setString(" - ")
		-- self.info_view_.running_view_.blind_timer_txt:setVisible(false)
		-- self.info_view_.running_view_.next_blind_info_txt:setVisible(false)
		-- self.info_view_.running_view_.clock_dec:setVisible(false)
	end
end

function MttMatchInfoDialog:setDownTime(downtime)
	self.downtime = tonumber(downtime) or 0
	self:updateBlindTxt()
	self:startBlindTimeClock()
end

function MttMatchInfoDialog:setMatchNextBChange(sb,bb,ante,isCur)
	if isCur then
		self.info_view_.next_blind_info_txt:setString( tt.gettext("當前等級: {s1}/{s2} ante {s3}",tt.getNumStr(sb),tt.getNumStr(bb),tt.getNumStr(ante)))
	else
		self.info_view_.next_blind_info_txt:setString( tt.gettext("下一等級: {s1}/{s2} ante {s3}",tt.getNumStr(sb),tt.getNumStr(bb),tt.getNumStr(ante)))
	end
end

function MttMatchInfoDialog:startBlindTimeClock()
	self:stopBlindTimeClock()
	self.blindTimeClock = scheduler.scheduleUpdateGlobal(function(dt) 
			-- printInfo("downtime %d dt %f" ,self.downtime,dt)
			self.downtime = self.downtime - dt
			if self.downtime < 0 then 
				self:stopBlindTimeClock()
				return
			end
			self:updateBlindTxt()
		end, 1)
end

function MttMatchInfoDialog:stopBlindTimeClock()
	if self.blindTimeClock then
		scheduler.unscheduleGlobal(self.blindTimeClock)
		self.blindTimeClock = nil
	end
end

function MttMatchInfoDialog:initRunningView()
	self.info_view_.running_info_list:removeAllItems()

	local content = display.newTTFLabel({
	    text = tt.gettext("當前等級: {s1}/{s2} ante {s3}","-","-","-"),
	    size = 36,
	    color = cc.c3b(0xd9, 0xd8, 0xd8), -- 使用纯红色
	    align = cc.TEXT_ALIGNMENT_LEFT,
	    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    	dimensions = cc.size(431, 36)
	})
	local item = self.info_view_.running_info_list:newItem()
	item:addContent(content)
	local size = content:getContentSize()
	content:align(display.LEFT_TOP)
	item:setItemSize(431, size.height)
	self.info_view_.running_info_list:addItem(item)
	self.info_view_.next_blind_info_txt = content
	

	local content = display.newTTFLabel({
	    text = tt.gettext("剩余人数:{s1}","-"),
	    size = 36,
	    color = cc.c3b(0xd9, 0xd8, 0xd8), -- 使用纯红色
	    align = cc.TEXT_ALIGNMENT_LEFT,
	    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    	dimensions = cc.size(431, 36)
	})
	local item = self.info_view_.running_info_list:newItem()
	item:addContent(content)
	local size = content:getContentSize()
	content:align(display.LEFT_TOP)
	item:setItemSize(431, size.height)
	self.info_view_.running_info_list:addItem(item)
	self.info_view_.left_num_txt = content

	local content = display.newTTFLabel({
	    text = tt.gettext("最低：{s1}","-"),
	    size = 36,
	    color = cc.c3b(0xd9, 0xd8, 0xd8), -- 使用纯红色
	    align = cc.TEXT_ALIGNMENT_LEFT,
	    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    	dimensions = cc.size(431, 36)
	})
	local item = self.info_view_.running_info_list:newItem()
	item:addContent(content)
	local size = content:getContentSize()
	content:align(display.LEFT_TOP)
	item:setItemSize(431, size.height)
	self.info_view_.running_info_list:addItem(item)
	self.info_view_.min_coin_txt = content

	local content = display.newTTFLabel({
	    text = tt.gettext("平均：{s1}","-"),
	    size = 36,
	    color = cc.c3b(0xd9, 0xd8, 0xd8), -- 使用纯红色
	    align = cc.TEXT_ALIGNMENT_LEFT,
	    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    	dimensions = cc.size(431, 36)
	})
	local item = self.info_view_.running_info_list:newItem()
	item:addContent(content)
	local size = content:getContentSize()
	content:align(display.LEFT_TOP)
	item:setItemSize(431, size.height)
	self.info_view_.running_info_list:addItem(item)
	self.info_view_.avg_coin_txt = content

	local content = display.newTTFLabel({
	    text = tt.gettext("最大：{s1}","-"),
	    size = 36,
	    color = cc.c3b(0xd9, 0xd8, 0xd8), -- 使用纯红色
	    align = cc.TEXT_ALIGNMENT_LEFT,
	    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    	dimensions = cc.size(431, 36)
	})
	local item = self.info_view_.running_info_list:newItem()
	item:addContent(content)
	local size = content:getContentSize()
	content:align(display.LEFT_TOP)
	item:setItemSize(431, size.height)
	self.info_view_.running_info_list:addItem(item)
	self.info_view_.max_coin_txt = content

	self.info_view_.running_info_list:reload()
end

function MttMatchInfoDialog:initSignBtn()
	-- 金币报名费用
	self.mMoneySignCost = 0

	local startY = 0
	self.mSignCostIndex = 0

	for i=#self.mData.entry,1,-1 do
		local value = self.mData.entry[i]
		if self.info_view_.cost_btn[value.etype] then
			self.info_view_.cost_btn[value.etype]:setVisible(true)
			self.info_view_.cost_btn_info[value.etype] = value
			if value.num > 0 then
				cc.uiloader:seekNodeByName(self.info_view_.cost_btn[value.etype], "num"):setString(tt.getNumShortStr(value.num))
			else
				cc.uiloader:seekNodeByName(self.info_view_.cost_btn[value.etype], "num"):setString(tt.gettext("免費"))
			end

			-- if self.mSignCostIndex == 0 then
			-- 	self.mSignCostIndex = value.etype
			-- 	self.info_view_.cost_btn[value.etype]:setButtonEnabled(false)
			-- end

			local x,y = self.info_view_.cost_btn[value.etype]:getPosition()
			self.info_view_.cost_btn[value.etype]:setPosition(cc.p(x,startY))
			startY = startY + 60
		elseif value.etype == 11 then
			local index = 3
			self.info_view_.cost_btn[index]:setVisible(true)
			self.info_view_.cost_btn_info[index] = value
			if value.num > 0 then
				cc.uiloader:seekNodeByName(self.info_view_.cost_btn[index], "num"):setString(tt.getNumShortStr(value.num))
			else
				cc.uiloader:seekNodeByName(self.info_view_.cost_btn[index], "num"):setString(tt.gettext("免費"))
			end
			-- if self.mSignCostIndex == 0 then
			-- 	self.mSignCostIndex = index
			-- 	self.info_view_.cost_btn[index]:setButtonEnabled(false)
			-- end

			local x,y = self.info_view_.cost_btn[index]:getPosition()
			self.info_view_.cost_btn[index]:setPosition(cc.p(x,startY))
			startY = startY + 60
		end
		if value.etype == 1 then
			self.mMoneySignCost = value.num
		end
	end

	for i=1,#self.mData.entry do
		local value = self.mData.entry[i]
		if value.etype == 1 then
			if tt.owner:getMoney() >= value.num then
				if self.mSignCostIndex == 0 then
					self.mSignCostIndex = value.etype
					self.info_view_.cost_btn[value.etype]:setButtonEnabled(false)
				end
			else
				cc.uiloader:seekNodeByName(self.info_view_.cost_btn[value.etype], "icon"):setTexture("icon/icon_chip5_grey.png")
				self.info_view_.cost_btn[value.etype]:setTouchEnabled(false)
			end
		elseif value.etype == 2 then
			if tt.owner:getVipScore() >= value.num then
				if self.mSignCostIndex == 0 then
					self.mSignCostIndex = value.etype
					self.info_view_.cost_btn[value.etype]:setButtonEnabled(false)
				end
			else
				cc.uiloader:seekNodeByName(self.info_view_.cost_btn[value.etype], "icon"):setTexture("icon/w_star_grey.png")
				self.info_view_.cost_btn[value.etype]:setTouchEnabled(false)
			end
		elseif value.etype == 11 then
			local index = 3
			if tt.owner:getJuan() >= value.num then
				if self.mSignCostIndex == 0 then
					self.mSignCostIndex = index
					self.info_view_.cost_btn[index]:setButtonEnabled(false)
				end
			else
				cc.uiloader:seekNodeByName(self.info_view_.cost_btn[index], "icon"):setTexture("icon/w_roll_grey.png")
				self.info_view_.cost_btn[index]:setTouchEnabled(false)
			end
		end
	end

	self.info_view_.sign_cost_info:setContentSize(170,startY)
	self.info_view_.sign_cost_info:setPosition(cc.p(514,135-startY/2))
end

function MttMatchInfoDialog:onSocketData(evt)
	tt.log.d(TAG, "cmd:[%s]",evt.cmd)	

	if evt.cmd == "match.blind_info" then 
		if evt.resp.ret == 200 then 
			tt.nativeData.saveBlindInfo(evt.resp.blind_id,evt.resp.blind_table)
			if self.mData.blind_id == evt.resp.blind_id then
				self:initBlindInfo()
			end
		end
	elseif evt.cmd == "mtt.match_rank" then
		-- ret = 200,   
		-- 	mlv = 1,           --比赛场次
		-- 	match_id = "1_1_1",      --比赛id
		-- 	urank = 1,  --用户自己的名次  
		-- 	left_num = 30, --比赛还剩的玩家
		-- 	ranks = {
		-- 		{mid=100,nick="xxx",coin=100,rank=1}
		-- 	}		
		if evt.resp then
			if evt.resp.ret == 200 then
				if self.mData.mlv == evt.resp.mlv and self.mData.match_id == evt.resp.match_id then
					dump(evt.resp,"mtt.match_rank")
					self:onRankUserView(evt.resp.ranks)
					print(tt.getNumStr(evt.resp.max_coin),tt.getNumStr(evt.resp.avg_coin),tt.getNumStr(evt.resp.min_coin))
					self.info_view_.left_num_txt:setString(tt.gettext("剩余人数:{s1}",evt.resp.left_num))
					self.info_view_.max_coin_txt:setString(tt.gettext("最大：{s1}",tt.getNumStr(evt.resp.max_coin)))
					self.info_view_.avg_coin_txt:setString(tt.gettext("平均：{s1}",tt.getNumStr(evt.resp.avg_coin)))
					self.info_view_.min_coin_txt:setString(tt.gettext("最低：{s1}",tt.getNumStr(evt.resp.min_coin)))

					-- 比赛开始后用排名更新报名总人数
					self:updateApplyNum(evt.resp.total_num)

					self.user_view_.my_rank_txt:setString(evt.resp.urank)
					local ctl_seat = self.control_.mModel:getCtlSeat()
					self.user_view_.my_chips_txt:setString(tt.getNumStr(self.control_:getSeatById(ctl_seat):getCoin()))
				end
			end
		end
	elseif evt.cmd == "mtt.match_blind" then
		if evt.resp then
			if self.mData.mlv == evt.resp.mlv and self.mData.match_id == evt.resp.match_id then
				local lv = evt.resp.cur_lv
				if lv == 0 then lv = 1 end
				local blind_id = evt.resp.blind_id
				self.blind_id = blind_id
				local data = tt.game_data.blind_table[blind_id][lv]
				local nextData = tt.game_data.blind_table[blind_id][lv+1]
				if nextData then
					self:setMatchNextBChange(nextData.sb,nextData.bb,nextData.ante)
				else
					self:setMatchNextBChange(data.sb,data.bb,data.ante,true)
				end
				self:setDownTime(evt.resp.left_time)
			end
		elseif evt.broadcast then
			-- cur_lv = 1,      --当前是第几个盲注名额
			-- change_lv = 2,    --涨盲为多少等级 
			-- left_time = 10,   --还有多少时间涨盲，为0则表示，开始涨盲
			if self.mData.mlv == evt.broadcast.mlv and self.mData.match_id == evt.broadcast.match_id then
				local blind_id = self.blind_id
				if tt.game_data.blind_table[blind_id] then
					if evt.broadcast.left_time <= 0 then
						local lv = evt.broadcast.change_lv
						local data = tt.game_data.blind_table[blind_id][lv]
						local nextData = tt.game_data.blind_table[blind_id][lv+1]
						if nextData then
							self:setMatchNextBChange(nextData.sb,nextData.bb,nextData.ante)
							self:setDownTime(nextData.tm)
						else
							self:setMatchNextBChange(data.sb,data.bb,data.ante,true)
							self:setDownTime(0)
						end
					else
						self:setDownTime(evt.broadcast.left_time)
					end
				end
			end
			-- tt.show_msg( string.format("当前盲注等级 %d 下一局涨盲等级 %d 下一次涨盲时间 %d",evt.broadcast.cur_lv,evt.broadcast.change_lv,evt.broadcast.left_time) )
		end
	elseif evt.cmd == "mtt.match_desc" then
		if evt.resp then
			if evt.resp.ret == 200 and evt.resp.match_id == self.mData.match_id then
				print("match_desc",evt.resp.desc)
				self:setMatchInfo(evt.resp.desc)
			end
		end
	end
end

function MttMatchInfoDialog:onCleanup()
	for _,handler in pairs(self.mHandlers) do
		PropDataHelper.unregister(handler)
	end
	self.mHandlers = {}
end

return MttMatchInfoDialog
