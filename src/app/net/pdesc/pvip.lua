--
-- Author: shineflag
-- Date: 2017-07-24 11:10:18
--
--vip相关的协议
return {

	["vip.upgrade"] = {  --广播用户升级，获取升级奖励

		broadcast = {
			uplv = 2,     --升到的vip等级 0--表示达到最高级
			add_score = 12,   --升级奖励的vip点数
			total_score = 534,  --总vip点数
		}
	},

	["vip.vip_info"] = {  --获取vip的相关信息
		req = {
			mid = 12345,           --用户名
		},
		resp = {
			ret = 200,   -- -101 的获取
			olv= 1,   --上个月的等级
			lv = 1,   --当前vip等级 
			exp = 1234,  --当前vip总经验 
			score = 4321, --当前vip总点数
		},
		broadcast = {
			add_exp = 23,     --本次增加vip经验
			total_exp = 4321,  --增加后的vip总经验 
			add_score = 12,   --本次增加vip点数
			total_score = 534,  --增加后的vip点数
		}
	},

	["vip.getlvinfo"] = {  --获取 vip 的相关等级信息
		req = {
			chan = "google",           --渠道名,暂时没什么实际作用
		},
		resp = {
			ret = 200,   -- -101:无此渠道
			ver = 1,           --该渠道版本号
			info = {  --等级详情
			   --       等级  升到下级所需要总经验  升级时的一次奖励vip点数  每个vip经验加成的vip点百分比             
				[1] = { lv=1,   exp = 49950,             rscore = 90000,      rate = 12 },
			}
		}
	},
}