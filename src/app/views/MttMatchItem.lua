--
-- Author: bearluo
-- Date: 2017-05-26 15:24:32
--

local PropDataHelper = require("app.libs.PropDataHelper")

local MttMatchItem = class("MttMatchItem", function()
	return display.newNode()
end)


function MttMatchItem:ctor(control,data)
	self:setNodeEventEnabled(true)

	self.control_ = control 
	self.mData = data
	--find view by layout
	local node, width, height = cc.uiloader:load("mtt_match_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))


	self.mFreeIcon = cc.uiloader:seekNodeByName(node,"free_icon")
	if #data.entry == 0 then
		self.mFreeIcon:setVisible(true)
	else
		self.mFreeIcon:setVisible(false)
	end

	self.mRewardBg = cc.uiloader:seekNodeByName(node,"reward_bg")
	self.mRewardBg:setVisible(false)
	self.mRewardTxt = cc.uiloader:seekNodeByName(self.mRewardBg,"reward_txt")
	self.mRewardTxt:setLineHeight(30)

	self.mWinIcon = cc.uiloader:seekNodeByName(node,"win_icon")
	self.mWinIcon:setVisible(false)
	
	-- self.mSignNum = cc.uiloader:seekNodeByName(node,"sign_num")
	-- self.mSignNum:setString(data.apply_num)

	self.mNameTxt = cc.uiloader:seekNodeByName(node,"name_txt")
	self.mNameTxt:setString(data.mname or "")
	self.mNameTxt:setLineHeight(30)

	self.mRewardHandler = cc.uiloader:seekNodeByName(node,"reward_1_handler")
	self.mRewardHandler:setVisible(false)
	-- local num = 0

	-- for _,v in ipairs(data.entry) do
	-- 	if v.etype == 1 then
	-- 		num = v.num
	-- 	end
	-- end
	-- self:setRewardViewMoney( num )

	self.mSignCost = 0

	if #data.entry > 0 then
		self.mSignCost = data.entry[1].num
		self.mSignEtype = data.entry[1].etype
	end
	self:updateReward()

	self.mMatchIconHandler = cc.uiloader:seekNodeByName(node,"match_icon_handler")
	self.mWaitView = cc.uiloader:seekNodeByName(node,"wait_bg"):setVisible(false)
	self.mCountdownView =  cc.uiloader:seekNodeByName(node,"countdown_view"):setVisible(false)

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
	    -- dump(event)
	    local x,y = event.x,event.y
	    if event.name == "began" then
	    	startX = x
        	startY = y
        	if not self:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" then
		    	tt.play.play_sound("click")
				-- tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.cashBtn)
				self.control_:showMttMatchInfoDialog(self.mData)
			end
		end
		if event.name == "ended" then
		end
	end)
	self:updateStatusByTime()
	self:setIcon(data.icon)

end

function MttMatchItem:setDelete(delete)
	self.mDelete = delete
end

function MttMatchItem:updateReward()
	local reward_type,reward_id = self.mData.reward_type,self.mData.reward_id
	print("updateReward",reward_type,reward_id)
	if reward_type == 1 then
		local data = tt.nativeData.getRewardInfo(reward_id)
		if data then
			local fkey,fnum
			for key,num in pairs(data) do
				if not fkey or fkey > tonumber(key) then
					fkey = tonumber(key)
					fnum = num
				end
			end
			print("MttMatchItem:updateReward RewardInfo fkey,fnum",fkey,fnum)
			if fkey then
				self:setRewardViewMoney( fnum )
			end
		else
			tt.gsocket.request("match.reward_info",{reward_id=reward_id})
		end
	elseif reward_type == 2 then
		local data = tt.nativeData.getDrewardInfo(reward_id)
		local apply_num = math.max(self.mData.apply_num,self.mData.min_player)
		local total_jackpot = apply_num * (self.mSignCost - self.mData.fee)
		if data then
			local fnum = math.floor(tt.getDrewardInfo(data,apply_num,1) * total_jackpot / 100)
			self:setRewardViewMoney( fnum )
		else
			tt.gsocket.request("match.dreward_info",{reward_id=reward_id})
		end
	elseif reward_type == 3 then
		local data = tt.nativeData.getMrewardInfo(reward_id)
		if data then
			local fkey,fvalue
			dump(data,"updateReward MrewardInfo")
			for key,value in pairs(data) do
				print("MrewardInfo",fkey,key)
				if not fkey or fkey > tonumber(key) then
					fkey = tonumber(key)
					fvalue = value
				end
			end
			if fkey then
				if fvalue.vgoods then
					for goods_id,num in pairs(fvalue.vgoods) do
						self:setRewardViewStr("")
						if self.mHandler then
							PropDataHelper.unregister(self.mHandler)
						end
						self.mHandler = PropDataHelper.register(goods_id,function(prop_data)
								if tolua.isnull(self) then return end
								if num > 1 then
									self:setRewardViewStr(prop_data.sname .. 'X' .. num)
								else
									self:setRewardViewStr(prop_data.sname)
								end
							end)
						break
					end
				elseif fvalue.money then
					self:setRewardViewMoney( fvalue.money )
				elseif fvalue.score then
					self:setRewardViewStr( tt.getNumShortStr(fvalue.score) .. tt.gettext("vip点") )
				end
			end
		else
			tt.gsocket.request("match.mreward_info",{reward_id=reward_id})
		end
	end
