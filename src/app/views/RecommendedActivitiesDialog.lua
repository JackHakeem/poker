
local BLDialog = require("app.ui.BLDialog")
local TAG = "RecommendedActivitiesDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local RecommendedActivitiesDialog = class("RecommendedActivitiesDialog", function()
	return BLDialog.new()
end)


function RecommendedActivitiesDialog:ctor(control,data)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("recommended_activities_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.content_bg = cc.uiloader:seekNodeByName(node,"content_bg")

	self.close_btn = cc.uiloader:seekNodeByName(node,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	self.click_handler = cc.uiloader:seekNodeByName(node,"click_handler")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self.control_:showActivityCenterDialog(data.url)
			self:dismiss()
		end)

	self:setImgUrl(data.img_url)
end

function RecommendedActivitiesDialog:setImgUrl(url)
	printInfo("RecommendedActivitiesDialog.setImgUrl %s", url)
	tt.asynGetHeadIconSprite(url,function(sprite)
		if sprite and self and self.click_handler then
			local width,height = self.click_handler:getLayoutSize()
			print("RecommendedActivitiesDialog.setImgUrl",width,height)
			local mask = display.newSprite("dec/activity_mask.png")
			if self.mImgIcon then
				self.mImgIcon:removeSelf()
			end
			self.mImgIcon = CircleClip.new(sprite,mask):addTo(self.click_handler)
			self.mImgIcon:setPosition(cc.p(-width/2,-height/2))
			self.mImgIcon:setCircleClipContentSize(width,height)

			-- self.mImgIcon = sprite:addTo(self.click_handler)
			-- self.mImgIcon:setPosition(cc.p(0,0))
		end
	end)
end

function RecommendedActivitiesDialog:show(notice)
	BLDialog.show(self)
end

function RecommendedActivitiesDialog:dismiss()
	BLDialog.dismiss(self)
	self.control_:showNextRecommendedActivities()
end

return RecommendedActivitiesDialog