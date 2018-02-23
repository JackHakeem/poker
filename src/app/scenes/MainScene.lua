local LocalNotication = require("app.libs.LocalNotication")
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor(fromLogin,signData,showCash,params)
	self.isFromLogin = fromLogin == true
	self.isShowMyMatchListView = fromLogin == true
	self.isShowMyMatchListViewCash = fromLogin == true
	self.mIsShowCash = showCash == true
	self.signData = signData -- 房间再来一局
	self.mActinfo = {}
	self.mRecom = {}
	self:initView()
	self.mParams = checktable(params)
	-- self:test()
end

function MainScene:initView() 

	--背景图	
	local node = display.newClippingRectangleNode()
    node:setClippingRegion(cc.rect(display.cx - 640, display.cy - 360, 1280, 720))
        :addTo(self)

    local scene, width, height = cc.uiloader:load("hall_scene.json")
	scene:addTo(node)
    scene:align(display.CENTER,display.cx,display.cy)

	self.bg_ = scene

	self.views_ = {
		main_play_view = app:createView("MainPlayView", self ),
	}

	self.views_.main_play_view:addTo(cc.uiloader:seekNodeByName(scene,"center_play_view"))
	

	-- for _,v in pairs(self.views_) do 
	-- 	self.bg_:addChild(v)
	-- end

	self.mHeadBg = cc.uiloader:seekNodeByName(scene,"head_bg")
	self.name_label_ = cc.uiloader:seekNodeByName(node,"user_name")


	self.mMallBtn = cc.uiloader:seekNodeByName(node, "mall_btn")
		:onButtonClicked(function()
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.mallBtn)
				tt.play.play_sound("click")
				self:onShopClick()
			end)

	self.mMyMatchBtn = cc.uiloader:seekNodeByName(node, "my_table_btn")
		:onButtonClicked(function()
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.myMatchBtn)
			tt.play.play_sound("click")
    		self:showMatchListView()
		end)
	self.mMyMatchTipsIcon = cc.uiloader:seekNodeByName(self.mMyMatchBtn, "tips_icon")
	self.mMyMatchTipsIcon:setVisible(false)
	self.mMailBtn = cc.uiloader:seekNodeByName(node, "message_btn")
		:onButtonClicked(function()
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.announcementBtn)
			tt.play.play_sound("click")
			self:showAnnouncementDialog()
		end)

	self.mSetBtn = cc.uiloader:seekNodeByName(node, "setting_btn")
		:onButtonClicked(function()
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.setBtn)
			tt.play.play_sound("click")
    		self:showSettingView()
		end)

	self.mActivityCenterBtn = cc.uiloader:seekNodeByName(node, "activity_center_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
    		self:showActivityCenterDialog()
		end)
	self.mActivityCenterTipsIcon = cc.uiloader:seekNodeByName(self.mActivityCenterBtn, "tips_icon")
	self.mActivityCenterTipsIcon:setVisible(false)
		
	self.mVpBtn = cc.uiloader:seekNodeByName(node, "vp_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
    		self:showVpDialog()
		end)
	self.mVpIcon = cc.uiloader:seekNodeByName(node, "vp_icon")

	cc.uiloader:seekNodeByName(scene,"head_btn")
    	:setLocalZOrder(1)
		:onButtonClicked(function()
			tt.play.play_sound("click")
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.userinfoBtn)
			self:showUserinfoView()
		end)

	self.mMoneyView = cc.uiloader:seekNodeByName(node, "money_view")

	self.mCoinLabel = cc.uiloader:seekNodeByName(self.mMoneyView,"money_txt")

	cc.uiloader:seekNodeByName(self.mMoneyView, "add_money_btn")
		:onButtonClicked(function()
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.addCoinBtn)
				tt.play.play_sound("click")
				self:onShopClick()
			end)



	self.mQuickPayBtn = cc.uiloader:seekNodeByName(node, "quick_play_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				-- self:quickJoinCash()
				-- local FacebookHelper = require("app.libs.FacebookHelper")
				-- FacebookHelper.appInvite(string.format("%s?invite_code=%d",kfbAppInviteUrl,tt.owner:getUid()),kfbAppInviteImgUrl)
				self:showFreeRewardDialog()
				-- self:showTouzhuWinningDialog(111)
			end)

	local clip = cc.ClippingNode:create()
	local mask = display.newSprite("dec/fr_dlight_are.png")
	clip:setStencil(mask)
	clip:setAlphaThreshold(0.9)  --不显示模板的透明区域
	clip:setInverted( false ) --显示模板不透明的部分
	clip:setContentSize(mask:getContentSize().width,mask:getContentSize().height)
	clip:setPosition(cc.p(0,0))

	clip:addTo(cc.uiloader:seekNodeByName(node, "bottom_view"))
	-- self.mQuickPayBtn:addChild(clip)
	clip:setPosition(self.mQuickPayBtn:getPosition())

	-- self.join_room_btn:addChild(clip)
	local animView = display.newSprite("dec/fr_dlight.png")
	animView:setBlendFunc(gl.DST_ALPHA, gl.DST_ALPHA)
	animView:setOpacity(200)
	animView:setPosition(cc.p(-300, 0))
	clip:addChild(animView)
	local sequence = transition.sequence({
	    cc.DelayTime:create(1.4),
	    cc.MoveTo:create(0, cc.p(-300, 0)),
	    cc.MoveTo:create(1.5, cc.p(300, 0)),
	    cc.DelayTime:create(0),
	})
	animView:runAction(cc.RepeatForever:create(sequence))

	self.mVipView = cc.uiloader:seekNodeByName(scene,"vip_view")
	
	self.mVipView:setTouchEnabled(true)
	self.mVipView:setTouchSwallowEnabled(false)

	local startX,startY =0,0
	local down = false
	self.mVipView:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    -- event.name 是触摸事件的状态：began, moved, ended, cancelled
	    -- event.x, event.y 是触摸点当前位置
	    -- event.prevX, event.prevY 是触摸点之前的位置
	    -- printf("sprite: %s x,y: %0.2f, %0.2f",
	    --        event.name, event.x, event.y)

	    -- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
	    -- 则必须返回 true
	    dump(event)
	    local x,y = event.x,event.y
	    if event.name == "began" then
	    	startX = x
        	startY = y
        	if not self.mVipView:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
	    	return true 
	    elseif event.name ~= "began" and down then
	    	-- if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    	-- 	down = false
	    	-- end
	    	if event.name == "ended" then
		    	tt.play.play_sound("click")
				self:showPrizeCenterView()
			end
		end
		if event.name == "ended" then
		end
	end)

    self.mIcon = cc.uiloader:seekNodeByName(self.mVipView,"icon")
    self.mVipTxt = cc.uiloader:seekNodeByName(self.mVipView,"vip_txt")

	-- self.vipExpProgress = cc.ProgressTimer:create(cc.Sprite:create("dec/vip_progress_bar.png"))
	--     :setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	--     :setMidpoint(cc.p(0.2,0.5))
	--     :setReverseDirection(true)
	--     :setPosition(1.5,0.5)
 --    	:addTo(cc.uiloader:seekNodeByName(self.mVipView,"process"))

	self.vipExpProgress = display.newDrawNode()
	local mask = display.newSprite("dec/vip_progress_bar.png")
	mask:setScaleX(1.1)
	local clip_node = cc.ClippingNode:create()
	clip_node:setStencil(self.vipExpProgress);
	clip_node:addChild(mask)
	clip_node:setPosition(cc.p(20,0.5));
	clip_node:setAlphaThreshold(0.05)  --不显示模板的透明区域
	clip_node:setInverted( false ) --显示模板不透明的部分
	clip_node:addTo(cc.uiloader:seekNodeByName(self.mVipView,"process"))

    self.mVipShopBtn = cc.uiloader:seekNodeByName(scene,"vip_shop_btn")
    	:setLocalZOrder(1)
		:onButtonClicked(function()
				tt.play.play_sound("click")
	    		self:showPrizeCenterView()
				-- tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.gotoEvaluate)
			end)

	self.mLogoView = cc.uiloader:seekNodeByName(scene,"logo_view")

  	self.mBackBtn = cc.uiloader:seekNodeByName(scene,"back_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.views_.main_play_view:showMainList()
				self:showTopView(1)
			end)

 	self.mFirstRechargeBtn = cc.uiloader:seekNodeByName(scene,"first_recharge_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:showFirstRechargeDialog()
			end)

	self.mBankruptcyBtn = cc.uiloader:seekNodeByName(scene,"bankruptcy_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:showBankruptcyDialog()
			end)

	cc.uiloader:seekNodeByName(scene,"trade_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:showGiftDialog()
			end)
	
	cc.uiloader:seekNodeByName(scene,"package_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:showUserinfoView()
			end)

	-- self.electricity_v = display.newSprite("dec/diancige.png")
	-- self.electricity_icon = display.newSprite("dec/diancikuang.png")
	-- self.timeClock = display.newTTFLabel({
 --            text = "10:00",
 --            size = 18,
 --            color=cc.c3b(0x75,0x75,0x75),
 --        }):addTo(self.bg_)

	-- self.electricity_v:addTo(self.bg_)
	-- self.electricity_icon:addTo(self.bg_)

	-- self.electricity_v:setAnchorPoint(cc.p(0,0.5))
	-- self.electricity_v:setPosition(cc.p(1081,30))
	-- self.electricity_v:setScaleX(8)
	-- self.electricity_icon:setPosition(cc.p(1100,30))

	-- self.timeClock:setAnchorPoint(cc.p(0,0.5))
	-- self.timeClock:setPosition(cc.p(1130,30))

	-- self:startTimeClock()
	-- self:startBatterypercentageAnim()


	self.mSpeakerView = app:createView("SpeakerView",self)
		:align(display.CENTER,640,550)
		:addTo(self.bg_,100)
	self.mSpeakerView:setDismissOpacity(60)
	self.mSpeakerView:addTouch()

	self.matchs_list = {} 
	self.cashs_list = {} 
	self.mtt_matchs_list = {}

	self:showTopView(1)
	self:updateFirstRechargeBtn()
	self:updateBankruptcyBtn()
	self:updateVipShopBtn()

