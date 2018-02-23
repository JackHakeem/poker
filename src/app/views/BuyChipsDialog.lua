local BLDialog = require("app.ui.BLDialog")
local TAG = "BuyChipsDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")
local SliderProgressSelectView = require("app.ui.SliderProgressSelectView")

local BuyChipsDialog = class("BuyChipsDialog", function()
	return BLDialog.new()
end)


function BuyChipsDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("buy_chips_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	self.mBlindInfoView = cc.uiloader:seekNodeByName(node, "blind_info_view")

	self.mBuyChipsTxt = cc.uiloader:seekNodeByName(node, "buy_chips_txt")
	self.mLeftChipsTxt = cc.uiloader:seekNodeByName(node, "left_chips_txt")

	self.mBlindConfig = {}
	local slider_view_handler = cc.uiloader:seekNodeByName(node, "slider_view_handler")
    local size = slider_view_handler:getContentSize()
	self.mSliderSelectView = SliderProgressSelectView.new({
			SliderBgFile = "bg/slider_bg06.png",
			SliderBgSize = cc.size(20,27),
			SliderBgCapInsets = cc.rect(10, 13,1, 1),
		})
	self.mSliderSelectView:addTo(slider_view_handler)
	self.mSliderSelectView:setPosition(cc.p(33,size.height/2-18))
	self.mSliderSelectView:setContentSize(324,30)
	self.mSliderSelectView:setSliderSize(324,13)
	self.mSliderSelectView:setSelectConfig({})
	self.mSliderSelectView:resetSliderScale()
    self.mIndex = 1
	self.mSliderSelectView:registerIndexChangeListener(function(index)
			self.mBlindIndex = index
			self:updateBuyChips()
		end)
	cc.uiloader:seekNodeByName(node, "add_btn"):onButtonClicked(function()
			tt.play.play_sound("click")
			self.mSliderSelectView:selectIndex(self.mBlindIndex+1)
		end)
	cc.uiloader:seekNodeByName(node, "sub_btn"):onButtonClicked(function()
			tt.play.play_sound("click")
			self.mSliderSelectView:selectIndex(self.mBlindIndex-1)
		end)

	cc.uiloader:seekNodeByName(node, "buy_btn"):onButtonClicked(function()
			tt.play.play_sound("click")
			if self.mBlindConfig[self.mBlindIndex] then
				self.control_.mControler:buyChips(self.mBlindConfig[self.mBlindIndex])
				self:dismiss()
			end
		end)
end

function BuyChipsDialog:setBlindInfo(sb,ante)
	self.mBlindInfoView:removeAllChildren()
	self.mBlindInfoView:setContentSize(cc.size(0,0))

	local blind_title = display.newTTFLabel({
	            text = tt.gettext("盲注:"),
	            size = 43,
	            color=cc.c3b(0x8e,0x54,0x2d),
	        })
		tt.linearlayout(self.mBlindInfoView,blind_title)
	local blind_txt = display.newTTFLabel({
            text = string.format("%s/%s",tt.getNumShortStr2(sb),tt.getNumShortStr2(sb*2)),
            size = 43,
            color=cc.c3b(0xff,0xff,0xff),
        })
	tt.linearlayout(self.mBlindInfoView,blind_txt)
	local height = blind_txt:getContentSize().height
	if ante > 0 then
		local ante_title = display.newTTFLabel({
	            text = tt.gettext("前注:"),
	            size = 43,
	            color=cc.c3b(0x8e,0x54,0x2d),
	        })
		tt.linearlayout(self.mBlindInfoView,ante_title)
		local ante_txt = display.newTTFLabel({
	            text = tt.getNumShortStr2(ante),
	            size = 43,
	            color=cc.c3b(0xff,0xff,0xff),
	        })
		tt.linearlayout(self.mBlindInfoView,ante_txt)
	end

	local size = self.mBlindInfoView:getContentSize()
	tt.LayoutUtil:layoutParentCenter(self.mBlindInfoView,0,55)
end

function BuyChipsDialog:setConfig(config)
	self.mBlindConfig = config
	self.mSliderSelectView:setSelectConfig(config)
	self.mSliderSelectView:resetSliderScale()
end

function BuyChipsDialog:updateLeftChips()
	local money = tt.owner:getMoney()
	self.mLeftChipsTxt:setString(tt.gettext("剩余筹码:{s1}",tt.getNumStr(money)))
end

function BuyChipsDialog:updateBuyChips()
	if self.mBlindConfig[self.mBlindIndex] then
		self.mBuyChipsTxt:setString(tt.gettext("买入:{s1}",tt.getNumStr(self.mBlindConfig[self.mBlindIndex])))
	end
end

function BuyChipsDialog:show()
	BLDialog.show(self)
	self:updateLeftChips()
end

function BuyChipsDialog:dismiss()
	BLDialog.dismiss(self)
end

return BuyChipsDialog