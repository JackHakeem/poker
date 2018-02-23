local BLDialog = require("app.ui.BLDialog")
local TAG = "ActivityCenterDialog"
local CircleClip = require("app.ui.CircleClip")

local ActivityCenterDialog = class("ActivityCenterDialog", function()
	return BLDialog.new()
end)


function ActivityCenterDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("activity_center_dialog.json")
	self:addChild(node)	
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	self.mWebviewHandler = cc.uiloader:seekNodeByName(node, "webview_handler")
	self.mMenuList = cc.uiloader:seekNodeByName(node, "menu_list")
end


function ActivityCenterDialog:loadData(data,obUrl)
	data = data or {}
	self.mMenuList:removeAllItems()
	self.mMenuBtns = {}
	self.mData = data

	local showIndex = 1

	for i,actinfo in ipairs(data) do
		local item = self.mMenuList:newItem()
		local content = display.newNode()
		local size = cc.size(220,100)

		local title = display.newTTFLabel({
		        text = actinfo.active_name,
		        size = 40,
		        color=cc.c3b(0xff,0xff,0xff),
		    })

		local btn = cc.ui.UIPushButton.new({
				normal = "btn/tab_detrules.png",
				pressed = "btn/tab_detrules_pre.png",
				disabled = "btn/tab_detrules_pre.png",
			})
			:setPosition(size.width/2,size.height/2)
			:onButtonClicked(function()
					tt.play.play_sound("click")
					for k,view in ipairs(self.mMenuBtns) do
						if k == i then
							view:getChildByName("btn"):setButtonEnabled(false)
							view:getChildByName("btn"):getChildByName("title"):setColor(cc.c3b(0xee,0xd6,0x0c))
						else
							view:getChildByName("btn"):setButtonEnabled(true)
							view:getChildByName("btn"):getChildByName("title"):setColor(cc.c3b(0xff,0xff,0xff))
						end
					end
					self:loadUrl(actinfo.url)
				end)
			:onButtonPressed(function()
				title:setColor(cc.c3b(0xee,0xd6,0x0c))
			end)
			:onButtonRelease(function()
				title:setColor(cc.c3b(0xff,0xff,0xff))
			end)

		btn:setName("btn")
		title:setName("title")

		local btn_size = btn:getContentSize()
		title:setPosition(btn_size.width/2-20,btn_size.height/2)
		title:addTo(btn)
		btn:addTo(content)

		content:setContentSize(size.width, size.height)
		item:addContent(content)
		item:setItemSize(size.width, size.height)
		self.mMenuList:addItem(item)

		self.mMenuBtns[i] = content

		if actinfo.url == obUrl then
			showIndex = i
		end
	end

	if self.mMenuBtns[showIndex] then
		self.mMenuBtns[showIndex]:getChildByName("btn"):setButtonEnabled(false)
		self.mMenuBtns[showIndex]:getChildByName("btn"):getChildByName("title"):setColor(cc.c3b(0xee,0xd6,0x0c))
		self:loadUrl(data[showIndex].url)
	end

	self.mMenuList:reload()
end

function ActivityCenterDialog:show()
	BLDialog.show(self)
	local p = self.mWebviewHandler:convertToWorldSpace(cc.p(0,0))
	local size = self.mWebviewHandler:getContentSize()
	tt.displayWebView(p.x,p.y+size.height,size.width,size.height)
end

function ActivityCenterDialog:loadUrl(url)
	if not tt.isWebViewVisible() then
		tt.dismissWebView()
		local p = self.mWebviewHandler:convertToWorldSpace(cc.p(0,0))
		local size = self.mWebviewHandler:getContentSize()
		tt.displayWebView(p.x,p.y+size.height,size.width,size.height)
	end
	tt.webViewLoadUrl(url)
	if device.platform == "windows" or device.platform == "mac" then
		device.openURL(url)
	end
end

function ActivityCenterDialog:dismiss()
	BLDialog.dismiss(self)
	tt.dismissWebView()
end

return ActivityCenterDialog