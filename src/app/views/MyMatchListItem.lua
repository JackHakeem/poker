--
-- Author: bearluo
-- Date: 2017-05-27
--

local MyMatchListItem = class("MyMatchListItem", function()
	return display.newNode()
end)

local TAG = "MyMatchListItem"

function MyMatchListItem:ctor(control,index,data,type)
	self.control_ = control 
	self.data_ = data
	self.index_ = index
	local node, width, height = cc.uiloader:load("my_match_list_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.index_txt = cc.uiloader:seekNodeByName(node,"index_txt")
	self.name_txt = cc.uiloader:seekNodeByName(node,"name_txt")
	self.status_txt = cc.uiloader:seekNodeByName(node,"status_txt")
	self.status_icon = cc.uiloader:seekNodeByName(node,"bg")

	self.click_btn = cc.uiloader:seekNodeByName(node,"click_btn")
		-- :onButtonClicked(handler(self, self.onMatchListBtnClick)

    self.index_txt:setString(self.index_)

    self.room_type = type


    if self.room_type == kCashRoom then
    	dump(self.data_)
    	local cashData = self:getCashData(self.data_.lv)
    	if cashData then
    		self.name_txt:setString(cashData.name)
	    else
	    	self.name_txt:setString(tt.gettext("現金場"))
		end
    	self:setMatchStatus(2)
    elseif self.room_type == kSngRoom then
	    self.name_txt:setString(self.data_.mname)
	    self:setMatchStatus(self.data_.status)
	elseif self.room_type == kMttRoom then
	    self.name_txt:setString(self.data_.mname)
	    self:setMatchStatus(self.data_.status)
	elseif self.room_type == kCustomRoom then
	    self.name_txt:setString(self.data_.name)
    	self:setMatchStatus(2)
    end
    self:addTouch()
end

function MyMatchListItem:getCashData(lv)
	print('----------',lv)
	local data = tt.nativeData.getCashInfo()
	dump(data)
	for i,v in ipairs(data) do
		if v.lv == lv then
			return v
		end
	end
	return 
end

function MyMatchListItem:setDialogHandler(handler)
	self.mHandler = handler
end

function MyMatchListItem:dismisDialog()
	if self.mHandler then
		self.mHandler:dismiss()
	end
end

function MyMatchListItem:setMatchStatus(status)
	if status == 1 then
		self.status_txt:setString(tt.gettext("报名中"))
		self.status_icon:setTexture("bg/bg_applying.png")
	elseif status == 2 then
		self.status_txt:setString(tt.gettext("进行中"))
		self.status_icon:setTexture("bg/bg_ongoing.png")
	else
		self.status_txt:setString("")
	end
end

function MyMatchListItem:entryRoom()
	if self.room_type == kCashRoom then
		self.control_:gotoRoom(self.data_.lv,self.data_.tid, kCashRoom)
	elseif self.room_type == kCustomRoom then
		self.control_:gotoRoom(self.data_.clv,self.data_.tid, kCustomRoom,self.data_)
    elseif self.room_type == kSngRoom then
    	if self.data_.status == 2 then
			self.control_:gotoRoom(self.data_.mlv, self.data_.match_id,kSngRoom)
		elseif self.data_.status == 1 then
			local data = tt.nativeData.getSngInfo(self.data_.mlv)
			if not data then 
				tt.gsocket.request("sng.mlv_info",{mlv=self.data_.mlv})
				return
			end
			self.control_:showMatchInfoDialog(data)
			self:dismisDialog()
		end
	elseif self.room_type == kMttRoom then
		if self.data_.status == 2 then
			self.control_:gotoRoom(self.data_.mlv, self.data_.match_id,kMttRoom)
		elseif self.data_.status == 1 then
			self.control_:checkShowMttMatchInfoDialog(self.data_.match_id)
			self:dismisDialog()
		end
    end
end



function MyMatchListItem:addTouch()
	self.click_btn:setTouchEnabled(true)
	self.click_btn:setTouchSwallowEnabled(false)
	local startX,startY =0,0
	local down = false
	self.click_btn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
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
        	if not self.click_btn:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" then
				tt.play.play_sound("click")
				self:entryRoom()
			end
		end
	end)
end

return MyMatchListItem
