--
-- Author: shineflag
-- Date: 2018-01-15 17:17:12
--
-- Desc: 奖励中心
return {
	["reward.info"] = {  --当前的奖励信息
		req = {
				--空
		},
		resp = {
			mycode = "ABCDE", --玩家的邀请码
			share = 10000,  --每日分享奖励
			invite_fb = 1000000,  --fb邀请并玩三局奖励 
			invite_code = 20000  --通过邀请码玩三局奖励
		}
	},

	["reward.write_invite"] = {  --填写邀请码
		req = {
			mtype = "fb",  -- 邀请类型 fb:为fb邀请类型 code:为邀请码 
			code = "ABCDE",  --填写的邀请码code fb:则填邀请人的mid  code:填邀请人的邀请码
		},
		resp = {
			ret = 200, -- -101 邀请码错误  -102 自己不能邀请自己 -103:已被邀请
		}
	},



	["reward.rewardstatus"] = {  --获取某种奖励是否可领取
		req = {
			mtype = "share"  --奖励的类型 share为每日分享奖励
		},
		resp = {
			ret = 200, -- -101 无此种类型的奖励
			mtype = "share",  --奖励的类型
			status = 0, -- 可领取状态： 1：已领取 0：未领取
		}
	},

	["reward.getreward"] = {  --领取 某种类型的奖励
		req = {
			mtype = "share"  --奖励的类型 share为分享奖励
		},
		resp = {
			ret = 200, -- -101 无此种类型的奖励  -102已领取
			mtype = "share",  --奖励的类型
			cmoney = 0,  --本次奖励的筹码
			tmoney = 0,  --领取奖励后总筹码
		},

		broadcast = {  --其它系统主动发的奖励通知
			mtype = "invite",  --奖励的类型 invite:邀请 invited:被邀请 invite_fb:fb邀请好友
			cmoney = 0,  --本次奖励的筹码
			tmoney = 0,  --发放奖励后总筹码
		}
	},
}





