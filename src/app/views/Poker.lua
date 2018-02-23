--
-- Author: shineflag
-- Date: 2017-02-26 14:23:01
--

local res = "poker/"

local band =  bit.band   --bit and 位与运算

-- mask
local CARD_MASK_SUIT		= 0xF0   --花色 用于求card的suit值
local CARD_MASK_RANK		= 0x0F   --数值 用于求card的rank值


local SUIT_DIAMOND = 0x00   --方块
local SUIT_CLUB    = 0x10   --梅花
local SUIT_HEART   = 0x20   --红桃
local SUIT_SPADE   = 0x30   --黑桃

local card_big_list = {
    ["card_back"]       = res .. "poker_big_blue.png",
    ["card_cover"]      = res .. "poker_big_front.png",

    ["card_black_2"]    = res .. "poker_big_black_2.png",
    ["card_black_3"]    = res .. "poker_big_black_3.png",
    ["card_black_4"]    = res .. "poker_big_black_4.png",
    ["card_black_5"]    = res .. "poker_big_black_5.png",
    ["card_black_6"]    = res .. "poker_big_black_6.png",
    ["card_black_7"]    = res .. "poker_big_black_7.png",
    ["card_black_8"]    = res .. "poker_big_black_8.png",
    ["card_black_9"]    = res .. "poker_big_black_9.png",
    ["card_black_10"]   = res .. "poker_big_black_10.png",
    ["card_black_11"]   = res .. "poker_big_black_j.png",
    ["card_black_12"]   = res .. "poker_big_black_q.png",
    ["card_black_13"]   = res .. "poker_big_black_k.png",
    ["card_black_14"]    = res .. "poker_big_black_a.png",

    ["card_red_2"]      = res .. "poker_big_red_2.png",
    ["card_red_3"]      = res .. "poker_big_red_3.png",
    ["card_red_4"]      = res .. "poker_big_red_4.png",
    ["card_red_5"]      = res .. "poker_big_red_5.png",
    ["card_red_6"]      = res .. "poker_big_red_6.png",
    ["card_red_7"]      = res .. "poker_big_red_7.png",
    ["card_red_8"]      = res .. "poker_big_red_8.png",
    ["card_red_9"]      = res .. "poker_big_red_9.png",
    ["card_red_10"]     = res .. "poker_big_red_10.png",
    ["card_red_11"]     = res .. "poker_big_red_j.png",
    ["card_red_12"]     = res .. "poker_big_red_q.png",
    ["card_red_13"]     = res .. "poker_big_red_k.png",
    ["card_red_14"]      = res .. "poker_big_red_a.png",

    ["suit_club"]  = res .. "poker_big_club.png",
    ["suit_diamond"] = res .. "poker_big_diamond.png",
    ["suit_heart"] = res .. "poker_big_heart.png",
    ["suit_spade"] = res .. "poker_big_spade.png",

    ["suit_black_jack"] = res .. "suit_black_jack.png",
    ["suit_red_jack"] = res .. "suit_red_jack.png",
    ["suit_black_queen"] = res .. "suit_black_queen.png",
    ["suit_red_queen"] = res .. "suit_red_queen.png",
    ["suit_black_king"] = res .. "suit_black_king.png",
    ["suit_red_king"] = res .. "suit_red_king.png",

    ["suit_club_small"]  = res .. "poker_small_club.png",
    ["suit_diamond_small"] = res .. "poker_small_diamond.png",
    ["suit_heart_small"] = res .. "poker_small_heart.png",
    ["suit_spade_small"] = res .. "poker_small_spade.png",

    ["win_face"] = res .. "win_face.png"


} 


local Poker = class("Poker",function( ... )
	return display.newNode()
end) 

local TAG = "Poker" 

function Poker.SUIT( card )
	return band(card,CARD_MASK_SUIT)
end

function Poker.RANK( card )
	return band(card, CARD_MASK_RANK)
end

function Poker:ctor(card_value)
	self.card_value_ = card_value 
	if card_value <=0 or card_value >= 255 then
		card_value = 0
	end
	self.suit_ = Poker.SUIT(card_value)   --花色
	self.rank_ = Poker.RANK(card_value)   --牌面值

	self.mFileName = self:getFileName()   --获取一张扑克所需的图片名

	--print(string.format("rank_num = %s,suit_big = %s",rank_num,suit_big)) 

	--生成图片
	self.bg_img_ = display.newSprite(self.mFileName) 
	self:addChild(self.bg_img_)


	--图片之间的位置关系
	local bg_size = self.bg_img_:getContentSize()
	self:setContentSize(bg_size) 
	self.bg_img_:align(display.CENTER, bg_size.width/2, bg_size.height/2)
	self:setAnchorPoint(cc.p(0.5, 0.5))

	self.bg_size_ = bg_size
end

function Poker:setCardValue(card_value)
	self.card_value_ = card_value 
	self.suit_ = Poker.SUIT(card_value)   --花色
	self.rank_ = Poker.RANK(card_value)   --牌面值
	self.mFileName = self:getFileName()   --获取一张扑克所需的图片名
	self.bg_img_:setTexture(self.mFileName)
