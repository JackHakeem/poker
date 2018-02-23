--
-- Author: bearluo
-- Date: 2017-12-20 15:59:59
--
local game_data = require("app.utils.game_data")
local LocalNotication = {}

function LocalNotication.addLocalNotication(title,content,time)
	local params = clone(tt.platformEventHalper.cmds.addLocalNotication)
	if device.platform == "ios" then
		time = time - tt.time()
		if time < 0 then time = 0 end 
	end
	params.args = {
    	title=title,
    	content=content,
        time=time,
    }
    dump(params,"addLocalNotication")
    local ok,ret = tt.platformEventHalper.callEvent(params)
    if ok then
    	return ret
    end
end

function LocalNotication.delLoaclNotication(id)
	local params = clone(tt.platformEventHalper.cmds.delLoaclNotication)
	params.args = {
    	id=id,
    }
    dump(params,"delLoaclNotication")
    local ok,ret = tt.platformEventHalper.callEvent(params)
    return ok
end

function LocalNotication.saveMatchNoticationId(match_id,id,time)
	local datas = game_data.getLocalNotication()
	match_id = tostring(match_id)
	datas[match_id] = {}
	datas[match_id].id = id
	datas[match_id].time = time
	local curTime = tt.time()
	for key,data in pairs(datas) do
		if data.time < curTime then
			datas[key] = nil
		end
	end
	game_data.saveLocalNotication(datas)
end

function LocalNotication.delMatchNoticationId(match_id)
	local datas = game_data.getLocalNotication()
	match_id = tostring(match_id)
	datas[match_id] = nil
	game_data.saveLocalNotication(datas)
end

function LocalNotication.getMatchNoticationId(match_id)
	local datas = game_data.getLocalNotication()
	match_id = tostring(match_id)
	dump(datas[match_id],"getMatchNoticationId")
	if not datas[match_id] then return end
	return datas[match_id].id
end

return LocalNotication