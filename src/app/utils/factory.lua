--
-- Author: shineflag
-- Date: 2017-02-26 14:32:51
--

local log = require("app.utils.log")
local Poker = require("app.views.Poker")
local pokers = {}

local function getPoker( value)
	if value <=0 or value >= 255 then   --暂时如此处理
		return Poker.new(0)
	end

	-- local poker = pokers[value]
	-- if not poker then
	-- 	log.d("POKERFACTORY", string.format("create poker[%d]", value ))
	-- 	poker = Poker.new(value)
	-- 	pokers[value] = poker
	-- else
	-- 	log.d("POKERFACTORY", string.format("get exists poker[%d]", value ))
	-- end

	-- return poker
	--log.d("POKERFACTORY", "create poker[%d]", value )
	return Poker.new(value)
end

local factory = {}
factory.getPoker = getPoker

return factory
