local BLDialog = require("app.ui.BLDialog")
local TAG = "CustomMasterDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local CustomMasterDialog = class("CustomMasterDialog", function()
	return BLDialog.new()
end)


function CustomMasterDialog:ctor(control,data)
	self.control_ = control 
	self.mData = data
	local node, width, height = cc.uiloader:load("custom_master_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)


	self.mRoomNameTxt = cc.uiloader:seekNodeByName(node,"room_name_txt")
	self.mPlayerNumTxt = cc.uiloader:seekNodeByName(node,"player_num_txt")

	self.mNameView = cc.uiloader:seekNodeByName(node,"name_view")
	self.mCreateInfoView = cc.uiloader:seekNodeByName(node,"create_info_view")
	self.mTimeInfoView = cc.uiloader:seekNodeByName(node,"time_info_view")
	self.mBlindInfoView = cc.uiloader:seekNodeByName(node,"blind_info_view")
	self.mBuyinInfoView = cc.uiloader:seekNodeByName(node,"buyin_info_view")
	self.mDecInfoView = cc.uiloader:seekNodeByName(node,"dec_info_view")
	self.mRoomRewardInfoView = cc.uiloader:seekNodeByName(node,"room_reward_info_view")
	self.mShowBg = cc.uiloader:seekNodeByName(node,"show_bg")
	self.mCostHandler = cc.uiloader:seekNodeByName(node,"cost_handler")
	self.mWatcherListview = cc.uiloader:seekNodeByName(node,"watcher_listview")


	cc.uiloader:seekNodeByName(node,"open_visible_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				tt.gsocket.request("custom.show_status",{
							roomid = data.roomid,
							show_status = 1,
						})
			end)

	local config = tt.nativeData.getCustomConfig()
	self:setRoomName(data.name)
	self:setNameView(data.owner_name,data.roomid)
	self:setCreateTime(data.create_time)
	self:setTime(data.left_time,data.ttime)
	self:setBlindInfo(data.sb,data.ante)
	self:setBuyin(data.min_buy,data.max_buy)
	self:setDec(data.msg)
	self:setPlayerNum(data.seat)
	self:setRoomReward(data.reward_money)
	self:setOpenVisible(data.show_status == 1,config.show_fee[data.sb .. ""] * math.ceil(data.left_time / 60))
end

function CustomMasterDialog:setOpenVisible(flag,cost)
	print("setOpenVisible",flag,cost)
	self.mShowBg:setVisible(not flag)
	if not flag then
		self.mCostHandler:removeAllChildren()
		local num = tt.getBitmapStrAscii("number/green00_%d.png",tt.getNumStr(cost))
		local icon = display.newSprite("icon/icon_chip7.png")
		num:scale(0.7)
		num:addTo(self.mCostHandler)
		icon:addTo(self.mCostHandler)
		tt.LayoutUtil:layoutParentCenter(num)
		tt.LayoutUtil:layoutLeft(icon,num)
	end
end

function CustomMasterDialog:setPlayerNum(player_num)
	self.mPlayerNumTxt:setString(player_num)
end

function CustomMasterDialog:setRoomName(name)
	self.mRoomNameTxt:setString(name)
end

function CustomMasterDialog:setRoomReward(reward)
	self.mRoomRewardInfoView:removeAllChildren()
	self.mRoomRewardInfoView:setContentSize(cc.size(0,0))
	local title = display.newTTFLabel({
	            text = tt.gettext("筹码奖励:"),
	            size = 43,
	            color=cc.c3b(0x86,0x5c,0x35),
	        })
		tt.linearlayout(self.mRoomRewardInfoView,title,0,-5)

	local txt = display.newTTFLabel({
            text = tt.getNumStr(reward),
            size = 43,
            color=cc.c3b(0x14,0x78,0xa7),
        })
	tt.linearlayout(self.mRoomRewardInfoView,txt,0,-5)

	local icon = display.newSprite("icon/icon_chip7.png")
	tt.linearlayout(self.mRoomRewardInfoView,icon,2,4)
end

