-- everyday_login 登录
local proc = {}

function proc.request(cmd,params)
    local data = {
    	mid = tt.owner:getUid(),
    	version = kVersion,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("everyday_login");
end

function proc.response(ret, params )
	print("everyday_login init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)

        if data.ret == 0 then
        	data.data.mid = tonumber(data.data.mid)
        	data.data.get_coin = tonumber(data.data.get_coin)
        	data.data.left = tonumber(data.data.left)
        	data.data.get_score = tonumber(data.data.get_score)
        	data.data.left_score = tonumber(data.data.left_score)
        	data.data.day_num = tonumber(data.data.day_num)
        	data.data.get_time = tonumber(data.data.get_time)
        end
        return data
    end
end

return proc