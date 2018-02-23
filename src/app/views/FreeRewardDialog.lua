local BLDialog = require("app.ui.BLDialog")
local FacebookHelper = require("app.libs.FacebookHelper")
local CircleClip = require("app.ui.CircleClip")

local FreeRewardDialog = class("FreeRewardDialog", function()
	return BLDialog.new()
end)


function FreeRewardDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("free_reward_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)


	self.mShareRewardView = cc.uiloader:seekNodeByName(node, "share_reward_view")
	self.mFbIcon = cc.uiloader:seekNodeByName(node, "fb_icon")
	self.mShareRewardTxtBg = cc.uiloader:seekNodeByName(node, "share_reward_txt_bg")
	self.mShareRewardTxt = cc.uiloader:seekNodeByName(self.mShareRewardTxtBg, "share_reward_txt")

	cc.uiloader:seekNodeByName(node, "share_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if device.platform == "windows" then
					tt.gsocket.request("reward.getreward",{mtype = "share"})
				else
					FacebookHelper.shareLink(kDownloadUrl)
				end
			end)

	cc.uiloader:seekNodeByName(node, "share_reward_txt"):setString(tt.gettext("分享奖励"))
	cc.uiloader:seekNodeByName(node, "invite_friends_txt"):setString(tt.gettext("邀请好友"))
	cc.uiloader:seekNodeByName(node, "invite_code_txt"):setString(tt.gettext("邀请码"))

	self.mShareRewardBtn = cc.uiloader:seekNodeByName(node, "share_reward_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:showShareRewardView()
			end)

	self.mInviteFriendsBtn = cc.uiloader:seekNodeByName(node, "invite_friends_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:showFbInviteView()
			end)

	self.mInviteCodeBtn = cc.uiloader:seekNodeByName(node, "invite_code_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:showInviteCodeView()
			end)

	self.mInviteFriendsView = cc.uiloader:seekNodeByName(node, "invite_friends_view")
	self.mInviteFriendsRuleTxt = cc.uiloader:seekNodeByName(self.mInviteFriendsView, "invite_friends_rule_txt")
	self.mInviteFriendsViewFbView = cc.uiloader:seekNodeByName(self.mInviteFriendsView, "fb_view"):setVisible(tt.owner:isFb())
	self.mInviteFriendsViewFbLoginView = cc.uiloader:seekNodeByName(self.mInviteFriendsView, "fb_login_view"):setVisible(not tt.owner:isFb())


	cc.uiloader:seekNodeByName(self.mInviteFriendsViewFbView, "refresh_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				FacebookHelper.getInvitableFriends()
			end)
	local inputClip = cc.uiloader:seekNodeByName(self.mInviteFriendsViewFbView, "search_input_clip")
	local size = inputClip:getContentSize()
	print("inputClip",size.width,size.height)
	self.mSearchInput = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.mSearchInput:setMaxLength(12)
    -- self.mSearchInput:setPlaceHolder("12333213")
    self.mSearchInput:setFontName(display.DEFAULT_TTF_FONT)
    self.mSearchInput:setFontSize(31)
    self.mSearchInput:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.mSearchInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mSearchInput:addTo(inputClip)


	cc.uiloader:seekNodeByName(self.mInviteFriendsViewFbView, "search_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				local name = self.mSearchInput:getText()
				if name ~= "" then
					self:search(name)
				end
			end)
	self.mSelectFriends = {}
	self.mFriendsListBtns = {}
	self.mFriendsList = cc.uiloader:seekNodeByName(self.mInviteFriendsViewFbView, "friends_list")
	self.mIsSelectAll = false
	self.mAllBtn = cc.uiloader:seekNodeByName(self.mInviteFriendsViewFbView, "all_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:setSelectAll(not self.mIsSelectAll)
				if self.mIsSelectAll then
					self:addAllSelectFriends()
				else
					self:clearAllSelectFriends()
				end
			end)
	
	cc.uiloader:seekNodeByName(self.mInviteFriendsViewFbView, "all_txt"):setString(tt.gettext("全选"))

	cc.uiloader:seekNodeByName(self.mInviteFriendsViewFbView, "invite_friends_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				local userIds = {}
				for id,value in pairs(self.mSelectFriends) do
					if value then
						table.insert(userIds,id)
					end
				end
				FacebookHelper.invitabelFriends(userIds,tt.gettext("快来和{s1}一起游戏，每天都有免费奖励！",tt.owner:getName()))
			end)

	cc.uiloader:seekNodeByName(self.mInviteFriendsViewFbLoginView, "fb_login_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				tt.nativeData.saveLoginData(0,{})
				app:enterScene("LoginScene", {true})
				tt.gsocket:close()
			end)

	self.mInviteCodeView = cc.uiloader:seekNodeByName(node, "invite_code_view")
	
	cc.uiloader:seekNodeByName(node, "url_txt"):setString("https://0x9.me/oTDyg")
	cc.uiloader:seekNodeByName(node, "code_dec_txt"):setString(tt.gettext("你的个人邀请码"))
	cc.uiloader:seekNodeByName(node, "code_txt"):setString(tt.owner:getFreeRewardData().mycode)
	cc.uiloader:seekNodeByName(node, "invite_code_rule_txt"):setString(tt.gettext("新玩家登录3天内，输入邀请码并进行3局现金场游戏，则双方均可获赠{s1}筹码",tt.getNumShortStr2(tt.owner:getFreeRewardData().invite_code)))
	cc.uiloader:seekNodeByName(node, "invite_code_rule_txt"):setLineHeight(30)
	local inputClip = cc.uiloader:seekNodeByName(node, "code_input_clip")
	local size = inputClip:getContentSize()
	self.mCodeInput = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.mCodeInput:setMaxLength(12)
    self.mCodeInput:setPlaceHolder(tt.gettext("请输入邀请码"))
    self.mCodeInput:setFontName(display.DEFAULT_TTF_FONT)
    self.mCodeInput:setFontSize(42)
    self.mCodeInput:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.mCodeInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mCodeInput:addTo(inputClip)

	cc.uiloader:seekNodeByName(node, "copy_url_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				local params = tt.platformEventHalper.cmds.copyToClipboard
				params.args = {
					text = kDownloadUrl,
				}
				local ok,ret = tt.platformEventHalper.callEvent(params)
				if ok then
					tt.show_msg(tt.gettext("复制成功"))
				else
					tt.show_msg(tt.gettext("复制失败"))
				end
			end)

	cc.uiloader:seekNodeByName(node, "copy_code_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				local params = tt.platformEventHalper.cmds.copyToClipboard
				params.args = {
					text = tt.owner:getFreeRewardData().mycode,
				}
				local ok,ret = tt.platformEventHalper.callEvent(params)
				if ok then
					tt.show_msg(tt.gettext("复制成功"))
				else
					tt.show_msg(tt.gettext("复制失败"))
				end
			end)

	self.mSelectDec = cc.uiloader:seekNodeByName(node, "select_dec")
	self.mMyCodeView = cc.uiloader:seekNodeByName(node, "my_code_view")
	self.mEditCodeView = cc.uiloader:seekNodeByName(node, "edit_code_view")
	
	cc.uiloader:seekNodeByName(node, "code_select_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if self.mMyCodeView:isVisible() then
					self:showEditView()
				else
					self:showCodeView()
				end
			end)

	cc.uiloader:seekNodeByName(node, "edit_select_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if self.mMyCodeView:isVisible() then
					self:showEditView()
				else
					self:showCodeView()
				end
			end)

	self.mCodeBtn = cc.uiloader:seekNodeByName(node, "code_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				local code = self.mCodeInput:getText()
				if code ~= "" then
					tt.gsocket.request("reward.write_invite",{mtype = "code",code=string.upper(code)})
				end
			end)
	self:updateInvertedStatus()
end
function FreeRewardDialog:updateInvertedStatus()
	self.mCodeInput:setTouchEnabled(not tt.owner:isInvited())
	self.mCodeBtn:setVisible(not tt.owner:isInvited())
end

function FreeRewardDialog:setShareReward(num)
	self.mShareRewardTxt:setString(tt.gettext("每天仅限一次,赠送{s1}筹码",tt.getNumShortStr2(num)))
	tt.fixBackgroudWidth(self.mShareRewardTxt,self.mShareRewardTxtBg,470,30)
	tt.LayoutUtil:layoutParentCenter(self.mShareRewardTxt)
	tt.LayoutUtil:layoutLeft(self.mFbIcon,self.mShareRewardTxtBg,-10)
end

function FreeRewardDialog:search(name)
	if not self.mFriendsDatas then return end
	local search = {}
	for i,data in ipairs(self.mFriendsDatas) do
		if string.find(data.name,name) then
			table.insert(search,data)
		end
	end
	self:reloadFriendsList(search)
end

function FreeRewardDialog:reloadFriendsList(datas)
	dump(datas,"reloadFriendsList")
	self.mFriendsDatas = checktable(datas)
	self.mFriendsList:removeAllItems()
	self.mFriendsListBtns = {}
	self:setSelectAll(false)
	self:clearAllSelectFriends()
	for k=1,#self.mFriendsDatas,6 do
		local item = self.mFriendsList:newItem()
		local content = display.newNode()
		for i=0,5 do
			local index = i+k
			local data = self.mFriendsDatas[index]
			if data then
				local btn = self:createUserBtn(data)
				tt.linearlayout(content,btn,9)
				self.mFriendsListBtns[index] = btn
			end
		end
		local size = content:getContentSize()
		content:setContentSize(cc.size(size.width, 120))
		item:addContent(content)
		item:setItemSize(size.width, 120)
		item:setMargin({left = 0, right = 0, top = 20, bottom = 0})
		self.mFriendsList:addItem(item)
	end
	self.mFriendsList:reload()

	self:setSelectAll(true)
	self:addAllSelectFriends()
end

function FreeRewardDialog:createUserBtn(data)
	local node, width, height = cc.uiloader:load("invite_friends_item.json")
	local head_bg = cc.uiloader:seekNodeByName(node, "head_bg")
	local icon_dec = cc.uiloader:seekNodeByName(node, "icon_dec")
	local name_txt = cc.uiloader:seekNodeByName(node, "name_txt")
	name_txt:setColor(cc.c3b(0xba,0x67,0x17))
	local isSelected = false
	tt.asynGetHeadIconSprite(data.picture.data.url,function(sprite)
		if sprite and not tolua.isnull(head_bg) then
			local size = head_bg:getContentSize()
			local mask = display.newSprite("dec/dec_friends.png")
			CircleClip.new(sprite,mask):addTo(head_bg)
				:setCircleClipContentSize(size.width,size.width)
		end
	end)

	tt.limitStr(name_txt,data.name,100)

	function node.setSelected(node,flag)
		isSelected = flag
		if flag then
			self:addSelectFriends(data.id)
			icon_dec:setTexture("dec/ckbox_friends_sel.png")
			name_txt:setColor(cc.c3b(0x17,0x73,0xba))
		else
			self:delSelectFriends(data.id)
			icon_dec:setTexture("dec/ckbox_friends.png")
			name_txt:setColor(cc.c3b(0xba,0x67,0x17))
		end
	end

	node:setTouchEnabled(true)
	node:setTouchSwallowEnabled(false)
	local startX,startY =0,0
	local down = false
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    local x,y = event.x,event.y
	    if event.name == "began" then
	    	startX = x
        	startY = y
        	if not node:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" then
				tt.play.play_sound("click")
				node:setSelected(not isSelected)
			end
		end
	end)

	return node
