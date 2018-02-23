local BLDialog = require("app.ui.BLDialog")
local TAG = "CreateRoomDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")
local SliderSelectView = require("app.ui.SliderSelectView")
local DoubleSliderSelectView = require("app.ui.DoubleSliderSelectView")
local SliderProgressSelectView = require("app.ui.SliderProgressSelectView")

local CreateRoomDialog = class("CreateRoomDialog", function()
	return BLDialog.new()
end)


function CreateRoomDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("create_room_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	cc.uiloader:seekNodeByName(node, "name_title"):setString(tt.gettext("房间名称:"))
	cc.uiloader:seekNodeByName(node, "dec_title"):setString(tt.gettext("留言:"))
	cc.uiloader:seekNodeByName(node, "blind_title"):setString(tt.gettext("盲注设置:"))
	cc.uiloader:seekNodeByName(node, "ante_title"):setString(tt.gettext("前注设置:"))
	cc.uiloader:seekNodeByName(node, "time_title"):setString(tt.gettext("牌局时间:"))
	cc.uiloader:seekNodeByName(node, "time_title2"):setString(tt.gettext("(小时)"))
	cc.uiloader:seekNodeByName(node, "pay_title"):setString(tt.gettext("买入大小:"))
	cc.uiloader:seekNodeByName(node, "buyin_title"):setString(tt.gettext("买入:"))
	cc.uiloader:seekNodeByName(node, "player_num_txt"):setString(tt.gettext("人数设置"))


	self.mBuyinTxt = cc.uiloader:seekNodeByName(node, "buyin_txt")


	local inputClip = cc.uiloader:seekNodeByName(node, "name_input_clip")
	local size = inputClip:getContentSize()
	self.mRoomNameInput = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.name_input:setMaxLength(12)
    -- self.name_input:setPlaceHolder()
    self.mRoomNameInput:setText(tt.owner:getName())
    self.mRoomNameInput:setPlaceHolder(tt.gettext("请输入房间名称"))
    self.mRoomNameInput:setFontName(display.DEFAULT_TTF_FONT)
    self.mRoomNameInput:setPlaceholderFontName(display.DEFAULT_TTF_FONT)
    self.mRoomNameInput:setFontSize(42)
    self.mRoomNameInput:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.mRoomNameInput:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self.mRoomNameInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mRoomNameInput:addTo(inputClip)

    local inputClip = cc.uiloader:seekNodeByName(node, "dec_input_clip")
	local size = inputClip:getContentSize()
	self.mDecInput = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.name_input:setMaxLength(12)
    -- self.name_input:setPlaceHolder()
    self.mDecInput:setPlaceHolder(tt.gettext("请输入房间留言"))
    self.mDecInput:setFontName(display.DEFAULT_TTF_FONT)
    self.mDecInput:setPlaceholderFontName(display.DEFAULT_TTF_FONT)
    self.mDecInput:setFontSize(42)
    self.mDecInput:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.mDecInput:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self.mDecInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mDecInput:addTo(inputClip)


    local blind_console_view = cc.uiloader:seekNodeByName(node, "blind_console_view")
    local size = blind_console_view:getContentSize()
	self.mBlindSliderSelectView = SliderProgressSelectView.new()
	self.mBlindSliderSelectView:addTo(blind_console_view)
	self.mBlindSliderSelectView:setPosition(cc.p(82,size.height/2-18))
	self.mBlindSliderSelectView:setContentSize(344,30)
	self.mBlindSliderSelectView:setSliderSize(344,13)
	self.mBlindSliderSelectView:setSelectConfig({})
	self.mBlindSliderSelectView:resetSliderScale()
    self.mBlindIndex = 1
	self.mBlindSliderSelectView:registerIndexChangeListener(function(index)
			if not self.mIniting and self.mBlindIndex == index then return end
			self.mBlindIndex = index
			if self.mBlindConfig[index] then
				self:setCostNum( self:getCostNum() )
		    	self.mBuyinTxt:setString( tt.getNumStr2(self.mPayConfig[self.mPayStartIndex]*self.mBlindConfig[self.mBlindIndex]*2) )
		    	self.mBlindTxt:setString( string.format("%s/%s",tt.getNumShortStr2(self.mBlindConfig[index]),tt.getNumShortStr2(self.mBlindConfig[index]*2)) )
		    	self.mAnteConfig = checktable(checktable(self.mCustomConfig.ante)[tostring(self.mBlindConfig[index])])
				self.mAnteSliderSelectView:setSelectConfig(self.mAnteConfig)
				self.mAnteSliderSelectView:resetSliderScale()
			end
			
		end)
	cc.uiloader:seekNodeByName(blind_console_view, "add_btn"):onButtonClicked(function()
			print(self.mBlindIndex)
			self.mBlindSliderSelectView:selectIndex(self.mBlindIndex+1)
		end)
	cc.uiloader:seekNodeByName(blind_console_view, "sub_btn"):onButtonClicked(function()
			self.mBlindSliderSelectView:selectIndex(self.mBlindIndex-1)
		end)

	local ante_console_view = cc.uiloader:seekNodeByName(node, "ante_console_view")
    local size = ante_console_view:getContentSize()
	self.mAnteSliderSelectView = SliderSelectView.new()
	self.mAnteSliderSelectView:addTo(ante_console_view)
	self.mAnteSliderSelectView:setPosition(cc.p(82,size.height/2-35))
	self.mAnteSliderSelectView:setContentSize(344,70)
	self.mAnteSliderSelectView:setSliderSize(344,13)
	self.mAnteSliderSelectView:setSelectConfig({})
	self.mAnteSliderSelectView:resetSliderScale()
    self.mAnteIndex = 1
	self.mAnteSliderSelectView:registerIndexChangeListener(function(index)
			if not self.mIniting and self.mAnteIndex == index then return end
			self.mAnteIndex = index
			if self.mAnteConfig[index] then
		    	self.mAnteTxt:setString(tt.getNumShortStr2(self.mAnteConfig[index]))
			end
		end)
	cc.uiloader:seekNodeByName(ante_console_view, "add_btn"):onButtonClicked(function()
			self.mAnteSliderSelectView:selectIndex(self.mAnteIndex+1)
		end)
	cc.uiloader:seekNodeByName(ante_console_view, "sub_btn"):onButtonClicked(function()
			self.mAnteSliderSelectView:selectIndex(self.mAnteIndex-1)
		end)

	local time_console_view = cc.uiloader:seekNodeByName(node, "time_console_view")
    local size = time_console_view:getContentSize()
	self.mTimeSliderSelectView = SliderSelectView.new()
	self.mTimeSliderSelectView:addTo(time_console_view)
	self.mTimeSliderSelectView:setPosition(cc.p(82,size.height/2-35))
	self.mTimeSliderSelectView:setContentSize(344,70)
	self.mTimeSliderSelectView:setSliderSize(344,13)
	self.mTimeSliderSelectView:setSelectConfig({})
	self.mTimeSliderSelectView:resetSliderScale()
    self.mTimeIndex = 1
	self.mTimeSliderSelectView:registerIndexChangeListener(function(index)
			if not self.mIniting and self.mTimeIndex == index then return end
			self.mTimeIndex = index
			self:setCostNum( self:getCostNum() )
		end)
	cc.uiloader:seekNodeByName(time_console_view, "add_btn"):onButtonClicked(function()
			self.mTimeSliderSelectView:selectIndex(self.mTimeIndex+1)
		end)
	cc.uiloader:seekNodeByName(time_console_view, "sub_btn"):onButtonClicked(function()
			self.mTimeSliderSelectView:selectIndex(self.mTimeIndex-1)
		end)

	local pay_console_view = cc.uiloader:seekNodeByName(node, "pay_console_view")
    local size = pay_console_view:getContentSize()
	self.mPaySliderSelectView = DoubleSliderSelectView.new()
	self.mPaySliderSelectView:addTo(pay_console_view)
	self.mPaySliderSelectView:setPosition(cc.p(40,size.height/2-35))
	self.mPaySliderSelectView:setContentSize(420,70)
	self.mPaySliderSelectView:setSliderSize(420,13)
	self.mPaySliderSelectView:setSelectConfig({})
	self.mPaySliderSelectView:resetSliderScale()
    self.mPayStartIndex = 1
    self.mPayEndIndex = 1
	self.mPaySliderSelectView:registerIndexChangeListener(function(startIndex,endIndex)
			if not self.mIniting and self.mPayStartIndex == startIndex and  self.mPayEndIndex == endIndex then return end
		    self.mPayStartIndex = startIndex
		    self.mPayEndIndex = endIndex
		    if self.mPayConfig[startIndex] and self.mPayConfig[endIndex] then
			    if startIndex == endIndex then
			    	self.mPayNumTxt:setString(self.mPayConfig[startIndex] .. "BB")
				else
			    	self.mPayNumTxt:setString(string.format("%dBB~%dBB",self.mPayConfig[startIndex],self.mPayConfig[endIndex]))
				end
		    	self.mBuyinTxt:setString( tt.getNumStr2(self.mPayConfig[self.mPayStartIndex]*self.mBlindConfig[self.mBlindIndex]*2) )
			end
		end)

	self.mCustomConfig = {}
	self.mBlindConfig = {}
	self.mAnteConfig = {}
	self.mTimeConfig = {}
	self.mPayConfig = {}

	self.mBlindTxt = cc.uiloader:seekNodeByName(node, "blind_txt")
	self.mAnteTxt = cc.uiloader:seekNodeByName(node, "ante_txt")
	self.mPayNumTxt = cc.uiloader:seekNodeByName(node, "pay_num_txt")

	self.mPlayerNum = 9
	self.mPlay9Btn = cc.uiloader:seekNodeByName(node, "play_9_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:selectPlayerNum(9)
			end)
	self.mPlay6Btn = cc.uiloader:seekNodeByName(node, "play_6_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:selectPlayerNum(6)
			end)
	self:selectPlayerNum(9)

	self.mOpenVisible = true
	self.mVisibleBtn = cc.uiloader:seekNodeByName(node, "visible_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:setOpenVisible(not self.mOpenVisible)
			end)
	self:setOpenVisible(true)

	self.mCostBg = cc.uiloader:seekNodeByName(node, "cost_bg")
	self.mChipIcon = cc.uiloader:seekNodeByName(node, "chip_icon")
	self.mChipsNumTxt = cc.uiloader:seekNodeByName(node, "chips_num_txt")

	self:setCostNum(0)

	self.mCreateBtn = cc.uiloader:seekNodeByName(node, "create_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:creatRoom()
			end)
end

function CreateRoomDialog:setCostNum(num)
	self.mChipsNumTxt:setString(num)
	local size = self.mChipsNumTxt:getContentSize()
	local w = math.max(size.width+50,151)
	self.mCostBg:setContentSize(cc.size(w,33))
	tt.LayoutUtil:layoutParentLeft(self.mChipIcon,0,-2)
	if w > 151 then
		tt.LayoutUtil:layoutParentLeft(self.mChipsNumTxt,38,0)
	else
		tt.LayoutUtil:layoutParentCenter(self.mChipsNumTxt,10,0)
	end
end

function CreateRoomDialog:getCostNum()
	return (self.mCustomConfig.create_fee + (self.mOpenVisible and self.mCustomConfig.show_fee[self.mBlindConfig[self.mBlindIndex] .. ""] or 0))*self.mTimeConfig[self.mTimeIndex]*60
end

function CreateRoomDialog:setOpenVisible(flag)
	self.mOpenVisible = flag
	if self.mOpenVisible then
		self.mVisibleBtn:setButtonImage("normal","btn/btn_dagou_pre.png",true)
		self.mVisibleBtn:setButtonImage("pressed","btn/btn_dagou_nor.png",true)
	else
		self.mVisibleBtn:setButtonImage("normal","btn/btn_dagou_nor.png",true)
		self.mVisibleBtn:setButtonImage("pressed","btn/btn_dagou_pre.png",true)
	end
	if self.mCustomConfig.create_fee and self.mCustomConfig.show_fee then
		self:setCostNum( self:getCostNum() )
	end
end

function CreateRoomDialog:selectPlayerNum(num)
	self.mPlayerNum = num
	self.mPlay9Btn:setButtonEnabled(num~=9)
	self.mPlay6Btn:setButtonEnabled(num~=6)
end

function CreateRoomDialog:loadConfig(config)
	self.mIniting = true
	self.mCustomConfig = config
	self.mBlindConfig = checktable(config.sb)
	self.mAnteConfig = checktable(checktable(config.ante)[tostring(self.mBlindConfig[self.mBlindIndex] or "")])
	self.mTimeConfig = clone(checktable(config.times))
	self.mPayConfig = checktable(config.buyin)

	-- 分钟转小时
	for i,v in ipairs(self.mTimeConfig) do
		self.mTimeConfig[i] = v / 60
	end

	self.mBlindSliderSelectView:setSelectConfig(self.mBlindConfig)
	self.mBlindSliderSelectView:resetSliderScale()
	self.mAnteSliderSelectView:setSelectConfig(self.mAnteConfig)
	self.mAnteSliderSelectView:resetSliderScale()
	self.mTimeSliderSelectView:setSelectConfig(self.mTimeConfig)
	self.mTimeSliderSelectView:resetSliderScale()
	self.mPaySliderSelectView:setSelectConfig(self.mPayConfig)
	self.mPaySliderSelectView:resetSliderScale()

	self:setCostNum( self:getCostNum() )

	local operation = tt.nativeData.getCustomOperation()
	if operation.blind then
		self.mBlindSliderSelectView:selectNum(operation.blind)
	end

	if operation.ante then
		self.mAnteSliderSelectView:selectNum(operation.ante)
	end

	if operation.time then
		self.mTimeSliderSelectView:selectNum(operation.time)
	end

	if operation.pay1 and operation.pay2 then
		self.mPaySliderSelectView:selectNum(operation.pay1,operation.pay2)
	else
		self.mPaySliderSelectView:selectNum(self.mPayConfig[1],self.mPayConfig[#self.mPayConfig])
	end

	if operation.open_visible then
		self:setOpenVisible(operation.open_visible == 1)
	end

	if operation.player_num then
		self:selectPlayerNum(operation.player_num)
	end

	self.mIniting = false
end

function CreateRoomDialog:saveOperation()
	local data = {}
	data.blind = self.mBlindConfig[self.mBlindIndex]
	data.ante = self.mAnteConfig[self.mAnteIndex]
	data.time = self.mTimeConfig[self.mTimeIndex]
	data.pay1 = self.mPayConfig[self.mPayStartIndex]
	data.pay2 = self.mPayConfig[self.mPayEndIndex]
	data.open_visible = self.mOpenVisible and 1 or 0
	data.player_num = self.mPlayerNum
	tt.nativeData.saveCustomOperation(data)
end

function CreateRoomDialog:creatRoom()
	local name = self.mRoomNameInput:getText()
	local msg = self.mDecInput:getText()
	local blind = self.mBlindConfig[self.mBlindIndex]
	local ante = self.mAnteConfig[self.mAnteIndex]
	local time = self.mTimeConfig[self.mTimeIndex]
	local pay1 = self.mPayConfig[self.mPayStartIndex]
	local pay2 = self.mPayConfig[self.mPayEndIndex]
	if name == "" then
		tt.show_msg(tt.gettext("请输入房间名称"))
		return
	end

	if not blind then return end
	if not ante then return end
	if not time then return end
	if not pay1 then return end
	if not pay2 then return end

	tt.gsocket.request("custom.create_room",{
			name = name, --房间名称 
			ante = ante,   --前注
			sb = blind,    --小盲  大盲=2X小盲
			time = time*60,  --房间时间
			min_buy = pay1,   --最小买入的大盲数 
			max_buy = pay2,   --最高买入的大盲数
			seat = self.mPlayerNum,   --几人座 
			show_status = self.mOpenVisible and 1 or 0,  --大厅展示状态
			mnick = tt.owner:getName(),
			msg = msg,
		})
end

function CreateRoomDialog:show()
	BLDialog.show(self)
	local config = tt.nativeData.getCustomConfig()
	tt.gsocket.request("custom.config",{
			ver = config.ver or 0,
		})
	if config.ver then
		self:loadConfig(config)
	end
end

function CreateRoomDialog:dismiss()
	BLDialog.dismiss(self)
	self:saveOperation()
end

function CreateRoomDialog:onEnter()
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}

	self.mUserInfoEventHandlers = {
		-- tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateCoinLabel)),
		-- tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_JUAN,handler(self,self.updateJuan)),
		-- tt.owner:addEventListener(tt.owner.EVENT_COINS,handler(self,self.updateCoins)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VP_LV,handler(self,self.updateVpLvView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VP_EXP,handler(self,self.updateVpExpView)),
	}
