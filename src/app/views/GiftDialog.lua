local BLDialog = require("app.ui.BLDialog")
local TAG = "GiftDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local GiftDialog = class("GiftDialog", function()
	return BLDialog.new()
end)


function GiftDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("gift_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	local inputClip = cc.uiloader:seekNodeByName(node, "id_input_clip")
	local size = inputClip:getContentSize()
	self.mIdInput = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.mIdInput:setMaxLength(12)
    self.mIdInput:setPlaceHolder(tt.gettext("请输入用户ID"))
    self.mIdInput:setFontName(display.DEFAULT_TTF_FONT)
    self.mIdInput:setFontSize(50)
    self.mIdInput:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.mIdInput:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.mIdInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mIdInput:addTo(inputClip)
    self.mIdInput:registerScriptEditBoxHandler(function (event)
	    if event == "began" then
	        -- 开始输入
	    elseif event == "changed" then
	        -- 输入框内容发生变化
	    elseif event == "ended" then
	        -- 输入结束
	        self:checkIdInput()
	    elseif event == "return" then
	        -- 从输入框返回
	    end
	end)

	local inputClip = cc.uiloader:seekNodeByName(node, "chips_input_clip")
	local size = inputClip:getContentSize()
	self.mChipsInput = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.mIdInput:setMaxLength(12)
    self.mChipsInput:setPlaceHolder(tt.gettext("请输入筹码数量"))
    self.mChipsInput:setFontName(display.DEFAULT_TTF_FONT)
    self.mChipsInput:setFontSize(45)
    self.mChipsInput:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.mChipsInput:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.mChipsInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mChipsInput:addTo(inputClip)
    self.mChipsInput:registerScriptEditBoxHandler(function (event)
	    if event == "began" then
	        -- 开始输入
	    elseif event == "changed" then
	        -- 输入框内容发生变化
	    elseif event == "ended" then
	        -- 输入结束
	        self:checkChipsInput()
	    elseif event == "return" then
	        -- 从输入框返回
	    end
	end)

	cc.uiloader:seekNodeByName(node, "search_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				local mid = checkint(self.mIdInput:getText())
				if mid == 0 or mid == tt.owner:getUid() then
					return 
				end
   				tt.gsocket.request("game.lookup_player",{mid=mid})
			end)

	self.mIdErrorView = cc.uiloader:seekNodeByName(node, "id_error_view"):setVisible(false)
	

	self.head_icon = cc.uiloader:seekNodeByName(node,"head_icon")
	self.mNameTxt = cc.uiloader:seekNodeByName(node, "name_txt")
	self.mIdTxt = cc.uiloader:seekNodeByName(node, "id_txt")

	self.mMaxChips = 0
	self.mMinChipsLeft = 0
	self.mMaxChipsTxt = cc.uiloader:seekNodeByName(node, "max_chips_txt")
	self.mLeftChipsTxt = cc.uiloader:seekNodeByName(node, "left_chips_txt")
	self.mMinChipsTxt = cc.uiloader:seekNodeByName(node, "min_chips_txt")

	self.mSendBtn = cc.uiloader:seekNodeByName(node, "send_btn")
		:setButtonEnabled(false)
		:onButtonClicked(function()
				tt.play.play_sound("click")
				local chips = tt.owner:getMoney()
				local money = checkint(self.mChipsInput:getText())
				if self.mGiftMid and money > 0 and chips > self.mMinChipsLeft then
   					tt.gsocket.request("game.gift_money",{
   							mid = tt.owner:getUid(),
   							gift_mid = self.mGiftMid,
   							money = money,
   						})
				end
			end)


	self.mIdErrorTxt = cc.uiloader:seekNodeByName(node,"id_error_txt")
	self.mChipsErrorTxt = cc.uiloader:seekNodeByName(node, "chips_error_txt"):setVisible(false)
	self.mFbIcon = cc.uiloader:seekNodeByName(node, "fb_icon"):setVisible(false)

end

function GiftDialog:checkIdInput()
	local mid = checkint(self.mIdInput:getText())
	if mid == 0 or mid == tt.owner:getUid() then
		self.mIdErrorTxt:setString(tt.gettext("输入用户ID错误"))
		self.mIdErrorView:setVisible(true)
		return 
	else
		self.mIdErrorView:setVisible(false)
	end
end

function GiftDialog:checkChipsInput()
	self.mSendBtn:setButtonEnabled(false)
	local money = checkint(self.mChipsInput:getText())
	if money <= 0 then
		self.mChipsErrorTxt:setString(tt.gettext("额度不对，请修改额度"))
		self.mChipsErrorTxt:setVisible(true)
		return
	end
	if money > self.mMaxChips then
		self.mChipsErrorTxt:setString(tt.gettext("额度不对，请修改额度"))
		self.mChipsErrorTxt:setVisible(true)
		return
	end
	self.mChipsErrorTxt:setVisible(false)
	self.mSendBtn:setButtonEnabled(self.mGiftMid ~= nil)
end

function GiftDialog:onEdit(textfield, eventType)
	print(textfield,eventType)
    if eventType == 0 then
        -- ATTACH_WITH_IME
    elseif eventType == 1 then
        -- DETACH_WITH_IME
        if self.mIdInput == textfield then
        	self:checkIdInput()
        elseif self.mChipsInput == textfield then
        	self:checkChipsInput()
        end
    elseif eventType == 2 then
        -- INSERT_TEXT
        if self.mIdInput == textfield then
        	local str = self.mIdInput:getString()
        	local num = string.gsub(str,"%D","")
        	self.mIdInput:setString(num)
        elseif self.mChipsInput == textfield then
        	local str = self.mChipsInput:getString()
        	local num = string.gsub(str,"%D","")
        	self.mChipsInput:setString(num)
        end
    elseif eventType == 3 then
        -- DELETE_BACKWARD
    end
end

function GiftDialog:updateHeadIcon(url)
	printInfo("updateHeadIcon %s", url)
	if not tolua.isnull(self.head_) then
		self.head_:removeSelf()
	end
	tt.asynGetHeadIconSprite(url,function(sprite)
		if sprite and self and self.head_icon then
			local size = self.head_icon:getContentSize()
			local mask = display.newSprite("dec/def_head2.png")
			if not tolua.isnull(self.head_) then
				self.head_:removeSelf()
			end

			self.head_ = CircleClip.new(sprite,mask):addTo(self.head_icon)
				:setCircleClipContentSize(size.width,size.width)

			-- local scalX=size.width/sprite:getContentSize().width--设置x轴方向的缩放系数
			-- local scalY=size.height/sprite:getContentSize().height--设置y轴方向的缩放系数
			-- sprite:setAnchorPoint(cc.p(0, 0))
			-- 	:setScaleX(scalX)
			-- 	:setScaleY(scalY)

			-- self.head_ = sprite:addTo(self.head_icon)
			-- self.head_:setPosition(cc.p(0,0))
		end
	end)
end

function GiftDialog:show()
	BLDialog.show(self)
	tt.gsocket.request("game.gift_minfo",{mid=mid})
end

function GiftDialog:dismiss()
	BLDialog.dismiss(self)
end

function GiftDialog:onEnter()
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}

	self.mUserInfoEventHandlers = {
		-- tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateMoney)),
		-- tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_JUAN,handler(self,self.updateJuan)),
		-- tt.owner:addEventListener(tt.owner.EVENT_COINS,handler(self,self.updateCoins)),

	}
