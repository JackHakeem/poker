local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")
local BLDialog = require("app.ui.BLDialog")

local TouzhuHistoryItems = class("TouzhuHistoryItems", function(...)
	return display.newNode()
end)


function TouzhuHistoryItems:ctor(control)
	self.control_ = control 
	local node, width, height = cc.uiloader:load("touzhu_history_items.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mTimeTxt = cc.uiloader:seekNodeByName(node, "time_txt")
	self.mTimeTxt:setLineHeight(30)
	self.mNumTxt = cc.uiloader:seekNodeByName(node, "num_txt")
	self.mCoinsTxt = cc.uiloader:seekNodeByName(node, "coins_txt")
	self.mCoinsIcon = cc.uiloader:seekNodeByName(node, "coins_icon")
	self.mTxt = cc.uiloader:seekNodeByName(node, "txt")
	self.mTxt:setLineHeight(30)
	self.mRewardTxt = cc.uiloader:seekNodeByName(node, "reward_txt")
	self.mRewardTxt:setLineHeight(30)
	self.mRewardNumTxt = cc.uiloader:seekNodeByName(node, "reward_num_txt")
	self.mVipIcon = cc.uiloader:seekNodeByName(node, "vip_icon")
end

function TouzhuHistoryItems:getData()
	return self.mData
end

function TouzhuHistoryItems:setData(data)
	self.mData = data

	local str = tt.gettext("\n期号 {s1}",self.mData.stage)

	self.mTimeTxt:setString(os.date("%Y/%m/%d %H:%M",self.mData.time)..str)
	local nums = {}
	local sum = 0
	for num,coins in pairs(self.mData.bets) do
		num = tonumber(num)
		if num >= 3 and num <= 18 then
			nums[num] = coins
		elseif num == 1 then
			nums[-1] = coins
		elseif num == 19 then
			nums[-2] = coins
		elseif num == 20 then
			nums[-3] = coins
		elseif num == 2 then
			nums[-4] = coins
		end
		sum = sum + coins
	end
	local str = ""
	for num=-4,18 do
		if nums[num] then
			if num >= 3 and num <= 18 then
				str = str == "" and (str .. num) or (str .. ", " .. num)
			elseif num == -1 then
				str = str == "" and (str .. tt.gettext("单")) or (str .. " " .. tt.gettext("单"))
			elseif num == -2 then
				str = str == "" and (str .. tt.gettext("小")) or (str .. " " .. tt.gettext("小"))
			elseif num == -3 then
				str = str == "" and (str .. tt.gettext("大")) or (str .. " " .. tt.gettext("大"))
			elseif num == -4 then
				str = str == "" and (str .. tt.gettext("双")) or (str .. " " .. tt.gettext("双"))
			end
		end
	end
	self.mNumTxt:setLineHeight(30)
	self.mNumTxt:setString(str)
	self:setCoinsNum(sum)

	self.mWinscore = -1
	self:update()
end

function TouzhuHistoryItems:setCoinsNum(num)
	self.mCoinsTxt:setString(tt.getNumStr2(num))
	local size = self.mCoinsTxt:getContentSize()
	local x,y = self.mCoinsTxt:getPosition()
	self.mCoinsIcon:setPositionX(x+size.width/2+20)
end

function TouzhuHistoryItems:setRewardCoinsNum(num)
	self.mRewardNumTxt:setString(tt.getNumStr2(num))
	local size = self.mRewardNumTxt:getContentSize()
	local x,y = self.mRewardNumTxt:getPosition()
	self.mVipIcon:setPositionX(x+size.width/2+20)
	self.mVipIcon:setVisible(true)
end

function TouzhuHistoryItems:update()
	if self.mData and self.mData.winscore ~= self.mWinscore then
		self.mWinscore = self.mData.winscore
		self.mRewardNumTxt:setString("")
		self.mRewardTxt:setString("")
		self.mTxt:setString("")
		self.mVipIcon:setVisible(false)

		if self.mData.winscore then
			local preStr = ""

			if self.mData.luck then
				local luck = self.mData.luck
				local num1 = luck[1] or 1
				local num2 = luck[2] or 1
				local num3 = luck[3] or 1
				local sum = num1 + num2 + num3
				preStr = tt.gettext("{s1},{s2},{s3} 和值:{s4}\n",luck[1],luck[2],luck[3],sum)
			end
			
			if self.mData.winscore == 0 then
				self.mTxt:setString(preStr .. tt.gettext("未中奖"))
				self.mTxt:setColor(cc.c3b(0x8e,0x8e,0x8e))
			else
				self.mRewardTxt:setString(preStr .. tt.gettext("中奖"))
				self:setRewardCoinsNum(self.mData.winscore)
			end
		else
			self.mTxt:setColor(cc.c3b(0x2d,0xa5,0xea))
			self.mTxt:setString(tt.gettext("开奖中"))
		end
	end
end


return TouzhuHistoryItems