end

function MainScene:onEnter()
	tt.log.d(TAG, "MainScene onEnter")	
	tt.gsocket.setHeartTime(10)
	-- tt.show_wait_view()
	self:addEventListener()
	tt.log.d(TAG,"MainScene gsocket isConnected %s",tt.gsocket:isConnected())
	if tt.gsocket:isConnected() then
   		tt.gsocket.request("info.ver",{chan=kChan})
		self:updateHeadIcon()
		self:updateName()
		self:updateCoinLabel()
		self:updateVipScoreView()
	    self:updateVipLvView()
	    self:updateVipExpView()
		self:updateFirstRechargeBtn()
    	self:updateVpLvView()
	end
	local ship_data = tt.nativeData.getRequestShipData()
	if ship_data then
	 	for _,params in pairs(ship_data) do
	 		if params.pmode == 1 then
				tt.ghttp.request(tt.cmd.gconsume,params)
	 		elseif params.pmode == 2 then
				tt.ghttp.request(tt.cmd.ivalidate,params)
	 		end
	 	end
	end
	tt.play.resume_music()
	tt.backEventManager.addBackEventLayer(self)
	self.callbackHandler = tt.backEventManager.registerCallBack(handler(self, self.onKeypadListener))


	-- local ok,ret = tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.isNotificationEnabled)
	-- if ok then
	-- 	if ret == 0 then
	-- 		self:showChooseDialog("是否打开通知", nil, function()
	-- 				tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.gotoSet)
	-- 			end)
	-- 	end
	-- end
	self:getPlayingRoom()


	if self.isFromLogin then
		-- self.isFromLogin = false
		self:requestAnnouncementData()
		tt.nativeData.setFirstRecharge()
		tt.ghttp.request(tt.cmd.firstshop,{})
		tt.ghttp.request(tt.cmd.everyday_list,{})
		tt.ghttp.request(tt.cmd.getshops,{})
		tt.ghttp.request(tt.cmd.vp_club,{})
	end

	local params = {}
	tt.ghttp.request(tt.cmd.active_entrance,params)

	if tt.checkBankruptcy() and not tt.nativeData.getBankruptcy() then
		local params = {}
		tt.ghttp.request(tt.cmd.user_break,params)
	end

	local params = {}
	tt.ghttp.request(tt.cmd.switch_shop,params)


	tt.gsocket.request("richdata.getprop",{mid=tt.owner:getUid()})

	self.views_.main_play_view:showMainList()
	if self.mIsShowCash then
		self.mIsShowCash = false
		self:loadCashList()
	end
	print("method",self.mParams.method)
	if self.mParams.method == "showCustomDialog" then
		self:showCustomRoomDialog()
	elseif self.mParams.method == "showCustomCreateDialog" then
		self:showCustomRoomDialog()
		self:showCreateRoomDialog()
	end
end

function MainScene:onKeypadListener(evt)
	if device.platform == "android" then
		if evt.key == "back" and evt.type == "Released" then
			if self.mBackBtn:isVisible() then
				self.views_.main_play_view:showMainList()
				self:showTopView(1)
			else
				self:showQuitDialog()
			end
			return true
		end
	elseif device.platform == "windows" then
		if evt.code == 140 and evt.type == "Released" then
			if self.mBackBtn:isVisible() then
				self.views_.main_play_view:showMainList()
				self:showTopView(1)
			else
				self:showQuitDialog()
			end
			return true
		end
	end
end

function MainScene:showQuitDialog()
	self:showChooseDialog(tt.gettext("是否退出游戏"), nil, function()
			os.exit()
		end):setMode(3)
end


function MainScene:updateHeadIcon()
	local url = tt.owner:getIconUrl()
	printInfo("MainScene:updateHeadIcon %s", url)
	tt.asynGetHeadIconSprite(url,function(sprite)
		if sprite and self and self.mHeadBg then
			local size = self.mHeadBg:getContentSize()
			local mask = display.newSprite("dec/def_head4.png")
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

function MainScene:showTopView(index)
	if index == 2 then
		self.mHeadBg:setVisible(false)
		self.name_label_:setVisible(false)
		-- self.mLogoView:setVisible(false)

		self.mBackBtn:setVisible(true)
	else
		self.mHeadBg:setVisible(true)
		self.name_label_:setVisible(true)
		-- self.mLogoView:setVisible(true)
		self.mBackBtn:setVisible(false)
	end
end 

function MainScene:updateName()
	self.name_label_:setString(tt.owner:getName())
end

function MainScene:updateCoinLabel()
	local coin = tt.owner:getMoney()
	self.mCoinLabel:setString(tt.getNumStr(coin))
end

function MainScene:updateVipScoreView()
    self.mVipTxt:setString(tt.getNumStr(tt.owner:getVipScore()))
end

function MainScene:updateVipLvView()
    self.mIcon:setTexture(string.format("dec/icon_vip".. tt.owner:getVipLv() .. ".png"))
    self:updateVipExpView()
end

function MainScene:updateVipExpView()
	local lv = tt.owner:getVipLv()
    if not tt.game_data.vip_info[lv] then return end
	local lv_info = tt.game_data.vip_info[lv]
	local pre_exp = tt.game_data.vip_info[lv-1] and tt.game_data.vip_info[lv-1].exp or 0
	local exp = tt.owner:getVipExp()
	print("MainScene:updateVipExpView",lv_info.exp,pre_exp)
	local percentage = (exp-pre_exp)*100/(lv_info.exp-pre_exp)
	if percentage < 0 then percentage = 0 end
	if percentage > 100 then percentage = 100 end
	self:updateProgress(self.vipExpProgress,percentage,-82,70.5,35)
end

function MainScene:updateProgress(view,per,left,right,radius)
	view:clear()
	local offsetl = right-left
	local length = offsetl*2+math.pi*radius
	local curlength = length*per/100
	print("updateProgress",per)
	if curlength >= offsetl then
		local pts1 = {
		    cc.p(left, 0),  -- point 1
		    cc.p(left, -radius),  -- point 1
		    cc.p(right, -radius),  -- point 2
		    cc.p(right, 0),  -- point 2
		}
		view:drawPolygon(pts1, {
	        fillColor = cc.c4f(1, 1, 1, 1),
	        borderWidth = 0,
	        borderColor = cc.c4f(1, 1, 1, 1)
	    })
	else
		local pts1 = {
		    cc.p(left, 0),  -- point 1
		    cc.p(left, -radius),  -- point 1
		    cc.p(left+curlength, -radius),  -- point 2
		    cc.p(left+curlength, 0),  -- point 2
		}
		view:drawPolygon(pts1, {
	        fillColor = cc.c4f(1, 1, 1, 1),
	        borderWidth = 0,
	        borderColor = cc.c4f(1, 1, 1, 1)
	    }) 
	end

	if curlength >= offsetl+math.pi*radius then
		local pts2 = tt.makePoint(right, 0,radius,-90,90,100)
		table.insert(pts2,1,{right,0})
	    display.newPolygon(pts2, {
	        fillColor = cc.c4f(1, 1, 1, 1),
	        borderWidth = 0,
	        borderColor = cc.c4f(1, 1, 1, 1)
	    }, view)
	elseif curlength >= offsetl then
		local tl = curlength - offsetl
		local pp = tl/(math.pi*radius)
		local pts2 = tt.makePoint(right, 0,radius,-90,-90+pp*180,100)
		table.insert(pts2,1,{right,0})
	    display.newPolygon(pts2, {
	        fillColor = cc.c4f(1, 1, 1, 1),
	        borderWidth = 0,
	        borderColor = cc.c4f(1, 1, 1, 1)
	    }, view)
	end

	if curlength >= offsetl*2+math.pi*radius then
		local pts3 = {
		    cc.p(right, 0),  -- point 1
		    cc.p(right, radius),  -- point 1
		    cc.p(left, radius),  -- point 2
		    cc.p(left, 0),  -- point 2
		}
		view:drawPolygon(pts3, {
	        fillColor = cc.c4f(1, 1, 1, 1),
	        borderWidth = 0,
	        borderColor = cc.c4f(1, 1, 1, 1)
	    })
	elseif curlength >= offsetl+math.pi*radius then
		local tl = curlength - offsetl-math.pi*radius
		local pts3 = {
		    cc.p(right, 0),  -- point 1
		    cc.p(right, radius),  -- point 1
		    cc.p(right-tl, radius),  -- point 2
		    cc.p(right-tl, 0),  -- point 2
		}
		view:drawPolygon(pts3, {
	        fillColor = cc.c4f(1, 1, 1, 1),
	        borderWidth = 0,
	        borderColor = cc.c4f(1, 1, 1, 1)
	    })
	end
end

function MainScene:updateVpExpView()
	if not tolua.isnull(self.mVpNum) then self.mVpNum:removeSelf() end
	local curLv = tt.owner:getVpLv()
	local curExp = tt.owner:getVpExp()
	local vpExpConfig = tt.nativeData.getVpExpConfig()
	if curLv == 6 then 
		local nExp = vpExpConfig[curLv] or 0
		self.mVpNum = tt.getBitmapStrAscii("number/yellow0_%d.png",string.format("%d/%d",curExp,nExp))
	else
		local nExp = vpExpConfig[curLv+1] or 0
		self.mVpNum = tt.getBitmapStrAscii("number/yellow0_%d.png",string.format("%d/%d",curExp,nExp))
	end
	self.mVpNum:scale(0.6)
	self.mVpNum:addTo(self.mVpBtn)
	tt.LayoutUtil:layoutParentCenter(self.mVpNum,25)
end

function MainScene:updateVpLvView()
	local curLv = tt.owner:getVpLv()
	self.mVpIcon:setTexture(string.format("icon/vp_%d.png",curLv))
	self:updateVpExpView()
end

function MainScene:startTimeClock()
	self:schedule(function() 
			local time = tt.time()
			if time % 2 == 1 then
				self.timeClock:setString(os.date("%H:%M"))
			else
				self.timeClock:setString(os.date("%H %M"))
			end
		end, 1)
end

function MainScene:startBatterypercentageAnim()
	self.electricity_v:setScaleX(8*self:getBatterypercentage()/100)
	self:schedule(function() 
			self.electricity_v:setScaleX(8*self:getBatterypercentage()/100)
		end, 5)
end

function MainScene:getBatterypercentage()
	local ok,ret = tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.getBatterypercentage)
	print("MainScene:getBatterypercentage",ok,ret)
	if ok then
		return ret
	else
		return 0
	end
