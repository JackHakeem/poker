local TAG = "UserinfoView"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")
local BLDialog = require("app.ui.BLDialog")

local UserinfoView = class("UserinfoView", function(...)
	return BLDialog.new(...)
end)


function UserinfoView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("userinfo_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node,"context_view")

	self.close_btn = cc.uiloader:seekNodeByName(self.context_view,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:dismiss()
		end)


	self.head_icon = cc.uiloader:seekNodeByName(self.context_view,"head_icon")

	self.name_txt = cc.uiloader:seekNodeByName(self.context_view,"name_txt")
	self.id_txt = cc.uiloader:seekNodeByName(self.context_view,"id_txt")


	self.money_txt = cc.uiloader:seekNodeByName(self.context_view,"money_txt")
	self.juan_txt = cc.uiloader:seekNodeByName(self.context_view,"juan_txt")

	cc.uiloader:seekNodeByName(self.context_view,"fb_icon"):setVisible(tt.owner:isFb())

    self.name_view = cc.uiloader:seekNodeByName(self.context_view,"name_view")

    local inputClip = cc.uiloader:seekNodeByName(node, "name_input_clip")
	local size = inputClip:getContentSize()
	self.name_input = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.name_input:setMaxLength(12)
    -- self.name_input:setPlaceHolder()
    self.name_input:setFontName(display.DEFAULT_TTF_FONT)
    self.name_input:setFontSize(36)
    self.name_input:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.name_input:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.name_input:addTo(inputClip)
    self.name_input:registerScriptEditBoxHandler(handler(self,self.onNickEdit_1))

    self.input_bg = cc.uiloader:seekNodeByName(self.context_view,"input_bg")
    self.modify_icon = cc.uiloader:seekNodeByName(self.context_view,"modify_icon")

    if tt.owner:isFb() then
    	self.name_input:setVisible(false)
    	self.modify_icon:setVisible(false)
    	self.input_bg:setVisible(false)
    	self.name_txt:setVisible(true)
    else
    	self.name_input:setVisible(true)
    	self.modify_icon:setVisible(true)
    	self.input_bg:setVisible(true)
    	self.name_txt:setVisible(false)
    end

    self.mNick = ""

    self.mIcon = cc.uiloader:seekNodeByName(node,"vip_icon")
    self.mVipTxt = cc.uiloader:seekNodeByName(node,"vip_txt")

    self:initPropView()
end

function UserinfoView:show()
	BLDialog.show(self)
	self:setVisible(true)
	self:updateMoney()
	self:updateName()
	self:updateId(tt.owner:getUid())
	self:updateHeadIcon(tt.owner:getIconUrl())
	self:updateJuan()
	self:updateVipLvView()
	self:updateVipScoreView()
	-- self.context_view:setScale(0.2)
	-- local action = cc.ScaleTo:create(0.5, 1, 1)
	-- self.context_view:runAction(transition.newEasing(action,"BACKINOUT"))

	tt.ghttp.request(tt.cmd.goods,{})
end

function UserinfoView:updateVipLvView()
	self.mIcon:setTexture(string.format("dec/icon_vip".. tt.owner:getVipLv() .. ".png"))
end

function UserinfoView:updateVipScoreView()
    self.mVipTxt:setString(tt.getNumStr(tt.owner:getVipScore()))
end

function UserinfoView:updateJuan()
	self.juan_txt:setString(tt.getNumStr(tt.owner:getJuan()))
end

function UserinfoView:updateMoney()
	local money = tt.owner:getMoney()
	self.money_txt:setString(tt.getNumStr(money))
end

function UserinfoView:updateName()
	local name = tt.owner:getName()
	printInfo("UserinfoView:updateName %s",name)
	self.name_txt:setString(name)
    self.name_input:setText(name)
	self.mNick = name
end

function UserinfoView:updateId(uid)
	self.id_txt:setString(string.format("ID:%d",uid))
end

function UserinfoView:updateHeadIcon(url)
	printInfo("updateHeadIcon %s", url)
	tt.asynGetHeadIconSprite(url,function(sprite)
		if sprite and self and self.head_icon then
			local size = self.head_icon:getContentSize()
			local mask = display.newSprite("dec/def_head2.png")
			if self.head_ then
				self.head_:removeSelf()
			end

			self.head_ = CircleClip.new(sprite,mask):addTo(self.head_icon)
				:setCircleClipContentSize(size.width,size.width)

			-- local scalX=size.width/sprite:getContentSize().width--设置x轴方向的缩放系数
			-- local scalY=size.height/sprite:getContentSize().height--设置y轴方向的缩放系数
			-- sprite:setAnchorPoint(cc.p(0, 0))
			-- 	:setScaleX(scalX)
			-- 	:setScaleY(scalY)

			-- self.head_ = sprite:addTo(self.head_icon)
			-- self.head_:setPosition(cc.p(0,0))
		end
	end)
end


function UserinfoView:dismiss()
	BLDialog.dismiss(self)
	self:removeSelf()
end

function UserinfoView:onEnter()
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}

	self.mUserInfoEventHandlers = {
		tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateMoney)),
		tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		tt.owner:addEventListener(tt.owner.EVENT_JUAN,handler(self,self.updateJuan)),
	}