end

function GiftDialog:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

function GiftDialog:onSocketData(evt)
	print("TouzhuGameView onSocketData",evt.cmd)
	if evt.cmd == "game.lookup_player" then
		if evt.resp then
			if evt.resp.ret == 200 then
				self.mGiftMid = evt.resp.mid
				self.mNameTxt:setString(evt.resp.mnick)
				self.mIdTxt:setString("ID:" .. evt.resp.mid)
				self:updateHeadIcon(evt.resp.icon)
				self.mIdErrorView:setVisible(false)
				self.mFbIcon:setVisible(evt.resp.sid == 101)
				local money = checkint(self.mChipsInput:getText())
				self.mSendBtn:setButtonEnabled(money > 0 and money <= self.mMaxChips)
			else
				self.mIdErrorTxt:setString(tt.gettext("用户不存在"))
				self.mIdErrorView:setVisible(true)
			end
		end
	elseif evt.cmd == "game.gift_minfo" then
		if evt.resp then
			self.mMaxChips = evt.resp.gift_left
			self.mMinChipsLeft = evt.resp.min_left
			local chips = tt.owner:getMoney()
			local can = math.max(chips - self.mMinChipsLeft,0)
			self.mMaxChipsTxt:setString(tt.gettext("最多赠送 {s1} 筹码",tt.getNumShortStr2(math.min(can,self.mMaxChips))))
			self.mLeftChipsTxt:setString(tt.gettext("今天还剩{s1}的赠送额度",tt.getNumShortStr2(self.mMaxChips)))
			self.mMinChipsTxt:setString(tt.gettext("账户内最少保留{s1}筹码",tt.getNumShortStr2(self.mMinChipsLeft)))
		end
	elseif evt.cmd == "game.gift_money" then
		if evt.resp then
			if evt.resp.ret == 200 then
				self.mChipsInput:setText("")
				self.mSendBtn:setButtonEnabled(false)
				self.mMaxChips = evt.resp.gift_left
				local chips = tt.owner:getMoney()
				local can = math.max(chips - self.mMinChipsLeft,0)
				self.mMaxChipsTxt:setString(tt.gettext("最多赠送 {s1} 筹码",tt.getNumShortStr2(math.min(can,self.mMaxChips))))
				self.mLeftChipsTxt:setString(tt.gettext("今天还剩{s1}的赠送额度",tt.getNumShortStr2(self.mMaxChips)))

				self.mChipsErrorTxt:setVisible(false)
				tt.show_msg(tt.gettext("赠送成功"))
			else
				tt.show_msg(tt.gettext("操作失败，请稍后再试"))
			end
		end
	end
end

return GiftDialog