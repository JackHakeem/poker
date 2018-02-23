


local net = require("framework.cc.net.init")
local User = require("app.model.User")
local FacebookHelper = require("app.libs.FacebookHelper")

local LoginScene = class("LoginScene", function()
    return display.newScene("LoginScene")
end)

function LoginScene:ctor(isLogout)
	-- 初始化用户单例
	tt.owner = User.new()
	self:initView()
	printInfo("isLogout" .. (isLogout == true and 1 or 2) .. " " .. type(isLogout))
	self.isLogout = isLogout == true
	if self.isLogout then
		tt.statisticsHalper.onProfileSignOff()
	end
	tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.luaVersion,{version=kVersion})
end

function LoginScene:initView() 
	local node, width, height = cc.uiloader:load("login_layer.json")
	node:align(display.CENTER,display.cx,display.cy)
	self:addChild(node)
	self.root_ = node

	self.facebookLoginBtn = cc.uiloader:seekNodeByName(node, "facebook_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.facebookLoginBtn)
			if device.platform == "windows" or device.platform == "mac" then
				self:performWithDelay(function()
	        		native_event(json.encode({
	        				cmd="loginYouke",
	        				params=json.encode({
	        						ret = 1,
							        phone = "18645678901",
							        uuid = self.nickEdit_:getText(),
							        device_no = "866333026356720",
							        iccid = "89860080191509823650",
							        devicename = "QK3",
							        imsi = "460002606708980",
							        imei = "866333026356720",
							        macid = "18:59:36:11:9f:f0",
							        pixel = "1080x1920",
							        nettype = "WIFI",
							        osversion = "win7",
							        url = "file://hall/head_default_img.png",
	        					})
	        			}))
        		end,0.5)
        	else
				self:onLoginFacebook()
			end
		end)
		:setVisible(false)
	self.youkeBtn = cc.uiloader:seekNodeByName(node, "youke_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.youkeBtn)
			self:onLoginYouke()
		end)
		:setVisible(false)

	self.content_view = cc.uiloader:seekNodeByName(node, "content_view")
	-- self.content_view:setVisible(false)

	self.loading_bg = cc.uiloader:seekNodeByName(node, "loading_bg")
	self.loading_bg:setVisible(false)
	-- local size = self.loading_bg:getContentSize()
	-- self.progress = cc.ProgressTimer:create(cc.Sprite:create("dec/landing_jiazaitiao.png"))
	--     :setType(cc.PROGRESS_TIMER_TYPE_BAR)
	--     :setMidpoint(cc.p(0,0))
	--     :setBarChangeRate(cc.p(1, 0))
	--     :setPosition(size.width/2,size.height/2+1)
 --    	:addTo(self.loading_bg,1)
	self.loading_txt = cc.uiloader:seekNodeByName(node, "loading_txt")
	self.loading_txt:setVisible(false)

	cc.uiloader:seekNodeByName(node, "tips_txt"):setString("gm@woyaoent.com " .. tt.gettext("版本{s1}",kVersion))

	local size = cc.size(130,40)
    local x,y = 640,600
	self.nickEdit_ = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = cc.size(200,200),
        x = x,
        y = y,
    })
    self.nickEdit_:setMaxLength(12)
    self.nickEdit_:setFontName(display.DEFAULT_TTF_FONT)
    self.nickEdit_:setFontColor(cc.c3b(0xD4, 0xD4, 0xD4))
    self.nickEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self.nickEdit_:addTo(self)
    self.nickEdit_:setText("1")

    if GAME_MODE_DEBUG then

	else
		self.nickEdit_:setVisible(false)
	end

end

function LoginScene:onEnter()
	tt.log.d(TAG,"LoginScene gsocket isConnected %s",tt.gsocket:isConnected())
	self.gevt_handlers_ = {
		-- tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
		tt.gevt:addEventListener(tt.gevt.SHAKE_OK, handler(self, self.onShakeOK)),
		tt.gevt:addEventListener(tt.gevt.NATIVE_EVENT, handler(self, self.onNativeEvent)),

		tt.gevt:addEventListener(tt.gevt.EVT_HTTP_RESP, handler(self, self.onHttpResp)),

		-- tt.gevt:addEventListener(tt.gevt.EVENT_RECONNECTING, handler(self, self.onNativeEvent))
		tt.gevt:addEventListener(tt.gevt.EVENT_RECONNECT_FAILURE, handler(self, self.reconnectServerFail)),
	}
	
	if tt.gsocket:isConnected() then
		tt.gsocket:close()
	end
	-- dump(tt.game_data)
	if not self.isLogout then
		self:checkVersion()
	else
		self:hide_wait_view()
	end
	tt.play.play_music("BGM")
	tt.backEventManager.addBackEventLayer(self)
	self.callbackHandler = tt.backEventManager.registerCallBack(handler(self, self.onKeypadListener))

	--清理本地缓存数据
	tt.nativeData.setBankruptcy()
	tt.nativeData.setVipShopLock(true)
