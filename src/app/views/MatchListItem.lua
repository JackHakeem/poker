--
-- Author: shineflag
-- Date: 2017-03-26 15:24:32
--

local MatchListItem = class("MatchListItem", function()
	return display.newNode()
end)


function MatchListItem:ctor(control, data)



	self.control_ = control 

	self.mlv_ = data.mlv
	self.mData = data
	--find view by layout
	local node, width, height = cc.uiloader:load("match_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	-- self.bg = cc.uiloader:seekNodeByName(node,"bg")
	-- local ct = data.ct

	-- if ct == 1 then
	-- 	self.bg:setTexture("dec/kuang_2.png")
	-- elseif ct == 2 then
	-- 	self.bg:setTexture("dec/kuang_2.png")
	-- else
	-- 	self.bg:setTexture("dec/kuang_2.png")
	-- end

	--比赛名称
	cc.uiloader:seekNodeByName(node,"name_txt"):setString( tostring(data.mname) )


	self.mFreeIcon = cc.uiloader:seekNodeByName(node,"free_icon")
	local num = 0 
	for _,v in ipairs(data.entry) do
		if v.etype == 1 then
			num = v.num
			break
		end
	end
	self.mFreeIcon:setVisible(num == 0)
	self.mWaitBg = cc.uiloader:seekNodeByName(node,"wait_bg")

	-- cc.uiloader:seekNodeByName(self.mWaitBg,"num"):setString(tonumber(data.player) or 0)

	-- 	:setString( string.format("买入:%s",data.entry[1].num) )

	self.mRewardHandler = cc.uiloader:seekNodeByName(node,"reward_1_handler")
	self:setRewardView( data.cp_reward )


	-- self.status_icon = cc.uiloader:seekNodeByName(node,"status_icon")
	-- self.status_icon:setVisible(false)

	self.mApplyBtn = cc.uiloader:seekNodeByName(node,"apply_btn")
	self:addTouchEvt()

end

function MatchListItem:getMatchLv()
	return self.mlv_
end

function MatchListItem:updateApplyNum(data)
	if self.mApplyNumView then
		self.mApplyNumView:removeSelf()
	end

	self.mApplyNumView = tt.getBitmapStrAscii("number/yellow0_%d.png",string.format("%d/%d",data.apply_num, data.start_num))
	local contentSize = self.mApplyNumView:getContentSize()

	self.mApplyNumView:addTo(self.mWaitBg)
	self.mApplyNumView:setPosition(cc.p(120-contentSize.width/2,10))
end

function MatchListItem:setRewardView(num)
	self.mRewardHandler:removeAllChildren()
	self.mRewardHandler:setContentSize(0,self.mRewardHandler:getContentSize().height)
	num = tonumber(num) or 0 
	local view = tt.getBitmapStrAscii("number/yellow1_%d.png",tostring(num) or "")
	local txt = display.newSprite("fonts/chip.png")
	tt.linearlayout(self.mRewardHandler,view)
	tt.linearlayout(self.mRewardHandler,txt)
end

function MatchListItem:addTouchEvt()
	self.mApplyBtn:setTouchEnabled(true)
	self.mApplyBtn:setTouchSwallowEnabled(false)
	local startX,startY =0,0
	local down = false
	self.mApplyBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    -- event.name 是触摸事件的状态：began, moved, ended, cancelled
	    -- event.x, event.y 是触摸点当前位置
	    -- event.prevX, event.prevY 是触摸点之前的位置
	    -- printf("sprite: %s x,y: %0.2f, %0.2f",
	    --        event.name, event.x, event.y)

	    -- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
	    -- 则必须返回 true
	    local x,y = event.x,event.y
	    if event.name == "began" then
	    	startX = x
        	startY = y
        	if not self.mApplyBtn:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" and down then
		    	tt.play.play_sound("click")
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.matchBtn,{name=tostring(self.mData.mname)})
				self.control_:showMatchInfoDialog(self.mData)
			end
		end
	end)
end



return MatchListItem
