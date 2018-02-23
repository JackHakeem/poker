local BLDialog = require("app.ui.BLDialog")
local TAG = "BankruptcyDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local BankruptcyDialog = class("BankruptcyDialog", function()
	return BLDialog.new()
end)


function BankruptcyDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("bankruptcy_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)
	self.mBankruptcyNum = 0

	self.money_bg = cc.uiloader:seekNodeByName(node, "money_bg")
	self.money_handler = cc.uiloader:seekNodeByName(node, "money_handler")
	self.bankruptcy_desc_txt = cc.uiloader:seekNodeByName(node, "bankruptcy_desc_txt")

	self.receive_btn = cc.uiloader:seekNodeByName(node, "receive_btn")
	self.receive_btn:onButtonClicked(function()
			tt.play.play_sound("click")
			-- self:setBankruptcyNum(self.mBankruptcyNum-1)
			self.receive_btn:setButtonEnabled(false)
			local params = {}
			tt.ghttp.request(tt.cmd.everyday_song,params)
		end)

	self.countdown_txt = cc.uiloader:seekNodeByName(node, "countdown_txt")

	self.num_handler = cc.uiloader:seekNodeByName(node, "num_handler")

	cc.uiloader:seekNodeByName(node, "recommend_desc_txt"):setString(tt.gettext("马上购买,畅玩游戏!"))

	self.mGoodData = nil
	self.buy_btn = cc.uiloader:seekNodeByName(node, "buy_btn")
	self.buy_btn:onButtonClicked(function()
			tt.play.play_sound("click")
			if self.mGoodData then
				self.control_:payGoods(self.mGoodData)
				self:dismiss()
			end
		end)
end

function BankruptcyDialog:setBankruptcyMoney(num)
	self.money_handler:removeAllChildren()
	self.money_handler:setContentSize(0,0)
	local num = tt.getBitmapStrAscii("number/yellow0_%d.png","X"..tt.getNumStr(num))
	tt.linearlayout(self.money_handler,num)

	local size = self.money_handler:getContentSize()

	self.money_handler:setPosition(cc.p(486/2-size.width/2,578/2-45))

	local width = math.max(size.width+60,128)
	self.money_bg:setContentSize(width,self.money_bg:getContentSize().height)
end

function BankruptcyDialog:setBankruptcyNum(num)
	if num < 0 then num = 0 end
	self.mBankruptcyNum = num
	if num > 0 then
		self.bankruptcy_desc_txt:setString(tt.gettext("今天还剩{s1}次领取机会",num))
	else
		self.bankruptcy_desc_txt:setString(tt.gettext("今天的补助已经领完，请您明天继续！"))
	end
	-- if num == 0 then
	-- 	self.receive_btn:setButtonEnabled(false)
	-- else
	-- 	self.receive_btn:setButtonEnabled(true)
	-- end
end

function BankruptcyDialog:startBankruptcyCountdown(end_time)
	local update = function()
		local time = end_time - tt.time()
		print(time)
		if time > 0 then
			self.countdown_txt:setString(os.date("%M:%S",time))
			self.receive_btn:setButtonEnabled(false)
		else
			self.countdown_txt:setString("")
			self.receive_btn:setButtonEnabled(self.mBankruptcyNum > 0)
			self:stopBankruptcyCountdown()
		end
	end
	update()
	self:schedule(update,1):setTag(1)
end

function BankruptcyDialog:stopBankruptcyCountdown()
	self:stopAllActionsByTag(1)
end

function BankruptcyDialog:setGoods(goods)
	self.mGoodData = goods
	dump(self.mGoodData,"BankruptcyDialog:setGoods")
	if not goods then return end
	self.num_handler:removeAllChildren()
	self.num_handler:setContentSize(0,0)

	local num = tt.getBitmapStrAscii("number/yellow0_%d.png","X"..tt.getNumStr(goods.coin))
	tt.linearlayout(self.num_handler,num)

	local size = self.num_handler:getContentSize()

	self.num_handler:setPosition(cc.p(867/2-size.width/2,578/2-50))
end

function BankruptcyDialog:setBankruptcy(data)
	self.mBankruptcyData = data
	self:reset()
	if not data then return end
	self:setBankruptcyNum(data.song_cishu)
	self:setBankruptcyMoney(data.coin)
	if data.song_cishu > 0 then
		self:startBankruptcyCountdown(data.endTime)
	else
		self.countdown_txt:setString("")
		self.receive_btn:setButtonEnabled(false)
	end
end

function BankruptcyDialog:reset()
	self.money_handler:removeAllChildren()
	self.money_bg:setContentSize(128,self.money_bg:getContentSize().height)
	self.bankruptcy_desc_txt:setString("")
	self.receive_btn:setButtonEnabled(false)
	self.countdown_txt:setString("")
end

function BankruptcyDialog:show()
	BLDialog.show(self)
end

function BankruptcyDialog:dismiss()
	BLDialog.dismiss(self)
	self:stopBankruptcyCountdown()
end

return BankruptcyDialog