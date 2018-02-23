local BLDialog = require("app.ui.BLDialog")
local TAG = "SpeakerEditDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")
local IMHelper = require("app.libs.IMHelper")

local SpeakerEditDialog = class("SpeakerEditDialog", function()
	return BLDialog.new()
end)


function SpeakerEditDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("speaker_edit_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	local inputClip = cc.uiloader:seekNodeByName(node, "clip_view")
	local size = inputClip:getContentSize()
	self.mInputTxt = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.mInputTxt:setMaxLength(12)
    -- self.mInputTxt:setPlaceHolder()
    self.mInputTxt:setFontName(display.DEFAULT_TTF_FONT)
    self.mInputTxt:setFontSize(40)
    self.mInputTxt:setFontColor(cc.c3b(0x2e, 0x45, 0xa8))
    self.mInputTxt:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mInputTxt:addTo(inputClip)
    self.mInputTxt:registerScriptEditBoxHandler(handler(self,self.onNickEdit_1))

	self.mLabaIcon = cc.uiloader:seekNodeByName(node, "laba_icon")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.control_:showShopDialog(3)
			end)
		
	cc.uiloader:seekNodeByName(node, "send_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
        		if tt.owner:getHorn() == 0 then
					self.control_:showShopDialog(3)
        			return 
        		end
        		local str = self.mInputTxt:getText()
        		if #str > 0 then
        			IMHelper.sendHornMsg(str)
        		end
			end)

	self.mMessegeList = cc.uiloader:seekNodeByName(node, "messege_list")
		
end

function SpeakerEditDialog:onEdit(textfield, eventType)
	print(textfield,eventType)
    if eventType == 0 then
        -- ATTACH_WITH_IME
    elseif eventType == 1 then
        -- DETACH_WITH_IME
    elseif eventType == 2 then
        -- INSERT_TEXT
        if self.mInputTxt == textfield then
        	local str = self.mInputTxt:getString()
        	self.mInputTxt:setString(string.sub(str,1,140))
        end
    elseif eventType == 3 then
        -- DELETE_BACKWARD
    end
end

function SpeakerEditDialog:onNickEdit_1(event)
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化
    elseif event == "ended" then
        -- 输入结束
    	local str = self.mInputTxt:getText()
		if str ~= string.sub(str,1,140) then
			self.mInputTxt:setText(string.sub(str,1,140))
		end
    elseif event == "return" then
        -- 从输入框返回
    end
end

function SpeakerEditDialog:updateLabaView()
	local labaNum = tt.owner:getHorn()
	if labaNum >= 10000 then labaNum = 9999 end
	if not tolua.isnull(self.mLabaNumView) then self.mLabaNumView:removeSelf() end
	self.mLabaNumView = tt.getBitmapStrAscii("number/green00_%d.png",labaNum)
	self.mLabaNumView:addTo(self.mLabaIcon)
	tt.LayoutUtil:layoutParentBottom(self.mLabaNumView,-2,-60)
end

function SpeakerEditDialog:initMessageList()
	self.mMessegeList:removeAllItems()
	local msgs = tt.nativeData.getHornMsgHistory()
	-- local content = ""
	-- for i=1,140 do
	-- 	content = content .. (i%10)
	-- end
	-- table.insert(msgs,{
	-- 		uid = 10012,
	-- 		name = "1234567890",
	-- 		content = content,
	-- 		time = 1516174020,
	-- 		mtype = "user_bar",
	-- 	})
	for i,msg in ipairs(msgs) do
		local item = self.mMessegeList:newItem()
		local content = self:createMsgItem(msg)
		item:addContent(content)
		local size = content:getContentSize()
		item:setItemSize(size.width, size.height)
		item:setMargin({left = 0, right = 0, top = 0, bottom = 0})
		self.mMessegeList:addItem(item)
	end
	self.mMessegeList:reload()
	if self.mMessegeList.viewRect_.height < self.mMessegeList.size.height then
		self.mMessegeList:scrollTo(0, 0)
	end
end

function SpeakerEditDialog:addMessage(msg)
	local item = self.mMessegeList:newItem()
	local content = self:createMsgItem(msg)
	item:addContent(content)
	local size = content:getContentSize()
	item:setItemSize(size.width, size.height)
	item:setMargin({left = 0, right = 0, top = 0, bottom = 0})
	self.mMessegeList:addItem(item)

	self.mMessegeList:reload()
	if self.mMessegeList.viewRect_.height < self.mMessegeList.size.height then
		self.mMessegeList:scrollTo(0, 0)
	end
