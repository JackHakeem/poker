--
-- Author: shineflag
-- Date: 2017-05-18 18:35:07
--



local MatchListItem = require("app.views.MatchListItem")
local CashListItem = require("app.views.CashListItem")
local out_pos = cc.p(display.right,0)
local in_pos = cc.p(0,0)

--系统推荐玩家可玩的场次
local MainPlayView = class("MainPlayView", function()
	return display.newNode()
end)

-- UIListView.ALIGNMENT_LEFT			= 0
-- UIListView.ALIGNMENT_RIGHT			= 1
-- UIListView.ALIGNMENT_VCENTER		= 2
-- UIListView.ALIGNMENT_TOP			= 3
-- UIListView.ALIGNMENT_BOTTOM			= 4
-- UIListView.ALIGNMENT_HCENTER		= 5

function MainPlayView:ctor(ctl)

	self.ctl_= ctl 
	self.match_list_ = cc.ui.UIListView.new {
        bgColor = cc.c4b(0, 0, 0, 0),
        viewRect = cc.rect(0, 0, 1280, 436),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
        alignment = cc.ui.UIScrollView.ALIGNMENT_BOTTOM,
    }
    :addTo(self)

	self:setPosition(out_pos)
end

function MainPlayView:showMainList()
	self.mShowView = "menu"
	self.ctl_:showTopView(1)
	self:stopMttRefreshTimer()
	self:stopSngRefreshTimer()
	self:refreshMainList()
	self:inHall()
end

function MainPlayView:refreshMainList()
	if self.mShowView ~= "menu" then return end
	local datas = tt.nativeData.getHallRecommendDatas()
	-- dump(data,"MainPlayView data:",4)
	self.match_list_:removeAllItems()

    local banner_icon = {
    	"dec/dec_banner1_red.png",
    	"dec/dec_banner1_yellow.png",
    	"dec/dec_banner1_green.png",
    	"dec/dec_banner1_blue.png",
    	"dec/dec_banner1_purple.png",
	}
	local hasMtt = false
	for i,data in ipairs(datas) do
		if data.gtype == "cash" then
			if data.rmd == 0 then
				-- 添加现金赛
				self:addCashItem()
			elseif type(data.rmd) == "table" then
				self:addCashMatchItem(data.rmd,banner_icon[(i-1)%5+1])
			end
		elseif data.gtype == "mtt" then
			if data.rmd == 0 then
				-- 添加mtt
				self:addMttItem()
			elseif type(data.rmd) == "table" then
				-- 添加mtt比赛
				hasMtt = true
				local mtt_data = data.rmd
				mtt_data.mlv = tonumber(mtt_data.mlv)
				mtt_data.apply_num = tonumber(mtt_data.apply_num)
				for _,entry in ipairs(mtt_data.entry) do
					entry.etype = tonumber(entry.etype)
					entry.num 	= tonumber(entry.num)
				end
				mtt_data.min_player = tonumber(mtt_data.min_player)
				mtt_data.max_player = tonumber(mtt_data.max_player)
				mtt_data.seat = tonumber(mtt_data.seat)
				mtt_data.bettime = tonumber(mtt_data.bettime)
				mtt_data.coin = tonumber(mtt_data.coin)
				mtt_data.blind_id = tonumber(mtt_data.blind_id)
				mtt_data.reward_type = tonumber(mtt_data.reward_type)
				mtt_data.reward_id = tonumber(mtt_data.reward_id)
				mtt_data.ct = tonumber(mtt_data.ct)
				mtt_data.fee = tonumber(mtt_data.fee)
				mtt_data.stime = tonumber(mtt_data.stime)
				mtt_data.jtime = tonumber(mtt_data.jtime)
				mtt_data.atime = tonumber(mtt_data.atime)
				mtt_data.ntime = tonumber(mtt_data.ntime)
				mtt_data.left = tonumber(mtt_data.left)
				tt.nativeData.saveMttInfo(mtt_data.match_id,mtt_data)
				self:addMttMatchItem(mtt_data)
			end
		elseif data.gtype == "dice" then
			if data.rmd == 0 then
				-- 添加投注
				if not tt.nativeData.isIosLock() then
					self:addTouzhuItem()
				end
			end
		elseif data.gtype == "custom" then
			if data.rmd == 0 then
				self:addCustomItem()
			end
		end
	end
	-- -- 添加sng
	-- self:addSngItem()


	self.match_list_:reload()

	if hasMtt then
		self:startMttRefreshTimer()
	end
end

function MainPlayView:showCashList()
	self.mShowView = "cash"
	self.ctl_:showTopView(2)
	self:stopMttRefreshTimer()
	self:stopSngRefreshTimer()
	self:initCashList()