end

function UserinfoView:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

function UserinfoView:onSocketData(evt)
	tt.log.d(TAG, "cmd:[%s]",evt.cmd)	

	local resp = evt.resp
	if evt.cmd == "uinfo.changnick" then
		dump(evt.resp)
		if evt.resp.ret == 200 then
			tt.owner:setName(evt.resp.mnick)
		else
			tt.show_msg(tt.gettext("修改失败:")..evt.resp.ret)
			tt.play.play_sound("action_failed")
		end
	end
end

function UserinfoView:sendChangeNameCmd(str)
	if str == tt.owner:getName() then return end
	local sStr = string.sub(str,1,10)
	print(sStr,str)
	if string.len(sStr) ~= string.len(str) then 
		tt.show_msg(tt.gettext("昵称最多10个英文"))
		tt.play.play_sound("action_failed")
		return 
	end

	tt.gsocket.request("uinfo.changnick",{mid=tt.owner:getUid(),mnick=str})
end

function UserinfoView:onEdit(textfield, eventType)
	print(textfield,eventType)
    if eventType == 0 then
        -- ATTACH_WITH_IME
		tt.play.play_sound("click")
		self.name_input:setString(self.mNick)
    elseif eventType == 1 then
        -- DETACH_WITH_IME
        local _text = self.name_input:getString()
		local _trimed = string.trim(_text)
   		self.name_input:setString(self.mNick)
        if _trimed ~= "" and _trimed ~= tt.owner:getName() then
	   		self:sendChangeNameCmd(_trimed)
		end
    elseif eventType == 2 then
        -- INSERT_TEXT
        local _text = self.name_input:getString()
		local _trimed = string.trim(_text)
		local _sub_trimed = string.sub(_trimed,1,10)
		print("`````````````````````````",#_sub_trimed)
		self.name_input:setString(_sub_trimed)
    elseif eventType == 3 then
        -- DELETE_BACKWARD
    end
end

function UserinfoView:onNickEdit_1(event)
    if event == "began" then
    	printInfo("UserinfoView:onNickEdit_ began")
		tt.play.play_sound("click")
		tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.userInfoChangeName)
		self.name_input:setText(self.mNick)
		self.isChangeName = false
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化
        self.isChangeName = true
    	printInfo("UserinfoView:onNickEdit_ changed")
        local _text = self.name_input:getText()
        local _trimed = string.trim(_text)
        if _trimed ~= _text then
			self.name_input:setText(_trimed)
			self.name_txt:setString(_trimed)
			-- self.mNick = _trimed
        end
    elseif event == "ended" then
    	printInfo("UserinfoView:onNickEdit_ ended")
        local _text = self.name_input:getText()
		local _trimed = string.trim(_text)
		self.name_input:setText(tt.owner:getName())
		self.name_txt:setString(tt.owner:getName())

    	if not self.isChangeName then return end
		if _trimed ~= "" and _trimed ~= self.mNick then
		    self:sendChangeNameCmd(_trimed)
		    self.mNick = _trimed
		end
        -- 输入结束
  --       local _text = self.name_input:getText()
		-- local _trimed = string.trim(_text)
		-- if _trimed ~= _text and _trimed ~= "" then
		--     self:updateName(_trimed)
		-- end
		-- self.name_input:setText("")
		-- printInfo("onNickEdit_ ended %s",_text)
    elseif event == "return" then
    	printInfo("UserinfoView:onNickEdit_ return")
		-- self.name_input:setText("")
        -- 从输入框返回
  --       local _text = self.name_input:getText()
		-- local _trimed = string.trim(_text)
		-- if _trimed ~= _text and _trimed ~= "" then
		--     self:updateName(_trimed)
		-- end
		-- self.name_input:setText("")
		-- printInfo("onNickEdit_ return %s",_text)
    end
