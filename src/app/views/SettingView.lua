--
-- Author: bearluo
-- Date: 2017-05-27
--
local BLDialog = require("app.ui.BLDialog")
local SettingView = class("SettingView", function(...)
	return BLDialog.new(...)
end)

local TAG = "SettingView"
local net = require("framework.cc.net.init")

function SettingView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("setting_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.back_btn = cc.uiloader:seekNodeByName(node,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	cc.uiloader:seekNodeByName(node,"Label_41"):setString(tt.gettext("音乐"))
	cc.uiloader:seekNodeByName(node,"Label_41_0"):setString(tt.gettext("音效"))
		

	self.music_btn_status = not (tt.game_data.music_btn_status == false)
	self.music_btn = cc.uiloader:seekNodeByName(node,"music_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self.music_btn_status = self:clickFunc(self.music_btn,self.music_btn_status)
			tt.nativeData.saveMusicBtnStatus(self.music_btn_status)
			if self.music_btn_status then 
				tt.play.resume_music()
				print("tt.play.resume_music")
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingMusicBtn,{enable=1})
			else
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingMusicBtn,{enable=0})
				print("tt.play.pause_music")
				tt.play.pause_music()
			end
		end)
	self:updateBtnView(self.music_btn,self.music_btn_status)

	self.sound_btn_status = not (tt.game_data.sound_btn_status == false)
	self.sound_btn = cc.uiloader:seekNodeByName(node,"sound_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self.sound_btn_status = self:clickFunc(self.sound_btn,self.sound_btn_status)
			tt.nativeData.saveSoundBtnStatus(self.sound_btn_status)
			if self.sound_btn_status then 
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingSoundBtn,{enable=1})
			else
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingSoundBtn,{enable=0})
			end
		end)
	self:updateBtnView(self.sound_btn,self.sound_btn_status)

	-- self.shock_btn_status = not (tt.game_data.shock_btn_status == false)
	-- self.shock_btn = cc.uiloader:seekNodeByName(node,"shock_btn")
	-- 	:onButtonClicked(function ()
	-- 		tt.play.play_sound("click")
	-- 		self.shock_btn_status = self:clickFunc(self.shock_btn,self.shock_btn_status)
	-- 		tt.nativeData.saveShockBtnStatus(self.shock_btn_status)
	-- 		if self.shock_btn_status then 
	-- 			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingShockBtn,{enable=1})
	-- 		else
	-- 			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingShockBtn,{enable=0})
	-- 		end
	-- 	end)
	-- self:updateBtnView(self.shock_btn,self.shock_btn_status)

	-- self.push_btn_status = not (tt.game_data.push_btn_status == false)
	self.push_btn = cc.uiloader:seekNodeByName(node,"push_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			-- self.push_btn_status = self:clickPushFunc(self.push_btn,self.push_btn_status)
			-- tt.nativeData.savePushBtnStatus(self.push_btn_status)
			-- if self.push_btn_status then 
			-- 	tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingPushBtn,{enable=1})
			-- else
			-- 	tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingPushBtn,{enable=0})
			-- end
			tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.gotoSet)
		end)

	-- self:updatePushBtnView(self.push_btn,self.push_btn_status)

	self.logout_btn = cc.uiloader:seekNodeByName(node,"logout_btn")
		:onButtonClicked(function ()
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingLogoutBtn)
			tt.play.play_sound("click")
			tt.nativeData.saveLoginData(0,{})
			app:enterScene("LoginScene", {true})
			tt.gsocket:close()
			self:dismiss()
		end)

	self.uid_txt = cc.uiloader:seekNodeByName(node,"uid_txt")
	self.uid_txt:setString( string.format("ID:%s",tt.owner:getUid()))

	self.name_txt = cc.uiloader:seekNodeByName(node,"name_txt")
	self.name_txt:setString( string.format("%s",tt.owner:getName()))

	self.content_bg = cc.uiloader:seekNodeByName(node,"content_bg")

	cc.uiloader:seekNodeByName(self.content_bg,"bottom_txt"):setString(tt.gettext("問題反饋：gm@woyaoent.com  版本:{s1}",kVersion))


	self.mHeadBg = cc.uiloader:seekNodeByName(node,"head_bg")
	self.facebook_icon = cc.uiloader:seekNodeByName(node,"facebook_icon")
	self.facebook_icon:setVisible(tt.owner:isFb())

	self:updateHeadIcon(tt.owner:getIconUrl())
end

function SettingView:updateBtnView(view,flag)
	if flag then
		view:setButtonImage("normal","btn/btn_voice_open.png",true)
		view:setButtonImage("pressed","btn/btn_voice_close.png",true)
	else
		view:setButtonImage("normal","btn/btn_voice_close.png",true)
		view:setButtonImage("pressed","btn/btn_voice_open.png",true)
	end
end

function SettingView:updatePushBtnView(view,flag)
	if flag then
		view:setButtonImage("normal","btn/btn_push_open.png",true)
		-- view:setButtonImage("pressed","btn/btn_push_close.png",true)
	else
		view:setButtonImage("normal","btn/btn_push_close.png",true)
		-- view:setButtonImage("pressed","btn/btn_push_open.png",true)
	end
end

function SettingView:setIsChangeLogout( flag )
	self.logout_btn:setVisible(flag)
end

function SettingView:clickFunc(view,flag)
	self:updateBtnView(view,not flag)
	return not flag
end

function SettingView:clickPushFunc(view,flag)
	self:updatePushBtnView(view,not flag)
	return not flag
end

function SettingView:updateHeadIcon(url)
	printInfo("SettingView:updateHeadIcon %s", url)
	tt.asynGetHeadIconSprite(url,function(sprite)
		if sprite and self and self.mHeadBg then
			local size = self.mHeadBg:getContentSize()
			local mask = display.newSprite("dec/def_head2.png")
			if self.head_ then
				self.head_:removeSelf()
			end
			local CircleClip = require("app.ui.CircleClip")
			self.head_ = CircleClip.new(sprite,mask):addTo(self.mHeadBg)
				:setCircleClipContentSize(size.width,size.width)

		-- 	local scalX=(size.width-17)/sprite:getContentSize().width--设置x轴方向的缩放系数
		-- 	local scalY=(size.height-17)/sprite:getContentSize().height--设置y轴方向的缩放系数
		-- 	sprite:setAnchorPoint(cc.p(0, 0))
		-- 		:setScaleX(scalX)
		-- 		:setScaleY(scalY)

		-- 	self.head_ = sprite:addTo(self.mHeadBg)
			-- self.head_:setPosition(cc.p(6,12))
		end
	end)
end

function SettingView:show()
	BLDialog.show(self)
	self:setVisible(true)

	self:schedule(function()
			local ok,ret = tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.isNotificationEnabled)
			self:updatePushBtnView(self.push_btn,ok and ret == 1)
		end,2):setTag(1)
end

function SettingView:dismiss()
	BLDialog.dismiss(self)
	self:removeSelf()
end

return SettingView