end

function FreeRewardDialog:addSelectFriends(id)
	self.mSelectFriends[id] = true
	print("addSelectFriends",self.mIsSelectAll,table.nums(self.mSelectFriends),#self.mFriendsDatas)
	if not self.mIsSelectAll and table.nums(self.mSelectFriends) == #self.mFriendsDatas and #self.mFriendsDatas > 0 then
		self:setSelectAll(true)
	end
end

function FreeRewardDialog:delSelectFriends(id)
	self.mSelectFriends[id] = nil
	if self.mIsSelectAll then
		self:setSelectAll(false)
	end
end

function FreeRewardDialog:clearAllSelectFriends()
	print("clearAllSelectFriends")
	self.mSelectFriends = {}
	for i,btn in ipairs(self.mFriendsListBtns) do
		btn:setSelected(false)
	end
end

function FreeRewardDialog:addAllSelectFriends()
	for i,btn in ipairs(self.mFriendsListBtns) do
		btn:setSelected(true)
	end
end

function FreeRewardDialog:setSelectAll(flag)
	print("setSelectAll",flag)
	self.mIsSelectAll = flag
	if flag then
		self.mAllBtn:setButtonImage("normal","dec/ckbox_tick_sel.png",true)
		self.mAllBtn:setButtonImage("pressed","dec/ckbox_tick_sel.png",true)
		self.mAllBtn:setButtonImage("disabled", "dec/ckbox_tick_sel.png", true)
	else
		self.mAllBtn:setButtonImage("normal","dec/ckbox_tick.png",true)
		self.mAllBtn:setButtonImage("pressed","dec/ckbox_tick.png",true)
		self.mAllBtn:setButtonImage("disabled", "dec/ckbox_tick.png", true)
	end
end

function FreeRewardDialog:show()
	BLDialog.show(self)
	self:showShareRewardView()
end

function FreeRewardDialog:showShareRewardView()
	self:setShareReward(tt.owner:getFreeRewardData().share)
	self.mShareRewardBtn:setButtonEnabled(false)
	self.mInviteFriendsBtn:setButtonEnabled(true)
	self.mInviteCodeBtn:setButtonEnabled(true)

	self.mShareRewardView:setVisible(true)
	self.mInviteFriendsView:setVisible(false)
	self.mInviteCodeView:setVisible(false)
end

function FreeRewardDialog:showFbInviteView()
	self.mInviteFriendsViewFbView:setVisible(tt.owner:isFb())
	self.mInviteFriendsViewFbLoginView:setVisible(not tt.owner:isFb())
	if tt.owner:isFb() then
		FacebookHelper.getInvitableFriends()
	end
	-- local data = {}
	-- for i=1,2 do
	-- 	table.insert(data,{
	--       	id = i,
	--       	name = "12323212312321id:" .. i,
	--       	picture = {
	--         	data = {
	-- 	          	is_silhouette = false,
	-- 	          	url = "https://scontent.xx.fbcdn.net/v/t1.0-1/c24.0.80.80/p80x80/1379841_10150004552801901_469209496895221757_n.jpg?oh=d15d84e401ea17e25741aa90a804bf8d&oe=5B256372"
	-- 	        }
	-- 	  	}
	--     })
	-- end
	-- self:reloadFriendsList(data)
	self.mInviteFriendsRuleTxt:setString(tt.gettext("每有一位新好友加入游戏，并进行3局游戏，你即可获赠{s1}筹码",tt.getNumShortStr2(tt.owner:getFreeRewardData().invite_fb)))

	self.mShareRewardBtn:setButtonEnabled(true)
	self.mInviteFriendsBtn:setButtonEnabled(false)
	self.mInviteCodeBtn:setButtonEnabled(true)

	self.mShareRewardView:setVisible(false)
	self.mInviteFriendsView:setVisible(true)
	self.mInviteCodeView:setVisible(false)
end

function FreeRewardDialog:showInviteCodeView()
	self.mShareRewardBtn:setButtonEnabled(true)
	self.mInviteFriendsBtn:setButtonEnabled(true)
	self.mInviteCodeBtn:setButtonEnabled(false)

	self.mShareRewardView:setVisible(false)
	self.mInviteFriendsView:setVisible(false)
	self.mInviteCodeView:setVisible(true)
	self:showCodeView()
end

function FreeRewardDialog:showCodeView()
	self.mSelectDec:stopAllActions()
	self.mSelectDec:moveTo(0.2, 257-126)
	self.mMyCodeView:setVisible(true)
	self.mEditCodeView:setVisible(false)

end

function FreeRewardDialog:showEditView()
	self.mSelectDec:stopAllActions()
	self.mSelectDec:moveTo(0.2, 257+125)
	self.mMyCodeView:setVisible(false)
	self.mEditCodeView:setVisible(true)
end


function FreeRewardDialog:dismiss()
	BLDialog.dismiss(self)
end

function FreeRewardDialog:onEnter()
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
		tt.gevt:addEventListener(tt.gevt.NATIVE_EVENT, handler(self, self.onNativeEvent)),
	}

	self.mUserInfoEventHandlers = {
		-- tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateMoney)),
		-- tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_JUAN,handler(self,self.updateJuan)),
		tt.owner:addEventListener(tt.owner.EVENT_INVITED,handler(self,self.updateInvertedStatus)),
	}
end

function FreeRewardDialog:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

function FreeRewardDialog:onSocketData(evt)
	if evt.cmd == "reward.write_invite" then
		if evt.resp then 
			if evt.resp.ret == 200 then
				tt.show_msg(tt.gettext("成功"))
				self.mCodeInput:setText("")
			else
				tt.show_msg(tt.gettext("失败"))
			end
		end
	end
end

function FreeRewardDialog:onNativeEvent(evt)
	if evt.cmd == tt.platformEventHalper.callbackCmds.FBGetInvitableFriendsCallback then
		local params = json.decode(evt.params)
		if params.ret == 1 then
			self:reloadFriendsList(params.data)
	 	elseif params.ret == 2 then
	 	elseif params.ret == 3 then
		end
	end
end

return FreeRewardDialog