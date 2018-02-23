--
-- Author: shineflag
-- Date: 2017-02-20 09:04:10
--

local CARD_FACE_TWO      = 0x02
local CARD_FACE_THERR    = 0x03
local CARD_FACE_FOUR     = 0x04
local CARD_FACE_FIVE     = 0x05
local CARD_FACE_SIX      = 0x06
local CARD_FACE_SEVEN    = 0x07
local CARD_FACE_EIGHT    = 0x08
local CARD_FACE_NINE     = 0x09
local CARD_FACE_TEN      = 0x0A
local CARD_FACE_JACK 	 = 0x0B
local CARD_FACE_QUEEN    = 0x0C
local CARD_FACE_KING     = 0x0D
local CARD_FACE_ACE      = 0x0E

local CARD_SUIT_DIAMOND 	= 0x00  --方片
local CARD_SUIT_CLUB 		= 0x10  --梅花
local CARD_SUIT_HEART 		= 0x20  --红桃
local CARD_SUIT_SPADE 		= 0x30  --黑桃

local kHighCard = 1
local kOnePair = 2
local kTwoPair = 3
local kThreeKind = 4
local kStraight = 5
local kFlush = 6
local kFullHouse = 7
local kKingKong = 8
local kFlushStraight = 9
local kRoyalFlush = 10

local tp_name = {
	"高牌",
	"一对",
	"二对",
	"三条",
	"顺子",
	"同花",
	"葫芦",
	"金刚",
	"同花顺",
	"皇家同花顺"
}

local suit_str = {  [CARD_SUIT_DIAMOND] = "方片",
					[CARD_SUIT_CLUB]    = "梅花",
					[CARD_SUIT_HEART]   = "红桃",
					[CARD_SUIT_SPADE]   = "黑桃"}
local face_str = { "1","2","3","4","5","6","7","8","9","T","J","Q","K","A"}

local band =  bit.band   --bit and 位与运算

--花色
local function suit( card )
	return band(card ,0xF0)
end

--牌面
local function face( card )
	return band(card , 0x0F)
end

--比较两张牌的大小
local function compare_card( a,b )
	return face(a) > face(b) 
end

local function type_str( tp )
	local str =  tp_name[tp]
	if not str then
		str = "Unknow_" .. tp 
	end

	return str
end

local function card_str(card)
	local s = suit(card) 
	local f = face(card)

	return string.format("%s%s",suit_str[s] ,face_str[f])
end

--将扑克字符串化
local function cards_str(cards)
	local t = {}
	for _, card in pairs(cards) do
		table.insert(t, card_str(card))
	end

	local str = table.concat(t,",")
	return str
end

