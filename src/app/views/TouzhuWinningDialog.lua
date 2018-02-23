local BLDialog = require("app.ui.BLDialog")
local TAG = "TouzhuWinningDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")
local FacebookHelper = require("app.libs.FacebookHelper")

local TouzhuWinningDialog = class("TouzhuWinningDialog", function()
	return BLDialog.new()
end)


function TouzhuWinningDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("touzhu_winning_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContextView = cc.uiloader:seekNodeByName(node, "content_view")
	self.mShareTxt = "Woyao Poker"
	cc.uiloader:seekNodeByName(node, "sure_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	cc.uiloader:seekNodeByName(node,"share_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			tt.makeScreen(function(outputFile)
					if not tolua.isnull(self) then
						FacebookHelper.shareOpenGraph(kDownloadUrl,self.mShareTxt,outputFile)
					end
				end)
		end)

	self.mDecLight = cc.uiloader:seekNodeByName(node, "dec_light")
	self.mDecLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 90)))

	self.mDecLamp = cc.uiloader:seekNodeByName(node, "dec_lamp")
	local index = 0
	self.mDecLamp:schedule(function()
			index = ( index + 1 ) % 2
			if index == 1 then
				self.mDecLamp:setTexture("dec/flowing_light01.png")
			elseif index == 0 then
				self.mDecLamp:setTexture("dec/flowing_light02.png")
			end
		end,0.3)

	self.mVipScoreTxt = cc.uiloader:seekNodeByName(node, "vip_score_txt")
	self.mVipScoreBg = cc.uiloader:seekNodeByName(node, "vip_score_bg")


	self.mStarBg = cc.uiloader:seekNodeByName(node, "star_bg")
	
	local clip = cc.ClippingNode:create()
	local mask = display.newSprite("dec/mask_star.png")
	clip:setStencil(mask)
	clip:setAlphaThreshold(0.9)  --不显示模板的透明区域
	clip:setInverted( false ) --显示模板不透明的部分
	clip:setContentSize(mask:getContentSize().width,mask:getContentSize().height)
	clip:setPosition(cc.p(0,0))

	self.mStarBg:addChild(clip)
	clip:setPosition(cc.p(209,230))

	-- self.join_room_btn:addChild(clip)
	local animView = display.newSprite("dec/shaoguang01.png")
	animView:setBlendFunc(gl.DST_ALPHA, gl.DST_ALPHA)
	animView:setOpacity(128)
	animView:setPosition(cc.p(-300, 0))
	clip:addChild(animView)
	local sequence = transition.sequence({
	    cc.DelayTime:create(0.8),
	    cc.MoveTo:create(0, cc.p(-300, 0)),
	    cc.MoveTo:create(2, cc.p(600, 0)),
	    cc.DelayTime:create(0),
	})

	animView:runAction(cc.RepeatForever:create(sequence))

end

function TouzhuWinningDialog:show()
	BLDialog.show(self)
	self:playShowAnim()
end

function TouzhuWinningDialog:playShowAnim()
	tt.play.play_sound("touzhu_winning")
	self.mContextView:stopAllActions()
	self.mContextView:scale(0.2)
	self.mContextView:scaleTo(0.5, 1)
	self.mContextView:performWithDelay(function()
			local animCsb = "particle/star_bomb.csb"
			local animView = cc.CSLoader:createNode(animCsb)
			animView:addTo(self.mContextView)
			animView:setLocalZOrder(99)
			animView:setPosition(cc.p(640,500))
			animView:performWithDelay(function()
					animView:removeSelf()
				end, 30)
		end, 0.6)
end

function TouzhuWinningDialog:setScore(score)
	score = tonumber(score) or 0
	self.mVipScoreTxt:setString(tt.getNumStr(score))
	local size = self.mVipScoreTxt:getContentSize()
	local w = math.max(size.width+80,116)
	self.mVipScoreBg:setContentSize(cc.size(w,92))
	self.mVipScoreTxt:setPositionX(w/2)
	self.mShareTxt = tt.gettext("{s1}刚刚赢得了 {s2} 积分,加入游戏一起分享荣誉!",tt.owner:getName(),tt.getNumStr(score))
end

function TouzhuWinningDialog:dismiss()
	BLDialog.dismiss(self)
	self:removeSelf()
end

return TouzhuWinningDialog