end

function MainScene:reconnectServering()
	if not self.hallReconnectView then
		self.hallReconnectView = app:createView("HallReconnectView", self)
			:addTo(self.bg_,1000)
	end
	self.hallReconnectView:showReconnectView()
end

function MainScene:reconnectServerFail()
	if not self.hallReconnectView then
		self.hallReconnectView = app:createView("HallReconnectView", self)
			:addTo(self.bg_,1000)
	end
	self.hallReconnectView:showReconnectfailView()
end

function MainScene:onHallClick()
	-- app:enterScene("AllocScene")
	-- if device.platform == "android" then
	-- 	luaj.callStaticMethod("com/woyao/facebook/FacebookProxy", "loginFacebook");
	-- end
	tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.loginFacebook)
end

function MainScene:showMatchListView()
	if tolua.isnull(self.mMyMatchListView) then
		self.mMyMatchListView = app:createView("MyMatchListView",self)
			:addTo(self.bg_,100)
		self.mMyMatchListView:show()
	else
		self.mMyMatchListView:refresh()
	end
end
-- 入场后拉取房间信息
function MainScene:gotoRoom(mlv,match_id,room_type,params)
	assert(mlv,"lv is nil")
	assert(match_id,"match_id is nil")
	assert(room_type,"room_type is nil")
	app:enterScene("RoomScene", {mlv, match_id,room_type,params})
end
--根据信息的版本号 选择获取信息
function MainScene:onInfoVer(info)
	dump(info,"onInfoVer")
	if tt.game_data.sng_info and tt.game_data.sng_info_ver == info.ver.sng then 
		if self.signData then
			local data = tt.nativeData.getSngInfo(self.signData.lv)
			self:showMatchInfoDialog(data)
			self:signMatch(self.signData.lv,self.signData.etype)
			self.signData = nil
		end
	end
end

function MainScene:showAnnouncementDialog(str)
	if not tolua.isnull(self.mAnnouncementDialog) and self.mAnnouncementDialog:isShowing() then return end
	if not tolua.isnull(self.mAnnouncementDialog) then
		self.mAnnouncementDialog:removeSelf()
	end
	self.mAnnouncementDialog = app:createView("AnnouncementDialog",self)
	self.mAnnouncementDialog:addTo(self.bg_,101)
	self.mAnnouncementDialog:show(str)
end

function MainScene:requestAnnouncementData()
	tt.gsocket.request("msgbox.newnotice",{})
end

--握手成功
function MainScene:onShakeOK()
	self:updateHeadIcon()
	self:updateName()
	self:updateCoinLabel()
	self:updateVipScoreView()
    self:updateVipLvView()
    self:updateVipExpView()
    self:updateVpLvView()
 
	if self.hallReconnectView then
		self.hallReconnectView:dismiss()
	end

	if not tolua.isnull(self.mTouzhuGameDialog) and self.mTouzhuGameDialog:isShowing() then
		self.mTouzhuGameDialog:show()
	end
end

--[[
	desc:用户报名比赛
	param: mlv-比赛场次  etype-报名费类型 
]]
function MainScene:onMatchApplyClick(mlv, etype)
	tt.log.d(TAG, "apply match:[%s]",mlv)	
	
	--已经报名了就退赛
	local match = self.matchs_list[mlv]
	if match then
		if match.status == 1 then
			tt.gsocket.request("sng.cancel",{mlv=match.mlv, match_id=match.match_id})
		elseif match.status == 2 then
			self:gotoRoom(match.mlv, match.match_id,kSngRoom)
		end
	else
		tt.gsocket.request("sng.apply",{mlv=mlv, etype=etype or 1})

		local blind_id = tt.nativeData.getSngInfo(mlv).blind_id
		if not tt.game_data.blind_table[blind_id] then 
			tt.gsocket.request("match.blind_info",{blind_id=blind_id})
		end
	end
end

function MainScene:signMatch(mlv,etype)
	local match = self.matchs_list[mlv]
	if not match then

		local data = tt.nativeData.getSngInfo(mlv)
		if data then
			local num = 0
			for _,v in ipairs(data.entry) do
				if v.etype == 1 then
					if v.num > 0 then
						num = v.num
					end
					break
				end
			end
			if num > 0 and num > tt.owner:getMoney() then 
				tt.show_msg(tt.gettext("筹码不足"))
				return
			end
		end

		local func = function()
			tt.gsocket.request("sng.apply",{mlv=mlv, etype=etype or 1})
			local blind_id = tt.nativeData.getSngInfo(mlv).blind_id
			if not tt.game_data.blind_table[blind_id] then 
				tt.gsocket.request("match.blind_info",{blind_id=blind_id})
			end
		end
		-- dump(self.matchs_list)
		local _,pre = next(self.matchs_list)
		if pre and tt.game_data.sng_info and tt.nativeData.getSngInfo(pre.mlv) then 
			if pre.status == 1 then
				self:showChooseDialog(tt.gettext("您已報名“{s1}”，比賽很快就要開始，要繼續嗎？",tt.nativeData.getSngInfo(pre.mlv).mname), nil, function ( )
					func()
				end)
			else
				self:showChooseDialog(tt.gettext("您已報名“{s1}”，要繼續嗎？",tt.nativeData.getSngInfo(pre.mlv).mname), nil, function ( )
					func()
				end)
			end
		else
			func()
		end
	end
end

function MainScene:unsignMatch(mlv)
	local match = self.matchs_list[mlv]
	if match and match.status == 1 then
		tt.gsocket.request("sng.cancel",{mlv=match.mlv, match_id=match.match_id})
	end
end

function MainScene:enterRoom(mlv)
	local match = self.matchs_list[mlv]
	if match and match.status == 2 then
		self:gotoRoom(match.mlv, match.match_id,kSngRoom)
	end
end

function MainScene:showCashSetView()
	if not tolua.isnull(self.mCashSetView) then self.mCashSetView:removeSelf() end
	self.mCashSetView = app:createView("CashSetView",self)
		:addTo(self.bg_,100)
	self.mCashSetView:show()
end

function MainScene:onShopClick()
	self:showShopDialog(1)
end

function MainScene:showShopDialog(index)
	if not tolua.isnull(self.mShopPopups) then
		self.mShopPopups:removeSelf()
	end
	self.mShopPopups = app:createView("ShopPopups", self)
		:addTo(self.bg_,100)
	self.mShopPopups:show()
	if index then
		self.mShopPopups:selectShowType(index)
	end
end

function MainScene:onExit()
	tt.log.d(TAG, "MainScene onExit")	
	self:removeEventListener()

	for _, v in pairs(self.views_) do 
		v:removeSelf()
	end

	self:stopAllActions()
	tt.backEventManager.unregisterCallBack(self.callbackHandler)
end

function MainScene:onCleanup()
	tt.log.d(TAG, "MainScene onCleanup")	
end

function MainScene:showSettingView()
	local settingView = app:createView("SettingView", self)
		:addTo(self.bg_,100)
	settingView:show()
end

