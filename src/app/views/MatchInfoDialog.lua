--
-- Author: bearluo
-- Date: 2017-05-27
--

local BLDialog = require("app.ui.BLDialog")
local net = require("framework.cc.net.init")
local MatchInfoDialog = class("MatchInfoDialog", function()
	return BLDialog.new()
end)

local TAG = "MatchInfoDialog"
local net = require("framework.cc.net.init")
local scheduler = require("framework.scheduler")

function MatchInfoDialog:ctor(control,matchData)
	self.control_ = control 
	dump(matchData)
	local node, width, height = cc.uiloader:load("match_info_dialog.json")
	self:addChild(node)
	self.root_ = node
	self.mData = matchData
	self.mlv = matchData.mlv
	self:setContentSize(cc.size(width,height))

	self.back_btn = cc.uiloader:seekNodeByName(node,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	-- display.newColorLayer(cc.c4b(16/255,24/255,42/255,60)):addTo(self,-1)

	self:setVisible(false)

	-- info view
	self.info_view_ = {}
	self.info_view = cc.uiloader:seekNodeByName(node, "info_view")
	self.info_view_.rank_reward_list = cc.uiloader:seekNodeByName(self.info_view, "rank_reward_list")

	cc.uiloader:seekNodeByName(self.info_view, "Label_40"):setString(tt.gettext("名次"))
	cc.uiloader:seekNodeByName(self.info_view, "Label_40_0"):setString(tt.gettext("獎勵"))

	self.info_view_.sign_view_ = {}
	self.info_view_.sign_view = cc.uiloader:seekNodeByName(self.info_view, "match_info_view")

	self.info_view_.sign_view_.sign_money = cc.uiloader:seekNodeByName(self.info_view_.sign_view, "sign_money")
	self.info_view_.sign_view_.start_coin = cc.uiloader:seekNodeByName(self.info_view_.sign_view, "start_coin")
	self.info_view_.sign_view_.blind_info = cc.uiloader:seekNodeByName(self.info_view_.sign_view, "blind_info")
	self.info_view_.sign_view_.num_title = cc.uiloader:seekNodeByName(self.info_view_.sign_view, "num_title")
	self.info_view_.sign_view_.sign_mun = cc.uiloader:seekNodeByName(self.info_view_.sign_view, "sign_mun")
	
	local time = 0
	self.info_view_.sign_btn = cc.uiloader:seekNodeByName(self.info_view, "sign_btn")
		:onButtonClicked(function()
				if time + 1 > net.SocketTCP.getTime() then return end
				tt.play.play_sound("click")
				time = net.SocketTCP.getTime()
				self.control_:signMatch(self.mlv)
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.matchSignBtn,{name=matchData.mname})
			end)
	self.info_view_.unsign_btn = cc.uiloader:seekNodeByName(self.info_view, "unsign_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.matchUnSignBtn,{name=matchData.mname})
				self.control_:showChooseDialog(tt.gettext("是否取消報名？"),nil,function()
						tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.matchUnSignSureBtn,{name=matchData.mname})
						self.control_:unsignMatch(self.mlv)
					end)
			end)

	self.info_view_.running_view_ = {}
	self.info_view_.running_view = cc.uiloader:seekNodeByName(self.info_view, "running_info_bg")
	self.info_view_.running_view_.num_title = cc.uiloader:seekNodeByName(self.info_view_.running_view, "num_title")
	self.info_view_.running_view_.play_mun = cc.uiloader:seekNodeByName(self.info_view_.running_view, "play_mun")
	self.info_view_.running_view_.clock_dec = cc.uiloader:seekNodeByName(self.info_view_.running_view, "clock_dec")
	self.info_view_.running_view_.blind_timer_txt = cc.uiloader:seekNodeByName(self.info_view_.running_view, "blind_timer_txt")
	self.info_view_.running_view_.next_blind_info_txt = cc.uiloader:seekNodeByName(self.info_view_.running_view, "next_blind_info_txt")
	self.info_view_.running_view_.min_coin_txt = cc.uiloader:seekNodeByName(self.info_view_.running_view, "min_coin_txt")
	self.info_view_.running_view_.average_coin_txt = cc.uiloader:seekNodeByName(self.info_view_.running_view, "average_coin_txt")
	self.info_view_.running_view_.max_coin_txt = cc.uiloader:seekNodeByName(self.info_view_.running_view, "max_coin_txt")


	self.info_view_.running_view_.num_title:setString(tt.gettext("剩餘人數："))

	self.info_view_.enter_room_btn = cc.uiloader:seekNodeByName(self.info_view, "enter_room_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.control_:gotoRoom(self.mlv,self.match_id,kSngRoom)
			end)
	
	local num = tt.gettext("免費")
	for _,v in ipairs(matchData.entry) do
		if v.etype == 1 then
			if v.num > 0 then
				num = tt.getNumStr(v.num)
			end
			break
		end
	end


	self.info_view_.sign_view_.sign_money:setString( tt.gettext("報名費用: {s1}",num))


	self.playerNum = tonumber(matchData.player) or 0
	self.info_view_.sign_view_.num_title:setString( tt.gettext("滿{s1}人開賽:",self.playerNum))
	local size = self.info_view_.sign_view_.num_title:getContentSize()
	self.info_view_.sign_view_.sign_mun:setPosition(size.width+20 ,112)
	self.info_view_.sign_view_.sign_mun:setString( string.format("0/%d",self.playerNum))

	local size = self.info_view_.running_view_.num_title:getContentSize()
	self.info_view_.running_view_.play_mun:setPosition(size.width-158 ,170)


	self.info_view_.sign_view_.start_coin:setString( tt.gettext("起始籌碼: {s1}",tt.getNumStr(matchData.coin)))

	-- blind view
	self.blind_view_ = {}
	self.blind_view = cc.uiloader:seekNodeByName(node, "blind_view")
	self.blind_view_.blind_info_list = cc.uiloader:seekNodeByName(self.blind_view, "blind_info_list")

	self.user_view_ = {}
	self.user_view = cc.uiloader:seekNodeByName(node, "user_view")
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

    self.isInRoom = false