--选出玩家的最好手牌 并排好序
local function make_cards(public, hands)

	local cards = {}
	for _,v in pairs(public) do table.insert(cards,v) end
	for _,v in pairs(hands) do table.insert(cards,v) end

	table.sort(cards, compare_card)
	local t = {}  --花色
	local fv = {} --牌面

	local four = {}
	local three = {}  --三张牌的
	local two = {}
	for _,card in ipairs(cards) do
		local s = suit(card)
		local f = face(card)
		if not t[s] then
			t[s] = {}
		end
		table.insert(t[s],card)
		if not fv[f] then
			fv[f] = 1
		else
			fv[f] = fv[f] + 1
			if fv[f] == 2 then table.insert(two,f)
			elseif fv[f] == 3 then table.insert(three,f)
			elseif fv[f] == 4 then table.insert(four,f) end
		end
	end

	local cardtype 
	local best_cards
	for _,ts in pairs(t) do
		if #ts > 4 then  --有五张以上相同的花色
			printInfo(cards_str(ts))
			for idx=1, #ts-4 do 
				if face(ts[idx]) - face(ts[idx+4]) == 4 then
					--同花顺
					if face(ts[idx]) == CARD_FACE_ACE then
						cardtype = kRoyalFlush 
					else 
						cardtype = kFlushStraight
					end

					return cardtype ,{ts[idx],ts[idx+1],ts[idx+2],ts[idx+3],ts[idx+4]}
				end
			end

			-- 1 2 3 4 5
			if face(ts[1]) == CARD_FACE_ACE and face(ts[#ts]) == CARD_FACE_TWO 
				and face(ts[#ts-3]) - face(ts[#ts]) == 3 then
				return kFlushStraight,{ts[#ts-3],ts[#ts-2],ts[#ts-1],ts[#ts],ts[1]}
			end
		

			--目前最好的牌为同花
			cardtype = kFlush 
			best_cards = {}
			for idx = 1,5 do best_cards[idx] = ts[idx] end
			break 
		end
	end


	local function list_move(dst, src)
		for k, v in  ipairs(src) do
			table.insert(dst, v)
		end
	end

	local function find_f_cards(f1,f2)
		local cs1,cs2,cs3 = {},{},{}
		for _,c in ipairs(cards) do 
			if face(c) == f1 then
				table.insert(cs1, c)
			elseif f2 and face(c) == f2 then
				table.insert(cs2, c)
			else
				table.insert(cs3, c)
			end
		end

		if #cs2 > 0 then
			list_move(cs1,cs2)
		end

		if #cs3 > 0 then
			list_move(cs1,cs3)
		end

		local best = {}
		for id=1,5 do 
			best[id] = cs1[id]
		end
		return best
	end


	if four[1] then  	--4金刚 四条
		best_cards = find_f_cards(four[1])
		return kKingKong,best_cards
	elseif three[1] and two[2] then   --葫芦
		local f2 = (three[1] == two[1]) and two[2] or two[1]
		best_cards = find_f_cards(three[1],f2)
		return kFullHouse,best_cards
	elseif cardtype then  --同花
		printInfo("同花 %s",cards_str(best_cards))
		return cardtype,best_cards
	else
		--检测是否成顺
		local st = {cards[1]}
		for idx = 2, #cards do 
			local last = st[#st]
			local card = cards[idx]

			if face(last) - face(card) == 1 then
				table.insert(st, card)

				if #st == 4 and fv[CARD_FACE_ACE]  and face(st[1]) == CARD_FACE_FIVE then
					--1 2 3 4 5 
					table.insert(st,cards[1])
					return kStraight, st 
				elseif #st == 5 then   --顺子
					return kStraight, st 
				end
			else
				-- 当前顺子的长度 + 剩余牌数 <4 就不能成顺
				if #st + (#cards-idx) < 4  then 
					break  --不能成顺了
				elseif  face(last) ~= face(card) then
					st = {card}
				end

			end
		end


		if three[1] then   --三条 
			best_cards = find_f_cards(three[1])
			return kThreeKind,best_cards
		elseif two[2] then   --二对
			best_cards = find_f_cards(two[1],two[2])
			return kTwoPair,best_cards
		elseif two[1] then   --一对 
			best_cards = find_f_cards(two[1])
			return kOnePair,best_cards
		else  --高牌
			best_cards = {}
			for idx =1,5 do 
				best_cards[idx] = cards[idx]
			end

			return kHighCard,best_cards
		end


	end 

end

--比较s1,s2牌的大小 >0:s1大 0:平 <0:s1小
local function compare_seat_cards(s1, s2)
	local ret = s1.cardtype - s2.cardtype
	if ret == 0 then
		for idx = 1,5 do 
			ret = face(s1.bestcards[idx]) - face(s2.bestcards[idx])
			if ret ~= 0 then
				return ret 
			end
		end
	end

	return ret 
end

--创建一副扑克牌
local function create_cards()
	local NUM = 52 --52张牌
	local cards =	{
	    0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,   --方块 2 - A
	    0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,   --梅花 2 - A
	    0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2a,0x2b,0x2c,0x2d,0x2e,   --红桃 2 - A
	    0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3a,0x3b,0x3c,0x3d,0x3e,   --黑桃 2 - A
	}

	local top = 1 --
	--日后改成 Fisher–Yates shuffle 
	local function shuffle()
		math.randomseed(os.time())
		for id, _ in pairs(cards) do 
			local pos = math.random(NUM)
			cards[id],cards[pos] = cards[pos], cards[id]
		end

		top = 1
	end

	local function deal(num)
		local cs = {}
		for index = 1,num do
			if top > NUM then 
				table.insert(cs,0)
			else
				table.insert(cs,cards[top])
				top = top + 1
			end
		end

		return cs 
	end	

	return {shuffle=shuffle, deal=deal}
end

local t = {}
t.type_str = type_str
t.cards_str = cards_str 
t.create_cards = create_cards
t.compare_seat_cards = compare_seat_cards
t.make_cards = make_cards 

return t 




