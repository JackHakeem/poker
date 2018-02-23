local gsocket = require("app.net.gsocket")

local IMHelper = {}

IMHelper.VOICE = 0
IMHelper.MSG = 1
IMHelper.SHORTCUT_MSG = 2
IMHelper.EMOTICON_MSG = 3
IMHelper.EXPRESSION_MSG = 4


function IMHelper.sendMsg(lv,tid,seatid,str)
	local sendData = {}
	sendData.lv = lv
	sendData.tid = tid
	sendData.seatid = seatid
	sendData.ct = IMHelper.MSG
	sendData.content = {
		msg = str,
	}
	gsocket.request("texas.chat",sendData)
end

function IMHelper.sendEmoticonMsg(lv,tid,seatid,emoticon_id)
	local sendData = {}
	sendData.lv = lv
	sendData.tid = tid
	sendData.seatid = seatid
	sendData.ct = IMHelper.EMOTICON_MSG
	sendData.content = {
		emoticon_id = emoticon_id,
	}
	gsocket.request("texas.chat",sendData)
end

function IMHelper.sendExpressionMsg(lv,tid,src_seatid,dst_seatid,expression_id)
	local sendData = {}
	sendData.lv = lv
	sendData.tid = tid
	sendData.src_seatid = src_seatid
	sendData.dst_seatid = dst_seatid
	sendData.exp = expression_id
	gsocket.request("texas.intexp",sendData)
end


function IMHelper.sendHornMsg(content)
	local sendData = {}
	sendData.mtype = "user_bar"
	sendData.content = json.encode({
			name = tt.owner:getName(),
			content = content,
		})  --消息的内容
	tt.gsocket.request("msgbox.live_broad",sendData)
end

return IMHelper