function MainScene:showPrizeCenterView()
	if tt.nativeData.isVipShopLock() then return end

	if not tolua.isnull(self.mPrizeCenterView) then
		self.mPrizeCenterView:removeSelf()
	end
	self.mPrizeCenterView = app:createView("PrizeCenterView", self)
		:addTo(self.bg_,100)
	self.mPrizeCenterView:show()
end

function MainScene:showUserinfoView()
	if not tolua.isnull(self.mUserinfoView) then
		self.mUserinfoView:dismiss()
	end
	self.mUserinfoView = app:createView("UserinfoView", self)
	self.mUserinfoView:addTo(self.bg_,100)
	self.mUserinfoView:show()
end

function MainScene:showMatchInfoDialog(data)
	if not tolua.isnull(self.mMatchInfoDialog) then
		self.mMatchInfoDialog:dismiss()
	end
	self.mMatchInfoDialog = app:createView("MatchInfoDialog",self,data):addTo(self.bg_,100)
	local match = self.matchs_list[data.mlv]
	if match then
		self.mMatchInfoDialog:setMatchId(match.match_id,match.status)
	else
		self.mMatchInfoDialog:setMatchId()
	end
	self.mMatchInfoDialog:show()
end

function MainScene:payGoods(goods)
	printInfo("shop pmode[%d] price[%s] coin[%d] pid[%s]",goods.pmode, goods.price,goods.coin, goods.pid)
	tt.ghttp.request(tt.cmd.order,{pmode=goods.pmode,pid = goods.pid})
end

function MainScene:showSpeaker(str)
	-- if not self.mSpeakerView then
	-- end
	self.mSpeakerView:show(str)
end

function MainScene:showChooseDialog(str,cancelClick,confirmClick)
	local dialog = app:createView("ChooseDialog")
	dialog:addTo(self.bg_,100)
	dialog:setContentStr(str)
	dialog:setOnCancelClick(cancelClick)
	dialog:setOnConfirmClick(confirmClick)
	dialog:show()
	return dialog
end

function MainScene:showPushSetDialog()
	if not tolua.isnull(self.mPushSetDialog) then
		self.mPushSetDialog:removeSelf()
	end
	self.mPushSetDialog = app:createView("PushSetDialog"):addTo(self.bg_,100)
	self.mPushSetDialog:show()
end

function MainScene:showInformationAuthenticationDialog(data)
	if not tolua.isnull(self.mInformationAuthenticationDialog) then
		self.mInformationAuthenticationDialog:removeSelf()
	end
	self.mInformationAuthenticationDialog = app:createView("InformationAuthenticationDialog")
		:addTo(self.bg_,100)
	self.mInformationAuthenticationDialog:setSendData(data)
	self.mInformationAuthenticationDialog:show()
end

function MainScene:loadCashList()
	self.views_.main_play_view:showCashList()
end

function MainScene:loadSngList()
	self.views_.main_play_view:showSngList()
end

function MainScene:loadMttList()
	self.views_.main_play_view:showMttList()
end

function MainScene:getPlayingRoom()
	tt.gsocket.request("sng.usersngs",{mid=tt.owner:getUid()})
	tt.gsocket.request("cash.usercashs",{mid=tt.owner:getUid()})
	tt.gsocket.request("mtt.usermtts",{mid=tt.owner:getUid()})
	tt.gsocket.request("custom.syn_tids",{mid=tt.owner:getUid()})

end

function MainScene:signMttMatch(mlv,match_id,etype,num)
	if num ~= 0 then
		if etype == 1 then
			local money = tt.owner:getMoney()
			if num > money then 
				local goods = tt.getSuitableGoodsByMoney(num-money)
				if goods then
					self:showRecommendGoodsDialog(goods)
				else
					tt.show_msg(tt.gettext("筹码不足"))
				end
				return
			end
		elseif etype == 2 then
			if num > tt.owner:getVipScore() then 
				tt.show_msg(tt.gettext("vip点不足"))
				return
			end
		end
	end
	tt.gsocket.request("mtt.apply",{
			mlv = mlv,   			--比赛场次
			match_id = match_id,    --比赛id
			etype = etype,         	--报名费的类型
		})
end

function MainScene:unsignMttMatch(match_id)
	tt.gsocket.request("mtt.cancel",{
			match_id = match_id,    --比赛id
		})
end

function MainScene:showMttMatchInfoDialog(data)
	dump(data,"showMttMatchInfoDialog")
	if not tolua.isnull(self.mMttMatchInfoDialog) then
		self.mMttMatchInfoDialog:dismiss()
	end
	self.mMttMatchInfoDialog = app:createView("MttMatchInfoDialog",self,data):addTo(self.bg_,100)

	self.mMttMatchInfoDialog:show()
end

function MainScene:checkShowMttMatchInfoDialog(match_id)
	if tt.nativeData.getMttInfo(match_id) then
		self:showMttMatchInfoDialog(tt.nativeData.getMttInfo(match_id))
	else
		self.mLoadMttMatchId = match_id
		tt.gsocket.request("mtt.match_info",{
			match_id = match_id,    --比赛id
		})
	end
end

function MainScene:mttAdvanceOver(match_id)
	if not tolua.isnull(self.mMttMatchInfoDialog) then
		if self.mMttMatchInfoDialog:getMatchId() == match_id then
			-- tt.show_msg(tt.gettext("比赛人数不足,提前结束"))
			self.mMttMatchInfoDialog:nextMatch()
		end
	end
end

function MainScene:getMatchNum()
	return table.nums(self.matchs_list)+table.nums(self.cashs_list)+table.nums(self.mtt_matchs_list)
end

function MainScene:isSignedMtt(match_id)
	if self.mtt_matchs_list[match_id] then
		return true
	end
	return false
end

function MainScene:getMttStatus(match_id)
	if self.mtt_matchs_list[match_id] then
		return self.mtt_matchs_list[match_id].status
	end
	return 0
end

function MainScene:showFirstRechargeDialog()
	local data = tt.nativeData.getFirstRecharge()
	if not data then return end
	if tolua.isnull(self.mFirstRechargeDialog) then
		self.mFirstRechargeDialog = app:createView("FirstRechargeDialog",self,data):addTo(self.bg_,100)
	end
	self.mFirstRechargeDialog:show()
end

function MainScene:updateFirstRechargeBtn()
	local data = tt.nativeData.getFirstRecharge()
	print("updateFirstRechargeBtn",data ~= nil)
	self.mFirstRechargeBtn:setVisible(data ~= nil)
end

function MainScene:showBankruptcyDialog()
	if tolua.isnull(self.mBankruptcyDialog) then
		self.mBankruptcyDialog = app:createView("BankruptcyDialog",self):addTo(self.bg_,100)
	end
	self.mBankruptcyDialog:setBankruptcy(tt.nativeData.getBankruptcy())
	self.mBankruptcyDialog:setGoods(tt.getSuitableGoodsByMoney(0))
	self.mBankruptcyDialog:show()
end

function MainScene:updateBankruptcyBtn()
	local data = tt.nativeData.getBankruptcy()
	print("updateBankruptcyBtn",data ~= nil)
	self.mBankruptcyBtn:setVisible(data ~= nil)
end

function MainScene:showTouzhuGameDialog()
	if not tolua.isnull(self.mTouzhuGameDialog) then
		self.mTouzhuGameDialog:removeSelf()
	end
	self.mTouzhuGameDialog = app:createView("TouzhuGameView",self):addTo(self.bg_,100)
	self.mTouzhuGameDialog:show()
end

function MainScene:showTouzhuRandomView()
	if not tolua.isnull(self.mTouzhuRandomView) then
		self.mTouzhuRandomView:removeSelf()
	end
	self.mTouzhuRandomView = app:createView("TouzhuRandomView",self):addTo(self.bg_,100)
	self.mTouzhuRandomView:setTouzhuGameView(self.mTouzhuGameDialog)
	self.mTouzhuRandomView:show()
end

function MainScene:showTouzhuExchangeView()
	if not tolua.isnull(self.mTouzhuExchangeView) then
		self.mTouzhuExchangeView:removeSelf()
	end
	self.mTouzhuExchangeView = app:createView("TouzhuExchangeView",self):addTo(self.bg_,100)
	self.mTouzhuExchangeView:show()
end

function MainScene:showTouzhuRuleView()
	if not tolua.isnull(self.mTouzhuRuleView) then
		self.mTouzhuRuleView:removeSelf()
	end
	self.mTouzhuRuleView = app:createView("TouzhuRuleView",self):addTo(self.bg_,100)
	self.mTouzhuRuleView:show()
end

function MainScene:showTouzhuHistoryView()
	if not tolua.isnull(self.mTouzhuHistoryView) then
		self.mTouzhuHistoryView:removeSelf()
	end
	self.mTouzhuHistoryView = app:createView("TouzhuHistoryView",self):addTo(self.bg_,100)
	self.mTouzhuHistoryView:show()
end

function MainScene:showTouzhuWinningDialog(score)
	if not tolua.isnull(self.mTouzhuWinningDialog) then
		self.mTouzhuWinningDialog:removeSelf()
	end
	self.mTouzhuWinningDialog = app:createView("TouzhuWinningDialog",self):addTo(self.bg_,100)
	self.mTouzhuWinningDialog:setScore(score)
	self.mTouzhuWinningDialog:show()
end

