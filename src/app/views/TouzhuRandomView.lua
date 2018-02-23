local BLDialog = require("app.ui.BLDialog")
local TAG = "TouzhuRandomView"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local TouzhuRandomView = class("TouzhuRandomView", function()
	return BLDialog.new()
end)


function TouzhuRandomView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("touzhu_random_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.context_view = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	self.mNumTxt = cc.uiloader:seekNodeByName(node, "num_txt")

	self.mNumIcons = {}
	self.mRandomSum = 0
	for i=1,3 do
		self.mNumIcons[i] = cc.uiloader:seekNodeByName(cc.uiloader:seekNodeByName(node, "num_" .. i .. "_bg"), "num_icon")
	end

	self.mNumType1 = cc.uiloader:seekNodeByName(node, "num_type_1")
	self.mNumType2 = cc.uiloader:seekNodeByName(node, "num_type_2")

	cc.uiloader:seekNodeByName(node, "reselection_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:playRandomAnim()
			end)


	cc.uiloader:seekNodeByName(node, "sure_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if self.mRandomSum ~= 0 and not tolua.isnull(self.mTouzhuGameView) then
					self.mTouzhuGameView:addNum(self.mRandomSum)
					self:dismiss()
				end
			end)
end

function TouzhuRandomView:show()
	BLDialog.show(self)
	self:playRandomAnim()
end

function TouzhuRandomView:setTouzhuGameView(view)
	self.mTouzhuGameView = view
end

function TouzhuRandomView:playRandomAnim()
	if not self:getActionByTag(1) then
		tt.play.play_sound("touzhu_lottery")
		self.mRandomSum = 0
		self.mNumType1:setVisible(false)
		self.mNumType2:setVisible(false)
		self.mNumTxt:setString("")
		local cnt = 50
		local time = 5/cnt
		local nums = {0,0,0}
		self:schedule(function()
				cnt = cnt - 1
				local sum = 0
				for i=1,3 do
					if i == 1 and cnt >= 10 then
						if cnt == 10 then
							tt.play.play_sound("touzhu_lottery_dice")
						end
						nums[i] = math.random(1,6)
					elseif i == 2 and cnt >= 5 then
						if cnt == 5 then
							tt.play.play_sound("touzhu_lottery_dice")
						end
						nums[i] = math.random(1,6)
					elseif i == 3 and cnt >= 0 then
						if cnt == 0 then
							tt.play.play_sound("touzhu_lottery_dice")
						end
						nums[i] = math.random(1,6)
					end
					self.mNumIcons[i]:setTexture("dec/dec_".. nums[i] ..".png")
					sum = sum + nums[i]
				end
				if cnt == 0 then
					self:setRandomNum(sum)
					self:stopAllActionsByTag(1)
				end
			end,time):setTag(1)
	end
end

function TouzhuRandomView:setRandomNum(num)
	self.mNumType1:setVisible(true)
	self.mNumType2:setVisible(true)
	self.mRandomSum = num
	self.mNumTxt:setString(tt.gettext("和值:{s1}",self.mRandomSum))
	if self.mRandomSum >= 11 then
		self.mNumType1:setTexture("dec/dec_big_sel.png")
	else
		self.mNumType1:setTexture("dec/dec_small_sel.png")
	end
	if self.mRandomSum % 2 == 0 then
		self.mNumType2:setTexture("dec/dec_double_sel.png")
	else
		self.mNumType2:setTexture("dec/dec_single_sel.png")
	end
end

function TouzhuRandomView:dismiss()
	BLDialog.dismiss(self)
end

return TouzhuRandomView