end

function UserinfoView:initPropView()
	print("UserinfoView:initPropView")
    self.mPropItems = {}
	self.mPropListviewHandler = cc.uiloader:seekNodeByName(self.root_,"listview_handler")
	self.mPropListview = cc.ui.UIListView.new {
	        viewRect = cc.rect(-4, -4, 405, 219),
	        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
	        -- scrollbarImgV = "dec/jinfutiao.png"
    	}
        :addTo(self.mPropListviewHandler)
   	self.mPropListview:onTouch(handler(self, self.onPropListviewEvent))

    self.mShowPropItem = cc.uiloader:seekNodeByName(self.root_,"show_prop_handler")
    self.mShowPropTimeLimitTxt = cc.uiloader:seekNodeByName(self.root_,"time_limit_txt")
    self.mShowPropInfoDecList = cc.uiloader:seekNodeByName(self.root_,"prop_info_list")
   	self.mShowPropInfoDecList:onTouch(handler(self, self.onPropListviewEvent2))
    self.mPropProcessBg = cc.uiloader:seekNodeByName(self.root_,"prop_process_bg")
    self.mPropProcessBtn = cc.uiloader:seekNodeByName(self.root_,"prop_process_btn")

    self.mShowPropUseBtn = cc.uiloader:seekNodeByName(self.root_,"use_btn")
    self.mProcessBg = cc.uiloader:seekNodeByName(self.mPropListviewHandler,"process_bg")
    self.mProcessBtn = cc.uiloader:seekNodeByName(self.mProcessBg,"process_btn")


    self.mShowPropBg = cc.uiloader:seekNodeByName(self.mShowPropItem,"show_prop_bg")
    self.mLimitTimeBg = cc.uiloader:seekNodeByName(self.root_,"limit_time_bg")
    cc.uiloader:seekNodeByName(self.mLimitTimeBg,"Label_30"):setString(tt.gettext("有效期"))
    
    self.mPropLight = cc.uiloader:seekNodeByName(self.root_,"prop_light")


    self.mShowPropUseBtn:setButtonEnabled(false)
    self.mShowPropUseBtn:onButtonClicked(handler(self, self.useProp))
    self:setShowProp()

	self.mPropListview:setBounceable(false)
	self.mShowPropInfoDecList:setBounceable(false)

    self.mPropListviewH = -219
    self.mPropListviewH2 = -154
    -- for i=1,4 do
    -- 	self:addPropLine()
    -- end
    self.mPropListview:reload()
end

function UserinfoView:onPropListviewEvent(event)
	local container = event.listView.container
	if event.name == "moved" then
		local x,y = container:getPosition()
		print("UserinfoView:onPropListviewEvent",x,y,self.mPropListviewH)
		if y > 0 then 
			self:setPropProcessPercent(1)
			return 
		end
		if self.mPropListviewH == 0 then
			self:setPropProcessPercent(0)
		else
			self:setPropProcessPercent(-y/self.mPropListviewH)
		end
	end
end

function UserinfoView:onPropListviewEvent2(event)
	local container = event.listView.container
	if event.name == "moved" then
		local x,y = container:getPosition()
		print("UserinfoView:onPropListviewEvent2",x,y,self.mPropListviewH2)
		if y > 0 then 
			self:setPropProcessPercent2(1)
			return 
		end
		if self.mPropListviewH2 == 0 then
			self:setPropProcessPercent2(0)
		else
			self:setPropProcessPercent2(-y/self.mPropListviewH2)
		end
	end
end