end

function LoginScene:autoLogin()
	if tt.getOpenUDID() == "PERMISSION_DENIED" then
		-- tt.show_msg("need permission")
		self:hide_wait_view()
		return 
	end
	if not self.isLogout and tt.game_data.preLoginType and tt.game_data.preLoginParams then
		if tt.game_data.preLoginType == 1 then
			tt.ghttp.request(tt.cmd.loginTour,tt.game_data.preLoginParams)
			self:show_wait_view(tt.gettext("游客登陸中..."),60,30)
		elseif tt.game_data.preLoginType == 2 then
			tt.ghttp.request(tt.cmd.loginFB,tt.game_data.preLoginParams)
			self:show_wait_view(tt.gettext("facebook登陸中..."),60,30)
		else
			self:hide_wait_view()
		end
	else
		self:hide_wait_view()
	end
end

function LoginScene:onKeypadListener(event)
	print("LoginScene event.key:",event.key)
	-- if device.platform == "android" then
	-- 	if event.key == "back" and event.type == "Released" then
	-- 		return self._backEvent()
	-- 	end
	-- elseif device.platform == "windows" then
	-- 	if event.code == 140 and event.type == "Released" then
	-- 		return self._backEvent()
	-- 	end
	-- end
end

function LoginScene:checkVersion()
	local params = {}
	tt.ghttp.request(tt.cmd.ver_check,params)
	self:show_wait_view(tt.gettext("版本檢查中..."),30,10)
end

function LoginScene:reconnectServerFail()
	tt.show_msg(tt.gettext("游戲服務器連接失敗"))
	self:hide_wait_view()
end


function LoginScene:onLoginFacebook()
	if tt.getOpenUDID() == "PERMISSION_DENIED" then
		-- tt.show_msg("need permission")
		return 
	end
	local ret,error = tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.loginFacebook)
	if not ret then
		tt.show_msg(error)
	else
		-- self:show_wait_view("facebook登陸中...",60,30)
	end
end

function LoginScene:onLoginYouke()
	if tt.getOpenUDID() == "PERMISSION_DENIED" then
		-- tt.show_msg("need permission")
		return 
	end
	local ret,error = tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.loginYouke)
	if not ret then
		tt.show_msg(error)
	else
		self:show_wait_view(tt.gettext("獲取配置..."),10,0)
	end
end

function LoginScene:onNativeEvent(evt)
	printInfo("LoginScene:onNativeEvent %s", evt.params)
	if evt.cmd == tt.platformEventHalper.callbackCmds.loginFacebook then
		local params = json.decode(evt.params)
		if params.ret == 1 then
			params.url = string.format("https://graph.facebook.com/%s/picture?width=%d&height=%d&loginTime=%d", params.id, 220, 220,net.SocketTCP.getTime())
			tt.nativeData.saveLoginData(2,params)
			self.isLogout = false
			self:autoLogin()
	 	elseif params.ret == 2 then
			self:hide_wait_view()
	 	elseif params.ret == 3 then
	 		tt.show_msg(tt.gettext("登陸失敗! error:") .. (params.error or ""))
			self:hide_wait_view()
		end
	elseif evt.cmd == tt.platformEventHalper.callbackCmds.loginYouke then
		local params = json.decode(evt.params)
		if params.ret == 1 then
			tt.nativeData.saveLoginData(1,params)
			self.isLogout = false
			self:autoLogin()
	 	elseif params.ret == 2 then
			self:hide_wait_view()
	 	elseif params.ret == 3 then
	 		tt.show_msg(tt.gettext("登陸失敗! error:") .. (params.error or ""))
			self:hide_wait_view()
		end
	end
end

