
-- Author: shineflag
-- Date: 2017-07-24 11:10:18
--
--happydice相关的协议
return {

	["happydice.info"] = {  --获取当前的 开奖状态
		req = {  --空
	    	mid = 0
		},
		resp = {
			ret = 200,   -- -101 暂停销售以下数据都有 只是不可以下注
			left_gold = 0, --身上暂无投注币
			stage = 0,   --当前第几期 数字
			happyid = "",  --总期标记(用日期表示)
			last_stage = 0,  --0表示无上期
			last_happyid  = "",  --无上期则为空字符串
			last_luck = {}, --上期的三个幸运数字，没有则表示开奖中
			luck_time = 360,   --本期还有多少时间开奖
			show_ver = 1, --赔率表版本号
		},
		broadcast = {-- 当可投注状态发生变化时 广播当前的投注状态
			flag = 0 --0:暂停投注  1:开放投注
		}
	},

	["happydice.bet"] = {  --用户下注请求

		req = {
			mid = 12345,
			place = "dice",  --下注的场合 room:房间 dice:下注大厅
			bets = {   -- 投注 和=金额 1:单 2：双 19:小 20:大  3-18代表和值
				-- [3] = 10000,
				-- [4] = 10000,
			}
		},
		resp = {
			ret = 200,   --200:成功 -101 不可下注  -102: 费用不够   -103:下注错误(参数) -104 频繁下注(2s) 
			stage = 1,   --当前第几期 数字
			happyid = "2017-02-01",  --总期标记(用日期表示)
			left_gold = 123, --玩家剩余的金币 (失败信息无效)
			bets = {   -- 投注 和=金额 1:单 2：双 19:小 20:大  3-18代表和值
				-- [3] = 10000,
				-- [4] = 10000,
			}
		},
	},

	["happydice.open_stage"] = {  --开奖状态 收到广播时才请求信息相关

		req = {
			mid = 12345,
			stage = 1,   --查询第几期 数字
			happyid = "2017-02-01",  --总期标记(用日期表示)
		},
		resp = {
			ret = 200,   -- -101 未找到或已过期  -102还未开奖  (非200请不要刷新自己的积分数据)
			stage = 1,   --当前第几期 数字
			happyid = "2017-02-01",  --总期标记(用日期表示)
			luck_num  = {1,2,3}, --开出的三个幸运数字
			total_bet = 12345,   --本期总下注多少金币 
			winscore = 12345,   --本期总赢取积分
			tscore = 54321,     --身上总积分 
		},


		broadcast = {--  当前一期开奖的时候 服务器广播  客户端 收到广播后如自己有下注则 调用本接口 拉取自己的本期的开奖状态
			stage = 1,     --开奖的期数
			happyid = "2017-02-01",  --总期标记(用日期表示)
			luck_num  = {1,2,3}, --开出的三个幸运数字
		}
	},




	["happydice.new_stage"] = {  --新开一场的广播
		broadcast = {--  当新开一期的时候 服务器广播  客户端当前期与新的一期 stage happyid 一致的时候，则不需要更新
			stage = 1,     --新开奖的期数
			happyid = "2017-02-01",  --总期标记(用日期表示)
			luck_time = 360,  -- 
		}
	},


	["happydice.bet_history"] = {  --下注记录
		req = {
			mid = 12345,  --用户id
			stage = 1,    --第几期
			happyid = "2017-02-01",  --总期标记(用日期表示)
		},
		resp = {
			ret = 200,   -- -101 获取失败
			stage = 1,
			happyid = "2017-02-01",  --总期标记(用日期表示)
			luck_num = {1,2,3}, --中奖号码 数组为空则表示还未开奖
			record = {   --下注数组
				{
					bets= {  -- 具体的下注数字与金额  
						[9] = 1000,
						[17] = 5000,
					},
					tbet = 12345,   --本注总额
					win = 1000,     --下注赢取(未开奖或未中奖为0)
					btime=123456789, --下注时间
				},
				--...

			}

		},

	},


	["happydice.luck_history"] = {  --当前总期的已开奖历史

		req = {
			happyid = "2017-02-01",  --总期标记(用日期表示)
			num = 10,    --几条历史记录 -1:表示拉所有
		},
		resp = {
			ret = 200,   --200:成功 -101 获取失败
			happyid = "2017-02-01",  --总期标记(用日期表示)
			record = {
				{stage=10,luck_num={1,2,3}},
				{stage=9,luck_num={1,2,3}},
			}
		},
	},


	["happydice.show_table"] = {  --赔率表
		req = {  --请求为空

		},
		resp = {
			ver = 1,  --赔率表版本号
			min_left = 10000, --玩下兑换之后的最小剩余筹码
			min_unit = 5000, --最小兑换单位
			show = {
				-- [3] = 1200,   --数字=倍数
				-- ...
				-- [18] = 1200,
			}
		},
	},

	--用筹码兑换成投注币
	["happydice.money2gold"] = {  --赔率表
		req = {  
			mid = 0,
			num = 5000,  --本次兑换额度
		},
		resp = {
			ret = 200, -- -101:筹码不够,  -102:兑换后剩余筹码太小 -103:未知错误
			cgold = 5000,  --兑换的金币
			left_money = 0,  --兑换后剩余筹码
			left_gold = 5000, --兑换身上的投注币
		}
	},
}