end

function MttMatchItem:setIcon(url)
	tt.asynGetHeadIconSprite(string.urldecode(url or ""),function(sprite)
		if sprite and self and self.mMatchIconHandler then
			self.mMatchIconHandler:removeChildByTag(1)
			local size = self.mMatchIconHandler:getContentSize()
			sprite:setTag(1)
			sprite:addTo(self.mMatchIconHandler)
			sprite:setPosition(cc.p(size.width/2,size.height/2))
			-- local size = self.head_handler:getContentSize()
			-- local mask = display.newSprite("dec/zhezhao.png")
			-- if self.head_ then
			-- 	self.head_:removeSelf()
			-- 	self.head_ = nil
			-- end
			-- self.head_ = CircleClip.new(sprite,mask)
			-- 	:addTo(self.head_handler,99)
			-- 	:setPosition(cc.p(-1,-1))
			-- 	:setCircleClipContentSize(size.width,size.width)
		end
	end)
end

function MttMatchItem:nextMatch()
	if self.mData.left == 0 then
		-- 刪除自己
		if self.mDelete then
			self.mDelete(self)
		end
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
		dump(self.mData,"MttMatchItem:nextMatch")
		if not self.mData then
			self.mData = data
			tt.nativeData.saveMttInfo(data.match_id,data)
		end
	end
end

function MttMatchItem:updateStatusByTime()
	local stime,jtime,atime = self.mData.stime,self.mData.jtime,self.mData.atime
	local curTime = tt.time()
	local canJoinRoomTime = stime - jtime
	if curTime >= stime then
		-- 更新下一场或者删除自己
		print(curTime,stime,jtime,atime)
		self:nextMatch()
	elseif curTime >= canJoinRoomTime then
		-- 显示即将开始
		self:updateCountdownTips(true)
		self:showCountdownView(stime-curTime)
	elseif atime < 0 or stime - atime <= curTime then
		self:updateCountdownTips(false)
		self:showCountdownView(stime-curTime)
	else
		self:showWaitView(stime,atime)
	end

	-- self.mSignNum:setString(self.mData.apply_num)

	self:performWithDelay(function()
			self:updateStatusByTime()
		end, 1)
end

function MttMatchItem:updateApplyNum(num)
	self.mData.apply_num = tonumber(num) or 0
	-- self.mSignNum:setString(self.mData.apply_num)
	if self.mData.reward_type == 2 then
		self:updateReward()
	end
end

function MttMatchItem:getMatchId()
	return self.mData.match_id
end

function MttMatchItem:getRewardId()
	return self.mData.reward_id
end

function MttMatchItem:setRewardViewMoney(num)

	self.mRewardBg:setVisible(false)
	self.mWinIcon:setVisible(true)
	self.mRewardHandler:setVisible(true)

	self.mRewardHandler:removeAllChildren()
	self.mRewardHandler:setContentSize(0,self.mRewardHandler:getContentSize().height)
	num = tonumber(num) or 0 
	local view = tt.getBitmapStrAscii("number/yellow1_%d.png",tt.getNumShortStr(num))
	local txt = display.newSprite("fonts/chip.png")
	tt.linearlayout(self.mRewardHandler,view,0,-5)
	tt.linearlayout(self.mRewardHandler,txt,0,-3)
end

function MttMatchItem:setRewardViewStr(str)
	self.mRewardBg:setVisible(true)
	self.mRewardTxt:setString(str)
	self.mRewardHandler:setVisible(false)
	self.mWinIcon:setVisible(false)
end

