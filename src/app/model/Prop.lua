local Prop = class("Prop")

function Prop:ctor()
	self.mName = ""
	self.mTimeLimit = {}
	self.mTimeLimit.startT = 0
	self.mTimeLimit.endT = 0	
	self.mDec = "test"
	self.mNum = 1
	self.mType = 0
	self.mIconUrl = ""
end

function Prop:setData(data)
	self.mData = data
	self.mTimeLimit.startT =  tonumber(data.stime)
	self.mTimeLimit.endT =  tonumber(data.expire)
	self.mIconUrl = data.iconurl
	self.mType = tonumber(data.type)
	self.mDec = data.descp or ""
end

function Prop:getData()
	return self.mData
end

function Prop:getPropDec()
	return self.mDec
end

function Prop:getTimeLimit()
	return self.mTimeLimit
end

function Prop:isCanUse()
	return self.mType == 1 or self.mType == 2 or self.mType == 4
end

function Prop:getIconUrl()
	return self.mIconUrl
end

return Prop