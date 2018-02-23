
--协议文本
local protos = {

	["heart_beat"] = {},

	["login.shake"] = {
		req = {
			mid = 0,
			secret =  "gaga"
		},
		resp = {
			ret = 200,  -- -101 无此用户  -- 102验证失败secret  -103非法cmd
			msg = "200 ok",
			utime = 12345, --服务器当前unix时间戳
		}
	},

	["login.kick"] = {
		resp = {
			ret = 200,
			msg = "you count login on addr"
		}
	},

	["alloc.info"] = {  --获取所有场次的信息
		req = {
			chan = "google"  --渠道号
		},
		resp = {
			ret = 200,
			ver = 1,  --目前配置的版本号
			levels = {
				{lv = 1, name = "初级场", ante=10,sb=5,bb=10,min_carry=250,max_carry=500,default_buy=500,player=500 },
			}
		}
	},
 
	["alloc.search"] = {  --找到一个游戏桌
		req = {
			lv = 1,     --场次
		},
		resp = {
			ret = 200,
			lv = 1,  --场次
			tid = 1234
		}
	},

	["texas.login"] = {  --登陆游戏桌子
		req = {
			lv = 1,     --场次
			tid = 0,     --目标桌子id 
			mid = 1000,  --用户id
			uinfo = "{win=100,lose=500}"
		},
		resp = {
			ret = 200,  --ok - 101 桌子找不到
			lv = 1,
			tid = 1001,
			min_carry = 200, --最小买入
			max_carry = 500, --最大买入
			seatnum = 6,  --几人桌
			ante = 0,   --前注
			sb = 50,   --小盲
			bb = 100,  --大盲
			bettime = 15, --下注思考时间
			watcher = 1,
			gamestatus = 0,  --当前的游戏状态-1:空闲阶段 0:准备开始 1:发手牌的第一轮行动 2:翻三张牌 3:转牌 4:河牌 5:结算时间
			seatinfo = {   --座位上的信息  sretain:0-离座留桌 1-回到座位  snet:0-断网 1-正常连接
				{seatid=1,coin=100,sretain=1,snet=1, player={mid=100,money=100,info="xxx"}},
			}
		},
		broadcast = {
			lv = 1,
			tid = 1001,
			mid = 100, --的用户id
		}

	},

	["texas.logout"] = {  --登出游戏桌子
		req = {
			lv = 1,     --场次
			tid = 0,     --目标桌子id 
			mid = 1000,  --用户id

		},
		resp = {
			ret = 200,  --ok -101没在桌子玩牌
			lv = 1,
			tid = 1001,
			money = 1000, --登录出还剩多少金币
		},
		broadcast = {
			lv = 1,
			tid = 1001,
			mid = 100, --登出的用户id
			rz = 1,    --1:自己登出, 2:离桌被T, 3:服务器退休(服务器已更新，请重新进入桌子)
		}
	},
	["texas.gameinfo"] = {  --获取游戏状态信息
		req = {
			lv = 1,     --场次
			tid = 0,     --目标桌子id 
			mid = 1000  --用户id
		},
		resp = {
			ret = 200,  --ok
			lv = 1,
			tid = 1001,
			gamestatus = 0,
			dealerseat = 1,
			sbseat = 2,
			bbseat = 3,
			publiccards={0x1,0x3},    --公共牌
			pots = {10000,2000,3000},   --奖池
			action = {seatid = 1, timeout=10,check = 100, raisemin = 100, raisemax = 200},
			playerinfo = {  --玩牌人数
			--   座位id   用户id  金币    坐下筹码  本轮下的筹码
				[1] = {seatid=1,coin=100,chips=1000,isfold=false,allin=false,cards={0x0,0x0}}, --
			}
		}
	},

	["texas.sitdown"] = {  --用户坐下
		req = {
			lv = 1,     --场次
			tid = 0,     --目标桌子id 
			mid = 1000,  --用户id
			seatid = 1,  --为0则自动坐下
			coin = 10000, --为0则买下默认100bb的筹码

		},
		resp = {
			ret = 200,  --ok   --[201]:坐下并买入上次离开的筹码   --[-101]:人数已满 --[-102]:重复坐下 --[-103] 金币不够买筹码 [-104]携带筹码错误 [-105] 没登录不能坐下
			lv = 1,
			tid = 1001,
			seatid = 1,
			money = 10000,  --金币
			coin = 1000,    --坐下所带筹码 
			buy_time = -1,  --如果坐下筹码为0则在buy_time时间需要购买
		},
		broadcast = {
			lv = 1,
			tid = 1001,
			seatid = 1,
			coin=100,
			player={mid=100,money=100,info="xxx"}
		}
	},

	["texas.standup"] = {  --用户站起
		req = {
			lv = 1,     --场次
			tid = 0,     --目标桌子id 
			mid = 1000,  --用户id
			seatid = 1,  --站起的座位id
		},
		resp = {
			ret = 200,  --ok
			lv = 1,
			tid = 1001,
			seatid = 1,
			money = 10000,  --金币
		},
		broadcast = {
			lv = 1,
			tid = 1001,
			seatid = 1,
			mid = 1000,
			money = 10000,  --金币
		}
	},

	["texas.buycoin"] = {
		req = {
			lv = 1,     --场次
			tid = 0,     --目标桌子id 
			mid = 1000,  --用户id
			coin = 10000, --为0则买下默认100bb的筹码

		},
		resp = {
			ret = 200,  --ok    --[-101]:未坐下 --[-102]:所带筹码超过最大携带 --[-103] 金币不够买筹码  [-104]游戏状态不对
			lv = 1,
			tid = 1001,
			addcoin = 100,   
			tmoney = 10000,  --金币
			tcoin = 1000,    --筹码 
		},
		broadcast = {
			lv = 1,
			tid = 1001,
			seatid = 2,
			tmoney = 10000,  --金币
			tcoin = 1000,
			addcoin = 1000,    --坐下所带筹码 
		}
	},



	["texas.wait"] = {  --等待游戏戏开始

		broadcast = {
			lv = 1,
			tid = 1000,
			status = 0, 
			wait = 3,   --等待时间
		}
	},


	["texas.start"] = {  --游戏戏开始，确定button与发牌

		broadcast = {
			lv = 1,
			tid = 1000,
			status = 1, 
			dealerseat = 1,
			sbseat = 2,
			bbseat = 3,
			playseat = {   --本局玩牌的座位
				1,2,3
			}
		}
	},

	["texas.deal"] = {  --发给用户的手牌

		resp = {
			lv = 1,
			tid = 1001,
			seatid = 1,
			cards={0x2,0x3}
		}
	},

	["texas.startbet"] = {  --轮到某座位开始下注

		broadcast = {
			lv = 1,
			tid = 1001,
			seatid = 1,
			check = 100,    --跟注
			raisemin = 100,
			raisemax = 200,
		}
	},

	["texas.ante"] = {  --用户下前注

		broadcast = {
			lv = 1,
			tid = 1001,
			seats = {
				{seatid=1, ante=10, coin=200}, --座位号 前注数 下完ante后剩余筹码
			},
			pots = {[1] = 100,[2] = 1000}  --本轮奖池增加的数目 可能产生多个底池
		}
	},

	["texas.useraction"] = {  --用户行动

		req = {
			lv = 1,
			tid = 1001,
			bettype = 0, --0:fold  1:bet  
			chips = 1000,   --下注金币
		},
		resp = {
			ret = 200,  --ok   -101:状态错误 -102下注数量错误
			lv = 1,
			tid = 1001,
		},

		broadcast = {
			lv = 1,
			tid = 1001,
			seatid = 1,     
			bettype = 0,--0:flod  1:bet  -1:refund 一轮结束前多余的退还给玩家
			chips = 0,
			coin = 1000,  --用户的当前筹码
		}
	},

	["texas.roundend"] = {  --回合结束，变化奖池的金币

		broadcast = {
			lv = 1,
			tid = 1001,
			pots = {[5] = 100,[6] = 1000}  --本轮奖池增加的数目
		}
	},

	["texas.flop"] = {  --发三张公共牌

		broadcast = {
			lv = 1,
			tid = 1001,
			cards={0x2,0x3,0x4}
		}
	},

	["texas.turn"] = {  --转牌

		broadcast = {
			lv = 1,
			tid = 1001,
			card = 0xc,
		}
	},

	["texas.river"] = {  --河牌

		broadcast = {
			lv = 1,
			tid = 1001,
			card = 0xc,
		}
	},

	["texas.showhands"] = {
		broadcast = {
			lv = 1,
			tid = 1001,
			seatid = 2,
			cards = {0xc,0xd}
		}
	},

	["texas.preshowhands"] = {  --所有玩家提前亮手牌
		broadcast = {
			lv = 1,
			tid = 1001,
			seats = {
				-- {seatid = 2,cards = {0xc,0xd}}
				-- ...
			}

			
		}
	},

	["texas.gameover"] = {

		broadcast = {
			lv = 1,
			tid = 1001,
			show = {[1]={seatid=1,hands={0x13,0x14}}},
			pots = {
				[1] = {tcoins = 1001,winers= { 
											--            赢取  
												{seatid=1,coin=501}, 
												{seatid=2,coin=500}, 
											 }
					   }
			}	
		}
	},

	["texas.koinfo"] = { --广播ko信息 一般在猎人赛中出现

		broadcast = {
			lv = 1,
			tid = 1001,
			winers={  --赢家
				-- {seatid=1, mid=2, addmoney=100, tmoney=1000},
			},
			lose={    --被KO者
				-- {seatid=2, mid=34567},
			},
		}
	},


	["texas.userstatus"] = {  --座位上的用户状态 （离座留桌 或 断网）

		req = {
			lv = 1,
			tid = 1001,
			seatid = 1,
			stype = 0, --1:为离座留桌的相关操作
			value = 1, --1:回到座位 0:离座留桌
		},
		resp = {
			ret = 200,  -- 200:ok   -101操作失败 -102需要再次买入筹码
			lv = 1,
			tid = 1001,
		},

		broadcast = {
			lv = 1,
			tid = 1001,
			seatid = 1,     --
			sretain = 1,--1:回到座位 0:离座留桌
			snet = 1,   -- 1:连上网络 0:网络断开
		}
	},


	["texas.chat"] = {  --房间内聊天

		req = {
			lv = 1,
			tid = 1001,
			seatid = 1,
			ct = 0, --类型 客户端自定义
			content = "", --消息内容 客户端自定义
		},
		resp = {
			ret = 200,  -- 200:ok   -101操作失败 
			lv = 1,
			tid = 1001,
		},

		broadcast = {  --某个玩家说话
			lv = 1,
			tid = 1001,
			seatid = 1,     --
			ct = 0, --类型 客户端自定义
			content = "", --消息内容 客户端自定义
		}
	},

	["texas.intexp"] = {  --互动道具

		req = {
			lv = 1,
			tid = 1001,
			src_seatid = 1,  --发起座位
			dst_seatid = 3,  --目标座位
			exp = 1,  --道具id
		},
		resp = {
			ret = 200,  -- 200:ok   -101参数错误  -102金币不足
			lv = 1,
			tid = 1001,
			fee = 50,    --发费金币
			left = 100,  --剩余金币
		},

		broadcast = {  --某个玩家发送互动道具
			lv = 1,
			tid = 1001,
			src_seatid = 1,  --发起座位
			dst_seatid = 3,  --目标座位
			exp = 1,  --道具id
		}
	},

	["texas.expfee"] = {  --互动道具的费用

		req = {
			lv = 1,
			tid = 1001,
		},
		resp = {
			ret = 200,  -- 200:ok   -101获取失败
			lv = 1,
			tid = 1001, 
			info = {    -- expid = fee
				[1] = 50,
				[2] = 50,
				[3] = 100,
				[4] = 200,
			}
		},
	},

	["texas.watcher_list"] = {  --房间观战列表(目前仅自定义房间有)

		req = {
			lv = 1,
			tid = 1001,
			begin = 1,   --观战列表的开始下标
			num = 5,     --本次获取的数量 
		},
		resp = {
			ret = 200,  -- 200:ok   -101获取失败
			lv = 1,
			tid = 1001, 
			total = 7, 
			begin = 1,
			num = 3,   --本次获取的真实数量
			list = {
				{ 
					mid = 10001,
					info = "xxx", --用户登陆房间自带的info
				},
			}
		},
	},
	
	["info.ver"] = {  --各种信息的版本号

		req = {
			chan = "google", --渠道名
		},
		resp = {
			ret = 200,  -- 200:ok   -101无此渠道
			ver = {   --各种配置信息的版本号
				cash = 1,  --现金场配置 版本号
				shop = 1, --商城当前的版本号
				sng = 1,  --sng比赛列表的版本号
			}
		},
		broadcast = {
			ctime = 1456789,  --配置有版本更新，收到此广播，建议重新摘取一下 info.ver
		}

	},

	["uinfo.changnick"] = {  --修改用户的昵称

		req = {
			mid = 1234,
			mnick = "賭俠"
		},
		resp = {
			ret = 200,  -- 200:ok   -101失败
			mnick = "賭俠"
		},
	},

	["cash.usercashs"] = {  --获取用户正在玩的现金桌
		req = {
			mid = 1234, --玩家用户id
		},
		resp = {
			ret = 200, -- -101 目前没有在现金桌中玩牌

			cashs = {
				--{lv = 12, tid=123, seatid=2}  --用户所在的现金桌
			}
		}
	},
	["uinfo.ginfo"] = {  --游戏的财富数据
	    req = {
	      	mid = 1234,
	    },
	    resp = {
	      	ret = 200,  -- 200:ok   -101失败
	      	money = 0,  --筹码
	      	score = 0,  --vip积分 
	      	gold = 0,   --投注币
	    },
  	},
  	["alloc.change"] = {  --换桌
		req = {
			lv = 1,     --场次
			old_tid = 1234,  --老的桌子id
		},
		resp = {
			ret = 200,
			lv = 1,  --场次
			tid = 1234
		}
	},

}

