local BLDialog = require("app.ui.BLDialog")
local TAG = "TouzhuHistoryView"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local TouzhuHistoryView = class("TouzhuHistoryView", function()
	return BLDialog.new()
end)


function TouzhuHistoryView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("touzhu_history_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")
	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	self.mHistoryList = cc.uiloader:seekNodeByName(node, "history_list")
	self.mHistoryItems = {}
end

function TouzhuHistoryView:show()
	BLDialog.show(self)
	self:initHistroys()
end


function TouzhuHistoryView:dismiss()
	BLDialog.dismiss(self)
end

function TouzhuHistoryView:initHistroys()
	local historys = tt.nativeData.getXiaZhuBetHistorys()
	self.mHistoryItems = {} 
	self.mHistoryList:removeAllItems()
	
	local check = {}

	for index,history in ipairs(historys) do
		local item = self.mHistoryList:newItem()
		local content = app:createView("TouzhuHistoryItems", self.control_)
		content:setData(history)
		item:addContent(content)
		local size = content:getContentSize()
		item:setItemSize(size.width+20, size.height)
		item:setMargin({left = 0, right = 0, top = 0, bottom = 0})

		if not history.winscore then
			check[history.happyid] = check[history.happyid] or {}
			check[history.happyid][history.stage] = 1
		end
		self.mHistoryItems[index] = content
		self.mHistoryList:addItem(item)
	end

	for happyid,stages in pairs(check) do
		for stage,value in pairs(stages) do
			tt.gsocket.request("happydice.open_stage",{
					mid = tt.owner:getUid(),
					happyid = happyid,
					stage = stage,
				})
		end
	end
	self.mHistoryList:reload()
end

function TouzhuHistoryView:onEnter()
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

	}
end

function TouzhuHistoryView:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

function TouzhuHistoryView:updateItems()
	for i,item in ipairs(self.mHistoryItems) do
		item:update()
	end
end

function TouzhuHistoryView:onSocketData(evt)
	print("TouzhuHistoryView onSocketData",evt.cmd)
	if evt.cmd == "happydice.open_stage" then
		if evt.resp then
		 	if evt.resp.ret == 200 then
		 		self:updateItems()
		 	elseif evt.resp.ret == -101 then
		 	end
		end
	end
end

return TouzhuHistoryView