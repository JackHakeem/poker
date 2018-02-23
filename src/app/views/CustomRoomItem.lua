--
-- Author: bearluo
-- Date: 2017-05-26 15:24:32
--

local CustomRoomItem = class("CustomRoomItem", function()
	return display.newNode()
end)


function CustomRoomItem:ctor(control,data)
	self.control_ = control 
	--find view by layout
	local node, width, height = cc.uiloader:load("custom_room_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))
	self.mData = data
	
	self.mContentView = cc.uiloader:seekNodeByName(node,"content_view")
	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")
	-- {  
	-- 				ownerid = 10035,  --房主id
	-- 				roomid = 1001,  --房号 1001-9999 四位数字
	-- 				clv = 9999,    --自定房间的场次号:目前都为9999
	-- 				tid = 5001,   --房间id
	-- 				name = "xxx", --房间名称 
	-- 				ante = 50,   --前注
	-- 				sb = 50,    --小盲  大盲=2X小盲
	-- 				left_time = 3600,  --房间剩余时间:s
	-- 				create_time = 60,  --房间创建时间unix时间戳
	-- 				min_buy = 100,   --最小买入的大盲数 
	-- 				max_buy = 400,   --最高买入的大盲数
	-- 				seat = 6,   --几人座 
	-- 				players = 5,  --在玩数
	-- 				watchers = 2,  --观战人数
	-- 				show_status = 0,  --大厅展示状态 0:不可见 1：可见
	-- 			},
	if data.ownerid == tt.owner:getUid() then
		self.mNorPath = "bg/list_bg_me.png"
		self.mSelPath = "bg/list_bg_me_sel.png"
	else
		self.mNorPath = "bg/list_bg.png"
		self.mSelPath = "bg/list_bg_sel.png"
	end
	self.mContentBg:setTexture(self.mNorPath)

	cc.uiloader:seekNodeByName(node,"room_id_txt"):setString(data.roomid)
	cc.uiloader:seekNodeByName(node,"room_name_txt"):setString(data.name)
	self.mBlindInfoView = cc.uiloader:seekNodeByName(node,"blind_info_view")
	self:setBlindInfo(data.sb,data.ante)
	self.mCountdownTxt = cc.uiloader:seekNodeByName(node,"countdown_txt")
	self:startCountDown(data.left_time)
	cc.uiloader:seekNodeByName(node,"player_num_txt"):setString(string.format("%d/%d",data.players,data.seat))

	self:addTouchEvent()
end

function CustomRoomItem:setBlindInfo(sb,ante)
	self.mBlindInfoView:removeAllChildren()
	self.mBlindInfoView:setContentSize(cc.size(0,0))
	local blind_txt = display.newTTFLabel({
            text = string.format("%s/%s",tt.getNumShortStr2(sb),tt.getNumShortStr2(sb*2)),
            size = 50,
            color=cc.c3b(0x21,0x68,0xb1),
        })
	tt.linearlayout(self.mBlindInfoView,blind_txt)
	local height = blind_txt:getContentSize().height
	if ante > 0 then
		local ante_title = display.newTTFLabel({
	            text = "ante",
	            size = 50,
	            color=cc.c3b(0x8b,0x56,0x17),
	        })
		tt.linearlayout(self.mBlindInfoView,ante_title,5)
		local ante_txt = display.newTTFLabel({
	            text = tt.getNumShortStr2(ante),
	            size = 50,
	            color=cc.c3b(0x21,0x68,0xb1),
	        })
		tt.linearlayout(self.mBlindInfoView,ante_txt,5)
	end

	local size = self.mBlindInfoView:getContentSize()
	tt.LayoutUtil:layoutParentCenter(self.mBlindInfoView,200-size.width/2,-height/2)
end

function CustomRoomItem:startCountDown(time)
	print("startCountDown",time)
	local endTime = os.time() + time
	self.mEndTime = endTime
	local update = function()
			local countdown = endTime - os.time()
			if countdown < 0 then countdown = 0 end
			self.mCountdownTxt:setString(os.date("!%H:%M",countdown))
			if countdown == 0 then 
				self.mCountdownTxt:stopAllActions()
				return
			end
		end
	self.mCountdownTxt:stopAllActions()
	update()
	self.mCountdownTxt:schedule(function()
			update()
		end, 1)
end

function CustomRoomItem:addTouchEvent()
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(false)
	local startX,startY =0,0
	local down = false
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    local x,y = event.x,event.y
		if event.name == "ended" then
			self.mContentBg:setTexture(self.mNorPath)
		end
	    if event.name == "began" then
	    	startX = x
        	startY = y
        	if not self:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
			self.mContentBg:setTexture(self.mSelPath)
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" then
		    	tt.play.play_sound("click")
		    	if self.mEndTime > os.time() then
					self.control_:gotoRoom(self.mData.clv,self.mData.tid, kCustomRoom,self.mData)
				end
			end
		end
	end)
end

return CustomRoomItem
