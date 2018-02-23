--
-- Author: shineflag
-- Date: 2017-06-18 11:39:03
--
--消息中心相关的协议
return {

	["msgbox.live_broad"] = {  --广播当前所有在线用户的消息
		req = { 
			mtype = "",     --消息类型 客户自己定义
			content = "",       -- --消息的内容 
		},
		resp = {
			ret = 200,   -- -101:失败, 小喇叭数据不足 
			left = 0,    --发送成功后剩余的喇叭
		},

		broadcast = {
			sender = 0,     --发送者id 0-为系统  其它为用户发的广播
			mtype = "bar",  --消息的类型 bar为广播条上的消息
			content = "content",  --消息的内容 
			stime = 1415926,   --发件时间 unix时间戳
		}
	},

	["msgbox.mails_num"] = {  --获取邮件数量
		req = {
			mid = 12345,           --用户名
		},
		resp = {
			ret = 200,   --
			num = 1,   --当前消息数量
		}
	},

	["msgbox.recv"] = {  --获取消息到本地 服务器端将会删除
		req = {
			mid = 12345,           --用户名
			num = 3,               --接收多少邮件 0 则全部接收
		},
		resp = {
			ret = 200,   --
			rnum = 1,   --当前接收消息数量
			lnum = 0,   --剩余消息数量
			rmsgs = {    --接收的消息 数组
				-- {sender=1234,   --发件者
				--  mtype="smsg",  --消息类型
				--  title = "xxx", --消息标题 
				--  content = "xxxx",  --消息内容
				--  stime = 1412334,  --发件时间 unix时间戳
				-- },
				-- ...
		    }
		}
	},

	["msgbox.send"] = {  --向一个用户发送消息
		req = {
			mid = 12345,           --用户名
			recver = 54321,       --接收邮件者
			mtype = "mail",        --消息类型
			title = "",            --标题
			content = "xxx",       --内容
		},
		resp = {
			ret = 200,   -- -101 接收者不存在
		}
	},

	["msgbox.newnotice"] = {  --获取最新的公告
		req = {
			--空
		},
		resp = {
			ret = 200,   -- -101 还没有公告
			notice = {    --公告具体内容
				--  title = "xxx", --公告标题 
				--  content = "xxxx",  --公告内容
		    }
		}
	},

	["msgbox.pushmsg"] = {  --在线用户接收单条推送信息

		broadcast = {
			mtype = 1,-- 消息类型：php与客户端自己定义
			msg = "{money=1234}",  --推荐自定义格式的json字符串 
		}
	},

}