--
-- Author: bearluo
-- Date: 2017-05-27
--

local PropDataHelper = require("app.libs.PropDataHelper")
local FacebookHelper = require("app.libs.FacebookHelper")
local BLDialog = require("app.ui.BLDialog")
local MatchResultView = class("MatchResultView", function()
	return BLDialog.new()
end)

local TAG = "MatchResultView"

function MatchResultView:ctor(control,data,match_type)
	self:setNodeEventEnabled(true)
	self.control_ = control 
	self.mData = data
	self.mMatchType = match_type
	self.mHandlers = {}
	local node, width, height = cc.uiloader:load("match_result_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.back_btn = cc.uiloader:seekNodeByName(node,"back_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			app:enterScene("MainScene")
			self:dismiss()
		end)

	self.mBgMask = cc.uiloader:seekNodeByName(node,"bg_mask")

	self.mBtnAgainClickClock = false
	self.btn_start = cc.uiloader:seekNodeByName(node,"again_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			if self.mBtnAgainClickClock then return end
			self.mBtnAgainClickClock = true
			if self.mMatchType == "sng" then
				app:enterScene("MainScene",{false,{lv=data.mlv,etype=1}})
			end
			self:dismiss()
		end)

	self.share_btn = cc.uiloader:seekNodeByName(node,"share_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			tt.makeScreen(function(outputFile)
					if not tolua.isnull(self) then
						FacebookHelper.shareOpenGraph(kDownloadUrl,self.mShareTxt,outputFile)
					end
				end)
			
		end)

	if self.mMatchType == "mtt" then
		self.btn_start:setVisible(false)
		self.share_btn:setVisible(true)
	else
		self.btn_start:setVisible(true)
		self.share_btn:setVisible(false)
	end

	self.mShareTxt = "Woyao Poker"
	self.mDecTxt = cc.uiloader:seekNodeByName(node,"dec_txt")
	self.mResultIcon = cc.uiloader:seekNodeByName(node,"result_icon")

	if self.mMatchType == "mtt" then
		self:initMttView(data)
	elseif self.mMatchType == "sng" then
		self:initSngView(data)
	end
end

function MatchResultView:initMttView(data)
	local mtt_info = tt.nativeData.getMttInfo(data.match_id)
	local name = ""
	if mtt_info then 
		name = mtt_info.mname
	end
	self.mShareTxt = tt.gettext("{s1}刚刚参与了[{s2}],和他一起加油，向冠军冲击!",tt.owner:getName(),name)
	self.mDecTxt:setString(tt.gettext("恭喜{s1}在{s2}{s3}人中荣获",tt.owner:getName(),name,self.mData.total))

	self:setRank(self.mData.urank)

	if self.mRewardView then
		self.mRewardView:removeSelf()
	end
	self.mRewardView = display.newNode()
	self.mRewardView:addTo(self.root_)

	local reward = self.mData.reward
	if next(reward) then
		self.mBgMask:setScaleY(1.4)
		self.mResultIcon:setTexture("dec/you_win.png")
		if reward.money then
			self:addRewardItem(reward.money,1)
		end
		if reward.score then
			self:addRewardItem(reward.score,2)
		end
		if reward.vgoods and next(reward.vgoods) then
			for goods_id,num in pairs(reward.vgoods) do
				self:addRewardItem({goods_id=goods_id,num=num},3)
			end
		end
	else
		self.mBgMask:setScaleY(1)
		self.mResultIcon:setTexture("dec/you_lost.png")
	end

	self:resetRewardViewPosition()
end

function MatchResultView:initSngView(data)
	local sng_info = tt.nativeData.getSngInfo(data.mlv)
	if not sng_info then return end
	self.mDecTxt:setString( tt.gettext("恭喜{s1}在{s2}{s3}人中荣获",tt.owner:getName(),sng_info.mname,self.mData.total))

	self:setRank(self.mData.urank)

	if self.mRewardView then
		self.mRewardView:removeSelf()
	end
	self.mRewardView = display.newNode()
	self.mRewardView:addTo(self.root_)

	local reward = self.mData.reward
	if reward and reward.money and reward.money > 0 then
		self.mBgMask:setScaleY(1.4)
		self.mResultIcon:setTexture("dec/you_win.png")
		self:addRewardItem(reward.money,1)
	else
		self.mBgMask:setScaleY(1)
		self.mResultIcon:setTexture("dec/you_lost.png")
	end

	self:resetRewardViewPosition()
