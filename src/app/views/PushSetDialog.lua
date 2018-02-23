local BLDialog = require("app.ui.BLDialog")
local TAG = "PushSetDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local PushSetDialog = class("PushSetDialog", function()
	return BLDialog.new()
end)


function PushSetDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("push_set_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "tips_text"):setString(tt.gettext("您还没有开启系统推送\n请立即设置!"))

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	cc.uiloader:seekNodeByName(node, "sure_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.gotoSet)
			self:dismiss()
		end)
end

function PushSetDialog:show()
	BLDialog.show(self)
end

function PushSetDialog:dismiss()
	BLDialog.dismiss(self)
	self:removeSelf()
end

return PushSetDialog