end

function MatchInfoDialog:show()
	BLDialog.show(self)
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}
	self:initBlindInfo()
	self:showInfoView()
end

function MatchInfoDialog:setInRoom(flag)
	self.isInRoom = flag
	self.info_view_.enter_room_btn:setVisible(not flag)
	self.info_view_.running_view:setVisible(flag)
end

function MatchInfoDialog:dismiss()
	BLDialog.dismiss(self)

	self:stopSignNumRefresh()
	self:stopRankRefresh()
	self:stopBlindTimeClock()

	-- if self.mBlur then 
	-- 	self.mBlur:removeSelf() 
	-- 	self.mBlur=nil 
	-- end
	self:removeSelf()
end


function MatchInfoDialog:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end
	BLDialog.onExit(self)
end

function MatchInfoDialog:refreshSignView()
	printInfo("MatchInfoDialog refreshSignView")
	if self.match_id then
		local flag = self.status
		printInfo("MatchInfoDialog refreshSignView %d",self.status or 0)
		if flag == 1 then
			self.info_view_.sign_view_.num_title:setVisible(true)
			self.info_view_.sign_view_.sign_mun:setVisible(true)
			self.info_view_.running_view:setVisible(false)
			self.info_view_.sign_btn:setVisible(false)
			self.info_view_.unsign_btn:setVisible(true)
			self:signNumRefreshFunc()
			self:stopSignNumRefresh()
		elseif flag == 2 then 
			self.info_view_.sign_view_.num_title:setVisible(false)
			self.info_view_.sign_view_.sign_mun:setVisible(false)

			self.info_view_.running_view:setVisible(self.isInRoom)
			self.info_view_.sign_btn:setVisible(false)
			self.info_view_.unsign_btn:setVisible(false)
			self.info_view_.enter_room_btn:setVisible(not self.isInRoom)
			self:stopSignNumRefresh()
			self:startRankRefresh()
			self:rankRefreshFunc()
			self:getPlayingInfo()
		else
			self.info_view_.sign_view_.num_title:setVisible(false)
			self.info_view_.sign_view_.sign_mun:setVisible(false)
			self.info_view_.running_view:setVisible(false)
			self.info_view_.sign_btn:setVisible(false)
			self.info_view_.unsign_btn:setVisible(false)
			self.info_view_.enter_room_btn:setVisible(false)
			self:stopSignNumRefresh()
		end
	else
		self.info_view_.sign_view_.num_title:setVisible(true)
		self.info_view_.sign_view_.sign_mun:setVisible(true)
		self.info_view_.running_view:setVisible(false)
		self.info_view_.sign_btn:setVisible(true)
		self.info_view_.unsign_btn:setVisible(false)
		self:startSignNumRefresh()
		self:signNumRefreshFunc()
	end
end


function MatchInfoDialog:initBlindInfo()
	local blind_id = self.mData.blind_id
	local data = tt.game_data.blind_table[blind_id]
	if not data then
		tt.gsocket.request("match.blind_info",{blind_id=blind_id})
	else
		local level_1 = data[1]
		if not level_1 then return end
		local str =  tt.gettext("起始盲注: {s1}/{s2} ante {s3}",tt.getNumStr(level_1.sb),tt.getNumStr(level_1.bb),tt.getNumStr(level_1.ante))
		self.info_view_.sign_view_.blind_info:setString(str)
		self:onBlindInfo(data)
	end
end

