local BLDialog = require("app.ui.BLDialog")
local TAG = "CustomRoomDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local CustomRoomDialog = class("CustomRoomDialog", function()
	return BLDialog.new()
end)


function CustomRoomDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("custom_room_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentView = cc.uiloader:seekNodeByName(node, "content_view")


	self.mRoomListView = cc.uiloader:seekNodeByName(node, "room_list_view")


	local inputClip = cc.uiloader:seekNodeByName(node, "room_input_clip")
	local size = inputClip:getContentSize()
	self.mRoomInput = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.name_input:setMaxLength(12)
    -- self.name_input:setPlaceHolder()
    self.mRoomInput:setPlaceHolder(tt.gettext("请输入房间ID"))
    self.mRoomInput:setFontName(display.DEFAULT_TTF_FONT)
    self.mRoomInput:setPlaceholderFontName(display.DEFAULT_TTF_FONT)
    self.mRoomInput:setFontSize(43)
    self.mRoomInput:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.mRoomInput:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.mRoomInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mRoomInput:addTo(inputClip)

    cc.uiloader:seekNodeByName(node, "search_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				local str = self.mRoomInput:getText()
				if str ~= "" and tonumber(str) then
					tt.gsocket.request("custom.look_up",{
							roomid = tonumber(str),
						})	
				end
			end)

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	self.mNextBtn = cc.uiloader:seekNodeByName(node, "next_page_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:nextPage()
			end)

	self.mPreBtn = cc.uiloader:seekNodeByName(node, "pre_page_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:prePage()
			end)

	cc.uiloader:seekNodeByName(node, "refresh_page_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:refresh()
			end)

	cc.uiloader:seekNodeByName(node, "add_money_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.control_:onShopClick()
			end)
	self.mCoinLabel = cc.uiloader:seekNodeByName(node,"money_txt")

	self.mVpBtn = cc.uiloader:seekNodeByName(node, "vp_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
    		self.control_:showVpDialog()
		end)
	self.mVpIcon = cc.uiloader:seekNodeByName(node, "vp_icon")

	self.mEmptyTipsView = cc.uiloader:seekNodeByName(node, "empty_tips_view")

	local tips_txt = cc.uiloader:seekNodeByName(node, "tips_txt"):setString(tt.gettext("创建自己的专属房间，打牌就能赢奖励！"))
	local tips_icon = cc.uiloader:seekNodeByName(node, "tips_icon")
	tt.LayoutUtil:layoutLeft(tips_icon,tips_txt)

	self.mCreateBtn = cc.uiloader:seekNodeByName(node, "create_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.control_:showCreateRoomDialog()
			end)

	local clip = cc.ClippingNode:create()
	local mask = display.newSprite("dec/dlight_area00.png")
	clip:setStencil(mask)
	clip:setAlphaThreshold(0.9)  --不显示模板的透明区域
	clip:setInverted( false ) --显示模板不透明的部分
	clip:setContentSize(mask:getContentSize().width,mask:getContentSize().height)
	clip:setPosition(cc.p(0,0))

	clip:addTo(self.mContentView)
	clip:setPosition(self.mCreateBtn:getPosition())
	
	local animView = display.newSprite("dec/fr_dlight.png")
	animView:setBlendFunc(gl.DST_ALPHA, gl.DST_ALPHA)
	animView:setOpacity(128)
	animView:setPosition(cc.p(-300, 0))
	clip:addChild(animView)
	local sequence = transition.sequence({
	    cc.DelayTime:create(1.4),
	    cc.MoveTo:create(0, cc.p(-300, 0)),
	    cc.MoveTo:create(1.5, cc.p(300, 0)),
	    cc.DelayTime:create(0),
	})
	animView:runAction(cc.RepeatForever:create(sequence))

	cc.uiloader:seekNodeByName(node, "feedback_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				tt.displayWebView(0,720,1280,720,true)
				tt.webViewLoadUrl(tt.ghttp.getGetUrl({mid=tt.owner:getUid()},kFacebackUrl))
				if device.platform == "windows" or device.platform == "mac" then
					device.openURL(tt.ghttp.getGetUrl({mid=tt.owner:getUid()},kFacebackUrl))
				end
			end)
end

function CustomRoomDialog:updateCoinLabel()
	local coin = tt.owner:getMoney()
	self.mCoinLabel:setString(tt.getNumStr(coin))
end

function CustomRoomDialog:updateVpExpView()
	if not tolua.isnull(self.mVpNum) then self.mVpNum:removeSelf() end
	local curLv = tt.owner:getVpLv()
	local curExp = tt.owner:getVpExp()
	local vpExpConfig = tt.nativeData.getVpExpConfig()
	if curLv == 6 then 
		local nExp = vpExpConfig[curLv] or 0
		self.mVpNum = tt.getBitmapStrAscii("number/yellow0_%d.png",string.format("%d/%d",curExp,nExp))
	else
		local nExp = vpExpConfig[curLv+1] or 0
		self.mVpNum = tt.getBitmapStrAscii("number/yellow0_%d.png",string.format("%d/%d",curExp,nExp))
	end
	self.mVpNum:scale(0.6)
	self.mVpNum:addTo(self.mVpBtn)
	tt.LayoutUtil:layoutParentCenter(self.mVpNum,25)
end

function CustomRoomDialog:updateVpLvView()
	local curLv = tt.owner:getVpLv()
	self.mVpIcon:setTexture(string.format("icon/vp_%d.png",curLv))
	self:updateVpExpView()
end

function CustomRoomDialog:show()
	BLDialog.show(self)
	self:resetRoomList()
	self:updateCoinLabel()
	self:updateVpLvView()
end

function CustomRoomDialog:dismiss()
	BLDialog.dismiss(self)
end

function CustomRoomDialog:resetRoomList()
	self.mCurIndex = 1
	self.mOffsetIndex = 5
	self.mTotalIndex = 0
	self.mIsHasMyRoom = false
	self:showEmptyRoomList()
	self:refresh()
end

function CustomRoomDialog:refresh()
	self.mRoomListView:removeAllItems()
	self.mRoomListView:reload()
	tt.gsocket.request("custom.show_rooms",{
			begin = self.mCurIndex,  --从第几个位置开始查找
			num = self.mOffsetIndex,   --本次共查找多少个房间
		})	
end

function CustomRoomDialog:roomListLoad(myRoom,roomList)
	local flag = true
	self.mRoomListView:removeAllItems()
	self.mIsHasMyRoom = myRoom and myRoom.roomid ~= nil
	local num = self.mOffsetIndex
	if self.mIsHasMyRoom then
		self:addRoomListItem(myRoom,true)
		local item = self.mRoomListView:newItem()
		local line = display.newSprite("dec/dec_dashed.png")
		local node = display.newNode()
		line:setPosition(cc.p(640,10))
		line:addTo(node)
		node:setContentSize(cc.size(1280,20))
		item:addContent(node)
		item:setItemSize(1280, 20)
		self.mRoomListView:addItem(item)
		flag = false
	end

	if roomList then
		for i=1,num do
			if roomList[i] then
				self:addRoomListItem(roomList[i])
				flag = false
			end
		end
	end

	if self.mCurIndex == 1 and not flag then
		local node = display.newNode()
		local view = self.mEmptyTipsView:clone()
		local item = self.mRoomListView:newItem()
		local size = view:getContentSize()
		view:setVisible(true)
		cc.uiloader:seekNodeByName(view, "tips_txt"):setString(tt.gettext("创建自己的专属房间，打牌就能赢奖励！"))
		view:addTo(node)
		item:addContent(node)
		node:setContentSize(cc.size(1280,size.height))
		tt.LayoutUtil:layoutParentCenter(view)
		item:setItemSize(1280,size.height)
		self.mRoomListView:addItem(item)
	end

	self.mRoomListView:reload()
	self.mEmptyTipsView:setVisible(flag)
end

function CustomRoomDialog:addRoomListItem(data,isSelf)
	local item = self.mRoomListView:newItem()
	local content = app:createView("CustomRoomItem", self.control_,data)
	item:addContent(content)
	local size = content:getContentSize()
	item:setItemSize(size.width+20, size.height)
	item:setMargin({left = 0, right = 0, top = 0, bottom = 0})
	self.mRoomListView:addItem(item)
end

function CustomRoomDialog:roomListLoadSearchRoom(room)
	self.mRoomListView:removeAllItems()
	self:addRoomListItem(room)
	self.mRoomListView:reload()
	self.mEmptyTipsView:setVisible(false)
end

function CustomRoomDialog:nextPage()
	local num = self.mOffsetIndex
	if self.mCurIndex + num <= self.mTotalIndex then
		self.mCurIndex = self.mCurIndex + num
		self:refresh()
		self:updateBtnStatus()
	end
end

function CustomRoomDialog:prePage()
	if self.mCurIndex ~= 1 then
		local num = self.mOffsetIndex
		self.mCurIndex = self.mCurIndex - num
		if self.mCurIndex < 1 then self.mCurIndex = 1 end
		self:refresh()
		self:updateBtnStatus()
	end
end

function CustomRoomDialog:updateBtnStatus()
	local num = self.mOffsetIndex
	self.mNextBtn:setButtonEnabled(self.mCurIndex + num <= self.mTotalIndex)
	self.mPreBtn:setButtonEnabled(self.mCurIndex ~= 1)
end

function CustomRoomDialog:showEmptyRoomList()
	self.mRoomListView:removeAllItems()
	self.mRoomListView:reload()
	self.mEmptyTipsView:setVisible(true)
	self.mNextBtn:setButtonEnabled(false)
	self.mPreBtn:setButtonEnabled(false)
end

function CustomRoomDialog:onEnter()
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}

	self.mUserInfoEventHandlers = {
		tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateCoinLabel)),
		-- tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_JUAN,handler(self,self.updateJuan)),
		-- tt.owner:addEventListener(tt.owner.EVENT_COINS,handler(self,self.updateCoins)),
		tt.owner:addEventListener(tt.owner.EVENT_VP_LV,handler(self,self.updateVpLvView)),
		tt.owner:addEventListener(tt.owner.EVENT_VP_EXP,handler(self,self.updateVpExpView)),
	}
end

function CustomRoomDialog:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

function CustomRoomDialog:onSocketData(evt)
	print("CustomRoomDialog onSocketData",evt.cmd)
	if evt.cmd == "custom.show_rooms" then
		if evt.resp then
			self.mCurIndex = evt.resp.begin
			self.mTotalIndex = evt.resp.total

			if self.mTotalIndex ~= 0 and self.mCurIndex > self.mTotalIndex then  
				self.mCurIndex = self.mTotalIndex
				self:refresh()
			else
				self:roomListLoad(evt.resp.myroom,evt.resp.roomlist)
			end
			self:updateBtnStatus()
		end
	elseif evt.cmd == "custom.look_up" then
		if evt.resp then
			if evt.resp.ret == 200 then
				self:roomListLoadSearchRoom(evt.resp.room)
			elseif evt.resp.ret == -101 then
				tt.show_msg(tt.gettext("房间不存在"))
			end
			self.mRoomInput:setText("")
		end
	end
end

return CustomRoomDialog