function UserinfoView:setPropProcessPercent(percent)
	local startY = 42
	local endY = 170
	print("UserinfoView:setPropProcessPercent",percent,(endY-startY)*percent + startY)

	self.mProcessBtn:setPosition(cc.p(11,(endY-startY)*percent + startY))

end

function UserinfoView:setPropProcessPercent2(percent)
	local startY = 38
	local endY = 114
	print("UserinfoView:setPropProcessPercent",percent,(endY-startY)*percent + startY)

	self.mPropProcessBtn:setPosition(cc.p(11,(endY-startY)*percent + startY))

end

function UserinfoView:addPropLine()
	local node = display.newNode()
	local item = self.mPropListview:newItem()
	local w = 10
	local h = 0
	for i=1,4 do
		local ins = self:newPropItem()
		ins:addTo(node)
		ins:setPosition(cc.p(w,0))
		w = w + ins:getContentSize().width
		h = ins:getContentSize().height
		table.insert(self.mPropItems,ins)
	end
	node:setContentSize(405,95)
	item:addContent(node)
	item:setItemSize(405, 95)
	self.mPropListviewH = self.mPropListviewH + 95
    self.mPropListview:addItem(item)
end

function UserinfoView:onVipProp(datas)
	self.mPropDatas = datas or {}
	self.mPropItems = {}
	self.mPropListview:removeAllItems()

    self.mPropListviewH = -219

	local hang = math.ceil(#self.mPropDatas / 3)
	for i=1,hang do
		self:addPropLine()
	end

	for i,data in ipairs(self.mPropDatas) do
		if self.mPropItems[i] then
			local prop = tt.newModel("Prop")
			prop:setData(data)
			self.mPropItems[i]:setPropData(prop)
		end
	end

	self.mPropListview:reload()
end

function UserinfoView:reloadData()
	tt.ghttp.request(tt.cmd.goods,{})
	self.mPropDatas = {}
	self.mPropItems = {}
	self.mPropListview:removeAllItems()
    self.mPropListviewH = -219
	self.mPropListview:reload()
	self:setShowProp()
end

function UserinfoView:setShowProp(prop)
	for _,item in ipairs(self.mPropItems) do
		item:clearSelected()
	end

	if not prop then
		self.mShowPropTimeLimitTxt:setVisible(false)
		self.mShowPropInfoDecList:setVisible(false)
		self.mShowPropUseBtn:setVisible(false)
		self.mShowPropBg:setVisible(false)
    	self.mLimitTimeBg:setVisible(false)
    	self.mPropLight:setVisible(false)
    	
		if self.mShowPropIcon then
			self.mShowPropIcon:removeSelf()
			self.mShowPropIcon = nil
		end
		self.mShowProp = nil
		return
	else
		self.mShowPropTimeLimitTxt:setVisible(true)
		self.mShowPropInfoDecList:setVisible(true)
		self.mShowPropUseBtn:setVisible(true)
		self.mShowPropBg:setVisible(true)
    	self.mLimitTimeBg:setVisible(true)
    	self.mPropLight:setVisible(true)
		self.mShowProp = prop
	end
	local timeLimit = prop:getTimeLimit()
	self.mShowPropTimeLimitTxt:setString(string.format("%s-%s",os.date("%Y/%m/%d",timeLimit.startT),os.date("%Y/%m/%d",timeLimit.endT)))

	self.mShowPropInfoDecList:removeAllItems()

    self.mPropListviewH2 = -154
    self:setPropProcessPercent2(1)

	local label = display.newTTFLabel({
		    text = prop:getPropDec(),
		    size = 36,
		    color = cc.c3b(255,255,255),
		    align = cc.TEXT_ALIGNMENT_LEFT,
		    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
		    dimensions = cc.size(406, 0)
		})

	local item = self.mShowPropInfoDecList:newItem()
	item:addContent(label)
	local size = label:getContentSize()
	item:setItemSize(size.width, size.height)
	print(size.width, size.height)
	self.mPropListviewH2 = self.mPropListviewH2 + size.height

    self.mShowPropInfoDecList:addItem(item)

	self.mShowPropInfoDecList:reload()

	self.mShowPropUseBtn:setButtonEnabled(prop:isCanUse())

	if self.mShowPropIcon then
		self.mShowPropIcon:removeSelf()
		self.mShowPropIcon = nil
	end

	tt.asynGetHeadIconSprite(prop:getIconUrl(),function(sprite)
		if sprite and self and self.mShowPropItem then
			-- local mask = display.newSprite("dec/zhezhao.png")
			if self.mShowPropIcon then
				self.mShowPropIcon:removeSelf()
			end
			-- self.head_ = CircleClip.new(sprite,mask):addTo(self.head_icon)
			-- 	:setCircleClipContentSize(size.width-6,size.width-6)
			local size = self.mShowPropItem:getContentSize()
			local scalX=size.width/sprite:getContentSize().width--设置x轴方向的缩放系数
			local scalY=size.height/sprite:getContentSize().height--设置y轴方向的缩放系数
			sprite:setAnchorPoint(cc.p(0, 0))
				:setScaleX(scalX)
				:setScaleY(scalY)

			self.mShowPropIcon = sprite:addTo(self.mShowPropItem)
			self.mShowPropIcon:setPosition(cc.p(0,0))
		end
	end)
	dump(self.mShowProp:getData())
end

function UserinfoView:useProp()
	if not self.mShowProp then return end
	tt.play.play_sound("click")
	self.control_:showInformationAuthenticationDialog(self.mShowProp:getData())
end

function UserinfoView:newPropItem()
	local width,height = 95,95
	local item = display.newNode()
	-- local item = display.newRect(cc.rect(0, 0, width, height),{fillColor = cc.c4f(1,0,0,1)})
	item:setContentSize(width,height)

	local touch_size = cc.size(72,64)
	local prop_handler = display.newNode()
	-- local prop_handler = display.newRect(cc.rect(0, 0, touch_size.width, touch_size.height),{fillColor = cc.c4f(1,1,0,1)})
	prop_handler:setAnchorPoint(cc.p(0.5,0.5))
	prop_handler:setContentSize(touch_size.width,touch_size.height)
	prop_handler:setPosition(cc.p(width/2,height/2))
	prop_handler:addTo(item)

	prop_handler:setTouchEnabled(true)
	prop_handler:setTouchSwallowEnabled(false)
	prop_handler:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    local x,y = event.x,event.y
	    if event.name == "began" then
	    	startX = x
        	startY = y
        	if not prop_handler:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" and down then
	    		if item.mProp then 
		    		tt.play.play_sound("click")
		    		item:selected()
		    	end
			end
		end
	end)

	local mask_img = display.newSprite("btn/btn_checkbox_nor.png")
	mask_img:addTo(item)
	mask_img:setPosition(cc.p(width/2,height/2))

	local function selected()
		self:setShowProp(item.mProp)
		mask_img:setTexture("btn/btn_checkbox_sel.png")
	end

	local function clearSelected()
		mask_img:setTexture("btn/btn_checkbox_nor.png")
	end

	local function setPropData(self,prop)
		self.mProp = prop
		print("test",prop:getIconUrl())
		tt.asynGetHeadIconSprite(prop:getIconUrl(),function(sprite)
			if sprite then
				if tolua.isnull(self) then
					sprite:removeSelf()
					return 
				end
				-- local mask = display.newSprite("dec/zhezhao.png")
				if self.mIcon then
					self.mIcon:removeSelf()
				end
				-- self.head_ = CircleClip.new(sprite,mask):addTo(self.head_icon)
				-- 	:setCircleClipContentSize(size.width-6,size.width-6)

				local scalX=touch_size.width/sprite:getContentSize().width--设置x轴方向的缩放系数
				local scalY=touch_size.height/sprite:getContentSize().height--设置y轴方向的缩放系数
				-- sprite:setAnchorPoint(cc.p(0, 0))
				sprite:setScaleX(scalX)
				sprite:setScaleY(scalY)
				sprite:setPosition(cc.p(touch_size.width/2,touch_size.height/2))
				self.mIcon = sprite:addTo(prop_handler)
			end
		end)

	end

	local function clearProp(self)
		self.mProp = nil
		if self.mIcon then
			self.mIcon:removeSelf()
			self.mIcon = nil
		end
	end


	item.setPropData = setPropData
	item.clearProp = clearProp
	item.selected = selected
	item.clearSelected = clearSelected
	return item
end

return UserinfoView
