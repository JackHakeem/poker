--
-- Author: shineflag
-- Date: 2017-09-14 15:21:22
--


return {

	["mtt.info"] = {  --获取比赛的场次
		req = {
			ct = 1,     --比赛子类型 0-代表所有(目前只有0)
			chan = "appstore"  --渠道号
		},
		resp = {
			ret = 200,  -- -101 获取信息失败or服务器维护
			levels = {
				--场次    名称                  比赛icon                     本场已报名人数  报名费                   最小报名人数   最高报名人数    位数    下注时间    初始筹码    盲注表id,     奖励表的类型  奖励表id   比赛子类  服务费  比赛开始时间   比赛提前进入时间(s) 比赛开始前多久可报名(s)-1:无限制   本场开始后，下场的的开始时间   还剩几场(0表示，没有下一场了) 比赛id前缀              当前场的比赛id
				{mlv = 1,mname = "坐满即开",icon="woyaoent.com/img/10001.png",apply_num=3,    entry={{etype=1,num=1000}},min_player=3, max_player=100, seat=6, bettime=12, coin=3000, blind_id=3, reward_type=1, reward_id=1, ct=1,  fee=1000,stime=14112345,jtime=60,           atime=-1,                             ntime=120,                     left=1,                   match_pre="utime_mlv_", match_id="utime_mlv_(left+1)"},
			}
		}
	},


	["mtt.apply"] = {  --比赛报名
		req = {
			mlv = 1234,   --比赛场次
			match_id = 1,           --比赛id
			etype = 1,         --报名费的类型
		},
		resp = {
			ret = 200,  -- ret  -101:重复报名， -102:费用不足 -103:比赛不存在 -104:未开放报名 -105比赛人数满
			mlv = 1,  --场次
			match_id = "1_1_1",  --报名成功的比赛id
			fee = { etype=1, num=1000, left=9000} --报名费用，及自己的剩余
		}
	},

	["mtt.cancel"] = {  --取消比赛报名
		req = {
			match_id = "1_1_1", --比赛id
		},
		resp = {
			ret = 200,  -- ret 200:玩家取消成功 201:比赛人数不够,自动取消 -101:未报名， -102:不可取消或比赛已结束
			mlv = 1,  --场次
			match_id = "1_1_1",  --取消报名的比赛id
			fee = { etype=1, num=1000, left=9000} --退赛费用，及自己退赛后的剩余
		}
	},

	["mtt.start"] = {  --比赛开始进度信息

		broadcast = {
			mlv = 1,          --比赛场次
			match_id = "1_1_1",     --比赛id
			stype = 1,  -- 1:代表可以提前入场， 2.代表比赛正式开始(第一次发牌前)
		}
	},



	["mtt.apply_num"] = {  --比赛的报名人数信息
		req = {
			match_ids = {"10001","10002"}           --比赛id的集合
		},
		resp = {
			ret = 200,  -- ret  -101:所有比赛id都不存在
			info={
				["10001"]=23,  --场次：报名人数
			}
		},
	},

	["mtt.match_rank"] = {  --获取比赛名次
		req = {
			mlv = 1,           --比赛场次
			match_id = "10001_1",   --比赛id
			mid = 0,           --用户的id
			begin = 1,         --排名起始值
			rnum = 10,         --排名个数   
		},
		resp = {
			ret = 200,   -- -101:获取信息失败
			mlv = 1,           --比赛场次
			match_id = "10001_1",      --比赛id
			urank = 1,  --用户自己的名次  
			left_num = 30, --比赛还剩的玩家
			total_num = 40, --比赛总人数
			max_coin = 8000,  --当前的最高筹码
			avg_coin = 4000,   --当前的平均筹码
			min_coin = 1000,  --当前的最小筹码
			ranks = {
				{mid=100,nick="xxx",coin=100,rank=1}
			}
		}
	},


	["mtt.match_blind"] = {  --比赛过程中的盲注信息
		req = {
			mlv = 1,           --比赛场次
			match_id = "1_1_1",   --比赛id
		},
		resp = {
			ret = 200,   -- -101:比赛还没开始
			mlv = 1,           --比赛场次
			match_id = "10001_1",      --比赛id
			blind_id = 1,  --本局比赛盲注表id
			cur_lv = 1,  --当前的盲注等级   -当为0时则表示 比赛还未开始
			left_time = 5, --剩余涨盲时间 
		},
		broadcast = {
			mlv = 1,          --比赛场次
			match_id = "10001_1",     --比赛id
			cur_lv = 1,      --当前是第几个盲注名额
			change_lv = 2,    --涨盲为多少等级 
			left_time = 10,   --还有多少时间涨盲，为0则表示，开始涨盲
		}
	},

	["mtt.result"] = {  --推送比赛的结果信息

		resp = {
			mlv = 1,          --比赛场次
			match_id = "10001_1",     --比赛id
			urank = 1,        --比赛最终名次
			total = 100,      --比赛总人数
			reward = {  --奖励 增加的数据
				money=100,  --金币奖励 可能无
				score=100,  --积分奖励 可能无
				prop={[5]=1,[6]=2}, --游戏内道具奖励 如虚拟参赛券 可能无
				vgoods={[1001]=1},  --vip商场 如虚拟参赛券 可能无

			},
			trich = { --如果有奖励,发奖后的总数是多少 key与reward相同
				-- money= 1000,
				-- score=1000,
				-- prop={[5]=1,[6]=2}, 
			}  
		}
	},

	["mtt.jointable"] = {  --加入比赛桌

		req = {
			mlv = 1,     --场次
			match_id = "10001_1",
			mid = 1000,  --用户id
		},

		resp = {
			ret = 200,  -- -101:没参加此场比赛
			mlv = 1,
			tid = 1001,
			match_id = "10001_1",
			blind_lv = 0, --当前桌子上的盲注等级
			ante = 0,   --前注
			sb = 50,   --小盲
			bb = 100,  --大盲
			seatnum = 6,  --几人桌
			bettime = 15, --下注思考时间
			gamestatus = 0,  --当前的游戏状态
			seatinfo = {   --座位上的信息 sretain:0-离座留桌 1-回到座位  snet:0-断网 1-正常连接
				{seatid=1,coin=100,sretain=1,snet=1, player={mid=100,money=0,info="xxx"}},
			}
		},

		broadcast = {
			mlv = 1,
			tid = 1001,
			seatid = 1,
			coin=100,
			sretain = 0,
			player={mid=100,money=0,info="xxx"}
		}
	},

	["mtt.leavetable"] = {  --离开比赛桌

		broadcast = {
			mlv = 1,
			tid = 1001,
			seatid = 1,
			mid = 1,
		}
	},

	["mtt.usermtts"] = {  --获取我参加或正在比赛的场次
		req = {
			mid = 1234, --玩家用户id
		},
		resp = {
			ret = 200, -- -101 目前没有报名或参加的比赛

			matchs = {
				--{mlv = 1,mname = "坐满即开",match_id="1234",status = 1}  --status 1报名 2.进行中
			}
		}
	},

	["mtt.wait"] = {  --等待比赛继续

		broadcast = {
			mlv = 1,          --比赛场次
			match_id = "1_1_1",     --比赛id
			wait_type = "start",  --等待的类型 -start:比赛开始  alloc：配桌
			wait_time = 10,    --估计等待时间
		}
	},

	["mtt.match_info"] = {  --获取指定 match 比赛的信息
		req = {
			match_id = "123",     --比赛的 id
		},
		resp = {
			ret = 200, -- -101无此比赛
			mlv = 1,  --场次
			match_id = "123",
				--场次    名称                  比赛icon                     本场已报名人数  报名费                   最小报名人数   最高报名人数    位数    下注时间    初始筹码    盲注表id,     奖励表的类型  奖励表id   比赛子类  服务费  比赛开始时间   比赛提前进入时间(s) 比赛开始前多久可报名(s)-1:无限制   本场开始后，下场的的开始时间   还剩几场(0表示，没有下一场了) 比赛id前缀              当前场的比赛id
			info = {mlv = 1,mname = "坐满即开",icon="woyaoent.com/img/10001.png",apply_num=3,    entry={{etype=1,num=1000}},min_player=3, max_player=100, seat=6, bettime=12, coin=3000, blind_id=3, reward_type=1, reward_id=1, ct=1,  fee=1000,stime=14112345,jtime=60,           atime=-1,                             ntime=120,                     left=1,                   match_pre="utime_mlv_", match_id="utime_mlv_(left+1)"},
		}
	},

	["mtt.match_desc"] = {  --获取指定 match 比赛的描述信息
		req = {
			match_id = "123",     --比赛的 id
		},
		resp = {
			ret = 200, -- -101
			match_id = "123",
			desc = "xxx",   --比赛描述
		}
	},

}