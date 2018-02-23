--
-- Author: bearluo
-- Date: 2017-05-26 15:24:32
--

local LttMatchItem = class("LttMatchItem", function()
	return display.newNode()
end)


function LttMatchItem:ctor(control)
	self.control_ = control 
	--find view by layout
	local node, width, height = cc.uiloader:load("ltt_match_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))


	
	self.mFreeIcon = cc.uiloader:seekNodeByName(node,"free_icon")
	self.mFreeIcon:setVisible(false)

	self.mWaitView = cc.uiloader:seekNodeByName(node,"wait_bg")
	self.mJoinBtn =  cc.uiloader:seekNodeByName(node,"join_btn")
	self.mCountdownView =  cc.uiloader:seekNodeByName(node,"countdown_view")


	-- self.apply_btn_ = cc.uiloader:seekNodeByName(node,"apply_btn")
	-- 	:onButtonClicked(function ()
	-- 		self.control_:onHallClick()
	-- 	end)
		-- :setTouchSwallowEnabled(false)
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
	    dump(event)
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
				-- self.control_:loadSngList()
			end
		end
		if event.name == "ended" then
		end
	end)

	self:showReliveView()
end


function LttMatchItem:showWaitView()
	self.mWaitView:setVisible(true)
	self.mJoinBtn:setVisible(false)
	self.mCountdownView:setVisible(false)
	self:stopAllActionsByTag(1)

	cc.uiloader:seekNodeByName(self.mWaitView,"tips_txt"):setString("")

	local startTimeHandler = cc.uiloader:seekNodeByName(self.mWaitView,"start_time_handler")
	startTimeHandler:setContentSize(0,35)
	startTimeHandler:removeAllChildren()

	local time1 = display.newTTFLabel({
        text = tt.gettext('今天'),
        size = 20,
        color=cc.c3b(0xff,0xff,0xff),
    })
	
	local timeHour = display.newSprite("dec/dec_time.png")
	local txt = display.newTTFLabel({
        text = '1',
        size = 20,
        x=17.5,
        y=14.5,
        color=cc.c3b(0xff,0xff,0xff),
    }):addTo(timeHour)

	local timeMinute = display.newSprite("dec/dec_time.png")
	local txt = display.newTTFLabel({
        text = '36',
        size = 20,
        x=17.5,
        y=14.5,
        color=cc.c3b(0xff,0xff,0xff),
    }):addTo(timeMinute)

	local dec = display.newTTFLabel({
        text = ':',
        size = 20,
        color=cc.c3b(0xff,0xff,0xff),
    })

    tt.linearlayout(startTimeHandler,time1,10,6)
    tt.linearlayout(startTimeHandler,timeHour,10,4)
    tt.linearlayout(startTimeHandler,dec,5,8)
    tt.linearlayout(startTimeHandler,timeMinute,5,4)
end


function LttMatchItem:showJoinView()
	self.mWaitView:setVisible(false)
	self.mJoinBtn:setVisible(true)
	self.mCountdownView:setVisible(false)
	self:stopAllActionsByTag(1)

	local timeTxt = cc.uiloader:seekNodeByName(self.mJoinBtn,"txt")
	local time = 100000
	local update = function()
			timeTxt:setString(tt.gettext("下次开奖时间 {s1}",os.date("%M:%S", time)))
			if time <= 0 then 
				self:stopAllActionsByTag(1)
				return
			end
			time = time - 1
		end
	update()
	self:schedule(update, 1):setTag(1)
end

function LttMatchItem:showReliveView()
	self.mWaitView:setVisible(false)
	self.mJoinBtn:setVisible(false)
	self.mCountdownView:setVisible(true)
	self:stopAllActionsByTag(1)

	local time1bg = cc.uiloader:seekNodeByName(self.mCountdownView,"time1_bg")
	local time2bg = cc.uiloader:seekNodeByName(self.mCountdownView,"time2_bg")

	local time = 70
	local update = function()
			local minute = os.date("%M", time)
			local second = os.date("%S", time)

			local minuteSp = tt.getBitmapStrAscii("number/yellow0_%d.png",minute)
			local secondSp = tt.getBitmapStrAscii("number/yellow0_%d.png",second)
			time1bg:removeAllChildren()
			time2bg:removeAllChildren()

			minuteSp:scale(0.8)
			secondSp:scale(0.8)
			minuteSp:setPosition(cc.p(4,15))
			secondSp:setPosition(cc.p(4,15))
			minuteSp:addTo(time1bg)
			secondSp:addTo(time2bg)

			if time <= 0 then 
				self:stopAllActionsByTag(1)
				return
			end
			time = time - 1
		end
	update()
	self:schedule(update, 1):setTag(1)
end

return LttMatchItem
