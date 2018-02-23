--
-- Author: shineflag
-- Date: 2017-06-01 16:48:58
--
--商城相关的协议
return {

	["shop.getshops"] = {  --获取相关渠道的商品信息
		req = {
			chan = "google",           --渠道名
		},
		resp = {
			ret = 200,   -- -101:无此渠道
			ver = 1,           --该渠道商城目前的版本号
			shops = {  --商品列表详情
			--order     价格             币种        金币           支付方式        额外加送        商品id 可识别的
				[1] = {price="0.99",     cy="USD",    coin=100000,	pmode={1,2,3},	extra="",    	pid="coin_p1_999_0.99usd"}
			}
		}
	},

	["shop.order"] = {  --创建订单id
		req = {
			chan = "google",           --渠道名
			pmode = 1,    --支付渠道
			pid =  "coin_p1_999_0.99usd", --自己的商品id
			mid = 1342,   --玩家的id
		},
		resp = {
			ret = 200,   -- -101:无此渠道 -102 无此商品 -103无此支付方式 
			pmode = 1,  --支付渠道
			pid = "xxxxx",  --本地的商品id
			pinfo = "{sku:coin_p1_999_0}", --支付渠道 需要支付的参数信息(json字符串)
			mid = 1342,  --玩家的id
			orderid = "time_seq"  --订单号
		}
	},

	["shop.gconsume"] = {  --google支付成功 请求发货
		req = {
			--json字符串
			params = ""
			-- "{
   --              "gorderid":"xxxxx",   --google的订单号 用于对帐
   --              "purdata":"xxxxx",    --google原始的数据信息json字符串 用于加密验证
   --              "signature":"xxxxx",  --google的签名信息               用于加密验证
   --              "orderid":"xxxxxx",   --服务器产生的订单号  用于对帐
   --              "pid":"xxxxx",        --本地的商品id
			-- }"
		},
		resp = {
			ret = 200,        -- -101:验证失败 -102:重复发送
			orderid = "xxxxx",  --本地产生的orderid
			add = 10000,      -- 增加的金币
			money = 999999,  --增加后用户的金币
			cscore = 0,      --变化的积分(可能无此字段) 0 代表没数据
			tscore = 0,      --总积分(可能无此字段) 0 代表没数据
		}
	},

	["shop.ivalidate"] = {  --苹果支付成功 请求发货
		req = {
			--json字符串
			params = ""
			-- "{
   --              "transid":"xxxxx",    --苹果产生的交易号 用于对帐
   --              "receipt":"xxxxx",    --向苹果服务器验证的字符串   
   --              "orderid":"xxxxxx",   --服务器产生的订单号  用于对帐
   --              "pid":"xxxxx",        --本地的商品id
			-- }"
		},
		resp = {
			ret = 200,        -- -101:验证失败 -102:重复发送
			orderid = "xxxxx",  --本地产生的orderid
			add = 10000,      -- 增加的金币
			money = 999999,  --增加后用户的金币
			cscore = 0,      --变化的积分(可能无此字段) 0 代表没数据
			tscore = 0,      --总积分(可能无此字段) 0 代表没数据

		}
	},

	["shop.firstshop"] = {  --首充礼包
		req = {
			chan = "google",           --渠道名
		},
		resp = {
			ret = 200,   -- -101: 无首充礼包
			--      价格               币种          原金币           实际金币           支付方式        额外加送        商品id 可识别的
			fshop = {price="0.99",     cy="USD",    old_coin = 5000, coin=10000,	pmode={1,2},	extra={score=20000},    	pid="coin_p1_999_0.99usd"}
		}
	},
}