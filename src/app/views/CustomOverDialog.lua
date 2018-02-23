local BLDialog = require("app.ui.BLDialog")
local TAG = "CustomOverDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local CustomOverDialog = class("CustomOverDialog", function()
	return BLDialog.new()
end)


function CustomOverDialog:ctor(control,data)
	self.control_ = control 
	self.mData = data

	local node, width, height = cc.uiloader:load("custom_over_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "back_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				app:enterScene("MainScene",{false,nil,nil,{method="showCustomDialog"}})
				self:dismiss()
			end)

	cc.uiloader:seekNodeByName(node, "again_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				app:enterScene("MainScene",{false,nil,nil,{method="showCustomCreateDialog"}})
				self:dismiss()
			end)

	cc.uiloader:seekNodeByName(node, "room_name_txt"):setString(data.rname)
	self.mCreateTxt = cc.uiloader:seekNodeByName(node, "create_name"):setString( tt.gettext("创建者:") .. data.owner_name)
	self.mTotalTime = cc.uiloader:seekNodeByName(node, "total_time"):setString( data.total_time / 60 .. tt.gettext("小时") )
	self.mOverIcon = cc.uiloader:seekNodeByName(node, "over_icon")
	self.mRewardTxt = cc.uiloader:seekNodeByName(node, "reward_txt")
	self.mChipIcon = cc.uiloader:seekNodeByName(node, "chip_icon")

	if data.ownerid == tt.owner:getUid() then
		self.mRewardTxt:setString(tt.gettext("筹码奖励:")..tt.getNumStr(data.reward_money))
		tt.LayoutUtil:layoutRight(self.mChipIcon,self.mRewardTxt,5)
	else
		self.mRewardTxt:setVisible(false)
		self.mChipIcon:setVisible(false)
		local x,y = self.mCreateTxt:getPosition()
		self.mCreateTxt:setPositionY(y - 20)
		local x,y = self.mTotalTime:getPosition()
		self.mTotalTime:setPositionY(y - 30)
		local x,y = self.mOverIcon:getPosition()
		self.mOverIcon:setPositionY(y - 40)
	end
end

function CustomOverDialog:show()
	BLDialog.show(self)
end

function CustomOverDialog:dismiss()
	BLDialog.dismiss(self)
end

return CustomOverDialog