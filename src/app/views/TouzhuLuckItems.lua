local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")
local BLDialog = require("app.ui.BLDialog")

local TouzhuLuckItems = class("TouzhuLuckItems", function(...)
	return display.newNode()
end)


function TouzhuLuckItems:ctor(control)
	self.control_ = control 
	local node, width, height = cc.uiloader:load("touzhu_luck_items.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mIndexTxt = cc.uiloader:seekNodeByName(node, "index_txt")
	self.mSumTxt = cc.uiloader:seekNodeByName(node, "sum_txt")
	self.mType1txt = cc.uiloader:seekNodeByName(node, "type_1_txt")
	self.mType2txt = cc.uiloader:seekNodeByName(node, "type_2_txt")
	self.mNum1 = cc.uiloader:seekNodeByName(node, "num_1")
	self.mNum2 = cc.uiloader:seekNodeByName(node, "num_2")
	self.mNum3 = cc.uiloader:seekNodeByName(node, "num_3")
end

function TouzhuLuckItems:setStage(stage)
	self.mIndexTxt:setString(stage)
end

function TouzhuLuckItems:setLuck(luck)
	luck = luck or {}
	luck[1] = luck[1] or 1
	luck[2] = luck[2] or 1
	luck[3] = luck[3] or 1
	local sum = luck[1] + luck[2] + luck[3]
	self.mNum1:setTexture("dec/dec_".. luck[1] ..".png")
	self.mNum2:setTexture("dec/dec_".. luck[2] ..".png")
	self.mNum3:setTexture("dec/dec_".. luck[3] ..".png")

	self.mSumTxt:setString(sum)

	if sum >= 11  then
		self.mType1txt:setColor(cc.c3b(0xff,0x7f,0x31))
		self.mType1txt:setString(tt.gettext("大"))
	else
		self.mType1txt:setColor(cc.c3b(0xff,0xdf,0x38))
		self.mType1txt:setString(tt.gettext("小"))
	end

	if sum % 2 == 1 then
		self.mType2txt:setColor(cc.c3b(0x38,0xbb,0xff))
		self.mType2txt:setString(tt.gettext("单"))
	else
		self.mType2txt:setColor(cc.c3b(0x62,0xff,0x38))
		self.mType2txt:setString(tt.gettext("双"))
	end
end



return TouzhuLuckItems