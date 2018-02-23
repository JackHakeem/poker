local BLDialog = require("app.ui.BLDialog")
local CircleClip = require("app.ui.CircleClip")

local RoomUserinfoDialog = class("RoomUserinfoDialog", function()
	return BLDialog.new()
end)


function RoomUserinfoDialog:ctor(control)
	self.mControl = control 

	local node, width, height = cc.uiloader:load("room_userinfo_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	self.mHeadBg = cc.uiloader:seekNodeByName(node, "head_bg")
	self.mFbIcon = cc.uiloader:seekNodeByName(node, "fb_icon")
	self.mNameTxt = cc.uiloader:seekNodeByName(node, "name_txt")
	self.mVipLevelTxt = cc.uiloader:seekNodeByName(node, "vip_level_txt"):setString(tt.gettext("vip等级"))
	self.mVipLevelIcon = cc.uiloader:seekNodeByName(node, "vip_level_icon")
	self.mUidTxt = cc.uiloader:seekNodeByName(node, "uid_txt")
	self.mCoinTxt = cc.uiloader:seekNodeByName(node, "coin_txt")
	self.mConsoleList = cc.uiloader:seekNodeByName(node, "console_list")

	_,self.mVipY = self.mVipLevelIcon:getPosition()
	_,self.mUidY = self.mUidTxt:getPosition()
end

function RoomUserinfoDialog:setUserinfo(userinfo)
	self.mUserinfo = userinfo
	dump(userinfo,"setUserinfo")
	self.mPinfo = json.decode(userinfo.info)

	-- 自己的vip等级可能升级
	if userinfo.mid == tt.owner:getUid() then
		self.mPinfo.name = tt.owner:getName()
		self.mPinfo.vip_lv = tt.owner:getVipLv()
		self.mUidTxt:setString(tt.gettext("游戏ID:{s1}",userinfo.mid))
		self.mCoinTxt:setString(tt.gettext("筹码剩余:{s1}",tt.getNumShortStr(tt.owner:getMoney())))

		self.mVipLevelTxt:setPositionY(self.mVipY)
		self.mVipLevelIcon:setPositionY(self.mVipY)
		self:initEmoticon()
	else
		
		self.mVipLevelTxt:setPositionY(self.mUidY)
		self.mVipLevelIcon:setPositionY(self.mUidY)
		self:initExpression()
	end
	self.mNameTxt:setString(self.mPinfo.name)
	self:setHeadUrl(self.mPinfo.img_url)
	self.mFbIcon:setVisible(self.mPinfo.fb == true)

	if self.mPinfo.vip_lv then
		self.mVipLevelIcon:setTexture(string.format("dec/icon_vip".. self.mPinfo.vip_lv .. ".png"))
	end
end

function RoomUserinfoDialog:setHeadUrl(url)
	tt.asynGetHeadIconSprite(string.urldecode(url or ""),function(sprite)
		if sprite and not tolua.isnull(self) and not tolua.isnull(self.mHeadBg) then
			local size = self.mHeadBg:getContentSize()
			local mask = display.newSprite("dec/zhezhao.png")
			if self.head_ then
				self.head_:removeSelf()
				self.head_ = nil
			end
			self.head_ = CircleClip.new(sprite,mask)
				:addTo(self.mHeadBg)
				:setPosition(cc.p(-1,-1))
				:setCircleClipContentSize(size.width,size.width)
		end
	end)
end

function RoomUserinfoDialog:initEmoticon()
	self.mConsoleList:removeAllItems()

	local emoticons = {
		{1,"emoticon/1_1.png"},
		{3,"emoticon/3_6.png"},
		{2,"emoticon/2_3.png"},
		{4,"emoticon/4_1.png"},
	}

	for _,data in ipairs(emoticons) do
		local item = self.mConsoleList:newItem()
		local content = display.newNode()
		local size = cc.size(134,120)
		local btn = cc.ui.UIPushButton.new(data[2])
			:setPosition(size.width/2,size.height/2)
			:onButtonClicked(function()
					if self.mControl.mControler:isEmoticonLock() then
						tt.show_msg(tt.gettext("操作过于频繁,请稍后再试"))
					else
						self.mControl.mControler:sendEmoticonMsg(data[1])
					end
					self:dismiss()
				end)
		btn:addTo(content)
		content:setContentSize(size.width, size.height)
		item:addContent(content)
		item:setItemSize(size.width, size.height)
		self.mConsoleList:addItem(item)
	end

	self.mConsoleList:reload()
end

function RoomUserinfoDialog:initExpression()
	self.mConsoleList:removeAllItems()

	local expressions = {
		{1,"expression/rose/rose_07.png",20},
		{2,"expression/cheers/cheers07.png",10},
		{3,"expression/chicken/chicken09.png",20},
		{4,"expression/shark/shark10.png",0},
	}

	local expFee = self.mControl.mModel:getExpFee()

	for _,data in ipairs(expressions) do
		local fee = expFee[data[1]] or expFee[data[1] .. ""]
		if fee then
			local item = self.mConsoleList:newItem()
			local content = display.newNode()
			local size = cc.size(134,120)
			local btn = cc.ui.UIPushButton.new(data[2])
				:setPosition(size.width/2,size.height/2+data[3])
				:scale(0.7)
				:onButtonClicked(function()
						local money = tt.owner:getMoney()
						if money < fee then
							local goods = tt.getSuitableGoodsByMoney(fee - money)
							if goods then
								self.mControl:showRecommendGoodsDialog(goods)
							else
								tt.show_msg(tt.gettext("您的筹码不足"))
							end
						elseif self.mControl.mControler:isExpressionLock() then
							tt.show_msg(tt.gettext("操作过于频繁,请稍后再试"))
						else
							local seat_id = self.mControl.mModel:getSeatIdByUid(self.mUserinfo.mid)
							self.mControl.mControler:sendExpressionMsg(seat_id,data[1])
						end
						self:dismiss()
					end)
			local fee_node = display.newNode()
			local icon = display.newSprite("icon/icon_chip5.png")
				:scale(0.7)
			local num = display.newTTFLabel({
			        text = fee,
			        size = 31,
			        color=cc.c3b(0xff,0xff,0xff),
			    })
			tt.linearlayout(fee_node,icon)
			tt.linearlayout(fee_node,num)

			local fee_size = fee_node:getContentSize()
			fee_node:setPosition(size.width/2-fee_size.width/2,fee_size.height)
			fee_node:addTo(content)
			btn:addTo(content)
			content:setContentSize(size.width, size.height)
			item:addContent(content)
			item:setItemSize(size.width, size.height)
			self.mConsoleList:addItem(item)
		end
	end

	self.mConsoleList:reload()
end

function RoomUserinfoDialog:show()
	BLDialog.show(self)
end

function RoomUserinfoDialog:dismiss()
	BLDialog.dismiss(self)
end

return RoomUserinfoDialog