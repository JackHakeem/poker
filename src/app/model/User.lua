--
-- Author: shineflag
-- Date: 2017-02-15 11:11:48
--

local K = 1000
local M = 1000 * K
local B = 1000 * M 
local User = class("User")

User.EVENT_MONEY = "EVENT_MONEY"
User.EVENT_NICK  = "EVENT_NICK"
User.EVENT_VIP_LV = "EVENT_VIP_LV"
User.EVENT_VIP_SCORE = "EVENT_VIP_SCORE"
User.EVENT_VIP_EXP 	 = "EVENT_VIP_EXP"
User.EVENT_JUAN 	 = "EVENT_JUAN"
User.EVENT_COINS 	 = "EVENT_COINS"
User.EVENT_VP_LV	 = "EVENT_VP_LV"
User.EVENT_VP_EXP	 = "EVENT_VP_EXP"
User.EVENT_HORN	 	 = "EVENT_HORN"
User.EVENT_FRIST_PAY = "EVENT_FRIST_PAY"
User.EVENT_INVITED = "EVENT_INVITED"

function User:ctor( ... )
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.uid_ = 0
	self.nick_ = ""
	self.money_ = 0
	self.coins_ = 100000
	self.img_url_ = ""
	self.mVipLv = 1
	self.mVipOLv = 1
	self.mVipScore = 0
	self.mVipExp = 0
	self.mJuan = 0
	self.isFb_ = false
	self.mVpLv = 1
	self.mVpExp = 0
	self.mHorn = 0
	self.mIsFristPay = false
	self.mInviteid = 0 -- 是否被邀请
	self:setFreeRewardData()
end

--房间展示其它信息专用
function User:getUinfo() 
	return json.encode(
		{
			name=self.nick_,
			img_url=self.img_url_,
			fb = self.isFb_,
			vip_lv = self.mVipLv,
		})
end

function User:setMoney(money)
	print("user:setMoney",money)
	self.money_ = tonumber(money) or 0
	self:dispatchEvent({name=User.EVENT_MONEY,money=self.money_})
end

function User:getMoney()
	return self.money_
end

function User:setCoins(coins)
	print("user:setCoins",coins)
	self.coins_ = tonumber(coins) or 0
	self:dispatchEvent({name=User.EVENT_COINS,money=self.coins_})
end

function User:getCoins()
	return self.coins_
end

function User:getUid(  )
	return self.uid_
end

function User:setName(name)
	self.nick_ = tostring(name) or ""
	self:dispatchEvent({name=User.EVENT_NICK,nick=self.nick_})
end

function User:getName()
	return self.nick_
end

function User:getIconUrl()
	return self.img_url_
end

function User:setFb(flag)
	self.isFb_ = flag
end

function User:isFb()
	return self.isFb_ == true
end

function User:setVipLv(lv)
	self.mVipLv = tonumber(lv) or 1
	self:dispatchEvent({name=User.EVENT_VIP_LV,lv=self.mVipLv})
end

function User:getVipLv()
	return self.mVipLv or 1
end

function User:setVipOLv(lv)
	self.mVipOLv = tonumber(lv) or 1
end

function User:getVipOLv()
	return self.mVipOLv or 1
end

function User:getMaxVipLv()
	return math.max(self.mVipOLv,self.mVipLv)
end

function User:setVipExp(exp)
	self.mVipExp = tonumber(exp) or 0
	self:dispatchEvent({name=User.EVENT_VIP_EXP,exp=self.mVipExp})
end

function User:getVipExp()
	return self.mVipExp
end

function User:setVipScore(score)
	self.mVipScore = tonumber(score) or 0
	self:dispatchEvent({name=User.EVENT_VIP_SCORE,score=self.mVipScore})
end

function User:getVipScore()
	return self.mVipScore
end

function User:setJuan(juan)
	self.mJuan = juan
	self:dispatchEvent({name=User.EVENT_JUAN,juan=self.mJuan})
end

function User:getJuan()
	return self.mJuan
end


function User:setVpLv(lv)
	self.mVpLv = tonumber(lv) or 1
	self:dispatchEvent({name=User.EVENT_VP_LV,lv=self.mVpLv})
end

function User:setVpExp(exp)
	self.mVpExp = tonumber(exp) or 0
	self:dispatchEvent({name=User.EVENT_VP_EXP,exp=self.mVpExp})
end

function User:getVpLv()
	return self.mVpLv
end

function User:getVpExp()
	return self.mVpExp
end

function User:setHorn(horn)
	self.mHorn = tonumber(horn) or 0
	self:dispatchEvent({name=User.EVENT_HORN,horn=self.mHorn})
end

function User:getHorn()
	return self.mHorn
end

function User:setFirstPay(flag)
	self.mIsFristPay = checkbool(flag)
	self:dispatchEvent({name=User.EVENT_FRIST_PAY,flag=self.mIsFristPay})
end

function User:isFirstPay()
	return self.mIsFristPay
end

function User:setFreeRewardData(data)
	self.mFreeRewardData = checktable(data)
	self.mFreeRewardData.mycode = self.mFreeRewardData.mycode or ""
	self.mFreeRewardData.share = self.mFreeRewardData.share or 0
	self.mFreeRewardData.invite_fb = self.mFreeRewardData.invite_fb or 0
	self.mFreeRewardData.invite_code = self.mFreeRewardData.invite_code or 0
end

function User:getFreeRewardData()
	return self.mFreeRewardData
end

function User:isInvited()
	return self.mInviteid ~= 0
end

function User:setInviteid(id)
	print("inviteid",id)
	self.mInviteid = checkint(id)
	self:dispatchEvent({name=User.EVENT_INVITED,flag=self.mInviteid})
end


return User