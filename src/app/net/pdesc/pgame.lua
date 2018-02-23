--
-- Author: shineflag
-- Date: 2017-12-30 11:01:47
--
-- 游戏总集相关的接口 

--

return {

	["game.rmdlvs"] = {  --获取相应场次的玩家人数信息
		req = {
			mid = 1234,
		},
		resp = {
			ret = 200,   --  -101获取失败(没有下面信息,客户端只显示 现金场 和 mtt场)
			info = {    --具体场次的信息 下面内容实时变化 目前gtype[cash, mtt, dice]
				-- {	
				-- 	gtype="cash",   --现金场 如有推荐场次则和 protos 的alloc.info 场次内容格式相同
				-- 	rmd={lv = 1, name = "初级场", ante=10,sb=5,bb=10,min_carry=250,max_carry=500,default_buy=500,player=500 },
				-- },
				-- {	
				-- 	gtype="cash",   --现金场
				-- 	rmd=0,  --整个现金场
				-- },
				-- {	
				-- 	gtype="mtt",   --mtt场次 如有推荐场次则和 pmtt 的 mtt.info中的场次内容格式相同
				-- 		--场次    名称                  比赛icon                     本场已报名人数   报名费(空表示免费报名)     最小报名人数   最高报名人数    位数    下注时间    初始筹码    盲注表id,     奖励表的类型  奖励表id   比赛子类  服务费  比赛开始时间   比赛提前进入时间(s) 比赛开始前多久可报名(s)-1:无限制   本场开始后，下场的的开始时间   还剩几场(0表示，没有下一场了) 比赛id前缀              当前场的比赛id
				-- 	rmd={mlv = 1,mname = "坐满即开",icon="woyaoent.com/img/10001.png",apply_num=3,    entry={{etype=1,num=1000}},min_player=3, max_player=100, seat=6, bettime=12, coin=3000, blind_id=3, reward_type=1, reward_id=1, ct=1,  fee=1000,stime=14112345,jtime=60,           atime=-1,                             ntime=120,                     left=1,                   match_pre="utime_mlv_", match_id="utime_mlv_(left+1)"},
				-- },
				-- {	
				-- 	gtype="mtt",   --mtt场次
				-- 	rmd=0,  --整个mtt场次
				-- },
				-- {	gtype="dice",   --投注场次
				-- 	rmd=0,  --目前投注只有一个场次图标
				-- },
				-- {  gtype="custom",   --自定义房间
		  --         rmd=0,  --目前自定义房间只有一个场次图标
		  --       },
		    }
		},
		broadcast = {  --推荐有变动，客户端收到此广播 需要重新拉取新的推荐页
			--内容为空
		}
	},
	
	["game.lookup_player"] = {  --查找可赠送用户的基本信息
		req = {
			mid = 1234,  --要查找的mid
		},
		resp = {
			ret = 200, -- -101：无此用户 
			mid = 1234,   --查找到的用户mid 
			mnick = "",   --查找到的用户昵称
			sid = 100,    -- 帐号类型  100:游客 101:fb帐号
			icon = "",    --查找到用户的头像 url
		},
	},


	["game.gift_minfo"] = {  --游戏可赠送筹码的信息
		req = {
			mid = 1234,
		},
		resp = {
			min_left = 20000, --赠送后的最小的剩余金币
			gift_left = 1000000, --当天还可赠送的金额 
			gift_total = 1000000,  --每天可送的最高总额
		},
	},

	["game.gift_money"] = {  --赠送筹码给某人
		req = {
			mid = 0,   --玩家自己的id
			gift_mid = 0,  --目标id
			money = 0,  --赠送金额 必须大于0
		},
		resp = {
			ret = 200, -- -101 金额不足 -102赠送后身上金币过少 -103赠送金币超过额度 -- -104 赠送的目标不存在-105不能赠送给自己
			gift_mid = 0,    --赠送的目标id
			gift_money = 0, --赠送的金额
			gift_left = 0,   --赠送后当天还可赠送的金额 
			left_money = 0, --赠送后还剩余的筹码
		},
		broadcast = {  --被赠送的玩家在线的话会收到通知
			benefactor_mid = 0,   --赠送者id
			benefactor_mnick = "",  --赠送者昵称
			gift_money = 0,    --赠送金额
			tmoney = 0        --被赠送后当前身上筹码
		}
	},
}