function MainScene:showVpDialog()
	if not tolua.isnull(self.mVpDialog) then
		self.mVpDialog:removeSelf()
	end
	self.mVpDialog = app:createView("VpDialog",self):addTo(self.bg_,100)
	self.mVpDialog:show()
end

function MainScene:updateVipShopBtn()
	self.mVipShopBtn:setVisible(not tt.nativeData.isVipShopLock())
end

function MainScene:showRecommendGoodsDialog(goods)
	if not goods then return end
	if not tolua.isnull(self.mRecommendGoodsDialog) then
		self.mRecommendGoodsDialog:removeSelf()
	end
	self.mRecommendGoodsDialog = app:createView("RecommendGoodsDialog",self):addTo(self.bg_,100)
	self.mRecommendGoodsDialog:setGoods(goods)
	self.mRecommendGoodsDialog:show()
end

function MainScene:showActivityCenterDialog(obUrl)
	if tolua.isnull(self.mActivityCenterDialog) then
		self.mActivityCenterDialog = app:createView("ActivityCenterDialog", self):addTo(self.bg_,100)
	end
	self.mRecom = {}
	self.mActivityCenterDialog:loadData(self.mActinfo,obUrl)
	self.mActivityCenterDialog:show()
end

function MainScene:showNextRecommendedActivities()
    print("showNextRecommendedActivities",#self.mRecom)
	while #self.mRecom > 0 do
		local data = table.remove(self.mRecom,1)
		if tt.imageCacheManager:isExist(data.img_url) then
			self:showRecommendedActivitiesDialog(data)
			break
		else
			tt.imageCacheManager:downloadImage(data.img_url)
			print("showNextRecommendedActivities not img_url",data.img_url)
		end
	end
end

function MainScene:showRecommendedActivitiesDialog(data)
	dump(data,"showRecommendedActivitiesDialog")
	if not data then return end
	if not tolua.isnull(self.mRecommendedActivitiesDialog) then
		self.mRecommendedActivitiesDialog:removeSelf()
	end
	self.mRecommendedActivitiesDialog = app:createView("RecommendedActivitiesDialog", self,data):addTo(self.bg_,100)
	self.mRecommendedActivitiesDialog:show()
end

function MainScene:showEverydayListDialog()
    local data = tt.nativeData.getEverydayList()
	if not data then return end
	if not tolua.isnull(self.mEverydayListDialog) then
		self.mEverydayListDialog:removeSelf()
	end
	self.mEverydayListDialog = app:createView("EverydayListDialog", self):addTo(self.bg_,100)
	self.mEverydayListDialog:setData(data)
	self.mEverydayListDialog:show()
end


function MainScene:quickJoinCash()
-- 	以筹码数/4往下找最近的场次，找不到，则以筹码数往下找最近的场次，仍然找不到，则弹出商品推荐。
	local data = tt.nativeData.getCashInfo()
	local money = tt.owner:getMoney()
	local fisrt_cash,second_cash

	for _,cash in ipairs(data) do
		local default_buy = cash.default_buy
		if money >= default_buy then
			second_cash = cash
		end
		if money/4 >= default_buy then
			fisrt_cash = cash
		end
	end

	if fisrt_cash then
		tt.show_wait_view(tt.gettext("匹配中..."))
		tt.gsocket.request("alloc.search",{lv = fisrt_cash.lv})
	elseif second_cash then
		tt.show_wait_view(tt.gettext("匹配中..."))
		tt.gsocket.request("alloc.search",{lv = second_cash.lv})
	else
		if data[1] then
			local goods = tt.getSuitableGoodsByMoney(data[1].default_buy-money)
			if goods then
				self:showRecommendGoodsDialog(goods)
			else
				tt.show_msg(tt.gettext("筹码不足"))
			end
		end
	end
end

function MainScene:showGiftDialog()
	if not tolua.isnull(self.mGiftDialog) then
		self.mGiftDialog:removeSelf()
	end
	self.mGiftDialog = app:createView("GiftDialog", self):addTo(self.bg_,100)
	self.mGiftDialog:show()
end

function MainScene:showSpeakerEditDialog()
	if not tolua.isnull(self.mSpeakerEditDialog) then
		self.mSpeakerEditDialog:removeSelf()
	end
	self.mSpeakerEditDialog = app:createView("SpeakerEditDialog", self):addTo(self.bg_,100)
	self.mSpeakerEditDialog:show()
end

function MainScene:showFreeRewardDialog()
	if not tolua.isnull(self.mFreeRewardDialog) then
		self.mFreeRewardDialog:removeSelf()
	end
	self.mFreeRewardDialog = app:createView("FreeRewardDialog", self):addTo(self.bg_,100)
	self.mFreeRewardDialog:show()
end

function MainScene:showCustomRoomDialog()
	if not tolua.isnull(self.mCustomRoomDialog) then
		self.mCustomRoomDialog:removeSelf()
	end
	self.mCustomRoomDialog = app:createView("CustomRoomDialog", self):addTo(self.bg_,100)
	self.mCustomRoomDialog:show()
end

function MainScene:showCreateRoomDialog()
	if not tolua.isnull(self.mCreateRoomDialog) then
		self.mCreateRoomDialog:removeSelf()
	end
	self.mCreateRoomDialog = app:createView("CreateRoomDialog", self):addTo(self.bg_,100)
	self.mCreateRoomDialog:show()
end


function MainScene:onHttpResp(evt)
	if evt.cmd == tt.cmd.vstore then
		local data = evt.data
		if data and data.ret == 0 then
			if not tolua.isnull(self.mPrizeCenterView) then
				self.mPrizeCenterView:initMenuView(data.data)
			end
		end
	elseif evt.cmd == tt.cmd.exchange then
		local data = evt.data
		if data then
			if data.ret == 0 then
				local params = data.data
				local ptype = tonumber(params.type)
				if ptype == 1 or ptype == 2 then
					tt.show_msg(tt.gettext("兌換成功，請到您的個人信息欄中查看具體信息"))
				else
					tt.show_msg(tt.gettext("兌換成功"))
				end
				dump(params)
				if params.amount then
					tt.owner:setMoney(params.amount)
				end
				tt.owner:setVipScore(params.coin)
			elseif data.ret == 6 then
				tt.show_msg(tt.gettext("库存不足"))
			else
				tt.show_msg(tt.gettext("兌換失敗"))
			end
			if not tolua.isnull(self.mPrizeCenterView) then
				self.mPrizeCenterView:onExchange(data)
			end
		end
	elseif evt.cmd == tt.cmd.goods then
		local data = evt.data
		if data then
			if data.ret == 0 then
				local params = data.data
				if not tolua.isnull(self.mUserinfoView) then
					self.mUserinfoView:onVipProp(params)
				end
			end
		end
	elseif evt.cmd == tt.cmd.add_detail then
		local data = evt.data
		if data then
			if data.ret == 0 then
				local params = data.data
				if not tolua.isnull(self.mInformationAuthenticationDialog) then
					self.mInformationAuthenticationDialog:dismiss()
				end

				if not tolua.isnull(self.mUserinfoView) then
					self.mUserinfoView:reloadData()
				end
				tt.show_msg(tt.gettext("您的資料已經提交成功，我們會儘快為您處理。"))
			else
				tt.show_msg(tt.gettext("數據提交失敗"))
			end
		end
	elseif evt.cmd == tt.cmd.user_break then
		local data = evt.data
		if data then
			tt.nativeData.setBankruptcy()
			if data.ret == 0 then
				local params = data.data
				if params.status == 0 then
					tt.nativeData.setBankruptcy(params)
					self:updateBankruptcyBtn()
					-- if not self.isFromLogin then
						self:showBankruptcyDialog()
					-- end
				end
			end
		end
	elseif evt.cmd == tt.cmd.everyday_song then
		local data = evt.data
		if data then
			dump(data,"everyday_song")
			if data.ret == 0 then
				local params = data.data
				tt.nativeData.setBankruptcy()
				self:updateBankruptcyBtn()
				if not tolua.isnull(self.mBankruptcyDialog) and self.mBankruptcyDialog:isShowing() then
					self.mBankruptcyDialog:setBankruptcyNum(params.song_cishu)
				end
				tt.owner:setMoney(params.left)
				tt.show_msg(tt.gettext("领取成功!"))
			end
		end
	elseif evt.cmd == tt.cmd.active_entrance then
		if evt.data.ret == 0 then
			dump(evt.data.data,"active_entrance")
			self.mActinfo = evt.data.data.actinfo or {}
			self.mRecom = evt.data.data.recom or {}
			if not tolua.isnull(self.mActivityCenterDialog) then
				self.mActivityCenterDialog:loadData(self.mActinfo)
			end

			if next(self.mActinfo) then
				self.mActivityCenterTipsIcon:setVisible(true)
			else
				self.mActivityCenterTipsIcon:setVisible(false)
			end

			if self.isFromLogin and #self.mRecom > 0 then
				for _,data in ipairs(self.mRecom) do
					if not tt.imageCacheManager:isExist(data.img_url) then
						tt.imageCacheManager:downloadImage(data.img_url)
						print("active_entrance download img_url",data.img_url)
					end
				end
				self:showNextRecommendedActivities()
			end
		end
	elseif evt.cmd == tt.cmd.switch_shop then
		if evt.data.ret == 0 then
			self:updateVipShopBtn()
		end
	elseif evt.cmd == tt.cmd.firstshop then
		self:updateFirstRechargeBtn()
	elseif evt.cmd == tt.cmd.everyday_list then
		if evt.data.ret == 0 then
			if self.isFromLogin then
			    local data = tt.nativeData.getEverydayList()
				if data and data.is_get == 0 then
					self:showEverydayListDialog()
				end
			end
		end
	elseif evt.cmd == tt.cmd.everyday_login then
		if evt.data then
			if evt.data.ret == 0 then
				if not tolua.isnull(self.mEverydayListDialog) then
					self.mEverydayListDialog:onSuccess()
				end
			else
				tt.show_msg(tt.gettext("领取失败"))
			end
		end
	end
end

function MainScene:onNativeEvent(evt)
	tt.log.d(TAG, "NATIVE EVENT cmd:[%s], params:[%s]",evt.cmd, evt.params)
end

function MainScene:onSocketData(evt)
	printInfo("onSocketData cmd:[%s], resp=[%s]",evt.cmd,json.encode(evt.resp))	
	printInfo("onSocketData cmd:[%s], broadcast=[%s]",evt.cmd,json.encode(evt.broadcast))	

	if evt.cmd == "sng.info" then 
		-- 更新自己的比賽狀態
		if evt.resp and evt.resp.ret == 200 then
			tt.nativeData.saveSngInfo(evt.resp.ver,evt.resp.levels)
			if self.signData then
				local data = tt.nativeData.getSngInfo(self.signData.lv)
				self:showMatchInfoDialog(data)
				self:signMatch(self.signData.lv,self.signData.etype)
				self.signData = nil
			end
		end
	elseif evt.cmd == "match.blind_info" then 
		if evt.resp.ret == 200 then 
			tt.nativeData.saveBlindInfo(evt.resp.blind_id,evt.resp.blind_table)
		end
	elseif evt.cmd == "sng.apply" then 
		if evt.resp.ret == 200 then 
			self.matchs_list[evt.resp.mlv] = {
				match_id = evt.resp.match_id,
				mlv = evt.resp.mlv,
				status = 1,
			}
			self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
			self.views_.main_play_view:refreshMatchView()
			if not tolua.isnull(self.mMatchInfoDialog) then
				self.mMatchInfoDialog:setMatchId(evt.resp.match_id, 1)
				self.mMatchInfoDialog:refreshSignView()
			end
			tt.show_msg(tt.gettext("報名成功"))
		elseif evt.resp.ret == -101 then
			tt.show_msg(tt.gettext("重複報名"))
			tt.play.play_sound("action_failed")
		elseif evt.resp.ret == -102 then
			tt.show_msg(tt.gettext("報名費用不足"))
			tt.play.play_sound("action_failed")
		elseif evt.resp.ret == -103 then
			tt.show_msg(tt.gettext("比賽不存在"))
			tt.play.play_sound("action_failed")
		else
			tt.show_msg(tt.gettext("報名失败 : ") .. evt.resp.ret)
			tt.play.play_sound("action_failed")
		end
	elseif evt.cmd == "sng.cancel" then 
		if evt.resp.ret == 200 then 
			self.matchs_list[evt.resp.mlv] = nil
			self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
			self.views_.main_play_view:refreshMatchView()
			if not tolua.isnull(self.mMatchInfoDialog) then
				self.mMatchInfoDialog:setMatchId()
				self.mMatchInfoDialog:refreshSignView()
			end
		else
			tt.show_msg(tt.gettext("退賽失敗 : ") .. evt.resp.ret)
			tt.play.play_sound("action_failed")
		end
	elseif evt.cmd == "sng.start" then 
		if evt.resp then
			if evt.resp.ret == 200 then
				self.views_.main_play_view:refreshSngApplyNum(evt.resp)
				-- tt.show_msg(string.format("%s 报名人数:%d/%d",tt.nativeData.getSngInfo(evt.resp.mlv).mname,evt.resp.apply_num, evt.resp.start_num))
			else
				-- tt.show_msg("无此比赛")	
			end
		elseif evt.broadcast then
			local data = evt.broadcast 
			-- tt.show_msg(string.format("bc %s 报名人数:%d/%d",tt.nativeData.getSngInfo(data.mlv).mname,data.apply_num, data.start_num))
			
			self.views_.main_play_view:refreshSngApplyNum(evt.broadcast)
			if data.apply_num == data.start_num then
				tt.play.play_sound("join_match")
				self:gotoRoom(evt.broadcast.mlv, evt.broadcast.match_id,kSngRoom)
			end
		end
	elseif evt.cmd == "texas.standup" then 
		-- 回收房间站起后的金币
		if evt.broadcast and evt.broadcast.mid == tt.owner:getUid() then
			tt.owner:setMoney(evt.broadcast.money)
		end
	elseif evt.cmd == "sng.result" then
		if evt.resp then
			local resp = evt.resp
			if tt.nativeData.getSngInfo(resp.mlv) then
    			tt.show_msg( tt.gettext("您在比賽“{s1}”中獲得第{s2}名",tt.nativeData.getSngInfo(resp.mlv).mname,resp.urank))
    		end
			tt.owner:setMoney(resp.money)
			self.matchs_list[resp.mlv] = nil
			self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
			self.views_.main_play_view:refreshMatchView()
			if not tolua.isnull(self.mMatchInfoDialog) then
				self.mMatchInfoDialog:refreshSignView()
				self.mMatchInfoDialog:setMatchId()
			end
		end
	elseif evt.cmd == "info.ver" then 
		if evt.resp then
			if evt.resp.ret == 200 then 
				self:onInfoVer(evt.resp)
			end
		end
	elseif evt.cmd == "sng.usersngs" then
		if evt.resp then
			local resp = evt.resp
			dump(resp)
			if resp.ret == 200 then
				self.matchs_list = {}
				local count = 0
				for v,match in pairs(resp.matchs) do
					self.matchs_list[match.mlv] = {
						match_id = match.match_id,
						mlv = match.mlv,
						status = match.status,
					}
					if match.status == 2 then
						count = count + 1
					end
				end
				print('-----------',count)
				if count > 0 then
					if self.isShowMyMatchListView then
						self:showMatchListView()
					end
				end
				self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
				self.isShowMyMatchListView = false
				self.views_.main_play_view:refreshMatchView()
			elseif resp.ret == -101 then
				self.matchs_list = {}
				self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
				self.views_.main_play_view:refreshMatchView()
			end
		end
	elseif evt.cmd == "cash.usercashs" then
		if evt.resp then
			local resp = evt.resp
			dump(resp)
			if resp.ret == 200 then
				self.cashs_list = {}
				local count = 0
				for v,cash in pairs(resp.cashs) do
					self.cashs_list[cash.lv] = {
						tid = cash.tid,
						mlv = cash.lv,
						seatid = cash.seatid,
					}
					count = count + 1
				end
				print('-----------',count)
				if count > 0 then
					if self.isShowMyMatchListViewCash then
						self:showMatchListView()
					end
				end
				self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
				self.isShowMyMatchListViewCash = false
			elseif resp.ret == -101 then
				self.cashs_list = {}
				self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
			end
		end
	elseif evt.cmd == "msgbox.live_broad" then
		if evt.broadcast then
			if evt.broadcast.mtype == "bar" then
				self:showSpeaker(evt.broadcast.content)
			elseif evt.broadcast.mtype == "user_bar" then
				local data = json.decode(evt.broadcast.content)
				self:showSpeaker(data.name .. ":" .. data.content)
			elseif evt.broadcast.mtype == "custom_bugle" then
				local data = json.decode(evt.broadcast.content)
				self:showSpeaker(data.msg)
			end
		end
	elseif evt.cmd == "msgbox.newnotice" then
		if evt.resp.ret == 200 then
			dump(evt.resp)
			if self.isFromLogin then
				self:showAnnouncementDialog(evt.resp.notice.content)
			end
		end
	elseif evt.cmd == "alloc.info" then 
		if evt.resp and evt.resp.ret == 200 then
			if not tolua.isnull(self.mCashSetView) then
				self.mCashSetView:initData(evt.resp.levels)
			end
			tt.nativeData.saveCashInfo(evt.resp.ver,evt.resp.levels)
			self.views_.main_play_view:initCashList()
		end
	elseif evt.cmd == "vip.upgrade" then
		if evt.broadcast then
			-- 0--表示达到最高级
			dump(evt.broadcast)
			if evt.broadcast.uplv ~= 0 then
				tt.owner:setVipLv(evt.broadcast.uplv)
			end
			tt.owner:setVipScore(evt.broadcast.total_score)
		end
	elseif evt.cmd == "msgbox.pushmsg" then
		dump(evt)
		if evt.broadcast then
			-- 0--表示达到最高级
			dump(evt.broadcast)
			if evt.broadcast.mtype == 1001 then
				local data = json.decode(evt.broadcast.msg)
				if data then
					if data.message and data.message ~= "" then
						tt.show_msg(data.message)
					end
				end
			elseif evt.broadcast.mtype == 1002 then
				local data = json.decode(evt.broadcast.msg)
				if data then
					if data.message and data.message ~= "" then
						tt.show_msg(data.message)
					end
				end
			elseif evt.broadcast.mtype == 1003 then
				local data = json.decode(evt.broadcast.msg)
				if data then
					if data.message and data.message ~= "" then
						tt.show_msg(data.message)
					end
				end
			end
		end
	elseif evt.cmd == "mtt.info" then
		if evt.resp and evt.resp.ret == 200 then
			dump(evt.resp,"mtt")
			tt.nativeData.clearMttInfo()
			if evt.resp.levels then
				for _,data in ipairs(evt.resp.levels) do
					data.mlv = tonumber(data.mlv)
					data.apply_num = tonumber(data.apply_num)
					for _,entry in ipairs(data.entry) do
						entry.etype = tonumber(entry.etype)
						entry.num 	= tonumber(entry.num)
					end
					data.min_player = tonumber(data.min_player)
					data.max_player = tonumber(data.max_player)
					data.seat = tonumber(data.seat)
					data.bettime = tonumber(data.bettime)
					data.coin = tonumber(data.coin)
					data.blind_id = tonumber(data.blind_id)
					data.reward_type = tonumber(data.reward_type)
					data.reward_id = tonumber(data.reward_id)
					data.ct = tonumber(data.ct)
					data.fee = tonumber(data.fee)
					data.stime = tonumber(data.stime)
					data.jtime = tonumber(data.jtime)
					data.atime = tonumber(data.atime)
					data.ntime = tonumber(data.ntime)
					data.left = tonumber(data.left)
					tt.nativeData.saveMttInfo(data.match_id,data)
				end
			end
			self.views_.main_play_view:initMttList(evt.resp.levels)
		end
	elseif evt.cmd == "mtt.apply_num" then
		if evt.resp then
			if evt.resp.ret == 200 then
				self.views_.main_play_view:refreshMttApplyNum(evt.resp.info)
				if not tolua.isnull(self.mMttMatchInfoDialog) and evt.resp.info[self.mMttMatchInfoDialog:getMatchId()] then
					self.mMttMatchInfoDialog:updateApplyNum(evt.resp.info[self.mMttMatchInfoDialog:getMatchId()])
				end
			elseif evt.resp.ret == -101 then
				self.views_.main_play_view:refreshMttApplyNum({})
			end
		end
	elseif evt.cmd == "mtt.usermtts" then
		if evt.resp then
			local resp = evt.resp
			dump(resp)
			if resp.ret == 200 then
				self.mtt_matchs_list = {}
				local count = 0
				for v,match in pairs(resp.matchs) do
					self.mtt_matchs_list[match.match_id] = match
					if match.status == 2 then
						count = count + 1
					end
				end
				if count > 0 then
					if self.isShowMyMatchListViewCash then
						self:showMatchListView()
					end
				end
				self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
				self.isShowMyMatchListViewCash = false
			elseif resp.ret == -101 then
				self.mtt_matchs_list = {}
				self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
			end
		end
	elseif evt.cmd == "mtt.apply" then
		if evt.resp.ret == 200 then 
			-- -101:重复报名， -102:费用不足 -103:比赛不存在 -104:未开放报名 -105比赛人数满
			self.mtt_matchs_list[evt.resp.match_id] = {
				match_id = evt.resp.match_id,
				mlv = evt.resp.mlv,
				status = 1,
			}
			self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
			self.views_.main_play_view:refreshMatchView()

			if not tolua.isnull(self.mMttMatchInfoDialog) and self.mMttMatchInfoDialog:getMatchId() == evt.resp.match_id then
				self.mMttMatchInfoDialog:refreshSignView()
			end

			local data = tt.nativeData.getMttInfo(evt.resp.match_id)
			if data then
				data.apply_num = data.apply_num + 1
				if not tolua.isnull(self.mMttMatchInfoDialog) and self.mMttMatchInfoDialog:getMatchId() == evt.resp.match_id then
					self.mMttMatchInfoDialog:updateApplyNum(data.apply_num)
				end

				local stime,jtime,atime = data.stime,data.jtime,data.atime
				local id = LocalNotication.addLocalNotication(data.mname or "Tips",tt.gettext("比赛已经开始，以免失去奖励资格，请尽快入场！"),stime - jtime)
				if id then
					LocalNotication.saveMatchNoticationId(data.match_id,id,stime - jtime)
					-- tt.show_msg(tt.gettext("提醒添加成功!"))
				else
					-- tt.show_msg(tt.gettext("提醒添加失败,稍后再试!"))
				end
			end

			local ok,ret = tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.isNotificationEnabled)
			if ok and ret == 1 then
				tt.show_msg(tt.gettext("您已报名成功,请按时参赛。祝您在比赛中获得好成绩！"))
			else
				tt.show_msg(tt.gettext("报名成功,为避免您错过比赛,建议您设置比赛提示!"),function()
						tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.gotoSet)
					end)
			end
		elseif evt.resp.ret == -101 then
			tt.show_msg(tt.gettext("重複報名"))
			tt.play.play_sound("action_failed")
		elseif evt.resp.ret == -102 then
			tt.show_msg(tt.gettext("報名費用不足"))
			tt.play.play_sound("action_failed")
		elseif evt.resp.ret == -103 then
			tt.show_msg(tt.gettext("比賽不存在"))
			tt.play.play_sound("action_failed")
		elseif evt.resp.ret == -104 then
			tt.show_msg(tt.gettext("未开放报名"))
			tt.play.play_sound("action_failed")
		elseif evt.resp.ret == -105 then
			tt.show_msg(tt.gettext("比赛人数满"))
			tt.play.play_sound("action_failed")
		else
			tt.show_msg(tt.gettext("報名失败 : ") .. evt.resp.ret)
			tt.play.play_sound("action_failed")
		end
	elseif evt.cmd == "mtt.cancel" then 
		if evt.resp.ret == 200 or evt.resp.ret == 201 then 
			if evt.resp.ret == 201 then
				tt.show_msg(tt.gettext("比赛人数不够,自动取消"))
			end

			self.mtt_matchs_list[evt.resp.match_id] = nil
			self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
			self.views_.main_play_view:refreshMatchView()
			if not tolua.isnull(self.mMttMatchInfoDialog) and self.mMttMatchInfoDialog:getMatchId() == evt.resp.match_id then
				self.mMttMatchInfoDialog:refreshSignView()
			end

			local data = tt.nativeData.getMttInfo(evt.resp.match_id)
			if data then
				data.apply_num = data.apply_num - 1
				if not tolua.isnull(self.mMttMatchInfoDialog) and self.mMttMatchInfoDialog:getMatchId() == evt.resp.match_id then
					self.mMttMatchInfoDialog:updateApplyNum(data.apply_num)
				end
			end
			local id = LocalNotication.getMatchNoticationId(evt.resp.match_id)
			if id and LocalNotication.delLoaclNotication(id) then
				LocalNotication.delMatchNoticationId(evt.resp.match_id)
			end
		else
			tt.show_msg(tt.gettext("退賽失敗 : ") .. evt.resp.ret)
			tt.play.play_sound("action_failed")
		end
	elseif evt.cmd == "mtt.start" then
		if evt.broadcast then
			self:gotoRoom(evt.broadcast.mlv,evt.broadcast.match_id,kMttRoom)
		end
	elseif evt.cmd == "mtt.result" then
		if evt.resp then
			local resp = evt.resp
			if tt.nativeData.getMttInfo(resp.match_id) then
    			tt.show_msg( tt.gettext("您在比賽“{s1}”中獲得第{s2}名",tt.nativeData.getMttInfo(resp.match_id).mname,resp.urank))
    		end
			local trich = resp.trich
			if trich.money then
				tt.owner:setMoney(trich.money)
			end
			if trich.score then
				tt.owner:setVipScore(score)
			end
			self.mtt_matchs_list[resp.match_id] = nil
			self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
			self.views_.main_play_view:refreshMatchView()
		end
	elseif evt.cmd == "mtt.match_info" then
		if evt.resp.ret == 200 then
			tt.nativeData.saveMttInfo(evt.resp.match_id,evt.resp.info)
			if self.mLoadMttMatchId == evt.resp.match_id then
				self:showMttMatchInfoDialog(evt.resp.info)
			end
		end
	elseif evt.cmd == "match.reward_info" then
		if evt.resp then
			dump(evt.resp,"reward_info")
			if evt.resp.ret == 200 then
				tt.nativeData.saveRewardInfo(evt.resp.reward_id,evt.resp.reward_table)
				self.views_.main_play_view:refreshMatchRewardView(evt.resp.reward_id)
			end
		end
	elseif evt.cmd == "match.dreward_info" then
		if evt.resp then
			dump(evt.resp,"dreward_info")
			if evt.resp.ret == 200 then
				tt.nativeData.saveDrewardInfo(evt.resp.reward_id,evt.resp.reward_table)
				self.views_.main_play_view:refreshMatchRewardView(evt.resp.reward_id)
			end
		end
	elseif evt.cmd == "match.mreward_info" then
		if evt.resp then
			dump(evt.resp,"mreward_info")
			if evt.resp.ret == 200 then
				tt.nativeData.saveMrewardInfo(evt.resp.reward_id,evt.resp.reward_table)
				self.views_.main_play_view:refreshMatchRewardView(evt.resp.reward_id)
			end
		end
	elseif evt.cmd == "alloc.search" then 
		if evt.resp then
			tt.hide_wait_view()
			if evt.resp.ret == 200 then
				tt.log.d(TAG,"ret [%s] lv[%s] tid[%s]",evt.resp.ret, evt.resp.lv, evt.resp.tid)
				self:gotoRoom(evt.resp.lv, evt.resp.tid, kCashRoom)
			end
		end
	elseif evt.cmd == "game.rmdlvs" then
		if evt.resp then
			self.views_.main_play_view:refreshMainList()
		 end
	elseif evt.cmd == "happydice.open_stage" then
		if evt.resp then
		elseif evt.broadcast then
			if tt.nativeData.checkXiazhuBetHistory(evt.broadcast.happyid,evt.broadcast.stage) then
				if tolua.isnull(self.mTouzhuGameDialog) or not self.mTouzhuGameDialog:isShowing() then
					local num1 = evt.broadcast.luck_num[1] or 1
					local num2 = evt.broadcast.luck_num[2] or 1
					local num3 = evt.broadcast.luck_num[3] or 1
					local sum = num1 + num2 + num3
					tt.show_msg(tt.gettext("{s1} 期 开奖号码是 {s2} {s3} {s4} 和值{s5}",evt.broadcast.stage,num1,num2,num3,sum))
				end
			end
		end
	elseif evt.cmd == "custom.syn_tids" then
		if evt.resp then
			local resp = evt.resp
			dump(resp)
			if resp.ret == 200 then
				self.custom_room_list = checktable(resp.tids)
				local count = #self.custom_room_list
				print('-----------',count)
				if count > 0 then
					if self.isShowMyMatchListViewCash then
						self:showMatchListView()
					end
				end
				self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
				self.isShowMyMatchListViewCash = false
			elseif resp.ret == -101 then
				self.custom_room_list = {}
				self.mMyMatchTipsIcon:setVisible(self:getMatchNum()>0)
			end
		end
	end