function MatchInfoDialog:getRewardInfo()
	if not self.mData then return end
	if self.needSeedRewardInfoCmd ~= false then
		self.needSeedRewardInfoCmd = false
		printInfo("MatchInfoDialog:getRewardInfo")
		tt.gsocket.request("match.reward_info",{reward_id=self.mData.reward_id})
	end
end

function MatchInfoDialog:signNumRefreshFunc()
	if tt.gsocket:isConnected() then
		tt.gsocket.request("sng.start",{mlv=self.mlv})
	end
end

function MatchInfoDialog:startSignNumRefresh()
	if self.refreshSignNumAction then return end
	self.refreshSignNumAction = self:schedule(handler(self, self.signNumRefreshFunc), 1)
end

function MatchInfoDialog:stopSignNumRefresh()
	if self.refreshSignNumAction then
		self:stopAction(self.refreshSignNumAction)
		self.refreshSignNumAction = nil
	end
end

function MatchInfoDialog:setMatchId(id,status)
	printInfo("MatchInfoDialog id %s,status %d", id or "",status or -1)
	self.match_id = id
	self.status = status
end

function MatchInfoDialog:rankRefreshFunc()
	if self.match_id and self.mlv then
		local flag = self.status
		if flag == 2 and tt.gsocket:isConnected() then 
			tt.gsocket.request("sng.rank",{
					mlv = self.mlv,           --比赛场次
					match_id = self.match_id,   --比赛id
					mid = tt.owner:getUid(),           --用户的id
					begin = 1,         --排名起始值
					rnum = math.min(20,self.playerNum),         --排名个数   
				})
		end
	end
end

function MatchInfoDialog:startRankRefresh()
	if self.refreshRankAction then return end
	if self.isInRoom then return end
	self.refreshRankAction = self:schedule(handler(self, self.rankRefreshFunc), 10)
end

function MatchInfoDialog:stopRankRefresh()
	if self.refreshRankAction then
		self:stopAction(self.refreshRankAction)
		self.refreshRankAction = nil
	end
end

function MatchInfoDialog:checkFunc(view,fileFormat,flag)
	if flag then
		view:setButtonImage("normal",string.format(fileFormat,"pre"),true)
	else
		view:setButtonImage("normal",string.format(fileFormat,"nor"),true)
	end
end

function MatchInfoDialog:showInfoView()
	self:checkFunc(self.info_view_btn,"btn/btn_detrules_%s.png", true)
	self:checkFunc(self.blind_view_btn,"btn/btn_blstructure_%s.png", false)
	self:checkFunc(self.user_view_btn,"btn/btn_maninfo_%s.png", false)
	self.info_view:setVisible(true)
	self.blind_view:setVisible(false)
	self.user_view:setVisible(false)
	self:getRewardInfo()
	self:stopRankRefresh()
	self:refreshSignView()
end

function MatchInfoDialog:showBlindView()
	self:checkFunc(self.info_view_btn,"btn/btn_detrules_%s.png", false)
	self:checkFunc(self.blind_view_btn,"btn/btn_blstructure_%s.png", true)
	self:checkFunc(self.user_view_btn,"btn/btn_maninfo_%s.png", false)
	self.info_view:setVisible(false)
	self.blind_view:setVisible(true)
	self.user_view:setVisible(false)
	self:stopRankRefresh()
	self:stopSignNumRefresh()
end

function MatchInfoDialog:showUserView()
	self:checkFunc(self.info_view_btn,"btn/btn_detrules_%s.png", false)
	self:checkFunc(self.blind_view_btn,"btn/btn_blstructure_%s.png", false)
	self:checkFunc(self.user_view_btn,"btn/btn_maninfo_%s.png", true)
	self.info_view:setVisible(false)
	self.blind_view:setVisible(false)
	self.user_view:setVisible(true)
	self:startRankRefresh()
	self:rankRefreshFunc()
	self:stopSignNumRefresh()
end

function MatchInfoDialog:onRewardInfo(reward_info)
	if reward_info.reward_id ~= self.mData.reward_id then return end
	self.info_view_.rank_reward_list:removeAllItems()
	local list = self.info_view_.rank_reward_list
	-- local reward_table = {
	-- 			[1] = 60,  -- 最小名次的
	-- 			[3] = 40,  -- 第一名的为奖励60 2-3名为40 
	-- 			[6] = 20,  -- 4-6名的为20
	-- 		}--
	local reward_table = reward_info.reward_table
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
		    text = tt.getNumStr(reward),
		    size = 43,
		    color = cc.c3b(0xd9, 0xd8, 0xd8),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		rewardLable:setPosition(292,top/2)

		local dec = display.newSprite("dec/dec_enrolrules_list.png")
			:setPosition(248,top/2)

		content:addChild(rankLable)
		content:addChild(rewardLable)
		content:addChild(dec)

		list:addItem(item)
	end

	list:reload()
