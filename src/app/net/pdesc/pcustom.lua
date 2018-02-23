--
-- Author: shineflag
-- Date: 2018-01-22 14:43:24
--
--  Desc: 自定义房间的协议

return {
	["custom.config"] = {  --获取自定场的最新配置
		req = {
			ver = 0,  --当前客户端的版本号，无则传0
		},
		resp = {
			ret = 200,  -- -101 已是最新版本，无需要更新(下面数据无)
			info = {
				ver = 1,  --当前版本号 
				sb = {100,500,2500, 5000, 25000,50000, 250000}, --小盲的可选范围
				times = {60,90,120, 180,240, 300, 360},  --创建房间或续时的可选时间点 单位:min
				buyin = {100,200, 300, 400},  --可选的买入范围  单位:bb(2倍小盲)
				seat = {6,9},--桌子座位数的可选项(目前只有6、9)两个值
				bettime = 15,  --下注时间
				create_fee = 0,  --创建房间的费用基数   总费用=基数*房间分钟数
				show_fee = {  --大厅展示的费用基数 不同小盲 展示费用不同
				    [100]    =  25,
				    [500]    =  125,
				    [2500]   =  600,
				    [5000]   =  1250,
				    [25000]  =  6000,
				   	[50000]  =  12500,
				   	[250000] =  60000,
				},  
				ante = { --以小盲为key的 前注的可选范围
					[100]    = {0, 10,    25,     50,     200},
				    [500]    = {0, 50,    100,    500,    2000},
				    [2500]   = {0, 500,   2500,   5000,   25000},
				    [5000]   = {0, 1000,  5000,   10000,  50000},
				    [25000]  = {0, 5000,  25000,  50000,  250000},
				    [50000]  = {0, 10000, 50000,  100000, 500000},
				    [250000] = {0, 50000, 250000, 500000, 2500000},
				}
			}
		}
	},

	["custom.create_room"] = {  --创建一个新的房间
		req = {
			name = "", --房间名称 
			ante = 50,   --前注
			sb = 50,    --小盲  大盲=2X小盲
			time = 60,  --房间时间
			min_buy = 100,   --最小买入的大盲数 
			max_buy = 400,   --最高买入的大盲数
			seat = 6,   --几人座 
			show_status = 0,  --大厅展示状态
			mnick = "xxx", --创建者的昵称(用来结束时展示)
			msg = "",  --房主留言
		},
		resp = {
			ret = 200,  -- -101:已创建过房间 -102:筹码不足 -103:参数验证失败  -104房间数量不够
			cmoney = 2000,  --本次创建房间费用 
			left_money = 10010, --剩余筹码数
			room = {
				ownerid = 10035,  --房主id
				roomid = 1001,  --房号 1001-9999 四位数字
				clv = 999,    --自定房间的场次号:目前都为999
				tid = 5001,   --房间id
				name = "xxx", --房间名称 
				ante = 50,   --前注
				sb = 50,    --小盲  大盲=2X小盲
				left_time = 3600,  --房间剩余时间:s
				create_time = 60,  --房间创建时间unix时间戳
				min_buy = 100,   --最小买入的大盲数 
				max_buy = 400,   --最高买入的大盲数
				seat = 6,   --几人座 
				players = 5,  --在玩数
				watchers = 2,  --观战人数
				show_status = 0,  --大厅展示状态 0:不可见 1：可见
				reward_money = 0, --房主赢利
				msg = "",  --房主留言
				ttime = 60,  --房间总时长,单位:分钟
				owner_name = "xxx", --房主昵称
			}
		}
	},



	["custom.show_rooms"] = {  --获取可见的房间列表
		req = {
			begin = 1,  --从第几个位置开始查找
			num = 20,   --本次共查找多少个房间
		},
		resp = {
			total = 100,
			begin = 1,  -- 本次的开始位置
			num  = 10,  --本次房间数
			myroom = {  --我自己的房间，可能为{}
				ownerid = 10035,  --房主id
				roomid = 1001,  --房号 1001-9999 四位数字
				clv = 999,    --自定房间的场次号:目前都为999
				tid = 5001,   --房间id
				name = "xxx", --房间名称 
				ante = 50,   --前注
				sb = 50,    --小盲  大盲=2X小盲
				left_time = 3600,  --房间剩余时间:s
				create_time = 60,  --房间创建时间unix时间戳
				min_buy = 100,   --最小买入的大盲数 
				max_buy = 400,   --最高买入的大盲数
				seat = 6,   --几人座 
				players = 5,  --在玩数
				watchers = 2,  --观战人数
				show_status = 0,  --大厅展示状态 0:不可见 1：可见
				reward_money = 0, --房主赢利
				msg = "",  --房主留言
				ttime = 60,  --房间总时长
				owner_name = "xxx", --房主昵称
			},
			roomlist = { --本次获取的房间列表
				{  
					ownerid = 10035,  --房主id
					roomid = 1001,  --房号 1001-9999 四位数字
					clv = 999,    --自定房间的场次号:目前都为999
					tid = 5001,   --房间id
					name = "xxx", --房间名称 
					ante = 50,   --前注
					sb = 50,    --小盲  大盲=2X小盲
					left_time = 3600,  --房间剩余时间:s
					create_time = 60,  --房间创建时间unix时间戳
					min_buy = 100,   --最小买入的大盲数 
					max_buy = 400,   --最高买入的大盲数
					seat = 6,   --几人座 
					players = 5,  --在玩数
					watchers = 2,  --观战人数
					show_status = 0,  --大厅展示状态 0:不可见 1：可见
					reward_money = 0, --房主赢利
					msg = "",  --房主留言
					ttime = 60,  --房间总时长
					owner_name = "xxx", --房主昵称
				},
				--...
			}
		},

	},

	["custom.look_up"] = {  --查找房间
		req = {
			roomid = 2000, --房号,四位数字
		},
		resp = {
			ret = 200,  -- -101 无此房间
			room = {  --我自己的房间，可能为{}
				ownerid = 10035,  --房主id
				roomid = 1001,  --房号 1001-9999 四位数字
				clv = 999,    --自定房间的场次号:目前都为999
				tid = 5001,   --房间id
				name = "xxx", --房间名称 
				ante = 50,   --前注
				sb = 50,    --小盲  大盲=2X小盲
				left_time = 3600,  --房间剩余时间:s
				create_time = 60,  --房间创建时间unix时间戳
				min_buy = 100,   --最小买入的大盲数 
				max_buy = 400,   --最高买入的大盲数
				seat = 6,   --几人座 
				players = 5,  --在玩数
				watchers = 2,  --观战人数
				show_status = 0,  --大厅展示状态 0:不可见 1：可见
				reward_money = 0, --房主赢利
				msg = "",  --房主留言
				ttime = 60,  --房间总时长
				owner_name = "xxx", --房主昵称
			}
		},
	},

	["custom.show_status"] = {  --设置房间可见性
		req = {
			roomid = 2001, --房号 
			show_status = 0,  --大厅展示状态 0:不可见 1：可见
		},
		resp = {
			ret = 200,  -- -101 无此房间 -102:不是房主无权设置 -103 筹码不足 -104 参数错误
			roomid = 2001, --设置的房号 
			show_status = 0, --设置成功后的状态
			cmoney = 0,  --本次改变可见性的费用 
			left_money = 0, --剩余筹码数
		},
	},

	["custom.room_info"] = {  --房主获取目前赢利信息
		req = {
			roomid = 2001, --房号 
		},
		resp = {
			ret = 200,  -- -101 无此房间 
			roomid = 0, --房号 
			players = 5,   --玩牌用户
			watchers = 5,  --观战用户
			reward_money = 0, --房主目前的赢利 
		},
	},

	["custom.room_over"] = {  --房间结束通知,用户收到信息后，约0.5秒会被T出房间

		broadcast = {  --自定义房间结束后 房主的赢利结算
			roomid = 0,   --房间id
			rname = "xxx",  --房间名称
			ownerid = 0,  --房主id
			owner_name = "xxx", --房主昵称
			total_time = 60,   --房间时长 单位:min
			reward_money = 0,  --房主的赢利筹码
		}
	},

	["custom.owner_reward"] = {  --房间结束后,房主奖励

		broadcast = {  --自定义房间结束后 房主的赢利结算
			roomid = 0,   --房间id
			rname = "xxx",  --房间名称
			ownerid = 0,  --房主id
			owner_name = "xxx", --房主昵称
			total_time = 60,   --房间时长 单位:min
			reward_money = 0,  --房主的赢利筹码
			left_money = 0,  --得到奖励后的金币
		}
	},

	["custom.syn_tids"] = {  --获取用户正在玩的自定义房间
		req = {
			mid = 1234, --玩家用户id
		},
		resp = {
			ret = 200, -- -101 目前没有在自定义房间玩牌

			tids = {  --目前的在玩房间列表
				{  --可能为{}
					ownerid = 10035,  --房主id
					roomid = 1001,  --房号 1001-9999 四位数字
					clv = 999,    --自定房间的场次号:目前都为999
					tid = 5001,   --房间id
					name = "xxx", --房间名称 
					ante = 50,   --前注
					sb = 50,    --小盲  大盲=2X小盲
					left_time = 3600,  --房间剩余时间:s
					create_time = 60,  --房间创建时间unix时间戳
					min_buy = 100,   --最小买入的大盲数 
					max_buy = 400,   --最高买入的大盲数
					seat = 6,   --几人座 
					players = 5,  --在玩数
					watchers = 2,  --观战人数
					show_status = 0,  --大厅展示状态 0:不可见 1：可见
					reward_money = 0, --房主赢利
					msg = "",  --房主留言
					ttime = 60,  --房间总时长
					owner_name = "xxx", --房主昵称
				},
			}
		}
	},

}