function CustomMasterDialog:setNameView(name,room_id)
	self.mNameView:removeAllChildren()
	self.mNameView:setContentSize(cc.size(0,0))
	local title = display.newTTFLabel({
	            text = tt.gettext("创建者:"),
	            size = 43,
	            color=cc.c3b(0x86,0x5c,0x35),
	        })
		tt.linearlayout(self.mNameView,title,0,-5)

	local txt = display.newTTFLabel({
            text = name,
            size = 43,
            color=cc.c3b(0x14,0x78,0xa7),
        })
	tt.linearlayout(self.mNameView,txt,0,-5)

	local title = display.newTTFLabel({
	            text = tt.gettext("房间ID:"),
	            size = 43,
	            color=cc.c3b(0x86,0x5c,0x35),
	        })
		tt.linearlayout(self.mNameView,title,20,-5)

	local txt = display.newTTFLabel({
            text = room_id,
            size = 43,
            color=cc.c3b(0x14,0x78,0xa7),
        })
	tt.linearlayout(self.mNameView,txt,0,-5)
end

function CustomMasterDialog:setCreateTime(create_time)
	self.mCreateInfoView:removeAllChildren()
	self.mCreateInfoView:setContentSize(cc.size(0,0))
	local title = display.newTTFLabel({
	            text = tt.gettext("创建时间:"),
	            size = 43,
	            color=cc.c3b(0x86,0x5c,0x35),
	        })
		tt.linearlayout(self.mCreateInfoView,title,0,-5)

	local txt = display.newTTFLabel({
            text = os.date("%Y-%m-%d %H:%M:%S",create_time),
            size = 43,
            color=cc.c3b(0x14,0x78,0xa7),
        })
	tt.linearlayout(self.mCreateInfoView,txt,0,-5)
end

function CustomMasterDialog:setTime(countdown,total_time)
	self.mTimeInfoView:removeAllChildren()
	self.mTimeInfoView:setContentSize(cc.size(0,0))
	local title = display.newTTFLabel({
	            text = tt.gettext("剩余时间:"),
	            size = 43,
	            color=cc.c3b(0x86,0x5c,0x35),
	        })
		tt.linearlayout(self.mTimeInfoView,title,0,-5)

	local txt = display.newTTFLabel({
            text = os.date("!%H:%M",countdown),
            size = 43,
            color=cc.c3b(0x14,0x78,0xa7),
        })
	tt.linearlayout(self.mTimeInfoView,txt,0,-5)

	local txt = display.newTTFLabel({
            text = total_time/60,
            size = 43,
            color=cc.c3b(0x14,0x78,0xa7),
        })
	tt.linearlayout(self.mTimeInfoView,txt,30,-5)

	local title = display.newTTFLabel({
	            text = tt.gettext("小时"),
	            size = 43,
	            color=cc.c3b(0x86,0x5c,0x35),
	        })
		tt.linearlayout(self.mTimeInfoView,title,0,-5)
end

function CustomMasterDialog:setBlindInfo(sb,ante)
	self.mBlindInfoView:removeAllChildren()
	self.mBlindInfoView:setContentSize(cc.size(0,0))
	local blind_txt = display.newTTFLabel({
            text = string.format("%s/%s",tt.getNumShortStr2(sb),tt.getNumShortStr2(sb*2)),
            size = 43,
            color=cc.c3b(0x14,0x78,0xa7),
        })
	tt.linearlayout(self.mBlindInfoView,blind_txt,0,-5)
	local height = blind_txt:getContentSize().height
	if ante > 0 then
		local ante_title = display.newTTFLabel({
	            text = "ante",
	            size = 43,
	            color=cc.c3b(0x86,0x5c,0x35),
	        })
		tt.linearlayout(self.mBlindInfoView,ante_title,10,-5)
		local ante_txt = display.newTTFLabel({
	            text = tt.getNumShortStr2(ante),
	            size = 43,
	            color=cc.c3b(0x14,0x78,0xa7),
	        })
		tt.linearlayout(self.mBlindInfoView,ante_txt,5,-5)
	end
	local size = self.mBlindInfoView:getContentSize()
end

function CustomMasterDialog:setBuyin(min_buyin,max_buyin)
	self.mBuyinInfoView:removeAllChildren()
	self.mBuyinInfoView:setContentSize(cc.size(0,0))
	local title = display.newTTFLabel({
	            text = tt.gettext("买入:"),
	            size = 43,
	            color=cc.c3b(0x86,0x5c,0x35),
	        })
		tt.linearlayout(self.mBuyinInfoView,title,0,-8)
	local str = ""
	if min_buyin == max_buyin then
		str = max_buyin .. "BB"
	else
		str = string.format("%dBB~%dBB",min_buyin,max_buyin)
	end
	local txt = display.newTTFLabel({
            text = str,
            size = 43,
            color=cc.c3b(0x14,0x78,0xa7),
        })
	tt.linearlayout(self.mBuyinInfoView,txt,0,-8)
