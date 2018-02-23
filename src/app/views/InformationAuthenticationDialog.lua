local BLDialog = require("app.ui.BLDialog")
local TAG = "InformationAuthenticationDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local InformationAuthenticationDialog = class("InformationAuthenticationDialog", function()
	return BLDialog.new()
end)


function InformationAuthenticationDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("information_authentication_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	self.mSendBtn = cc.uiloader:seekNodeByName(node, "send_btn")
		:onButtonClicked(handler(self,self.onSendClick))
		
	self:initInput(node)
	

	self.mNameTipsView = cc.uiloader:seekNodeByName(node, "name_tips_view")
	self.mPhoneNumTipsView = cc.uiloader:seekNodeByName(node, "phone_num_tips_view")
	self.mIdCardTipsView = cc.uiloader:seekNodeByName(node, "id_card_tips_view")
	self.mLocationTipsView = cc.uiloader:seekNodeByName(node, "location_tips_view")

	local initView = function(view)
		-- cc.uiloader:seekNodeByName(view, "success"):setVisible(false)
		cc.uiloader:seekNodeByName(view, "fail"):setVisible(false)
	end
	initView(self.mNameTipsView)
	initView(self.mPhoneNumTipsView)
	initView(self.mIdCardTipsView)
	initView(self.mLocationTipsView)
		

	self.mDesc1 = cc.uiloader:seekNodeByName(node, "desc_1")
	self.mDesc2 = cc.uiloader:seekNodeByName(node, "desc_2")

	self.mNameTitle = cc.uiloader:seekNodeByName(node, "name_title")
	self.mPhonenumTitle = cc.uiloader:seekNodeByName(node, "phonenum_title")
	self.mIdcardTitle = cc.uiloader:seekNodeByName(node, "idcard_title")
	self.mLocaltionTitle = cc.uiloader:seekNodeByName(node, "localtion_title")
	self.mPhonetypeTitle = cc.uiloader:seekNodeByName(node, "phonetype_title")


	self.mNameBg = cc.uiloader:seekNodeByName(node, "name_bg")
	self.mPhonenumBg = cc.uiloader:seekNodeByName(node, "phonenum_bg")
	self.mIdcardBg = cc.uiloader:seekNodeByName(node, "idcard_bg")
	self.mLocaltionBg = cc.uiloader:seekNodeByName(node, "localtion_bg")
	self.mPhoneTypeHandler = cc.uiloader:seekNodeByName(node, "phone_type_handler")




	self.mNameInput:setPlaceHolder(tt.gettext("請輸入真實姓名"))
		:setFontName(display.DEFAULT_TTF_FONT)
	self.mNameTitle:setString(tt.gettext("真实姓名:"))
	cc.uiloader:seekNodeByName(self.mNameTipsView, "Label_20"):setString(tt.gettext("請輸入有效的真實姓名"))

	self.mPhoneNumInput:setPlaceHolder(tt.gettext("請輸入聯絡電話"))
		:setFontName(display.DEFAULT_TTF_FONT)
	self.mPhonenumTitle:setString(tt.gettext("联络电话:"))
	cc.uiloader:seekNodeByName(self.mPhoneNumTipsView, "Label_20"):setString(tt.gettext("請輸入有效的電話號碼"))


	self.mIdCardInput:setPlaceHolder(tt.gettext("請輸入身份證"))
		:setFontName(display.DEFAULT_TTF_FONT)
	self.mIdcardTitle:setString(tt.gettext("ID CARD:"))
	cc.uiloader:seekNodeByName(self.mIdCardTipsView, "Label_20"):setString(tt.gettext("請輸入有效的身份證號碼"))


	self.mLocationInput:setPlaceHolder(tt.gettext("請輸入通訊地址"))
		:setFontName(display.DEFAULT_TTF_FONT)
	self.mLocaltionTitle:setString(tt.gettext("通訊地址:"))
	cc.uiloader:seekNodeByName(self.mLocationTipsView, "Label_20"):setString(tt.gettext("請輸入有效的通訊地址"))


	self.mPhonetypeTitle:setString(tt.gettext("运营商"))
	self.mPhoneType = "True MOVE"
	self.mPhoneTypeBtns = {}
	for i=1,4 do
		self.mPhoneTypeBtns[i] = cc.uiloader:seekNodeByName(self.mPhoneTypeHandler, "btn_"..i)
		if i==1 then
			cc.uiloader:seekNodeByName(self.mPhoneTypeBtns[i], "select"):setVisible(true)
		end
		self.mPhoneTypeBtns[i]:onButtonClicked(function()
				for j=1,4 do
					cc.uiloader:seekNodeByName(self.mPhoneTypeBtns[j], "select"):setVisible(i==j)
				end
				if i==1 then
					self.mPhoneType = "True MOVE"
				elseif i==2 then
					self.mPhoneType = "my by CAT"
				elseif i==3 then
					self.mPhoneType = "AIS"
				elseif i==4 then
					self.mPhoneType = "DTAC"
				end
			end)
	end

	self.mDesc1:setString(tt.gettext("該信息只為提供獎品兌換而收集，不會存在個人信息泄露的風險"))
	self.mDesc2:setString(tt.gettext("中獎人同意本公司取得個人資料后，僅供本次活動領獎及提供第三人寄送獎品之用"))
end

function InformationAuthenticationDialog:initInput(node)
	local inputClip = cc.uiloader:seekNodeByName(node, "name_input_clip")
	local size = inputClip:getContentSize()
	self.mNameInputClip = inputClip
	self.mNameInput = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.mNameInput:setMaxLength(12)
    self.mNameInput:setFontName(display.DEFAULT_TTF_FONT)
    self.mNameInput:setFontSize(43)
    self.mNameInput:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.mNameInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mNameInput:addTo(inputClip)
    self.mNameInput:registerScriptEditBoxHandler(function (event)
		    if event == "began" then
		        -- 开始输入
		    elseif event == "changed" then
		        -- 输入框内容发生变化
		    elseif event == "ended" then
		        -- 输入结束
        	self:inputCheck(self.mNameInput,self.mNameTipsView)
		    elseif event == "return" then
		        -- 从输入框返回
		    end
		end)

    local inputClip = cc.uiloader:seekNodeByName(node, "phone_num_input_clip")
	local size = inputClip:getContentSize()
	self.mPhoneNumInputClip = inputClip
	self.mPhoneNumInput = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.mPhoneNumInput:setMaxLength(12)
    self.mPhoneNumInput:setFontName(display.DEFAULT_TTF_FONT)
    self.mPhoneNumInput:setFontSize(43)
    self.mPhoneNumInput:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.mPhoneNumInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mPhoneNumInput:addTo(inputClip)
    self.mPhoneNumInput:registerScriptEditBoxHandler(function (event)
		    if event == "began" then
		        -- 开始输入
		    elseif event == "changed" then
		        -- 输入框内容发生变化
		    elseif event == "ended" then
		        -- 输入结束
        	local flag = self:inputCheck(self.mPhoneNumInput,self.mPhoneNumTipsView,10) or self:inputCheck(self.mPhoneNumInput,self.mPhoneNumTipsView,9)
		    elseif event == "return" then
		        -- 从输入框返回
		    end
		end)

    local inputClip = cc.uiloader:seekNodeByName(node, "id_card_input_clip")
	local size = inputClip:getContentSize()
	self.mIdCardInputClip = inputClip
	self.mIdCardInput = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.mIdCardInput:setMaxLength(12)
    self.mIdCardInput:setFontName(display.DEFAULT_TTF_FONT)
    self.mIdCardInput:setFontSize(43)
    self.mIdCardInput:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.mIdCardInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mIdCardInput:addTo(inputClip)
    self.mIdCardInput:registerScriptEditBoxHandler(function (event)
		    if event == "began" then
		        -- 开始输入
		    elseif event == "changed" then
		        -- 输入框内容发生变化
		    elseif event == "ended" then
		        -- 输入结束
        	if tonumber(self.mSendData.type) == 2 or tonumber(self.mSendData.type) == 4 then
        		self:inputCheck(self.mIdCardInput,self.mIdCardTipsView)
	        	local str = self.mIdCardInput:getText()
				if not self:isRightEmail(str) then
					-- cc.uiloader:seekNodeByName(self.mIdCardTipsView, "success"):setVisible(false)
					cc.uiloader:seekNodeByName(self.mIdCardTipsView, "fail"):setVisible(true)
				end
			else
        		self:inputCheck(self.mIdCardInput,self.mIdCardTipsView,13)
			end
		    elseif event == "return" then
		        -- 从输入框返回
		    end
		end)

    local inputClip = cc.uiloader:seekNodeByName(node, "location_input_clip")
	local size = inputClip:getContentSize()
	self.mLocationInputClip = inputClip
	self.mLocationInput = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = size,
        x = size.width/2,
        y = size.height/2,
    })
    -- self.mLocationInput:setMaxLength(12)
    self.mLocationInput:setFontName(display.DEFAULT_TTF_FONT)
    self.mLocationInput:setFontSize(43)
    self.mLocationInput:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.mLocationInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mLocationInput:addTo(inputClip)
    self.mLocationInput:registerScriptEditBoxHandler(function (event)
		    if event == "began" then
		        -- 开始输入
		    elseif event == "changed" then
		        -- 输入框内容发生变化
		    elseif event == "ended" then
		        -- 输入结束
        	self:inputCheck(self.mLocationInput,self.mLocationTipsView)
		    elseif event == "return" then
		        -- 从输入框返回
		    end
		end)
