local BLDialog = require("app.ui.BLDialog")
local TAG = "VpDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local VpDialog = class("VpDialog", function()
	return BLDialog.new()
end)


function VpDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("vp_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	cc.uiloader:seekNodeByName(node, "buynow_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.control_:showShopDialog(1)
				self:dismiss()
			end)
	self.mCurVp = cc.uiloader:seekNodeByName(node, "cur_vp")
	self.mNextVp = cc.uiloader:seekNodeByName(node, "next_vp")

	self.mVpExpBg = cc.uiloader:seekNodeByName(node, "vp_exp_bg")
	self.mVpExpProgress = display.newDrawNode()
	local mask = display.newSprite("bg/bg_article01_vipclub.png")
	local size = self.mVpExpBg:getContentSize()
	local clip_node = cc.ClippingNode:create()
	clip_node:setStencil(self.mVpExpProgress);
	clip_node:addChild(mask)
	clip_node:setPosition(cc.p(size.width/2-5,size.height/2+1));
	clip_node:setAlphaThreshold(0.05)  --不显示模板的透明区域
	clip_node:setInverted( false ) --显示模板不透明的部分
	clip_node:addTo(self.mVpExpBg)

	self.mExpProcessTxt = cc.uiloader:seekNodeByName(node, "exp_process_txt")
	self.mExpNeedTxt = cc.uiloader:seekNodeByName(node, "exp_need_txt")

	cc.uiloader:seekNodeByName(node, "level_title"):setString("LEVEL")
	cc.uiloader:seekNodeByName(node, "vp_title"):setString("VP")
	cc.uiloader:seekNodeByName(node, "title_1"):setString(tt.gettext("购买优惠"))
	cc.uiloader:seekNodeByName(node, "title_2"):setString(tt.gettext("兑奖折扣"))
	cc.uiloader:seekNodeByName(node, "title_3"):setString(tt.gettext("登录奖励"))
	self.mConfigBg = cc.uiloader:seekNodeByName(node, "config_bg")
	self.mTipsIcon = cc.uiloader:seekNodeByName(node, "tips_icon")
	self.mVpConfigViews = {}
end

function VpDialog:show()
	BLDialog.show(self)
	self:update()
end

function VpDialog:update()
	self:updateVp()
	self:updateVpConfigView()
end

function VpDialog:updateVp()
	local curLv = tt.owner:getVpLv()
	if curLv == 6 then curLv = 5 end
	self.mCurVp:setTexture(string.format("icon/vp_%d.png",curLv))
	cc.uiloader:seekNodeByName(self.mCurVp, "name"):setString(tt.getVpName(curLv))
	local nextLv = curLv + 1
	self.mNextVp:setTexture(string.format("icon/vp_%d.png",nextLv))
	cc.uiloader:seekNodeByName(self.mNextVp, "name"):setString(tt.getVpName(nextLv))
	self:updateVpExpView()
end

function VpDialog:updateVpExpView()
	local size = self.mVpExpBg:getContentSize()
	local curLv = tt.owner:getVpLv()
	local curExp = tt.owner:getVpExp()
	local vpExpConfig = tt.nativeData.getVpExpConfig()
	local per = 0
	if curLv == 6 then 
		per = 1 
		local nExp = vpExpConfig[curLv] or 0
		self.mExpProcessTxt:setString(string.format("%d/%d",curExp,nExp))
		self.mExpNeedTxt:setString(tt.gettext("尚需{s1}VP",0))
	else
		local nExp = vpExpConfig[curLv+1] or 0
		per = curExp / nExp
		self.mExpProcessTxt:setString(string.format("%d/%d",curExp,nExp))
		self.mExpNeedTxt:setString(tt.gettext("尚需{s1}VP",nExp - curExp))
	end
	if per < 0 then per = 0 end
	if per > 1 then per = 1 end
	self.mVpExpProgress:clear()
	local pts1 = {
	    cc.p(-size.width/2, -size.height/2),  -- point 1
	    cc.p(-size.width/2, size.height/2),  -- point 1
	    cc.p(size.width*per-size.width/2, size.height/2),  -- point 2
	    cc.p(size.width*per-size.width/2, -size.height/2),  -- point 2
	}
	self.mVpExpProgress:drawPolygon(pts1, {
        fillColor = cc.c4f(1, 1, 1, 1),
        borderWidth = 0,
        borderColor = cc.c4f(1, 1, 1, 1)
    })