end

function MainPlayView:initCashList()
	if self.mShowView ~= "cash" then return end
	local data = tt.nativeData.getCashInfo()

	self.match_list_:removeAllItems()

	-- 添加返回按钮
	-- local item = self.match_list_:newItem()
	-- local content = cc.ui.UIPushButton.new('btn/btn_back_nor.png'):onButtonClicked(function()
	-- 		tt.play.play_sound("click")
	-- 		self:showSngList()
	-- 	end)
	-- item:addContent(content)
	-- local size = content:getContentSize()
	-- item:setItemSize(size.width+100, size.height)
	-- self.match_list_:addItem(item)

    -- 添加cash赛
    local banner_icon = {
    	"dec/dec_banner1_red.png",
    	"dec/dec_banner1_yellow.png",
    	"dec/dec_banner1_green.png",
    	"dec/dec_banner1_blue.png",
    	"dec/dec_banner1_purple.png",
	}
	for i, v in ipairs(data) do 
		-- dump(v)
		self:addCashMatchItem(v,banner_icon[(i-1)%5+1])
	end
	
	self:addCustomItem()

	self.match_list_:reload()
end

function MainPlayView:showSngList()
	self.mShowView = "sng"
	self.ctl_:showTopView(2)
	self:stopMttRefreshTimer()
	self:stopSngRefreshTimer()
	self:initSngList()
end

function MainPlayView:initSngList()
	if self.mShowView ~= "sng" then return end
	local data = tt.game_data.sng_info_sort

	self.match_list_:removeAllItems()

	-- 添加返回按钮
	-- local item = self.match_list_:newItem()
	-- local content = cc.ui.UIPushButton.new('btn/btn_back_nor.png'):onButtonClicked(function()
	-- 		tt.play.play_sound("click")
	-- 		self:showSngList()
	-- 	end)
	-- item:addContent(content)
	-- local size = content:getContentSize()
	-- item:setItemSize(size.width+100, size.height)
	-- self.match_list_:addItem(item)

    -- 添加sng赛
	for _, v in ipairs(data) do 
		-- dump(v)
		local item = self.match_list_:newItem()
		local content = MatchListItem.new(self.ctl_,v) 
		item:addContent(content)
		local size = content:getContentSize()
		item:setItemSize(size.width+20, size.height)
		item:setMargin({left = 0, right = 0, top = 0, bottom = 50})
		self.match_list_:addItem(item)
	end

	self.match_list_:reload()
	self:startSngRefreshTimer()
end

function MainPlayView:showMttList()
	tt.gsocket.request("mtt.info",{ct=0,chan=kChan})
	self.mShowView = "mtt"
	self.ctl_:showTopView(2)
	self.match_list_:removeAllItems()
	self.match_list_:reload()
	self:stopMttRefreshTimer()
	self:stopSngRefreshTimer()
end

function MainPlayView:initMttList(data)
	if self.mShowView ~= "mtt" then return end
	self.match_list_:removeAllItems()

	if data then
		for _, v in ipairs(data) do
			self:addMttMatchItem(v)
		end
	end
	self.match_list_:reload()
	self:startMttRefreshTimer()
end

function MainPlayView:removeMttItem(item)
	if self.mShowView ~= "mtt" then return end
	self.match_list_:removeItem(item, true)
end

function MainPlayView:addCashItem()
	local item = self.match_list_:newItem()
	local content = CashListItem.new(self.ctl_) 
	item:addContent(content)
	local size = content:getContentSize()
	item:setItemSize(size.width+20, size.height)
	item:setMargin({left = 10, right = 0, top = 0, bottom = 15})
	self.match_list_:addItem(item)
end

function MainPlayView:addSngItem()
	local item = self.match_list_:newItem()
	local content = app:createView("SngItem", self.ctl_)
	item:addContent(content)
	local size = content:getContentSize()
	item:setItemSize(size.width+20, size.height)
	item:setMargin({left = 10, right = 0, top = 0, bottom = 15})
	self.match_list_:addItem(item)
end

function MainPlayView:addMttItem()
	local item = self.match_list_:newItem()
	local content = app:createView("MttItem", self.ctl_)
	item:addContent(content)
	local size = content:getContentSize()
	item:setItemSize(size.width+20, size.height)
	item:setMargin({left = 10, right = 0, top = 0, bottom = 15})
	self.match_list_:addItem(item)
end