function MttMatchItem:showWaitView(stime,jtime)
	if self.mWaitView:isVisible() then return end
	self.mWaitView:setVisible(true)
	self.mCountdownView:setVisible(false)

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

	cc.uiloader:seekNodeByName(self.mWaitView,"tips_txt"):setString(timeStr)

	local startTimeHandler = cc.uiloader:seekNodeByName(self.mWaitView,"start_time_handler")
	startTimeHandler:setContentSize(0,35)
	startTimeHandler:removeAllChildren()

	local obTime = os.date("*t",stime)
    local curTime = os.date("*t")
    local tomorrow = os.date("*t",tt.time()+86400)
    local tomorrow_tomorrow = os.date("*t",tt.time()+86400*2)
    local prefix
    -- 今天
    if not prefix and curTime.year == obTime.year and curTime.month == obTime.month and curTime.day == obTime.day then
        prefix = tt.gettext("今天")
    end
    if not prefix and tomorrow.year == obTime.year and tomorrow.month == tomorrow.month and tomorrow.day == obTime.day then
        prefix = tt.gettext("明天")
    end
    if not prefix and tomorrow_tomorrow.year == obTime.year and tomorrow_tomorrow.month == tomorrow.month and tomorrow_tomorrow.day == obTime.day then
        prefix = tt.gettext("后天")
    end
	if not prefix then
        prefix = tt.gettext("{s1}月{s2}日",obTime.month,obTime.day)
    end
	local time1 = display.newTTFLabel({
        text = prefix,
        size = 30,
        color=cc.c3b(0xff,0xff,0xff),
    })
	
	local timeHour = display.newSprite("dec/dec_time.png")
	local txt = display.newTTFLabel({
        text = string.format("%02d",obTime.hour),
        size = 36,
        x=21,
        y=17,
        color=cc.c3b(0xff,0xff,0xff),
    }):addTo(timeHour)

	local timeMinute = display.newSprite("dec/dec_time.png")
	local txt = display.newTTFLabel({
        text = string.format("%02d",obTime.min),
        size = 36,
        x=21,
        y=17,
        color=cc.c3b(0xff,0xff,0xff),
    }):addTo(timeMinute)

	local dec = display.newTTFLabel({
        text = ':',
        size = 36,
        color=cc.c3b(0xff,0xff,0xff),
    })

    tt.linearlayout(startTimeHandler,time1,10,0)
    tt.linearlayout(startTimeHandler,timeHour,10,0)
    tt.linearlayout(startTimeHandler,dec,5,-2)
    tt.linearlayout(startTimeHandler,timeMinute,5,0)

    local size = startTimeHandler:getContentSize()
    startTimeHandler:setPosition(cc.p(-size.width/2+90,0))
end

function MttMatchItem:showCountdownView(countdownTime)
	self.mWaitView:setVisible(false)
	self.mCountdownView:setVisible(true)

	if countdownTime < 0 then 
		return
	end

	local obTime = os.date("!*t",countdownTime)

	local countdownTimeHandler = cc.uiloader:seekNodeByName(self.mCountdownView,"countdown_time_handler")
	countdownTimeHandler:setContentSize(0,35)
	countdownTimeHandler:removeAllChildren()

	local timeHour = display.newSprite("dec/dec_time.png")
	local txt = display.newTTFLabel({
        text = string.format("%02d",obTime.hour),
        size = 36,
        x=21,
        y=17,
        color=cc.c3b(0xff,0xff,0xff),
    }):addTo(timeHour)

	local timeMinute = display.newSprite("dec/dec_time.png")
	local txt = display.newTTFLabel({
        text = string.format("%02d",obTime.min),
        size = 36,
        x=21,
        y=17,
        color=cc.c3b(0xff,0xff,0xff),
    }):addTo(timeMinute)


	local timeSecond = display.newSprite("dec/dec_time.png")
	local txt = display.newTTFLabel({
        text = string.format("%02d",obTime.sec),
        size = 36,
        x=21,
        y=17,
        color=cc.c3b(0xff,0xff,0xff),
    }):addTo(timeSecond)

	local dec1 = display.newTTFLabel({
        text = ':',
        size = 36,
        color=cc.c3b(0xff,0xff,0xff),
    })


	local dec2 = display.newTTFLabel({
        text = ':',
        size = 36,
        color=cc.c3b(0xff,0xff,0xff),
    })

    tt.linearlayout(countdownTimeHandler,timeHour,18,0)
    tt.linearlayout(countdownTimeHandler,dec1,5,0)
    tt.linearlayout(countdownTimeHandler,timeMinute,5,0)
    tt.linearlayout(countdownTimeHandler,dec2,5,0)
    tt.linearlayout(countdownTimeHandler,timeSecond,5,0)

end

function MttMatchItem:updateCountdownTips(canJoin)
	local countdown_tips = cc.uiloader:seekNodeByName(self.mCountdownView,"countdown_tips")
	if canJoin then
		if self.control_:isSignedMtt(self.mData.match_id) then
			countdown_tips:setTexture("dec/dec_yibaoming.png")
		else
			countdown_tips:setTexture("dec/dec_jijiangkaishi.png")
		end
	else
		if self.control_:isSignedMtt(self.mData.match_id) then
			countdown_tips:setTexture("dec/dec_yibaoming.png")
		else
			countdown_tips:setTexture("dec/dec_kaifangbaoming.png")
		end
	end
end


function MttMatchItem:onCleanup()
	if self.mHandler then
		PropDataHelper.unregister(self.mHandler)
		self.mHandler = nil
	end
end



return MttMatchItem