end

function VpDialog:updateVpConfigView()
	for _,view in ipairs(self.mVpConfigViews) do view:removeSelf() end
	self.mTipsIcon:setVisible(false)
	local curLv = tt.owner:getVpLv()
	local vpExpConfig = tt.nativeData.getVpExpConfig()
	local vpPayConfig = tt.nativeData.getVpPayConfig()
	local vpExchangeConfig = tt.nativeData.getVpExchangeConfig()
	local vpLoginConfig = tt.nativeData.getVpLoginConfig()

	local x,y = 163,0
	local offset = 160
	for i=1,6 do
		local item = display.newNode()
		local vpIcon = display.newSprite(string.format("icon/vp_%d.png",i))
		local vpName = display.newTTFLabel({
			    text = tt.getVpName(i),
			    size = 27,
			    color = cc.c3b(0xff,0xff,0xff),
			})
		local vpExp = display.newTTFLabel({
			    text = string.format("%d",vpExpConfig[i] or 0),
			    size = 43,
			    color = cc.c3b(0xff,0xff,0xff),
			})
		local vpPay = display.newTTFLabel({
			    text = string.format("%d%%",vpPayConfig[i] or 0),
			    size = 43,
			    color = cc.c3b(0xff,0xff,0xff),
			})
		local vpExchange = display.newTTFLabel({
			    text = string.format("%d%%",vpExchangeConfig[i] or 0),
			    size = 43,
			    color = cc.c3b(0xff,0xff,0xff),
			})
		local vpLogin = display.newTTFLabel({
			    text = string.format("%d%%",vpLoginConfig[i] or 0),
			    size = 43,
			    color = cc.c3b(0xff,0xff,0xff),
			})
		vpIcon:setPosition(cc.p(offset/2,295))
		vpName:setPosition(cc.p(offset/2,250))
		vpExp:setPosition(cc.p(offset/2,205))
		vpPay:setPosition(cc.p(offset/2,145))
		vpExchange:setPosition(cc.p(offset/2,90))
		vpLogin:setPosition(cc.p(offset/2,30))

		vpIcon:addTo(item)
		vpName:addTo(item)
		vpExp:addTo(item)
		vpPay:addTo(item)
		vpExchange:addTo(item)
		vpLogin:addTo(item)
		item:addTo(self.mConfigBg)
		item:setPosition(cc.p(x+(i-1)*offset,y))
		self.mVpConfigViews[i] = item
		if i == curLv then
			self.mTipsIcon:setVisible(true)
			self.mTipsIcon:setPositionX(x+(i-1)*offset+offset/2)
		end
	end
end

function VpDialog:dismiss()
	BLDialog.dismiss(self)
end

function VpDialog:onEnter()
	self.gevt_handlers_ = {
		-- tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}

	self.mUserInfoEventHandlers = {
		-- tt.owner:addEventListener(tt.owner.EVENT_MONEY,handler(self,self.updateMoney)),
		-- tt.owner:addEventListener(tt.owner.EVENT_NICK,handler(self,self.updateName)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_LV,handler(self,self.updateVipLvView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_SCORE,handler(self,self.updateVipScoreView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_VIP_EXP,handler(self,self.updateVipExpView)),
		-- tt.owner:addEventListener(tt.owner.EVENT_JUAN,handler(self,self.updateJuan)),
		tt.owner:addEventListener(tt.owner.EVENT_VP_LV,handler(self,self.updateVp)),
		tt.owner:addEventListener(tt.owner.EVENT_VP_EXP,handler(self,self.updateVpExpView)),
	}
end

function VpDialog:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end

	for _, v in pairs(self.mUserInfoEventHandlers) do 
		tt.owner:removeEventListener(v)
	end 
	BLDialog.onExit(self)
end

return VpDialog