function MainPlayView:addCustomItem()
	local item = self.match_list_:newItem()
	local content = app:createView("CustomListItem", self.ctl_)
	item:addContent(content)
	local size = content:getContentSize()
	item:setItemSize(size.width+20, size.height)
	item:setMargin({left = 10, right = 0, top = 0, bottom = 15})
	self.match_list_:addItem(item)
end


function MainPlayView:addTouzhuItem()
	local item = self.match_list_:newItem()
	local content = app:createView("TouzhuItem", self.ctl_)
	item:addContent(content)
	local size = content:getContentSize()
	item:setItemSize(size.width+20, size.height)
	item:setMargin({left = 10, right = 0, top = 0, bottom = 15})
	self.match_list_:addItem(item)
end

function MainPlayView:addMttMatchItem(data)
	local item = self.match_list_:newItem()
	local content = app:createView("MttMatchItem", self.ctl_,data)
	content:setDelete(function()
			self:removeMttItem(item)
		end)
	item:addContent(content)
	local size = content:getContentSize()
	item:setItemSize(size.width+20, size.height)
	item:setMargin({left = 10, right = 0, top = 0, bottom = 35})
	self.match_list_:addItem(item)
end

function MainPlayView:addCashMatchItem(data,img)
	local item = self.match_list_:newItem()
	local content = app:createView("CashMatchItem", self.ctl_,data,img)
	item:addContent(content)
	local size = content:getContentSize()
	item:setItemSize(size.width+10, size.height)
	item:setMargin({left = 10, right = 0, top = 0, bottom = 40})
	self.match_list_:addItem(item)
end

function MainPlayView:startMttRefreshTimer()
	self:stopMttRefreshTimer()
	self:schedule(function()
		local match_ids = {}

		for _,item in pairs(self.match_list_.items_) do 
			local content = item:getContent() 
			if iskindof(content,"MttMatchItem") then
				table.insert(match_ids,content:getMatchId())
			end
		end
		
		if #match_ids > 0 and tt.gsocket:isConnected() then
			tt.gsocket.request("mtt.apply_num",{
						match_ids = match_ids           --比赛id的集合
					})
		end
		end,5):setTag(2)
end

function MainPlayView:stopMttRefreshTimer()
	self:stopAllActionsByTag(2)
end

function MainPlayView:startSngRefreshTimer()
	self:stopSngRefreshTimer()
	local refresh = function()
			local data = tt.game_data.sng_info_sort
			if tt.gsocket:isConnected() then
				for _, v in ipairs(data) do 
					tt.gsocket.request("sng.start",{mlv=v.mlv})
				end
			end
		end
	refresh()
	self:schedule(refresh,5):setTag(3)
end

function MainPlayView:stopSngRefreshTimer()
	self:stopAllActionsByTag(3)
end

function MainPlayView:refreshMttApplyNum(data)
	if not data then return end
	local removeContents = {}
	for _,item in pairs(self.match_list_.items_) do 
		local content = item:getContent() 
		if iskindof(content,"MttMatchItem") then
			if data[content:getMatchId()] then
				content:updateApplyNum(data[content:getMatchId()])
			else
				table.insert(removeContents,content)
			end
		end
	end

	for _,content in ipairs(removeContents) do 
		print("removeMtt",content:getMatchId())
		self.ctl_:mttAdvanceOver(content:getMatchId())
		content:nextMatch()
	end
end

function MainPlayView:refreshSngApplyNum(data)
	dump(data,"refreshSngApplyNum")
	if not data then return end
	local removeContents = {}
	for _,item in pairs(self.match_list_.items_) do 
		local content = item:getContent() 
		if iskindof(content,"MatchListItem") then
			if content:getMatchLv() == data.mlv then
				content:updateApplyNum(data)
			end
		end
	end
end

function MainPlayView:refreshMatchView()
	for _,item in pairs(self.match_list_.items_) do 
		local content = item:getContent() 
		if iskindof(content,"MatchListItem") then
			if self.ctl_.matchs_list[content.mlv_] then
				content:setApplyed(self.ctl_.matchs_list[content.mlv_].status)
			else
				content:setApplyed(0)
			end
		end
	end
end

function MainPlayView:refreshMatchRewardView(reward_id)
	-- if self.mShowView ~= "mtt" then return end
	for _,item in pairs(self.match_list_.items_) do 
		local content = item:getContent() 
		if iskindof(content,"MttMatchItem") then
			if content:getRewardId() == reward_id then
				content:updateReward()
			end
		end
	end
end

function MainPlayView:inHall()
	transition.moveTo(self, {x = in_pos.x, time = 0.3})

end

function MainPlayView:outHall()
	transition.moveTo(self, {x = out_pos.x, time = 0.3})
end




return MainPlayView
