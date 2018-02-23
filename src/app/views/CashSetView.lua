--
-- Author: bearluo
-- Date: 2017-05-27
--

local BLDialog = require("app.ui.BLDialog")
local CashSetView = class("CashSetView", function()
	return BLDialog.new()
end)

local TAG = "CashSetView"
local net = require("framework.cc.net.init")

function CashSetView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("cash_set_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.back_btn = cc.uiloader:seekNodeByName(node,"back_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.cashCancelBtn)
			self:dismiss()
		end)
	self.mBtnStartClickTime = 0
	self.btn_start = cc.uiloader:seekNodeByName(node,"btn_start")
		
	self.is_goto_room = false
	self.btn_start:onButtonClicked(function()
			tt.play.play_sound("click")
			if self.is_goto_room then
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.cashStartBtn)
				self:gotoCashRoom()
			else
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.cashBuyMoneyBtn)
				self:buyMoney()
			end
		end)

	self.select_view = cc.uiloader:seekNodeByName(node,"select_view")
	self.select_view:setTouchEnabled(true)
	self.select_view:setTouchSwallowEnabled(true)
	self.select_view:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))
	self.select_btn = cc.uiloader:seekNodeByName(self.select_view,"select_btn")

	self.blind_bg = cc.uiloader:seekNodeByName(node,"blind_bg")
	self.blind_view = cc.uiloader:seekNodeByName(node,"blind_view")

	self.money_tips_view = cc.uiloader:seekNodeByName(node,"money_tips_view")
	self.money_buy_view = cc.uiloader:seekNodeByName(node,"money_buy_view")


	self.btn_sub = cc.uiloader:seekNodeByName(node,"btn_sub")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:subPay()
			end)
	self.btn_add = cc.uiloader:seekNodeByName(node,"btn_add")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:addPay()
			end)

	-- display.newColorLayer(cc.c4b(16/255,24/255,42/255,60)):addTo(self,-1)
		-- :setAnchorPoint(cc.p(0,0))
		-- :setPosition((1280-display.width), (720-display.height))
	self.normal_pay = cc.uiloader:seekNodeByName(node,"normal_pay")
	-- 	:onButtonClicked(handler(self,self.onCheckChange))

	self.normal_pay_btn = cc.uiloader:seekNodeByName(node,"normal_pay_btn")
		:onButtonClicked(function() 
				tt.play.play_sound("click")
				self:onCheckChange()
			end)
		:setVisible(false)

		cc.uiloader:seekNodeByName(node,"Label_37"):setVisible(false)

end

function CashSetView:show()
	BLDialog.show(self)
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}
	-- tt.gsocket.request("alloc.info",{chan=kChan})
	local data = tt.nativeData.getCashInfo()
	dump(data)
	self:initData(data)

	self.normal_pay:setVisible(false)
end

function CashSetView:dismiss()
	BLDialog.dismiss(self)
	self:removeSelf()
	-- if self.mBlur then 
	-- 	self.mBlur:removeSelf() 
	-- 	self.mBlur=nil 
	-- end
end

function CashSetView:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end
	BLDialog.onExit(self)
end

function CashSetView:updateMoneyBuyView(str)
	self.money_buy_view:removeAllChildren()
 	self.money_buy_view:setContentSize(0,22)

	tt.linearlayout(self.money_buy_view,display.newTTFLabel({
		    text = tt.gettext("买入:"),
		    size = 36,
		    color = cc.c3b(255,255,255),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		}))
	tt.linearlayout(self.money_buy_view,display.newTTFLabel({
		    text = str,
		    size = 36,
		    color = cc.c3b(0xee,0xd6,0x0c),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		}))
end

