local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")
local BLDialog = require("app.ui.BLDialog")

local TouzhuLuckItems = class("TouzhuLuckItems", function(...)
	return display.newNode()
end)


function TouzhuLuckItems:ctor(control)
	self.control_ = control 
	local node, width, height = cc.uiloader:load("touzhu_luck_room_items.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mIndexTxt = cc.uiloader:seekNodeByName(node, "index_txt")
	self.mSumTxt = cc.uiloader:seekNodeByName(node, "sum_txt")
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
end



return TouzhuLuckItems