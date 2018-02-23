--
-- Author: bearluo
-- Date: 2017-05-27
--

local CashSetBlindItem = class("CashSetBlindItem", function()
	return display.newNode()
end)

local TAG = "CashSetBlindItem"
local net = require("framework.cc.net.init")

function CashSetBlindItem:ctor(control,index,data)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("cash_set_blind_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))


	self.mBlindBtnClickTime = 0
	self.blind_btn = cc.uiloader:seekNodeByName(node,"blind_btn")
		:onButtonClicked(function ()
			if self.mBlindBtnClickTime + 1 > net.SocketTCP.getTime() then return end
			tt.play.play_sound("click")
			if tt.owner:getMoney() < data.min_carry then
				tt.show_msg(tt.gettext("筹码不足"))
				tt.play.play_sound("action_failed")
				return
			end
			self.mBlindBtnClickTime = net.SocketTCP.getTime()
			self.control_:onChangeLvData(index,data)
		end)
	self.blind_icon = cc.uiloader:seekNodeByName(node,"blind_icon")
	local blind_icon_file = "icon/XJC_AnNiu1.png"
	if index and index >= 1 and index <= 5 then
		blind_icon_file = string.format("icon/XJC_AnNiu%d.png",index)
	end
	self.blind_icon:setTexture(blind_icon_file)
	self.blind_txt = cc.uiloader:seekNodeByName(node,"blind_txt")
	self:setBlindTxt(data.sb,data.bb)
	-- dump(data)
end

function CashSetBlindItem:setSelect(isSelected)
	if isSelected then
		self:scale(1.2,1.2)
	else
		self:scale(1,1)
	end
end

function CashSetBlindItem:setBlindTxt(sb,bb)
	self.blind_txt:setString( string.format("%d/%d",sb or 0,bb or 0))
end


return CashSetBlindItem
