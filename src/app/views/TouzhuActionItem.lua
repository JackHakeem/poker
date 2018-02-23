local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")
local BLDialog = require("app.ui.BLDialog")

local TouzhuActionItem = class("TouzhuActionItem", function(...)
	return display.newNode()
end)


function TouzhuActionItem:ctor(control)
	self.control_ = control 
	local node, width, height = cc.uiloader:load("touzhu_aciton_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	cc.uiloader:seekNodeByName(node, "sub_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.control_:subNum(self.mNum)
			end)
	cc.uiloader:seekNodeByName(node, "add_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.control_:addNum(self.mNum)
			end)

	self.mCoinsNum = 0
	self.mCoinsNumTxt = cc.uiloader:seekNodeByName(node, "coins_num_txt")
	self.mNum = 0
	self.mNumTxt = cc.uiloader:seekNodeByName(node, "num_txt")
end

function TouzhuActionItem:setCoinsNum(num)
	self.mCoinsNum = tonumber(num) or 0
	self.mCoinsNumTxt:setString(tt.getNumShortStr2(self.mCoinsNum))
end

function TouzhuActionItem:addCoins(coins)
	coins = tonumber(coins) or 0
	self:setCoinsNum(self.mCoinsNum+coins)
end

function TouzhuActionItem:subCoins(coins)
	coins = tonumber(coins) or 0
	if self.mCoinsNum-coins < 0 then
		self:setCoinsNum(0)
	else
		self:setCoinsNum(self.mCoinsNum-coins)
	end
end

function TouzhuActionItem:getCoins()
	return self.mCoinsNum
end

function TouzhuActionItem:setNum(num)
	self.mNum = tonumber(num) or 0
	if self.mNum >= 3 and self.mNum <= 18 then
		self.mNumTxt:setString(tt.gettext("和值:{s1}",self.mNum))
	elseif self.mNum == -1 then
		self.mNumTxt:setString(tt.gettext("单"))
	elseif self.mNum == -2 then
		self.mNumTxt:setString(tt.gettext("小"))
	elseif self.mNum == -3 then
		self.mNumTxt:setString(tt.gettext("大"))
	elseif self.mNum == -4 then
		self.mNumTxt:setString(tt.gettext("双"))
	end
end

return TouzhuActionItem