function LoginScene:onHttpResp(evt)
	if evt.cmd == tt.cmd.ver_check then
		dump(evt,"ver_check")
		if evt.data.ret == 0 then
			local data = evt.data.data
			local utype = tonumber(data.type)
			dump(data,"ver_check")
			if utype == 1 then
				local view = self:showChooseDialog(string.format("%s",data.info),nil,function()
						device.openURL(data.url)
						return true
					end)
				view:setMode(2)
				view:setBackEvent(function() return true end)
				self:hide_wait_view()
			elseif utype == 2 then
				local view = self:showChooseDialog(string.format("%s",data.info),function()
						tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.selectUpdateCancelBtn)
						self:addhotupdate()
					end,function()
						tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.selectUpdateConfirmBtn)
						device.openURL(data.url)
						return true
					end)
				view:setMode(1)
				view:setBackEvent(function() view:dismiss() return true end)
				self:hide_wait_view()
			else
				self:addhotupdate()
			end
		else
			self:hide_wait_view()
		end
	elseif evt.cmd == tt.cmd.loginTour then
		if evt.data.ret == 0 then
	        local data = evt.data.data
	        if data.mstatus == 1 then
	            local sinfo = data.serverinfo
	            if sinfo then
	            	self:show_wait_view(tt.gettext("連接服務器中..."),80,60)
	            	local token = tt.PushHelper.getToken()
	            	print("push token:",token)
	            	if token and token ~= "" then
	            		tt.PushHelper.bindtoken(token)
	            	end
	            else
					self:hide_wait_view()
	            end
	        elseif data.mstatus == 2 then
				self:hide_wait_view()
	        elseif data.mstatus == 3 then
	        	local view = self:showChooseDialog(tt.gettext("服务器正在维护当中，预计完成时间为{s1}，请您稍后再尝试登录。给您带来的不便敬请原谅！",os.date("%x %H:%M",data.ltime)),nil,function()
	        		app:exit()
					return true
				end)
				view:setMode(2)
				view:setBackEvent(function() view:dismiss() return true end)
				self:hide_wait_view()
	        else
				self:hide_wait_view()
	        end
	    else
			self:hide_wait_view()
	    end
	elseif evt.cmd == tt.cmd.loginFB then
		if evt.data.ret == 0 then
	        local data = evt.data.data
	        if data.mstatus == 1 then
	            if data.is_reg == 1 then
	            	FacebookHelper.getAllRequestsForReward()
            	end
	            local sinfo = data.serverinfo
	            if sinfo then
	            	self:show_wait_view(tt.gettext("連接服務器中..."),80,60)
	            	local token = tt.PushHelper.getToken()
	            	print("push token:",token)
	            	if token and token ~= "" then
	            		tt.PushHelper.bindtoken(token)
	            	end
	            else
					self:hide_wait_view()
	            end
	        elseif data.mstatus == 2 then
				self:hide_wait_view()
			elseif data.mstatus == 3 then
	        	local view = self:showChooseDialog(tt.gettext("服务器正在维护当中，预计完成时间为{s1}，请您稍后再尝试登录。给您带来的不便敬请原谅！",os.date("%x %H:%M",data.ltime)),nil,function()
	        		app:exit()
					return true
				end)
				view:setMode(2)
				view:setBackEvent(function() view:dismiss() return true end)
				self:hide_wait_view()
	        else
				self:hide_wait_view()
	        end
	    else
			self:hide_wait_view()
	    end
	end
end

--握手成功
function LoginScene:onShakeOK()
	self:show_wait_view(tt.gettext("連接服務器中..."),100,80)
	self:performWithDelay(function()
			app:enterScene("MainScene",{true})
		end, 1)
end

function LoginScene:showChooseDialog(str,cancelClick,confirmClick)
	local view = app:createView("ChooseDialog")
		:addTo(self.root_)
		:setContentStr(str)
		:setOnCancelClick(cancelClick)
		:setOnConfirmClick(confirmClick)
	view:show()
	return view
end

function LoginScene:show_wait_view(str,per,startPer)
	print("LoginScene:show_wait_view",str,per,startPer)
	self.loading_bg:setVisible(true)
	self.loading_txt:setVisible(true)
	self.loading_txt:setString(str)


	-- startPer = startPer or self.progress:getPercentage()
	-- if startPer > per then per = startPer end
	-- local action  = cc.ProgressFromTo:create(1, startPer,per)
	-- action:setTag(1)
	-- self.progress:stopActionByTag(1)
	-- self.progress:runAction(action)

	local rotationAction = cc.RepeatForever:create(cc.RotateBy:create(1.5, 360))
	rotationAction:setTag(1)
	self.loading_bg:runAction(rotationAction)
	self.facebookLoginBtn:setVisible(false)
	self.youkeBtn:setVisible(false)
	-- self.content_view:setVisible(false)
end

function LoginScene:hide_wait_view()
	print("LoginScene:hide_wait_view")
	self.loading_bg:setVisible(false)
	self.loading_txt:setVisible(false)
	self.loading_bg:stopActionByTag(1)
	-- self.progress:stopActionByTag(1)
	-- self.progress:setPercentage(0)
	self.facebookLoginBtn:setVisible(true)
	self.youkeBtn:setVisible(true)
	-- self.content_view:setVisible(true)
