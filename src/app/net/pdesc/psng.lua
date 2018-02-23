

return {
	["sng.info"] = {  --获取比赛的场次
		req = {
			mtype = 1,     --比赛类型 1--sng
			chan = "appstore"  --渠道号
		},
		resp = {
			ret = 200,
			ver = 1,  --目前配置的版本号
			levels = {
				--场次    名称                报名费                    第一名奖金     开赛人数 盲注表id    奖励表id    比赛子类型，用于客户端颜色展示
				{mlv = 1,mname = "坐满即开",entry={{etype=1,num=1000}},cp_reward=2000,player=28,blind_id=1, reward_id=1,ct=1},
			}
		}
	},

	["sng.blind_info"] = {  --获取盲注表的信息
		req = {
			blind_id = 1,     --盲注表的id
		},
		resp = {
			ret = 200, -- -101无此盲注表
			blind_id = 1,
			blind_table = {
			    --lv   小盲      大盲     前注    升盲时间  时间银行
				[1]  = {sb=10,   bb=20,   ante=0,   tm=60, tbank=15},
			}
		}
	},

	["sng.apply"] = {  --比赛报名
		req = {
			mlv = 1,           --比赛场次
			etype = 1,         --报名费的类型
		},
		resp = {
			ret = 200,  -- ret  -101:重复报名， -102:费用不足 -103:比赛不存在 -104:已经报名或正在参加一场sng
			mlv = 1,  --场次
			match_id = "1_1_1",  --报名成功的比赛id
			fee = { etype=1, num=1000, left=9000} --报名费用，及自己的剩余
		}
	},

	["sng.cancel"] = {  --取消比赛报名
		req = {
			mlv = 1,           --比赛场次
			match_id = "1_1_1", --比赛id
		},
		resp = {
			ret = 200,  -- ret  -101:未报名， -102:比赛已开始 -103:比赛不存在或已经结束
			mlv = 1,  --场次
			match_id = "1_1_1",  --取消报名的比赛id
			fee = { etype=1, num=1000, left=9000} --退赛费用，及自己退赛后的剩余
		}
	},



	["sng.start"] = {  --比赛开始进度信息
		req = {
			mlv = 1,           --比赛场次
		},
		resp = {
			ret = 200,  -- ret  -101:比赛不存在
			mlv = 1,  --场次
			match_id = "1_1_1",  --该场比赛正在报名的比赛id
			apply_num = 2,  ----已报名人数
			start_num = 6,  ----开赛人数
		},

		broadcast = {
			mlv = 1,          --比赛场次
			match_id = "1_1_1",     --比赛id
			apply_num = 2,  --已报名人数
			start_num = 6,  --开赛人数
			left_time = 3,  --预估开赛时间 --为0时则进入比赛
		}
	},

	["sng.rank"] = {  --获取比赛名次
		req = {
			mlv = 1,           --比赛场次
			match_id = "1_1_1",   --比赛id
			mid = 0,           --用户的id
			begin = 1,         --排名起始值
			rnum = 10,         --排名个数   

		},
		resp = {
			ret = 200,   
			mlv = 1,           --比赛场次
			match_id = "1_1_1",      --比赛id
			urank = 1,  --用户自己的名次  
			left_num = 30, --比赛还剩的玩家
			max_coin = 8000,  --当前的最高筹码
			avg_coin = 4000,   --当前的平均筹码
			min_coin = 1000,  --当前的最小筹码
			ranks = {
				{mid=100,nick="xxx",coin=100,rank=1}
			}
		}
	},


	["sng.blind"] = {  --比赛过程中的盲注信息
		req = {
			mlv = 1,           --比赛场次
			match_id = "1_1_1",   --比赛id
		},
		resp = {
			ret = 200,   -- -101:比赛还没开始
			mlv = 1,           --比赛场次
			match_id = "1_1_1",      --比赛id
			blind_id = 1,  --本局比赛盲注表id
			cur_lv = 1,  --当前的盲注等级   -当为0时则表示 比赛还未开始
			left_time = 5, --剩余涨盲时间 
		},
		broadcast = {
			mlv = 1,          --比赛场次
			match_id = "1_1_1",     --比赛id
			cur_lv = 1,      --当前是第几个盲注名额
			change_lv = 2,    --涨盲为多少等级 
			left_time = 10,   --还有多少时间涨盲，为0则表示，开始涨盲
		}
	},

	["sng.result"] = {  --广播比赛的结果信息

		resp = {
			mlv = 1,          --比赛场次
			match_id = "1_1_1",     --比赛id
			urank = 1,        --比赛最终名次
			total = 100,      --比赛总人数
			money = 1000,     --比赛结束后的金币
			reward = {money=100},  --奖励
		}
	},

	["sng.jointable"] = {  --加入比赛桌

		req = {
			mlv = 1,     --场次
			match_id = "1_1_1",
			mid = 1000,  --用户id
		},

		resp = {
			ret = 200,  -- -101:没参加此场比赛
			mlv = 1,
			tid = 1001,
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
			player={mid=100,money=0,info="xxx"}
		}
	},

	["sng.leavetable"] = {  --离开比赛桌

		broadcast = {
			mlv = 1,
			tid = 1001,
			seatid = 1,
			mid = 1,
		}
	},

	["sng.reward_info"] = {  --获取比赛奖励表
		req = {
			reward_id = 1,     --奖励表的id
		},
		resp = {
			ret = 200, -- -101无此盲注表
			reward_id = 1,  --奖励表id
			reward_table = {
				[1] = 60,  -- 最小名次的
				[3] = 40,  -- 第一名的为奖励60 2-3名为40 
				[6] = 20,  -- 4-6名的为20
			}
		}
	},

	["sng.usersngs"] = {  --获取我参加或正在比赛的场次
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

	["sng.wait"] = {  --等待比赛继续

		broadcast = {
			mlv = 1,          --比赛场次
			match_id = "1_1_1",     --比赛id
			wait_type = "start",  --等待的类型 -start:比赛开始  alloc：配桌
			wait_time = 10,    --估计等待时间
		}
	},

	["sng.mlv_info"] = {  --获取指定 mlv 比赛的信息
		req = {
			mlv = 1,     --比赛的 mlv
		},
		resp = {
			ret = 200, -- -101无此mlv的比赛
			mlv = 1,  --奖励表id
				  --场次    名称                报名费                    第一名奖金     开赛人数 盲注表id    奖励表id
			info = {mlv = 1,mname = "坐满即开",entry={{etype=1,num=1000}},cp_reward=2000,player=28,blind_id=1, reward_id=1},
		}
	},


}