function CashSetView:updateMoneyTipsView(isCanGotoRoom)
	self.money_tips_view:removeAllChildren()
 	self.money_tips_view:setContentSize(0,22)

	tt.linearlayout(self.money_tips_view,display.newTTFLabel({
		    text = tt.gettext("我的筹码餘額:"),
		    size = 36,
		    color = cc.c3b(255,255,255),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		}))
	if isCanGotoRoom then
		tt.linearlayout(self.money_tips_view,display.newTTFLabel({
			    text = tt.getNumStr(tt.owner:getMoney()),
			    size = 36,
			    color = cc.c3b(0xee,0xd6,0x0c),
			    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
			}))
	else
		tt.linearlayout(self.money_tips_view,display.newTTFLabel({
			    text = tt.getNumStr(tt.owner:getMoney()),
			    size = 36,
			    color = cc.c3b(0x98,0x99,0x99),
			    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
			}))
	end
	-- if not self.is_goto_room then

	-- 	tt.linearlayout(self.money_tips_view,display.newTTFLabel({
	-- 		    text = "離買入還差",
	-- 		    size = 22,
	-- 		    color = cc.c3b(200,200,200),
	-- 		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
	-- 		}))
	-- 	tt.linearlayout(self.money_tips_view,display.newTTFLabel({
	-- 		    text = tt.getNumStr(self.default_buy_ - tt.owner:getMoney()) .. '金幣',
	-- 		    size = 22,
	-- 		    color = cc.c3b(200,200,200),
	-- 		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
	-- 		}))
	-- end
end

function CashSetView:updateBlindView(sb,bb,ante)
	self.blind_view:removeAllChildren()
 	self.blind_view:setContentSize(0,40)
 	local fontSize = 50
 	tt.linearlayout(self.blind_view,display.newTTFLabel({
		    text = tt.gettext("盲注:"),
		    size = fontSize,
		    color = cc.c3b(0xff,0xff,0xff),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		}))
	tt.linearlayout(self.blind_view,display.newTTFLabel({
		    text = string.format("%s/%s",tt.getNumStr(sb),tt.getNumStr(bb)),
		    size = fontSize,
		    color = cc.c3b(0xee,0xd6,0x0c),
		    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
		}))
	if ante > 0 then
	 	tt.linearlayout(self.blind_view,display.newTTFLabel({
			    text = tt.gettext("前注:"),
			    size = fontSize,
		    	color = cc.c3b(0xff,0xff,0xff),
			    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
			}),20)
		tt.linearlayout(self.blind_view,display.newTTFLabel({
			    text = tt.getNumStr(ante),
			    size = fontSize,
		    	color = cc.c3b(0xee,0xd6,0x0c),
			    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
			}))
	end
	local size = self.blind_view:getContentSize()
	local width = math.max(size.width + 60,419)
	-- self.blind_bg:setContentSize(width, 91)
end

function CashSetView:onSocketData(evt)
	-- tt.log.d(TAG, "cmd:[%s]",evt.cmd)	

	local resp = evt.resp
	if evt.cmd == "alloc.search" then 
		tt.log.d(TAG,"ret [%s] lv[%s] tid[%s]",resp.ret, resp.lv, resp.tid)
		tt.hide_wait_view()
		if resp.ret == 200 then
			self:dismiss()
		end
	end
end

function CashSetView:gotoCashRoom()
	if not self.select_data then 
		tt.show_msg(tt.gettext("請選擇場次"))
		tt.play.play_sound("action_failed")
		return 
	end
	if self.mBtnStartClickTime + 1 > net.SocketTCP.getTime() then return end

	tt.nativeData.saveCashLvSelect(self.mSelectData.lv)

	self.mBtnStartClickTime = net.SocketTCP.getTime()
	-- tt.log.d(TAG,"lv[%s]", self.select_data.lv)
	self:searchTable(self.select_data.lv)
end

function CashSetView:buyMoney()
	if self.mBtnStartClickTime + 1 > net.SocketTCP.getTime() then return end
	self.mBtnStartClickTime = net.SocketTCP.getTime()
	if self.control_ then
		self.control_:onShopClick()
	end
	self:dismiss()
end

function CashSetView:initData(datas)
	local width = self.select_btn:getContentSize().width - 6
	self.max_w = self.select_view:getContentSize().width - width
	self.start_w = width / 2  
	self.offset_w = 0
	self.mDatas = datas or {}
	self.mSelectIndex = 0
	local index = 0
	local num = #self.mDatas
	if num > 1 then
		index = 1
		self.offset_w = self.max_w / (num-1)
	elseif num == 1 then
		index = 1
		self.offset_w = 0
	else
		index = 0
		self.offset_w = 0
	end

	for i,data in ipairs(self.mDatas) do
		if data.lv == tt.game_data.cash_lv_select then
			index = i
		end
	end

	self:onChangeLvData(index)