end

function LoginScene:addhotupdate()
	local writablepath = cc.FileUtils:getInstance():getWritablePath()
    local storagepath = writablepath .. "hotupdate/" .. kPlatformVersionCode .. "/"
	
	--[[
	参数1是读取文件地址。
	参数2是下载的资源储存到哪。
	如果要将 project.manifest 放到 res/version 下的话，
	必须设置优先路径 res/version，否则 project.manifest 只能放在res目录下
	]]

    local am = cc.AssetsManagerEx:create("project.manifest",storagepath)
    am:retain()
	self.am = am 
	self.failedcount = 0
    --获得当前本地版本
    local localManifest = am:getLocalManifest()
    if localManifest:getVersion() ~= kVersion then
    	if GAME_MODE_DEBUG then
    		tt.show_msg( string.format("Manifest version %s is != kVersion %s",localManifest:getVersion(),kVersion))
    	end
    end
    print(storagepath)
    print(localManifest:getVersion())
	print("getPackageUrl",localManifest:getPackageUrl())
	print("getManifestFileUrl",localManifest:getManifestFileUrl())
	print("getVersionFileUrl",localManifest:getVersionFileUrl())

    if not am:getLocalManifest():isLoaded() then 
        print("加载本地project.manifest错误.")
        --进登录界面
		self:autoLogin()
    else 
        local listener = cc.EventListenerAssetsManagerEx:create(am,function(event)
        	if not tolua.isnull(self) then
	            self:onUpdateEvent(event)
	        end
        end)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener,1)
        am:update()
       	self:show_wait_view(tt.gettext("检测资源文件中..."),60,0)
    end
end

function LoginScene:onUpdateEvent(event)
    local eventCode = event:getEventCode()

	local assetId = event:getAssetId()
    local percent = event:getPercent()
    local percentByFile = event:getPercentByFile()
    local message = event:getMessage()
    printInfo("游戏更新("..eventCode.."):"..", assetId->"..assetId..", percent->"..percent..", percentByFile->"..percentByFile..", message->"..message)
    if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
        print("找不到本地manifest文件.")
		self._perent = 100
		self:autoLogin()
        --进登录界面 
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ASSET_UPDATED then
		-- self:show_wait_view("正在更新文件 : " .. assetId,event:getPercentByFile())
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
        print("正在更新文件 : ",event:getAssetId())
        --print("更新进度 : ",event:getPercent())
        if event:getAssetId() == cc.AssetsManagerExStatic.VERSION_ID then 
       		self:show_wait_view(tt.gettext("检测文件版本中..."),event:getPercent(),0)
            --print("文件版本 : ",event:getPercent())
        elseif event:getAssetId() == cc.AssetsManagerExStatic.MANIFEST_ID then
       		self:show_wait_view(tt.gettext("检测文件Manifest中..."),event:getPercent(),0)
            --print("文件Manifest : ",event:getPercent())
        else 
			self:show_wait_view( tt.gettext("正在更新资源包({s1}%)",string.format("%.0f",event:getPercentByFile())),event:getPercentByFile())
            --print("进度条的进度 : ",event:getPercent())
            --跳进度
			self._perent = event:getPercentByFile()
        end
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or 
        	eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
        print("远程资源清单文件下载失败")
		self._perent = 100
		self:updateFail()
        --print("资源清单文件解析失败 ")
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE then 
		print("已经是服务器最新版本ALREADY_UP_TO_DATE")
		self._perent = 100
		self:autoLogin()
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
        print("更新到服务器最新版本UPDATE_FINISHED")
		self._perent = 100
		tt.clearAll()
		app:run()
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
        print("更新过程中遇到错误")
        self:updateFail()
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND  then
        print("发现新版本，开始升级",self.am:getRemoteManifest():getVersion())
        self:show_wait_view(tt.gettext("发现新版本，开始升级"),0,0)
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED  then
		print("更新失败")
		if self.failedcount > 10 then 
			self._perent = 100
			self:updateFail()
		else 
			self.failedcount = self.failedcount + 1 --如果有的文件更新失败,连续更新10次,超过十次还是进游戏
			self.am:downloadFailedAssets() 
		end
    end
end

function LoginScene:updateFail(str)
	local view = self:showChooseDialog( str or tt.gettext("更新失败,请重试") ,nil,function()
			self:addhotupdate()
			return true
		end)
	view:setMode(2)
	view:setBackEvent(function() return true end)
end

function LoginScene:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end 
	tt.backEventManager.unregisterCallBack(self.callbackHandler)
end

return LoginScene