end

function InformationAuthenticationDialog:inputCheck(input,view,num)
	local txt = input:getText()
	if txt == "" then
		-- cc.uiloader:seekNodeByName(view, "success"):setVisible(false)
		cc.uiloader:seekNodeByName(view, "fail"):setVisible(true)
		return false
	else
		if num and #txt ~= num then
			-- cc.uiloader:seekNodeByName(view, "success"):setVisible(false)
			cc.uiloader:seekNodeByName(view, "fail"):setVisible(true)
			return false
		end
		-- cc.uiloader:seekNodeByName(view, "success"):setVisible(true)
		cc.uiloader:seekNodeByName(view, "fail"):setVisible(false)
		return true
	end
end

function InformationAuthenticationDialog:onEdit(textfield, eventType)
	print(textfield,eventType)
    if eventType == 0 then
        -- ATTACH_WITH_IME
    elseif eventType == 1 then
        -- DETACH_WITH_IME
        if self.mNameInput == textfield then
        	self:inputCheck(self.mNameInput,self.mNameTipsView)
        elseif self.mPhoneNumInput == textfield then
        	local flag = self:inputCheck(self.mPhoneNumInput,self.mPhoneNumTipsView,10) or self:inputCheck(self.mPhoneNumInput,self.mPhoneNumTipsView,9)
        elseif self.mIdCardInput == textfield then
			if tonumber(self.mSendData.type) == 2 or tonumber(self.mSendData.type) == 4 then
        		self:inputCheck(self.mIdCardInput,self.mIdCardTipsView)
	        	local str = self.mIdCardInput:getText()
				if not self:isRightEmail(str) then
					-- cc.uiloader:seekNodeByName(self.mIdCardTipsView, "success"):setVisible(false)
					cc.uiloader:seekNodeByName(self.mIdCardTipsView, "fail"):setVisible(true)
				end
			else
        		self:inputCheck(self.mIdCardInput,self.mIdCardTipsView,13)
			end
        elseif self.mLocationInput == textfield then
        	self:inputCheck(self.mLocationInput,self.mLocationTipsView)
        end
    elseif eventType == 2 then
        -- INSERT_TEXT
    elseif eventType == 3 then
        -- DELETE_BACKWARD
    end
