local BLDialog = require("app.ui.BLDialog")
local TAG = "ChooseDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local ChooseDialog = class("ChooseDialog", function()
	return BLDialog.new()
end)


function ChooseDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("choose_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")
	self.content_txt = cc.uiloader:seekNodeByName(node, "content_txt")
	self.content_txt_2 = cc.uiloader:seekNodeByName(node, "content_txt_2")
	self.cancel_btn = cc.uiloader:seekNodeByName(node, "cancel_btn")
		:onButtonClicked(handler(self, self.onCancelBtnClick))
	self.confirm_btn = cc.uiloader:seekNodeByName(node, "confirm_btn")
		:onButtonClicked(handler(self, self.onConfirmBtnClick))
	self.mContentStr = ""

	cc.uiloader:seekNodeByName(node, "scroll_view"):setDirection(0)
	
	self:setMode(1)
end

function ChooseDialog:show()
	BLDialog.show(self)
end

function ChooseDialog:setMode(flag)
	self.mMode = flag
	if flag == 1 then
		self.cancel_btn:setVisible(true)
		self.cancel_btn:setPositionX(259)
		self.confirm_btn:setVisible(true)
		self.confirm_btn:setPositionX(611)
		self.content_txt:setString(self.mContentStr)
		self.content_txt_2:setString("")
	elseif flag == 2 then
		self.cancel_btn:setVisible(false)
		self.confirm_btn:setVisible(true)
		self.confirm_btn:setPositionX(435)
		self.content_txt:setString(self.mContentStr)
		self.content_txt_2:setString("")
	elseif flag == 3 then
		self.cancel_btn:setVisible(true)
		self.cancel_btn:setPositionX(611)
		self.confirm_btn:setVisible(true)
		self.confirm_btn:setPositionX(259)
		self.content_txt:setString(self.mContentStr)
		self.content_txt_2:setString("")
	elseif flag == 4 then
		self.cancel_btn:setVisible(false)
		self.confirm_btn:setVisible(true)
		self.confirm_btn:setPositionX(435)
		self.content_txt:setString("")
		self.content_txt_2:setString(self.mContentStr)
	end
end

function ChooseDialog:dismiss()
	BLDialog.dismiss(self)
end

function ChooseDialog:setContentStr(str)
	self.mContentStr = str
	if self.mMode == 4 then
		self.content_txt_2:setString(str)
	else
		self.content_txt:setString(str)
	end
	return self
end

function ChooseDialog:setOnCancelClick(func)
	self.cancelClick = func
	return self
end

function ChooseDialog:setOnConfirmClick(func)
	self.confirmClick = func
	return self
end

function ChooseDialog:onCancelBtnClick()
	tt.play.play_sound("click")
	if type(self.cancelClick) == "function" and self.cancelClick() then
		return
	end
	self:dismiss()
end

function ChooseDialog:onConfirmBtnClick()
	tt.play.play_sound("click")
	if type(self.confirmClick) == "function" and self.confirmClick() then
		return
	end
	self:dismiss()
end


return ChooseDialog