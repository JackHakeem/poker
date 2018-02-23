local BLDialog = require("app.ui.BLDialog")
local TAG = "FirstRechargeDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local FirstRechargeDialog = class("FirstRechargeDialog", function()
	return BLDialog.new()
end)


function FirstRechargeDialog:ctor(control,data)
	self.control_ = control
	self.mData = data

	local node, width, height = cc.uiloader:load("first_recharge_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	self.money_percent_txt = cc.uiloader:seekNodeByName(node, "money_percent_txt")
	self.new_money_txt = cc.uiloader:seekNodeByName(node, "new_money_txt")
	self.old_money_txt = cc.uiloader:seekNodeByName(node, "old_money_txt")
	self.old_dec = cc.uiloader:seekNodeByName(node, "old_dec")
	self.vip_score_txt = cc.uiloader:seekNodeByName(node, "vip_score_txt")

	self.sure_btn = cc.uiloader:seekNodeByName(node, "sure_btn")
	self.price_txt = cc.uiloader:seekNodeByName(node, "price_txt")
	self.desc = cc.uiloader:seekNodeByName(node, "desc")

	self.new_money_txt:setString(tt.getNumStr(data.coin))
	self.old_money_txt:setString(tt.getNumStr(data.old_coin))

	if data.old_coin == 0 then
		self.money_percent_txt:setString("")
	else
		self.money_percent_txt:setString(string.format("+%d%%",(data.coin-data.old_coin)*100/data.old_coin))
	end

	local size1 = self.old_money_txt:getContentSize()
	local size2 = self.old_dec:getContentSize()
	self.old_dec:setScaleX(size1.width/size2.width)

	local extra = data.extra
	if type(extra) == "table" and extra.score then
		self.vip_score_txt:setString(tt.getNumStr(extra.score))
	else
		self.vip_score_txt:setString("0")
	end

	self:setPrice(data.price,data.cy)

	self.desc:setString(tt.gettext("每位玩家仅能购买一次首充礼包"))

	self.sure_btn:onButtonClicked(function()
			tt.play.play_sound("click")
			self.control_:payGoods(self.mData)
			self:dismiss()
		end)

	cc.uiloader:seekNodeByName(node, "close_btn"):onButtonClicked(function()
			tt.play.play_sound("click")
			self:dismiss()
		end)
	
end

function FirstRechargeDialog:setPrice(price,cy)
	self.price_txt:setString(tt.gettext("仅需{s1}{s2}",price,cy))
end

function FirstRechargeDialog:show()
	BLDialog.show(self)

end

function FirstRechargeDialog:dismiss()
	BLDialog.dismiss(self)
end


return FirstRechargeDialog