end

function MatchResultView:setRank(rank)
	if self.mRankView then
		self.mRankView:removeSelf()
	end
	self.mRankView = display.newNode()
	self.mRankView:addTo(self.root_)

	local pre = display.newTTFLabel({
		    text = "อันดับที่",
		    size = 103,
		    color = cc.c3b(0xff, 0xff, 0xff),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})


	local rank = display.newTTFLabel({
		    text = rank,
		    size = 150,
		    color = cc.c3b(0xee, 0xd6, 0x0c),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})

	tt.linearlayout(self.mRankView,pre)
	tt.linearlayout(self.mRankView,rank,10,-20)

	local size = self.mRankView:getContentSize()
	self.mRankView:setPosition(cc.p(640-size.width/2,320))
end

function MatchResultView:addRewardItem(data,reward_type)
	local node = display.newNode()
	-- local node = display.newRect(cc.rect(0, 0, 200, 200))
	node:setContentSize(200,200)
	if reward_type == 1 then
		local icon = display.newSprite("icon/icon_chip6.png")
		local num = display.newTTFLabel({
		    text = "x" .. tt.getNumStr(data),
		    size = 40,
		    color = cc.c3b(0xee, 0xd6, 0x0c),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		icon:setPosition(cc.p(100,120))
		num:setPosition(cc.p(100,30))
		icon:addTo(node)
		num:addTo(node)
	elseif reward_type == 2 then
		local icon = display.newSprite("icon/icon_start.png")
		local num = display.newTTFLabel({
		    text = "x" .. tt.getNumStr(data),
		    size = 40,
		    color = cc.c3b(0xee, 0xd6, 0x0c),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		icon:setPosition(cc.p(100,120))
		num:setPosition(cc.p(100,30))
		icon:addTo(node)
		num:addTo(node)
	elseif reward_type == 3 then
		local icon = display.newSprite("dec/dec_checkbox.png")

		local name = display.newTTFLabel({
		    text = "***",
		    size = 40,
		    color = cc.c3b(0xee, 0xd6, 0x0c),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		local num = display.newTTFLabel({
		    text = "x" .. data.num,
		    size = 40,
		    color = cc.c3b(0xee, 0xd6, 0x0c),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
		self.mHandlers[data.goods_id] = PropDataHelper.register(data.goods_id,function(prop_data)
				if tolua.isnull(self) and tolua.isnull(icon) then return end
				name:setString(prop_data.sname)
				tt.asynGetHeadIconSprite(string.urldecode(prop_data.iconurl or ""),function(sprite)
						if sprite and not tolua.isnull(self) and not tolua.isnull(icon) then
						icon:removeChildByTag(1)
						local size = icon:getContentSize()
						sprite:setTag(1)
						sprite:addTo(icon)
						sprite:setPosition(cc.p(size.width/2,size.height/2))
						local scalX=size.width/sprite:getContentSize().width--设置x轴方向的缩放系数
						local scalY=size.height/sprite:getContentSize().height--设置y轴方向的缩放系数
						sprite:setScaleX(scalX)
							:setScaleY(scalY)
					end
				end)
			end)
		icon:setPosition(cc.p(100,120))
		name:setPosition(cc.p(100,40))
		num:setPosition(cc.p(100,20))
		icon:addTo(node)
		name:addTo(node)
		num:addTo(node)
	end
	if self.mRewardView then
		tt.linearlayout(self.mRewardView,node)
	end
end

function MatchResultView:resetRewardViewPosition()
	if self.mRewardView then
		local size = self.mRewardView:getContentSize()
		self.mRewardView:setPosition(cc.p(640-size.width/2,150))
	end
end

function MatchResultView:show()
	BLDialog.show(self)
end

function MatchResultView:dismiss()
	BLDialog.dismiss(self)
	self:removeSelf()
end

function MatchResultView:onCleanup()
	for _,handler in pairs(self.mHandlers) do
		PropDataHelper.unregister(handler)
	end
	self.mHandlers = {}
end

return MatchResultView