local psng = require("app.net.pdesc.psng")
for k,v in pairs(psng) do 
	protos[k] = v 
end

local pshop = require("app.net.pdesc.pshop")
for k,v in pairs(pshop) do 
	protos[k] = v 
end

local pmsgbox = require("app.net.pdesc.pmsgbox")
for k,v in pairs(pmsgbox) do 
	protos[k] = v 
end

local pvip = require("app.net.pdesc.pvip")
for k,v in pairs(pvip) do 
	protos[k] = v 
end

local pmtt = require("app.net.pdesc.pmtt")
for k,v in pairs(pmtt) do 
	protos[k] = v 
end

local pmatch = require("app.net.pdesc.pmatch")
for k,v in pairs(pmatch) do 
	protos[k] = v 
end

local prichdata = require("app.net.pdesc.prichdata")
for k,v in pairs(prichdata) do 
	protos[k] = v 
end

local phappydice = require("app.net.pdesc.phappydice")
for k,v in pairs(phappydice) do 
	protos[k] = v 
end

local pgame = require("app.net.pdesc.pgame")
for k,v in pairs(pgame) do 
	protos[k] = v 
end

local preward = require("app.net.pdesc.preward")
for k,v in pairs(preward) do 
	protos[k] = v 
end

local pcustom = require("app.net.pdesc.pcustom")
for k,v in pairs(pcustom) do 
	protos[k] = v 
end

return protos