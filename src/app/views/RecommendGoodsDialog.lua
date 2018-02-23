local BLDialog = require("app.ui.BLDialog")
local TAG = "RecommendGoodsDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local RecommendGoodsDialog = class("RecommendGoodsDialog", function()
	return BLDialog.new()
end)


function RecommendGoodsDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("recommend_goods_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

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

function RecommendGoodsDialog:setGoods(goods)
	self.mGoodData = goods
	dump(self.mGoodData,"RecommendGoodsDialog:setGoods")
	if not goods then return end
	self.num_handler:removeAllChildren()
	self.num_handler:setContentSize(0,0)

	local num = tt.getBitmapStrAscii("number/yellow0_%d.png","X"..tt.getNumStr(goods.coin))
	tt.linearlayout(self.num_handler,num)

	local size = self.num_handler:getContentSize()

	self.num_handler:setPosition(cc.p(1271/2-size.width/2,578/2-60))
end

function RecommendGoodsDialog:show()
	BLDialog.show(self)
end

function RecommendGoodsDialog:dismiss()
	BLDialog.dismiss(self)
end

return RecommendGoodsDialog