end

function MatchInfoDialog:onBlindInfo(blind_info)
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

function MatchInfoDialog:onRankUserView(rank_list)
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

function MatchInfoDialog:getPlayingInfo()
	-- if self.isInRoom then return end
	tt.gsocket.request("sng.blind",{mlv=self.mlv,match_id = self.match_id})
end

function MatchInfoDialog:updateBlindTxt()
	if not self.downtime then return end
	local downtime = self.downtime
	if downtime > 0 then
		self.info_view_.running_view_.blind_timer_txt:setString(tt.gettext("{s1}分鍾後",math.ceil(downtime/60)))
		-- self.info_view_.running_view_.blind_timer_txt:setVisible(true)
		-- self.info_view_.running_view_.next_blind_info_txt:setVisible(true)
		-- self.info_view_.running_view_.clock_dec:setVisible(true)
	else
		self.info_view_.running_view_.blind_timer_txt:setString(" - ")
		-- self.info_view_.running_view_.blind_timer_txt:setVisible(false)
		-- self.info_view_.running_view_.next_blind_info_txt:setVisible(false)
		-- self.info_view_.running_view_.clock_dec:setVisible(false)
	end
end

function MatchInfoDialog:setDownTime(downtime)
	self.downtime = tonumber(downtime) or 0
	self:updateBlindTxt()
	self:startBlindTimeClock()
end

function MatchInfoDialog:setMatchNextBChange(sb,bb,ante,isCur)
	if isCur then
		self.info_view_.running_view_.next_blind_info_txt:setString( tt.gettext("當前等級: {s1}/{s2} ante {s3}",tt.getNumStr(sb),tt.getNumStr(bb),tt.getNumStr(ante)))
	else
		self.info_view_.running_view_.next_blind_info_txt:setString( tt.gettext("下一等級: {s1}/{s2} ante {s3}",tt.getNumStr(sb),tt.getNumStr(bb),tt.getNumStr(ante)))
	end
end

function MatchInfoDialog:startBlindTimeClock()
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

function MatchInfoDialog:stopBlindTimeClock()
	if self.blindTimeClock then
		scheduler.unscheduleGlobal(self.blindTimeClock)
		self.blindTimeClock = nil
	end
end

function MatchInfoDialog:onSocketData(evt)
	tt.log.d(TAG, "cmd:[%s]",evt.cmd)	

	
	if evt.cmd == "match.reward_info" then 
		if evt.resp then
			if evt.resp.ret == 200 then
				self:onRewardInfo(evt.resp)
			end
		end

	elseif evt.cmd == "match.blind_info" then 
		if evt.resp.ret == 200 then 
			tt.nativeData.saveBlindInfo(evt.resp.blind_id,evt.resp.blind_table)
			if self.mData.blind_id == evt.resp.blind_id then
				self:initBlindInfo()
			end
		end
	elseif evt.cmd == "sng.start" then
		if evt.resp then
			if evt.resp.ret == 200 then
				if evt.resp.mlv == self.mlv then
					self.info_view_.sign_view_.sign_mun:setString( string.format("%d/%d",evt.resp.apply_num, evt.resp.start_num))
				end
			end
		elseif evt.broadcast then
			if evt.broadcast.mlv == self.mlv then
				self.info_view_.sign_view_.sign_mun:setString( string.format("%d/%d",evt.broadcast.apply_num, evt.broadcast.start_num))
			end
		end
	elseif evt.cmd == "sng.rank" then
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
				if self.mlv == evt.resp.mlv and self.match_id == evt.resp.match_id then
					dump(evt.resp)
					self:onRankUserView(evt.resp.ranks)
					self.info_view_.running_view_.play_mun:setString(string.format("%d/%d",evt.resp.left_num,self.playerNum))

					self.info_view_.running_view_.min_coin_txt:setString(tt.gettext("最低：{s1}",tt.getNumStr(evt.resp.min_coin)))
					self.info_view_.running_view_.average_coin_txt:setString(tt.gettext("平均：{s1}",tt.getNumStr(evt.resp.avg_coin)))
					self.info_view_.running_view_.max_coin_txt:setString(tt.gettext("最大：{s1}",tt.getNumStr(evt.resp.max_coin)))

					self.user_view_.my_rank_txt:setString(evt.resp.urank)
					if self.isInRoom then
						self.user_view_.my_chips_txt:setString(tt.getNumStr(self.control_:getSelfCoin()))
					end
				end
			end
		end
	elseif evt.cmd == "sng.blind" then
		if evt.resp then
			if self.mlv == evt.resp.mlv and self.match_id == evt.resp.match_id then
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
			if self.mlv == evt.broadcast.mlv and self.match_id == evt.broadcast.match_id then
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
	end
end

return MatchInfoDialog