end

function CustomMasterDialog:setDec(dec)
	self.mDecInfoView:removeAllChildren()
	self.mDecInfoView:setContentSize(cc.size(0,0))
	local title = display.newTTFLabel({
	            text = tt.gettext("留言:"),
	            size = 43,
	            color=cc.c3b(0x86,0x5c,0x35),
	        })
		tt.linearlayout(self.mDecInfoView,title,0,-8)

	local txt = display.newTTFLabel({
            text = dec,
            size = 43,
            color=cc.c3b(0x14,0x78,0xa7),
        })
	tt.linearlayout(self.mDecInfoView,txt,0,-8)
end

function CustomMasterDialog:loadWatcherList(data)
	self.mWatcherListview:removeAllItems()
	if data then
		for i=1,#data do
			if data[i] then
				self:addWatcherItem(data[i])
			end
		end
	end
	self.mWatcherListview:reload()
end

function CustomMasterDialog:addWatcherItem(data)
	local item = self.mWatcherListview:newItem()
	local info = json.decode(data.info)
	local content = display.newNode()
	local head = display.newSprite("dec/def_head3.png")
	local dec = display.newSprite("dec/def_viewer.png")
	local name = display.newTTFLabel({
	            text = info.name,
	            size = 25,
	            color=cc.c3b(0x86,0x5c,0x35),
	        })
	tt.limitStr(name,info.name,80)
	head:addTo(content)
	head:scale(0.64)
	dec:addTo(content)
	dec:scale(0.8)
	name:addTo(content)

	content:setContentSize(cc.size(90,90))

	tt.LayoutUtil:layoutParentCenter(head,0,10)
	tt.LayoutUtil:layoutParentCenter(dec,0,10)
	tt.LayoutUtil:layoutParentBottom(name,0,-2)

	tt.asynGetHeadIconSprite(string.urldecode(info.img_url or ""),function(sprite)
		if sprite and not tolua.isnull(head) then
			local size = head:getContentSize()
			local mask = display.newSprite("dec/def_head4.png")
			CircleClip.new(sprite,mask)
				:addTo(head)
				:setPosition(cc.p(-1,-1))
				:setCircleClipContentSize(size.width,size.width)
		end
	end)


	item:addContent(content)
	local size = content:getContentSize()
	item:setItemSize(size.width, size.height)
	item:setMargin({left = 0, right = 0, top = 0, bottom = 0})
	self.mWatcherListview:addItem(item)
end

function CustomMasterDialog:show()
	BLDialog.show(self)
	tt.gsocket.request("custom.room_info",{
							roomid = self.mData.roomid,
						})
	tt.gsocket.request("texas.watcher_list",{
							lv = self.control_.mModel:getLv(),
							tid = self.control_.mModel:getTid(),
							begin = 1,   --观战列表的开始下标
							num = 20,     --本次获取的数量 
						})
end

function CustomMasterDialog:dismiss()
	BLDialog.dismiss(self)
end

function CustomMasterDialog:onEnter()
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}

	self.mUserInfoEventHandlers = {
		-- tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateCoinLabel)),
		-- tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_JUAN,handler(self,self.updateJuan)),
		-- tt.owner:addEventListener(tt.owner.EVENT_COINS,handler(self,self.updateCoins)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VP_LV,handler(self,self.updateVpLvView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VP_EXP,handler(self,self.updateVpExpView)),
	}
end

function CustomMasterDialog:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

function CustomMasterDialog:onSocketData(evt)
	print("CreateRoomDialog onSocketData",evt.cmd)
	if evt.cmd == "custom.show_status" then
		if evt.resp then
			if evt.resp.ret == 200 and evt.resp.roomid == self.mData.roomid then
				self:setOpenVisible(true)
				local params = self.control_.mModel:getCustomRoomParams()
				params.show_status = checkint(evt.resp.show_status)
			end
		end
	elseif evt.cmd == "custom.room_info" then
		if evt.resp then
			if evt.resp.ret == 200 and evt.resp.roomid == self.mData.roomid then
				self:setRoomReward(evt.resp.reward_money)
			end
		end
	elseif evt.cmd == "texas.watcher_list" then
		if evt.resp then
			if evt.resp.ret == 200 then
				self:loadWatcherList(evt.resp.list)
			end
		end
	end
end

return CustomMasterDialog