end

function SpeakerEditDialog:createSysMsgItem(msg)
	local node = display.newNode()
	local timeTxt = display.newTTFLabel({
		    text = os.date("%H:%M:%S",msg.time),
		    size = 40,
		    color = cc.c3b(0x16,0xa6,0x31),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
	-- local name = msg.name
	-- if #name > 7 then
	-- 	name = string.sub(name,1,6) .. ".."
	-- end
	-- local nameTxt = display.newTTFLabel({
	-- 	    text = name,
	-- 	    size = 40,
	-- 	    color = cc.c3b(0x16,0xa6,0x31),
	-- 	    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
	-- 	})
	local content = msg.content
	-- if #content >= 119 then
	-- 	content = string.sub(content,1,118) .. "\n" .. string.sub(content,119)
	-- end
	-- if #content >= 60 then
	-- 	content = string.sub(content,1,59) .. "\n" .. string.sub(content,60)
	-- end
	local msgTxt = display.newTTFLabel({
		    text = content,
		    size = 40,
		    color = cc.c3b(0xce,0x2b,0x2b), -- 0x
		    align = cc.TEXT_ALIGNMENT_LEFT, -- 文字内部居中对齐
		    dimensions = cc.size(925, 0),
		})
	msgTxt:setLineHeight(30)

	local dec_line = display.newSprite("dec/line_broadcast.png")

	timeTxt:addTo(node)
	-- nameTxt:addTo(node)
	msgTxt:addTo(node)
	dec_line:addTo(node)
	local size = msgTxt:getContentSize()
	local h = math.max(size.height,30)

	node:setContentSize(cc.size(1070,h+20))
	tt.LayoutUtil:layoutParentTopLeft(timeTxt,10)
	-- tt.LayoutUtil:layoutParentTopLeft(nameTxt,10,-30)
	tt.LayoutUtil:layoutParentTopLeft(msgTxt,140)
	tt.LayoutUtil:layoutParentBottom(dec_line)
	return node
end


function SpeakerEditDialog:createUserMsgItem(msg)
	local node = display.newNode()
	local timeTxt = display.newTTFLabel({
		    text = os.date("%H:%M:%S",msg.time),
		    size = 40,
		    color = cc.c3b(0x16,0xa6,0x31),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
	local name = msg.name .. ':'
	if #name > 7 then
		name = string.sub(name,1,6) .. "..:"
	end
	local nameTxt = display.newTTFLabel({
		    text = name,
		    size = 40,
		    color = cc.c3b(0x16,0xa6,0x31),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
	local content = msg.content
	-- if #content >= 119 then
	-- 	content = string.sub(content,1,118) .. "\n" .. string.sub(content,119)
	-- end
	-- if #content >= 60 then
	-- 	content = string.sub(content,1,59) .. "\n" .. string.sub(content,60)
	-- end
	local msgTxt = display.newTTFLabel({
		    text = content,
		    size = 40,
		    color = cc.c3b(0x2e,0x45,0xa8), -- 0x
		    align = cc.TEXT_ALIGNMENT_LEFT, -- 文字内部居中对齐
		    dimensions = cc.size(925, 0),
		})
	msgTxt:setLineHeight(30)

	local dec_line = display.newSprite("dec/line_broadcast.png")

	timeTxt:addTo(node)
	nameTxt:addTo(node)
	msgTxt:addTo(node)
	dec_line:addTo(node)
	local size = msgTxt:getContentSize()
	local h = math.max(size.height,60)

	node:setContentSize(cc.size(1070,h+20))
	tt.LayoutUtil:layoutParentTopLeft(timeTxt,10,-30)
	tt.LayoutUtil:layoutParentTopLeft(nameTxt,10)
	tt.LayoutUtil:layoutParentTopLeft(msgTxt,140)
	tt.LayoutUtil:layoutParentBottom(dec_line)
	return node
end

function SpeakerEditDialog:createCustomBugleMsgItem(msg)
	local node = display.newNode()
	local timeTxt = display.newTTFLabel({
		    text = os.date("%H:%M:%S",msg.time),
		    size = 40,
		    color = cc.c3b(0x16,0xa6,0x31),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		})
	-- local name = msg.name
	-- if #name > 7 then
	-- 	name = string.sub(name,1,6) .. ".."
	-- end
	-- local nameTxt = display.newTTFLabel({
	-- 	    text = name,
	-- 	    size = 40,
	-- 	    color = cc.c3b(0x16,0xa6,0x31),
	-- 	    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
	-- 	})
	local data = json.decode(msg.content)
	local content = data.msg

	-- if #content >= 119 then
	-- 	content = string.sub(content,1,118) .. "\n" .. string.sub(content,119)
	-- end
	-- if #content >= 60 then
	-- 	content = string.sub(content,1,59) .. "\n" .. string.sub(content,60)
	-- end

	local msgTxt = display.newTTFLabel({
		    text = content,
		    size = 40,
		    color = cc.c3b(0xce,0x2b,0x2b), -- 0x
		    align = cc.TEXT_ALIGNMENT_LEFT, -- 文字内部居中对齐
		    dimensions = cc.size(925, 0),
		})
	msgTxt:setLineHeight(30)

	local dec_line = display.newSprite("dec/line_broadcast.png")

	timeTxt:addTo(node)
	-- nameTxt:addTo(node)
	msgTxt:addTo(node)
	dec_line:addTo(node)
	local size = msgTxt:getContentSize()
	local h = math.max(size.height,30)

	node:setContentSize(cc.size(1070,h+20))
	tt.LayoutUtil:layoutParentTopLeft(timeTxt,10)
	-- tt.LayoutUtil:layoutParentTopLeft(nameTxt,10,-30)
	tt.LayoutUtil:layoutParentTopLeft(msgTxt,140)
	tt.LayoutUtil:layoutParentBottom(dec_line)
	return node
end

function SpeakerEditDialog:createMsgItem(msg)
	if msg.mtype == "bar" then return self:createSysMsgItem(msg) end
	if msg.mtype == "user_bar" then return self:createUserMsgItem(msg) end
	if msg.mtype == "custom_bugle" then return self:createCustomBugleMsgItem(msg) end
	return display.newNode()
end

function SpeakerEditDialog:show()
	BLDialog.show(self)
	self:updateLabaView()
	self:initMessageList()
end

function SpeakerEditDialog:dismiss()
	BLDialog.dismiss(self)
end

function SpeakerEditDialog:onEnter()
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}

	self.mUserInfoEventHandlers = {
		-- tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateMoney)),
		-- tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_JUAN,handler(self,self.updateJuan)),
		-- tt.owner:addEventListener(tt.owner.EVENT_COINS,handler(self,self.updateCoins)),
		tt.owner:addEventListener(tt.owner.EVENT_HORN,handler(self,self.updateLabaView)),
	}
end

function SpeakerEditDialog:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

function SpeakerEditDialog:onSocketData(evt)
	print("TouzhuGameView onSocketData",evt.cmd)
	if evt.cmd == "msgbox.live_broad" then
		if evt.resp then
			if evt.resp.ret == 200 then
				self.mInputTxt:setText("")
			else
				tt.show_msg(tt.gettext("发送失败，请稍后再试！"))
			end
		end
		if evt.broadcast then
			if evt.broadcast.mtype == "bar" then
				self:addMessage({
			        mtype = evt.broadcast.mtype,
			        uid = evt.broadcast.sender,
			        name = "",
			        content = evt.broadcast.content,
			        time = evt.broadcast.stime,
			    })
			elseif evt.broadcast.mtype == "user_bar" then
				local data = json.decode(evt.broadcast.content)
				self:addMessage({
			        mtype = evt.broadcast.mtype,
			        uid = evt.broadcast.sender,
			        name = data.name,
			        content = data.content,
			        time = evt.broadcast.stime,
			    })
			elseif evt.broadcast.mtype == "custom_bugle" then
				local data = json.decode(evt.broadcast.content)
				self:addMessage({
			        mtype = evt.broadcast.mtype,
			        uid = evt.broadcast.sender,
			        name = "",
			        content = evt.broadcast.content,
			        time = evt.broadcast.stime,
			    })
			end
		end
	end
end

return SpeakerEditDialog