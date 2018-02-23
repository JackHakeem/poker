local BLDialog = require("app.ui.BLDialog")
local TAG = "TouzhuRuleView"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local TouzhuRuleView = class("TouzhuRuleView", function()
	return BLDialog.new()
end)


function TouzhuRuleView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("touzhu_rule_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)
end

function TouzhuRuleView:show()
	BLDialog.show(self)
end

function TouzhuRuleView:dismiss()
	BLDialog.dismiss(self)
end

return TouzhuRuleView