end

function MainScene:addEventListener()
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
		tt.gevt:addEventListener(tt.gevt.SHAKE_OK, handler(self, self.onShakeOK)),
		tt.gevt:addEventListener(tt.gevt.NATIVE_EVENT, handler(self, self.onNativeEvent)),
		tt.gevt:addEventListener(tt.gevt.EVT_HTTP_RESP, handler(self, self.onHttpResp)),
		tt.gevt:addEventListener(tt.gevt.EVENT_RECONNECTING, handler(self, self.reconnectServering)),
		tt.gevt:addEventListener(tt.gevt.EVENT_RECONNECT_FAILURE, handler(self, self.reconnectServerFail)),
	}

	self.mUserInfoEventHandlers = {
		tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateCoinLabel)),
		tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		tt.owner:addEventListener(tt.owner.EVENT_VP_LV,handler(self,self.updateVpLvView)),
		tt.owner:addEventListener(tt.owner.EVENT_VP_EXP,handler(self,self.updateVpExpView)),
	}
end

function MainScene:removeEventListener()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end 
	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
end

function MainScene:test()
	local CARD_FACE_TWO      = 0x02
	local CARD_FACE_THERR    = 0x03
	local CARD_FACE_FOUR     = 0x04
	local CARD_FACE_FIVE     = 0x05
	local CARD_FACE_SIX      = 0x06
	local CARD_FACE_SEVEN    = 0x07
	local CARD_FACE_EIGHT    = 0x08
	local CARD_FACE_NINE     = 0x09
	local CARD_FACE_TEN      = 0x0A
	local CARD_FACE_JACK 	 = 0x0B
	local CARD_FACE_QUEEN    = 0x0C
	local CARD_FACE_KING     = 0x0D
	local CARD_FACE_ACE      = 0x0E

	local CARD_SUIT_DIAMOND 	= 0x00  --方片
	local CARD_SUIT_CLUB 		= 0x10  --梅花
	local CARD_SUIT_HEART 		= 0x20  --红桃
	local CARD_SUIT_SPADE 		= 0x30  --黑桃



	-- local tl = require("app.utils.texaslogic")
	-- local pc = {
	-- 				bit.bor(CARD_SUIT_SPADE,CARD_FACE_THERR),
	-- 				bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_NINE),
	-- 				bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_EIGHT),
	-- 				bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_JACK),
	-- 				bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_THERR),
	-- 			} 
	-- local s1 = {hands = {	
	-- 						bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_FOUR),
	-- 						bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_ACE),
	-- 					}
	-- 			}
	-- local s2 = {hands = {	
	-- 						bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_QUEEN),
	-- 						bit.bor(CARD_SUIT_CLUB,CARD_FACE_ACE),
	-- 					}
	-- 			}
	-- s1.cardtype,s1.bestcards = tl.make_cards(pc,s1.hands)
	-- s2.cardtype,s2.bestcards = tl.make_cards(pc,s2.hands)
	-- local ret = tl.compare_seat_cards(s1, s2)
	-- tt.log.d(TAG,"seat1 cardtype[%s] handcards[%s]", tl.type_str(s1.cardtype),tl.cards_str(s1.bestcards))
	-- tt.log.d(TAG,"seat2 cardtype[%s] handcards[%s]", tl.type_str(s2.cardtype),tl.cards_str(s2.bestcards))
	-- tt.log.d(TAG,"campare ret[%d]",ret)


 --    local net = require("framework.cc.net.init")
 --    tt.log.d(TAG,"getTime ret[%f]",net.SocketTCP.getTime())
	-- local function onEdit(event, editbox)
 --        if event == "began" then
 --            -- 开始输入
 --        elseif event == "changed" then
 --            -- 输入框内容发生变化
 --        elseif event == "ended" then
 --            -- 输入结束
 --        elseif event == "return" then
 --            -- 从输入框返回
 --        end
 --    end
    
    -- local editbox = cc.ui.UIInput.new({
    --     image = "icon/XJC_AnNiu1.png",
    --     listener = onEdit,
    --     size = CCSize(200, 40)
    -- })
    
    -- editbox:pos(display.cx, display.cy)
    -- editbox:addTo(self)
    -- --------
    -- local editbox2 = cc.ui.UIInput.new({
    --     image = "icon/XJC_AnNiu1.png",
    --     listener = onEdit,
    --     size = CCSize(200, 40)
    -- })
    -- --设置密码输入框
    -- editbox2:setInputFlag(0)
    -- editbox2:pos(display.cx, display.cy/2)
    -- editbox2:addTo(self)
    --------------