end

function InformationAuthenticationDialog:isRightEmail(str)
	if string.len(str or "") < 6 then return false end  
    local b,e = string.find(str or "", '@')  
    local bstr = ""  
    local estr = ""  
    if b then  
        bstr = string.sub(str, 1, b-1)  
        estr = string.sub(str, e+1, -1)  
    else  
        return false  
    end  
  
    -- check the string before '@'  
    -- local p1,p2 = string.find(bstr, "[%w_]+")  
    -- if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end  
  
    -- check the string after '@'  
    if string.find(estr, "^[%.]+") then return false end  
    if string.find(estr, "%.[%.]+") then return false end  
    if string.find(estr, "@") then return false end  
    if string.find(estr, "%s") then return false end --空白符  
    if string.find(estr, "[%.]+$") then return false end  
  
    _,count = string.gsub(estr, "%.", "")  
    if (count < 1 ) or (count > 3) then  
        return false  
    end  
  
    return true  
end

function InformationAuthenticationDialog:onSendClick()
	tt.play.play_sound("click")
	local flag = true
	flag = self:inputCheck(self.mNameInput,self.mNameTipsView) and flag
	flag = (self:inputCheck(self.mPhoneNumInput,self.mPhoneNumTipsView,10) or self:inputCheck(self.mPhoneNumInput,self.mPhoneNumTipsView,9)) and flag
	if tonumber(self.mSendData.type) ~= 2 and tonumber(self.mSendData.type) ~= 4 then
		flag = self:inputCheck(self.mIdCardInput,self.mIdCardTipsView,13) and flag
		flag = self:inputCheck(self.mLocationInput,self.mLocationTipsView) and flag
	else
		flag = self:inputCheck(self.mIdCardInput,self.mIdCardTipsView) and flag
	end
	local detail = {}
	if tonumber(self.mSendData.type) == 2 then
		local str = self.mIdCardInput:getText()
		if not self:isRightEmail(str) then
			-- cc.uiloader:seekNodeByName(self.mIdCardTipsView, "success"):setVisible(false)
			cc.uiloader:seekNodeByName(self.mIdCardTipsView, "fail"):setVisible(true)
			flag = false
		end

		detail = {
			name = self.mNameInput:getText(),
			phone = self.mPhoneNumInput:getText(),
			email = self.mIdCardInput:getText(),
		}
	elseif tonumber(self.mSendData.type) == 4 then
		local str = self.mIdCardInput:getText()
		if not self:isRightEmail(str) then
			-- cc.uiloader:seekNodeByName(self.mIdCardTipsView, "success"):setVisible(false)
			cc.uiloader:seekNodeByName(self.mIdCardTipsView, "fail"):setVisible(true)
			flag = false
		end

		detail = {
			name = self.mNameInput:getText(),
			phone = self.mPhoneNumInput:getText(),
			email = self.mIdCardInput:getText(),
			phonebus = self.mPhoneType,
		}
	else
		detail = {
			name = self.mNameInput:getText(),
			phone = self.mPhoneNumInput:getText(),
			idcard = self.mIdCardInput:getText(),
			address = self.mLocationInput:getText(),
		}
	end
	if flag then
	    local params = {
	    	goods_id=self.mSendData.goods_id,
	    	pid=self.mSendData.pid,
	    	detail=json.encode(detail),
	    }
		tt.ghttp.request(tt.cmd.add_detail,params)
	end