end

function Poker.getCardValue(self)
	return self.card_value_
end

function Poker.getRank(self)
	return self.rank_ or 0 
end

function Poker:setAliasTexParameters()
	self.bg_img_:getTexture():setAliasTexParameters()
end

--获取一张扑克的图片名 分别是 数字、小花色、大花色
 function Poker.getFileName(self)

	local suit = self.suit_ 
	local rank = tonumber(self.rank_) 

	if rank < 2 or rank > 14 then
		return "poker/poker_cad81_108/card_back.png"
	end

	local fileName = ""

	if suit == SUIT_DIAMOND then
		--方块
		fileName = "_diamond" 
	elseif suit == SUIT_CLUB then
		--梅花
		fileName = "_club" 
	elseif suit == SUIT_HEART then
		--红桃
		fileName = "_heart" 
	elseif suit == SUIT_SPADE then
		--黑桃
		fileName = "_spade"
	else
		return "poker/poker_cad81_108/card_back.png"
	end

	if rank == 11 then
		fileName = 'j' .. fileName
	elseif rank == 12 then
		fileName = 'q' .. fileName
	elseif rank == 13 then
		fileName = 'k' .. fileName
	elseif rank == 14 then
		fileName = 'a' .. fileName
	else
		fileName = rank .. fileName 
	end

	--print(rank_num,suit_small,suit_big )
	return "poker/poker_cad81_108/" .. fileName .. ".png"

end

-- function Poker:getContentSize()
-- 	return self.bg_img_:getContentSize()
-- end

-- function Poker:setContentSize( ... )
-- 	return self.bg_img_:setContentSize( ... )
-- end

function Poker:showAnim(needMove)
	self:showBack()
	if needMove then
		local bg_size = self.bg_img_:getContentSize()
		self.bg_img_:setPosition(cc.p(bg_size.width/2+10, bg_size.height/2-10))
	end

	self:performWithDelay(function()
		local st = 	cc.OrbitCamera:create(0.1, 1, 0, 0, 90, 0, 0)
		-- local st = cc.ScaleTo:create(0.08, 0, 1)
		self:runAction(st)

		self:performWithDelay(function()
				self:showFront()
				local st = 	cc.OrbitCamera:create(0.08, 1, 0, -90, 90, 0, 0)
			local bg_size = self.bg_img_:getContentSize()
			self.bg_img_:setPosition(cc.p(bg_size.width/2, bg_size.height/2))
				-- local st = cc.ScaleTo:create(0.08, 1, 1)
				self:runAction(st)
			end, 0.1)
		end, 0.1)
end

function Poker:showBack()
	self.isBack = true
	if self.mIsGray and self.gshow_gray then
		self.gshow_gray:setVisible(false)
	end

	if self.isWinShow and self.gshow_face_ then
		self.gshow_face_:setVisible(false)
	end

	if self.isWinShow and self.gshow_face2_ then
		self.gshow_face2_:setVisible(false)
	end

	self.bg_img_:setTexture("poker/poker_cad81_108/card_back.png")
end

function Poker:showFront()
	self.isBack = false
	if self.mIsGray and self.gshow_gray then
		self.gshow_gray:setVisible(true)
	end

	if self.isWinShow and self.gshow_face_ then
		self.gshow_face_:setVisible(true)
	end

	if self.isWinShow and self.gshow_face2_ then
		self.gshow_face2_:setVisible(true)
	end

	self.bg_img_:setTexture(self.mFileName)
end

function Poker:setGray(flag)
	self.mIsGray = flag
	if not self.gshow_gray then 
		self.gshow_gray = display.newSprite("dec/card_type_prompt1.png") 
			:align(display.CENTER, self.bg_size_.width/2-1, self.bg_size_.height/2+1)
		self:addChild(self.gshow_gray)
	end
	self.gshow_gray:setVisible(flag and not self.isBack)
end

--赢的时候展示的状态
function Poker:winShow()
	self.isWinShow = true
	if not self.gshow_face_ then 
		self.gshow_face_ = 	display.newSprite("dec/card_type_prompt.png") 
			:align(display.CENTER, self.bg_size_.width/2, self.bg_size_.height/2)
		self:addChild(self.gshow_face_)
	end
	self.gshow_face_:setVisible(self.isWinShow and not self.isBack)
	printInfo("winShow")
end

--赢的时候展示的状态
function Poker:winShow2()
	self.isWinShow = true
	if not self.gshow_face2_ then 
		self.gshow_face2_ = 	display.newSprite("dec/card_type_prompt2.png") 
			:scale(1.5,1.5)
			:align(display.CENTER, self.bg_size_.width/2, self.bg_size_.height/2)
		self:addChild(self.gshow_face2_)
	end
	self.gshow_face2_:setVisible(self.isWinShow and not self.isBack)
	printInfo("winShow")
end


function Poker:normal()
	printInfo("normal")
	self.isWinShow = false
	if self.gshow_face_ then
		self.gshow_face_:setVisible(false)
	end

	if self.gshow_face2_ then
		self.gshow_face2_:setVisible(false)
	end
end

return Poker