-- local MatchResultView = require("app.views.MatchResultView")
-- 	MatchResultView.new(self,{
-- 			mlv = 1004,          --比赛场次
-- 			match_id = "sng_1004_1",     --比赛id
-- 			urank = 1,        --比赛最终名次
-- 			total = 100,      --比赛总人数
-- 			money = 1000,     --比赛结束后的金币
-- 			reward = {money=0},  --奖励
-- 		},"sng")
--     	:addTo(self)
--     	:show()
 	-- 	MatchResultView.new(self,{
		-- 	mlv = 10001,          --比赛场次
		-- 	match_id = "1509959940_10001_522",     --比赛id
		-- 	urank = 1,        --比赛最终名次
		-- 	total = 100,      --比赛总人数
		-- 	reward = {  --奖励 增加的数据
		-- 		money=100,  --金币奖励 可能无
		-- 		score=100,  --积分奖励 可能无
		-- 		prop={[5]=1,[6]=2}, --游戏内道具奖励 如虚拟参赛券 可能无
		-- 		vgoods={[1010]=1},  --vip商场 如虚拟参赛券 可能无

		-- 	},
		-- 	trich = { --如果有奖励,发奖后的总数是多少 key与reward相同
		-- 		-- money= 1000,
		-- 		-- score=1000,
		-- 		-- prop={[5]=1,[6]=2}, 
		-- 	}  
		-- },"mtt")
  --   	:addTo(self)
  --   	:show()

	--引入LuaJavaBridge  
	-- local luaj = require "luaj"  
	-- local className="com/lua/java/Test" --包名/类名  
	-- local args = { "hello android", callbackLua }  
	-- local sigs = "(Ljava/lang/String;I)V" --传入string参数，无返回值  
	 
	--     --luaj 调用 Java 方法时，可能会出现各种错误，因此 luaj 提供了一种机制让 Lua 调用代码可以确定 Java 方法是否成功调用。  
	--     --luaj.callStaticMethod() 会返回两个值  
	--     --当成功时，第一个值为 true，第二个值是 Java 方法的返回值（如果有）  
	--     --当失败时，第一个值为 false，第二个值是错误代码  
	-- local ok,ret = luaj.callStaticMethod(className,"test",args,sigs)  
	-- if not ok then  
	    
	--     item:setString(ok.."error:"..ret)  
	     
	-- end  

	-- require("app.utils.sutils")
	-- local str = "你y好_*瓜神$g瓜瓜哇卡卡"
	-- print("#######################")
	-- print("str len",string.len(str))
	-- print("utf8 len",string.utf8_len(str))
	-- print(string.utf8_sub(str,2,5))
	-- print(string.utf8_sub(str,2,4))
	-- print(string.utf8_sub_width(str,1,10))
	-- print("#######################")
end

return MainScene