end

function InformationAuthenticationDialog:show()
	BLDialog.show(self)
end

function InformationAuthenticationDialog:setSendData(data)
	self.mSendData = data
	local width = self.context_view:getContentSize().width/2
	local height = self.context_view:getContentSize().height/2
	if data then
		if tonumber(data.type) == 2 then
			self.mDesc1:setPosition(cc.p(width,height-152))
			self.mDesc2:setPosition(cc.p(width,height-177))
			self.mSendBtn:setPosition(cc.p(width,height-263))

			self.mNameTitle:setPosition(cc.p(width-215,height+151))
			self.mPhonenumTitle:setPosition(cc.p(width-215,height+67))
			self.mIdcardTitle:setPosition(cc.p(width-215,height-14))
			self.mLocaltionTitle:setVisible(false)
			self.mPhonetypeTitle:setVisible(false)

			self.mNameBg:setPosition(cc.p(width+92,height+151))
			self.mPhonenumBg:setPosition(cc.p(width+92,height+67))
			self.mIdcardBg:setPosition(cc.p(width+92,height-14))
			self.mLocaltionBg:setVisible(false)
			self.mPhoneTypeHandler:setVisible(false)

			self.mNameTipsView:setPosition(cc.p(width-201,height+99))
			self.mPhoneNumTipsView:setPosition(cc.p(width-201,height+17))
			self.mIdCardTipsView:setPosition(cc.p(width-201,height-65))
			self.mLocationTipsView:setVisible(false)

			tt.LayoutUtil:layoutCenter(self.mNameInputClip,self.mNameBg)
			tt.LayoutUtil:layoutCenter(self.mPhoneNumInputClip,self.mPhonenumBg)
			tt.LayoutUtil:layoutCenter(self.mIdCardInputClip,self.mIdcardBg)
			-- self.mNameInputClip:setPosition(cc.p(width-193,height+151))
			-- self.mPhoneNumInputClip:setPosition(cc.p(width-193,height+67))
			-- self.mIdCardInputClip:setPosition(cc.p(width-193,height-14))
			self.mLocationInputClip:setVisible(false)

			self.mIdCardInput:setPlaceHolder(tt.gettext("請輸入郵箱地址"))
			self.mIdcardTitle:setString(tt.gettext("郵箱地址:"))
			cc.uiloader:seekNodeByName(self.mIdCardTipsView, "Label_20"):setString(tt.gettext("請輸入有效的郵箱地址"))
		elseif tonumber(data.type) == 4 then

			self.mDesc1:setPosition(cc.p(width,height-176))
			self.mDesc2:setPosition(cc.p(width,height-201))
			self.mSendBtn:setPosition(cc.p(width,height-263))

			self.mNameTitle:setPosition(cc.p(width-215,height+151))
			self.mPhonenumTitle:setPosition(cc.p(width-215,height+67))
			self.mIdcardTitle:setPosition(cc.p(width-215,height-14))
			self.mLocaltionTitle:setVisible(false)
			self.mPhonetypeTitle:setVisible(true)

			self.mNameBg:setPosition(cc.p(width+92,height+151))
			self.mPhonenumBg:setPosition(cc.p(width+92,height+67))
			self.mIdcardBg:setPosition(cc.p(width+92,height-14))
			self.mLocaltionBg:setVisible(false)
			self.mPhoneTypeHandler:setVisible(true)

			self.mNameTipsView:setPosition(cc.p(width-201,height+99))
			self.mPhoneNumTipsView:setPosition(cc.p(width-201,height+17))
			self.mIdCardTipsView:setPosition(cc.p(width-201,height-65))
			self.mLocationTipsView:setVisible(false)

			
			tt.LayoutUtil:layoutCenter(self.mNameInputClip,self.mNameBg)
			tt.LayoutUtil:layoutCenter(self.mPhoneNumInputClip,self.mPhonenumBg)
			tt.LayoutUtil:layoutCenter(self.mIdCardInputClip,self.mIdcardBg)
			-- self.mNameInputClip:setPosition(cc.p(width-193,height+151))
			-- self.mPhoneNumInputClip:setPosition(cc.p(width-193,height+67))
			-- self.mIdCardInputClip:setPosition(cc.p(width-193,height-14))
			self.mLocationInputClip:setVisible(false)

			self.mIdCardInput:setPlaceHolder(tt.gettext("請輸入郵箱地址"))
			self.mIdcardTitle:setString(tt.gettext("郵箱地址:"))
			cc.uiloader:seekNodeByName(self.mIdCardTipsView, "Label_20"):setString(tt.gettext("請輸入有效的郵箱地址"))

		else
			self.mDesc1:setPosition(cc.p(width,height-185))
			self.mDesc2:setPosition(cc.p(width,height-210))
			self.mSendBtn:setPosition(cc.p(width,height-273))

			self.mNameTitle:setPosition(cc.p(width-215,height+212))
			self.mPhonenumTitle:setPosition(cc.p(width-215,height+128))
			self.mIdcardTitle:setPosition(cc.p(width-215,height+47))
			self.mLocaltionTitle:setVisible(true)
			self.mPhonetypeTitle:setVisible(false)

			self.mNameBg:setPosition(cc.p(width+92,height+212))
			self.mPhonenumBg:setPosition(cc.p(width+92,height+128))
			self.mIdcardBg:setPosition(cc.p(width+92,height+47))
			self.mLocaltionBg:setVisible(true)
			self.mPhoneTypeHandler:setVisible(false)

			self.mNameTipsView:setPosition(cc.p(width-201,height+160))
			self.mPhoneNumTipsView:setPosition(cc.p(width-201,height+78))
			self.mIdCardTipsView:setPosition(cc.p(width-201,height-4))
			self.mLocationTipsView:setVisible(true)


			tt.LayoutUtil:layoutCenter(self.mNameInputClip,self.mNameBg)
			tt.LayoutUtil:layoutCenter(self.mPhoneNumInputClip,self.mPhonenumBg)
			tt.LayoutUtil:layoutCenter(self.mIdCardInputClip,self.mIdcardBg)
			-- self.mNameInputClip:setPosition(cc.p(width-193,height+212))
			-- self.mPhoneNumInputClip:setPosition(cc.p(width-193,height+128))
			-- self.mIdCardInputClip:setPosition(cc.p(width-193,height+47))
			self.mLocationInputClip:setVisible(true)


			self.mIdCardInput:setPlaceHolder(tt.gettext("請輸入身份證"))
			self.mIdcardTitle:setString(tt.gettext("ID CARD:"))
			cc.uiloader:seekNodeByName(self.mIdCardTipsView, "Label_20"):setString(tt.gettext("請輸入有效的身份證號碼"))
		end
	end
end

function InformationAuthenticationDialog:dismiss()
	BLDialog.dismiss(self)
end

return InformationAuthenticationDialog