end

function CreateRoomDialog:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

function CreateRoomDialog:onSocketData(evt)
	print("CreateRoomDialog onSocketData",evt.cmd)
	if evt.cmd == "custom.config" then
		if evt.resp then
			if evt.resp.ret == 200 then
				self:loadConfig(evt.resp.info)
			end
		end
	elseif evt.cmd == "custom.create_room" then
		if evt.resp then
			if evt.resp.ret == 200 then
				self.control_:gotoRoom(evt.resp.room.clv,evt.resp.room.tid, kCustomRoom,evt.resp.room)
			elseif evt.resp.ret == -102 then
				tt.show_msg(tt.gettext("筹码不足"))
			else
				tt.show_msg(tt.gettext("创建失败,请稍后再试!"))
			end
		end
	end
	-- resp = {
	-- 		ret = 200,  -- -101:已创建过房间 -102:筹码不足 -103:参数验证失败  -104房间数量不够
	-- 		cmoney = 2000,  --本次创建房间费用 
	-- 		left_money = 10010, --剩余筹码数
	-- 		room = {
	-- 			ownerid = 10035,  --房主id
	-- 			roomid = 1001,  --房号 1001-9999 四位数字
	-- 			clv = 9999,    --自定房间的场次号:目前都为9999
	-- 			tid = 5001,   --房间id
	-- 			name = "xxx", --房间名称 
	-- 			ante = 50,   --前注
	-- 			sb = 50,    --小盲  大盲=2X小盲
	-- 			left_time = 3600,  --房间剩余时间:s
	-- 			create_time = 60,  --房间创建时间unix时间戳
	-- 			min_buy = 100,   --最小买入的大盲数 
	-- 			max_buy = 400,   --最高买入的大盲数
	-- 			seat = 6,   --几人座 
	-- 			players = 5,  --在玩数
	-- 			watchers = 2,  --观战人数
	-- 			show_status = 0,  --大厅展示状态 0:不可见 1：可见
	-- 		}
	-- 	}
end

return CreateRoomDialog