end

function CashSetView:onChangeLvData(index)
	if self.mSelectIndex ~= nil then
		if self.mSelectIndex ~= index then
			tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.cashLevelChange,{index=index-self.mSelectIndex})
		end
	end

	if self.mSelectIndex == index or not self.mDatas[index] then return end
	-- tt.log.d(TAG,"CashSetView:onChangeLvData:" .. index)
	self.mSelectIndex = index

	self.mSelectData = self.mDatas[self.mSelectIndex]


	self:updateMaxPaySetView(self.mSelectData)
end

function CashSetView:updateMaxPaySetView(data)
	-- tt.log.d(TAG,"CashSetView:updateMaxPaySetView")
	local money = tt.owner:getMoney()
	self.select_data = data
	self.sb_ = data.sb or 0
	self.bb_ = data.bb or 0
	self.min_ = data.min_carry or 0
	self.max_ = data.max_carry or 0
	self.default_buy_ = data.default_buy or 0
	self.ante_ = data.ante or 0

	self:updateBlindView(self.sb_,self.bb_,self.ante_)

	self:updateMoneyBuyView(tt.getNumStr(self.default_buy_))


	if money >= self.default_buy_ then
		self.is_goto_room = true
		self.btn_start:setButtonImage("normal","btn/btn_startgame_nor.png",true)
		self.btn_start:setButtonImage("pressed","btn/btn_startgame_pre.png",true)
		self:updateMoneyTipsView(true)
	else
		self.is_goto_room = false
		self.btn_start:setButtonImage("normal","btn/btn_addgold_nor.png",true)
		self.btn_start:setButtonImage("pressed","btn/btn_addgold_pre.png",true)
		self:updateMoneyTipsView(false)
	end

	self.select_btn:setPosition(self.start_w + (self.mSelectIndex-1)*self.offset_w,25)
end

function CashSetView:subPay()
	if not self.mSelectIndex or self.mSelectIndex < 0 then return end
	self:onChangeLvData(self.mSelectIndex-1)
end

function CashSetView:addPay()
	if not self.mSelectIndex or self.mSelectIndex < 0 then return end
	self:onChangeLvData(self.mSelectIndex+1)
end

function CashSetView:searchTable(lv)
	assert(lv ~=nil, string.format("CashSetView:searchTable lv:%s",type(lv)))
	tt.gsocket.request("alloc.search",{lv = lv})
	tt.show_wait_view(tt.gettext("匹配中..."))
end

function CashSetView:onCheckChange()
	if not self.select_data then return end
end

function CashSetView:onTouch_(event)
	if not self.start_w then return end
    local name, x, y = event.name, event.x, event.y
    local pos = {x=346}--self.select_view:getCascadeBoundingBox().origin
    -- printInfo("CashSetView:onTouch_ ：xy %f %f", x, y )
    -- printInfo("CashSetView:onTouch_ ：xy %f %f", pos.x, self.start_w )
    local diff = x-pos.x-self.start_w

    if diff < 0 then
    	diff = 0
    elseif diff > self.max_w then
    	diff = self.max_w
    end

    -- printInfo("CashSetView:onTouch_ ： %f %f", diff ,diff /self.offset_w )
    
    local index = math.floor(diff/self.offset_w + 0.5)
	if index > #self.mDatas then
		index = #self.mDatas
	end
	if index < 0 then
		index = 0
	end
    self:onChangeLvData(index+1)
    if "began" == event.name then
    	self.select_btn:setPosition(self.start_w+diff,25)
	elseif "moved" == event.name then
		self.select_btn:setPosition(self.start_w+diff,25)
	elseif "ended" == event.name then
		self.select_btn:setPosition(self.start_w + (self.mSelectIndex-1)*self.offset_w,25)
	end
    return true
    -- printInfo("CashSetView:onTouch_ ： %f %f", x-pos.x,y-pos.y)
end

return CashSetView
